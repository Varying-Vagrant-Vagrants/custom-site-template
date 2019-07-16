# VVV Custom site template
For when you just need a simple dev site

## Overview
This template will allow you to create a WordPress dev environment using only `vvv-custom.yml`.

The supported environments are:
- A single site
- A subdomain multisite
- A subdirectory multisite

# Configuration

### The minimum required configuration:

```yaml
my-site:
  repo: https://github.com/Varying-Vagrant-Vagrants/custom-site-template
  hosts:
    - my-site.test
```
| Setting    | Value       |
|------------|-------------|
| Domain     | my-site.test |
| Site Title | my-site.test |
| DB Name    | my-site     |
| Site Type  | Single      |
| WP Version | Latest      |

### Minimal configuration with custom domain and WordPress Nightly:

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
| Domain     | foo.test     |
| Site Title | foo.test     |
| DB Name    | my-site     |
| Site Type  | Single      |
| WP Version | Nightly     |

### WordPress Multisite with Subdomains:

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

### WordPress Multisite with Subdirectory:

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
Defines the WordPress version you wish to install.
Valid values are:
- nightly
- latest
- a version number

Older versions of WordPress will not run on PHP7, see this page on [how to change PHP version per site](https://varyingvagrantvagrants.org/docs/en-US/adding-a-new-site/changing-php-version/).

```yaml
custom:
    wp_type: single
```
Defines the type of install you are creating.
Valid values are:
- single
- subdomain
- subdirectory
- none

```yaml
custom:
    db_name: super_secet_db_name
```
Defines the DB name for the installation.

Other parameters available:

```yaml
custom:
    delete_default_plugins: true # Only on install of WordPress
    install_plugins: # Various way to install a plugin
         - query-monitor
         - https://github.com/crstauf/query-monitor-extend/archive/version/1.0.zip
         - https://github.com/norcross/airplane-mode/archive/master.zip
    constants:
         WP_DEBUG: true
         WP_DEBUG_LOG: true
         WP_DISABLE_FATAL_ERROR_HANDLER: true # To disable in WP 5.2 the FER mode
    locale: it_IT
```
