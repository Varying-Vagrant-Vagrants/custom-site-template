# VVV Custom site template

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/6fc9d45abb02454aa052771bda2d40ff)](https://www.codacy.com/gh/Varying-Vagrant-Vagrants/custom-site-template?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Varying-Vagrant-Vagrants/custom-site-template&amp;utm_campaign=Badge_Grade)

This tells VVV how to install WordPress and set up Nginx, great for doing development work or testing out plugins and themes.

 - [Overview](#overview)
 - [Configuration Options](#configuration-options)
 - [Examples](#examples)

## Overview

This template will allow you to create a WordPress dev environment using only `config/config.yml`.

The supported environments are:

- A single site
- A subdomain multisite
- A subdirectory multisite
- A blank folder for manual installation

The Nginx configuration for this site can be overriden by creating a `provision/vvv-nginx-custom.conf`.

## Configuration Options


| Key                      | Default                    | Description                                                                                                                                                                                                                                                                        |
|--------------------------|----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `admin_email`            | `admin@local.test`         | The email address of the initial admin user                                                                                                                                                                                                                                        |
| `admin_password`         | `password`                 | The password for the initial admin user                                                                                                                                                                                                                                            |
| `admin_user`             | `admin`                    | The name of the initial admin user                                                                                                                                                                                                                                                 |
| `db_name`                | The sites name             | The name of the MySQL database to create and install to                                                                                                                                                                                                                           |
| `db_prefix`              | `wp_`                      | The WP table prefix                                                                                                                                                                                                                                                               |
| `delete_default_plugins` | `false`                    | Deletes the Hello Dolly and Akismet plugins on install                                                                                                                                                                                                                             |
| `install_test_content`   | `false`                    | When first installing WordPress, run the importer and import standard test content from github.com/poststatus/wptest                                                                                                                                                               |
| `public_dir`             | `public_html`              | Change the default folder inside the website's folder with the WP installation            |
| `live_url`               |                            | The production site URL, this tells Nginx to redirect requests for assets to the production server if they're not found. This prevents the need to store those assets locally.                                                                                                     |
| `locale`                 | `en_US`                    | The locale for WP Admin language                                                                                                                                                                                                                                                   |
| `install_plugins`        |                            | A list/array of plugins to install and activate. Similar to the hosts array. These values are passed to the WP CLI plugin install command and take the same format.                                                                                                                |
| `install_themes`         |                            | A list/array of themes to install. Similar to the hosts array. These values are passed to the WP CLI plugin install command and take the same format.                                                                                                                              |
| `site_title`             | The first host of the site | The main name/title of the site, defaults to `sitename.test`                                                                                                                                                                                                                       |
| `wp_type`                | `single`                   |  - `single` will create a standard WP install<br> - `subdomain` will create a subdomain multisite<br> - `subdirectory` will create a subdirectory multisite<br> - `none` will skip installing WordPress, and let you install WordPress manually (useful for custom folder layouts) |
| `wp_version`             | `latest`                   | The version of WordPress to install if no installation is present                                                                                                                                                                                                                  |


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
         - https://github.com/crstauf/query-monitor-extend/archive/version/1.0.zip
         - https://github.com/norcross/airplane-mode/archive/master.zip
    install_themes: # Various way to install a theme
         - understrap
         - https://github.com/understrap/understrap-child.git
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
