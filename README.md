# VVV Custom Site Provisioner

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/6fc9d45abb02454aa052771bda2d40ff)](https://www.codacy.com/gh/Varying-Vagrant-Vagrants/custom-site-template?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Varying-Vagrant-Vagrants/custom-site-template&amp;utm_campaign=Badge_Grade)

This tells VVV how to install WordPress and set up Nginx, great for doing development work or testing out plugins and themes.

_Note that this repository is not a place to put your website. Create a new git repo to hold WordPress and the contents of `public_html`. See the VVV documentation for more details_

 - [Overview](#overview)
 - [Custom Configuration Options](#custom-configuration-options)
 - [Custom Nginx configs](#custom-nginx-configs)
 - [Using Git for your site](#using-git-for-your-site)
 - [Examples](#examples)

## Overview

This template will allow you to create a WordPress dev environment using only `config/config.yml`.

The supported environments are:

- A single site
- A subdomain multisite
- A subdirectory multisite
- A blank folder for manual installation

## Custom Configuration Options

These are custom options unique to the custom site template, and go in the `custom:` section of the site in `config.yml`. For example here is how to use `wp_version`:

```yaml
  my-site:
    repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template
    hosts:
      - foo.test
    custom:
      wp_version: nightly
```

Below is a full list of the custom options this template implements:

| Key                      | Type   | Default                    | Description                                                                                                                                                                                                                                                           |
|--------------------------|--------|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `admin_email`            | string | `admin@local.test`         | The email address of the initial admin user                                                                                                                                                                                                                           |
| `admin_password`         | string | `password`                 | The password for the initial admin user                                                                                                                                                                                                                               |
| `admin_user`             | string | `admin`                    | The name of the initial admin user                                                                                                                                                                                                                                    |
| `db_name`                | string | The sites name             | The name of the MySQL database to create and install to                                                                                                                                                                                                               |
| `db_prefix`              | string | `wp_`                      | The WP table prefix                                                                                                                                                                                                                                                   |
| `delete_default_plugins` | bool   | `false`                    | Deletes the Hello Dolly and Akismet plugins on install                                                                                                                                                                                                                |
| `install_test_content`   | bool   | `false`                    | When first installing WordPress, run the importer and import standard test content from github.com/poststatus/wptest                                                                                                                                                  |
| `public_dir`             | string | `public_html`              | Change the default folder inside the website's folder with the WP installation                                                                                                                                                                                        |
| `live_url`               | string |                            | The production site URL, e.g. `https://example.com`. This tells Nginx to browser redirect requests for assets at `/wp-content/uploads` to the production server if they're not found. This prevents the need to store those assets locally.  <br>If you do not use the `wp-content/uploads` path then this will not work, and you should not add a trailing slash.                                                                                        |
| `locale`                 | string | `en_US`                    | The locale for WP Admin language                                                                                                                                                                                                                                      |
| `install_plugins`        | list   |                            | A list/array of plugins to install and activate. Similar to the hosts array. These values are passed to the WP CLI plugin install command and take the same format.                                                                                                   |
| `install_themes`         | list   |                            | A list/array of themes to install. Similar to the hosts array. These values are passed to the WP CLI plugin install command and take the same format.                                                                                                                 |
| `site_title`             | string | The first host of the site | The main name/title of the site, defaults to `sitename.test`                                                                                                                                                                                                          |
| `wp_type`                | string | `single`                   | - `single` will create a standard WP install<br> - `subdomain` will create a subdomain multisite<br> - `subdirectory` will create a subdirectory multisite<br> - `none` will skip installing WordPress, and let you install WordPress manually (useful for custom folder layouts)  |
| `wp_version`             | string | `latest`                   | The version of WordPress to install if no installation is present                                                                                                                                                                                                     |
| `wpconfig_constants`     | list   |                            | A list/array of constants with their value to add to the wp-config.php                                                                                                                                                                                                |

## Custom Nginx configs

The Nginx configuration for this site can be overriden by creating a `provision/vvv-nginx-custom.conf` file. Copy the `provision/vvv-nginx-default.conf` file and make modifications, then reprovision, and VVV will use your `vvv-nginx-custom.conf` instead as the template.

Note that if you make a mistake VVV may fail to provision, this normally happens when restarting Nginx. Make sure you test your configs, `vagrant ssh` followed by `sudo nginx -t` will validate the config file for basic errors. You may also see the default VVV error pages if your config file is valid but set up incorrectly. Also be sure to preserve the placeholders VVV uses so that features such as SSL certificates and the `nginx_upstream` parameter and others continue to work.

Note that VVV will search and replace identifiers in brackets such as `{vvv_tls_key}`, and if these are removed then functionality from `config.yml` or SSL certificates may stop working. Some identifiers are implemented using `provision/provision.sh` in the custom site template, and will have double brackets, e.g. `{{LIVE_URL}}`.

If you are looking to rename the `public_html` folder, you should use the `public_dir` parameter in `config.yml` instead of a custom Nginx config file.

## Using Git for Your Site

If you want to manage your site using `git`, you can do that inside the `public_html` folder. This git repo is just for the site template provisioner, you don't need to fork it. You can also set the `wp_type` to `none` and clone a git repo using the `folders:` feature. You might do this if your host has provided you with a git repository. See the examples below for a WordPress VIP site that uses a site in a git repository.

## Examples

### The Minimum Required Configuration

A standard WordPress site:

```yaml
  my-site:
    repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template
    hosts:
      - my-site.test
```

| Setting    | Value        |
|------------|--------------|
| Domain     | my-site.test |
| Site Title | my-site.test |
| DB Name    | my-site      |
| Site Type  | Single       |
| WP Version | Latest       |

### Minimal configuration with custom domain and WordPress Nightly

```yaml
  my-site:
    repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template
    hosts:
      - foo.test
    custom:
      wp_version: nightly
```

| Setting    | Value       |
|------------|-------------|
| Domain     | foo.test    |
| Site Title | foo.test    |
| DB Name    | my-site     |
| Site Type  | Single      |
| WP Version | Nightly     |

### VIP Go WordPress Installation

Replace the VIP Go skeleton URL with your client repository then reprovision, the `folders:` parameter requires VVV 3.5+ to use.

```yaml
  vip:
    repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template.git
    hosts:
      - vip.test
    folders:
      # VIP Site repo
      public_html/wp-content/:
        git:
          repo: https://github.com/Automattic/vip-go-skeleton.git
          overwrite_on_clone: true
      # VIP Go MU Plugins
      public_html/wp-content/mu-plugins:
        git:
          repo: https://github.com/Automattic/vip-go-mu-plugins.git
          overwrite_on_clone: true
          hard_reset: true
          pull: true
```

| Setting    | Value       |
|------------|-------------|
| Domain     | vip.test    |
| Site Title | vip.test    |
| DB Name    | vip         |

### Manual WordPress Installation

Useful for when you already have a WordPress install you want to copy into place, or if you want to use a non-WordPress setup.

```yaml
  my-site:
    repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template
    hosts:
      - foo.test
    custom:
      wp_type: none
```

| Setting    | Value       |
|------------|-------------|
| Domain     | foo.test    |
| Site Title | foo.test    |
| DB Name    | my-site     |
| Site Type  | none        |

### Drupal and other CMS Installation

A `provision/vvv-nginx-custom.conf` will be need for custom routing to work if it doesn't already. Once the site is provisioned, open the folder and install Drupal or another CMS into the `public_html` folder.

```yaml
  drupal-site:
    repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template
    hosts:
      - drupal.test
    custom:
      wp_type: none
```

| Setting    | Value       |
|------------|-------------|
| Domain     | drupal.test |
| DB Name    | my-site     |
| Site Type  | none        |

### WordPress Multisite with Subdomains

```yaml
  my-site:
    repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template
    hosts:
      - multisite.test
      - site1.multisite.test
      - site2.multisite.test
    custom:
      wp_type: subdomain
```

| Setting    | Value               |
|------------|---------------------|
| Domain     | multisite.test      |
| Site Title | multisite.test      |
| DB Name    | my-site             |
| Site Type  | Subdomain Multisite |

### WordPress Multisite with Subdirectory

```yaml
  my-site:
    repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template
    hosts:
      - multisite.test
    custom:
      wp_type: subdirectory
```

| Setting    | Value                  |
|------------|------------------------|
| Domain     | multisite.test         |
| Site Title | multisite.test         |
| DB Name    | my-site                |
| Site Type  | Subdirectory Multisite |

## Configuration Options

```yaml
hosts:
    - foo.test
    - bar.test
    - baz.test
```

Defines the domains and hosts for VVV to listen on.
The first domain in this list is your sites primary domain.

```yaml
custom:
    site_title: My Awesome Dev Site
```

Defines the site title to be set upon installing WordPress.

```yaml
custom:
    wp_version: 4.6.4
```

Defines the WordPress version you wish to install. Valid values are:

- nightly
- latest
- a version number

Older versions of WordPress will not run on PHP7, see this page on [how to change PHP version per site](https://varyingvagrantvagrants.org/docs/en-US/adding-a-new-site/changing-php-version/).

```yaml
custom:
    wp_type: single
```
Defines the type of install you are creating. Valid values are:

- `single`
- `subdomain`
- `subdirectory`
- `none`

```yaml
custom:
    db_name: super_secret_db_name
```

Defines the DB name for the installation.

Other parameters available:

```yaml
custom:
    delete_default_plugins: true # Only on install of WordPress
    install_test_content: true # Install test content. Only on install of WordPress
    install_plugins: # Various way to install a plugin
         - query-monitor
    install_themes: # Various way to install a theme
         - understrap
    wpconfig_constants:
         WP_DEBUG: true
         WP_DEBUG_LOG: true
         WP_DISABLE_FATAL_ERROR_HANDLER: true # To disable in WP 5.2 the FER mode
    locale: it_IT
    admin_user: admin # Only on install of WordPress
    admin_password: password # Only on install of WordPress
    admin_email: admin@local.test # Only on install of WordPress
    live_url: http://example.com # Redirect any uploads not found locally to this domain
```
