#!/usr/bin/env bash
# Provision WordPress Stable

echo " * Custom site template provisioner - downloads and installs a copy of WP stable for testing, building client sites, etc"

# fetch the first host as the primary domain. If none is available, generate a default using the site name
DOMAIN=`get_primary_host "${VVV_SITE_NAME}".test`
SITE_TITLE=`get_config_value 'site_title' "${DOMAIN}"`
WP_VERSION=`get_config_value 'wp_version' 'latest'`
WP_LOCALE=`get_config_value 'locale' 'en_US'`
WP_TYPE=`get_config_value 'wp_type' "single"`
DB_NAME=`get_config_value 'db_name' "${VVV_SITE_NAME}"`
DB_NAME=${DB_NAME//[\\\/\.\<\>\:\"\'\|\?\!\*]/}

# Make a database, if we don't already have one
echo -e "\nCreating database '${DB_NAME}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`"
echo -e "\nGranting the wp user priviledges to the '${DB_NAME}' database"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"


echo "Setting up the log subfolder for Nginx logs"
noroot mkdir -p ${VVV_PATH_TO_SITE}/log
noroot touch ${VVV_PATH_TO_SITE}/log/nginx-error.log
noroot touch ${VVV_PATH_TO_SITE}/log/nginx-access.log

if [ "${WP_TYPE}" != "none" ]; then

  # Install and configure the latest stable version of WordPress
  if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp-load.php" ]]; then
    echo "Downloading WordPress..." 
    noroot wp core download --locale="${WP_LOCALE}" --version="${WP_VERSION}"
  fi

  if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp-config.php" ]]; then
    echo "Configuring WordPress Stable..."
    noroot wp core config --dbname="${DB_NAME}" --dbuser=wp --dbpass=wp --quiet --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'SCRIPT_DEBUG', true );
PHP
  fi

  if [ -f "${VVV_PATH_TO_SITE}/public_html/wp-content/database.sql" ]; then
    echo "Found database backup on site directory. Installing site from there..."
    noroot wp config set DB_USER "wp"
    noroot wp config set DB_PASSWORD "wp"
    noroot wp config set DB_HOST "localhost"
    noroot wp config set DB_NAME "${DB_NAME}"
    noroot wp db import "${VVV_PATH_TO_SITE}/public_html/wp-content/database.sql"
    echo "Installed database backup"
  elif [ -f "/srv/database/backups/${VVV_SITE_NAME}.sql" ]; then
    echo "Found database backup on the backups directory. Installing site from there..."
    noroot wp config set DB_USER "wp"
    noroot wp config set DB_PASSWORD "wp"
    noroot wp config set DB_HOST "localhost"
    noroot wp config set DB_NAME "${DB_NAME}"
    noroot wp db import "/srv/database/backups/${VVV_SITE_NAME}.sql"
    echo "Installed database backup"
  else
    if ! $(noroot wp core is-installed); then
      echo "Installing WordPress Stable..."

      if [ "${WP_TYPE}" = "subdomain" ]; then
        echo "Using multisite subdomain type install"
        INSTALL_COMMAND="multisite-install --subdomains"
      elif [ "${WP_TYPE}" = "subdirectory" ]; then
        echo "Using a multisite install"
        INSTALL_COMMAND="multisite-install"
      else
        echo "Using a single site install"
        INSTALL_COMMAND="install"
      fi

      ADMIN_USER=`get_config_value 'admin_user' "admin"`
      ADMIN_PASSWORD=`get_config_value 'admin_password' "password"`
      ADMIN_EMAIL=`get_config_value 'admin_email' "admin@local.test"`
      noroot wp core ${INSTALL_COMMAND} --url="${DOMAIN}" --quiet --title="${SITE_TITLE}" --admin_name="${ADMIN_USER}" --admin_email="${ADMIN_EMAIL}" --admin_password="${ADMIN_PASSWORD}"
      echo "WordPress was installed, with the username '${ADMIN_USER}', and the password '${ADMIN_PASSWORD}' at '${ADMIN_EMAIL}'"

      DELETE_DEFAULT_PLUGINS=`get_config_value 'delete_default_plugins' ''`
      if [ ! -z "${DELETE_DEFAULT_PLUGINS}" ]; then
          noroot wp plugin delete akismet
          noroot wp plugin delete hello
      fi

      INSTALL_TEST_CONTENT=`get_config_value 'install_test_content' ""`
      if [ ! -z "${INSTALL_TEST_CONTENT}" ]; then
        echo "Installing test content..."
        curl -s https://raw.githubusercontent.com/poststatus/wptest/master/wptest.xml > import.xml 
        noroot wp plugin install wordpress-importer
        noroot wp plugin activate wordpress-importer
        noroot wp import import.xml --authors=create
        rm import.xml
        echo "Test content installed"
      fi
    else
      echo "Updating WordPress Stable..."
      cd ${VVV_PATH_TO_SITE}/public_html
      noroot wp core update --version="${WP_VERSION}"
    fi
  fi
else
  echo "wp_type was set to none, provisioning WP was skipped, moving to Nginx configs"
fi

echo "Copying the sites Nginx config template ( fork this site template to customise the template )"
if [ -f "${VVV_PATH_TO_SITE}/provision/vvv-nginx-custom.conf" ]; then
  echo "A vvv-nginx-custom.conf file was found"
  cp -f "${VVV_PATH_TO_SITE}/provision/vvv-nginx-custom.conf" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
else
  echo "Using the default vvv-nginx-default.conf"
  cp -f "${VVV_PATH_TO_SITE}/provision/vvv-nginx-default.conf" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
fi

LIVE_URL=`get_config_value 'live_url' ''`
if [ ! -z "$LIVE_URL" ]; then
  # replace potential protocols, and remove trailing slashes
  LIVE_URL=$(echo ${LIVE_URL} | sed 's|https://||' | sed 's|http://||'  | sed 's:/*$::')

  redirect_config=$((cat <<END_HEREDOC
if (!-e \$request_filename) {
  rewrite ^/[_0-9a-zA-Z-]+(/wp-content/uploads/.*) \$1;
}
if (!-e \$request_filename) {
  rewrite ^/wp-content/uploads/(.*)\$ \$scheme://${LIVE_URL}/wp-content/uploads/\$1 redirect;
}
END_HEREDOC

  ) |
  # pipe and escape new lines of the HEREDOC for usage in sed
  sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n\\1/g'
  )

  sed -i -e "s|\(.*\){{LIVE_URL}}|\1${redirect_config}|" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
else
  sed -i "s#{{LIVE_URL}}##" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
fi

get_config_value 'wpconfig_constants' |
  while IFS='' read -r -d '' key &&
        IFS='' read -r -d '' value; do
      noroot wp config set "${key}" "${value}" --raw
  done

WP_PLUGINS=`get_config_value 'install_plugins' ''`
if [ ! -z "${WP_PLUGINS}" ]; then
    for plugin in ${WP_PLUGINS//- /$'\n'}; do
        noroot wp plugin install "${plugin}" --activate
    done
fi

echo "Site Template provisioner script completed"
