#MySQL

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup - The basics of getting started with galera](#setup)
4. [Example](#usage)

##Overview

The Galera module installs, configures, and manages the MariaDB/MySQL Galera cluster.

##Module Description

The Galera module manages both the installation and configuration. It acts primarily
as a pass through module for puppetlabs/mysql as well as Galera specific extensions.

##Setup

###What Galera affects

* MariaDB/MySQL + Galera package.
* MariaDB/MySQL + Galera configuration files.
* MariaDB/MySQL + Galera service.

###Requirements

Supports Enterprise Linux only with MariaDB.orgs Galera suite

The packages can be obtained by adding to /etc/yum.conf.d the package repository.

EL6 x86_64 example

    cat > /etc/yum.conf.d/mariadb.org <<EOF
    [mariadb]
    name = MariaDB
    baseurl = http://yum.mariadb.org/5.5/centos6-amd64
    gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
    gpgcheck=1
    #
    EOF

For more examples see the MariaDB.org download [site](https://downloads.mariadb.org/mariadb/repositories)

##Galera Parameters

###galera::server

####`package_distribution`

Sets three options `package_name`, `client_package_name`, `service_name` to
match the relevant distribution.

`mariadborg (default)`

  MariaDB+Galera distribution from MariaDB.Orgs

    package_name = MariaDB-Galera-Server
    client_package_name = MariaDB-Client
    service_name = mysql

`native`

  Native packages from OS distribution.

####`wsrep_sst_auth`

Default: `root:$root_password`

####`wsrep_cluster_address`

Default: `gcomm://`

####`wsrep_cluster_name`

Default: `my_wsrep_cluster`

####`wsrep_node_address`

Default: `$::ipaddress`

####`wsrep_sst_method`

Default: `rsync`

####`wsrep_provider`

Default:

    /usr/lib/galera/libgalera_smm.so   # x86
    /usr/lib64/galera/libgalera_smm.so # x86_64

###galera::server pass through

The following options are pass through to mysql::server

* config_file
* manage_config_file
* old_root_password
* override_options
* package_ensure
* package_name
* purge_conf_dir
* remove_default_accounts
* restart
* root_group
* root_password
* service_enabled
* service_manage
* service_name
* service_provider
* users
* grants
* databases

###`galera::client`

###Examples

Setup:

    cat > /etc/yum.conf.d/mariadb.org <<EOF
    [mariadb]
    name = MariaDB
    baseurl = http://yum.mariadb.org/5.5/centos6-amd64
    gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
    gpgcheck=1
    EOF

Configuration:

    node galeracluster {
      class {
        'galera::server':
          root_password    => 'password',
          service_name     => 'mysql',
          service_enabled  => false,
          wsrep_cluster_address    => 'gcomm://192.168.1.15,192.168.1.16,192.168.1.17',
          wsrep_cluster_name       => 'my_wsrep_cluster',
          wsrep_provider           => '/usr/lib64/galera/libgalera_smm.so',
          wsrep_node_address       => $::ipaddress_eth1,
          wsrep_sst_method         => 'rsync',
          wsrep_sst_auth           => "root:password",
          override_options => {
            mysqld => {
              bind-address             => false,
              query_cache_limit        => '0',
              query_cache_size         => '0',
            },
          }
      }

      # Create puppet database
      mysql_database {
        'puppet':
          ensure  => 'present',
          charset => 'utf8',
          collate => 'utf8_swedish_ci',
      }

      # Create puppet user
      mysql_user {
        'puppet@%':
          password_hash => mysql_password('password'),
      }

      # Grant access
      mysql_grant {
        'puppet@%/puppet.*':
          table => 'puppet.*',
          options => [ 'grant' ],
          privileges => [
            'SELECT', 'INSERT',
            'UPDATE', 'DELETE',
            'CREATE', 'DROP',
            'INDEX', 'ALTER'
          ],
          user => 'puppet@%',
          require => Mysql_user[ 'puppet@%' ];
      }
    }

    # Galera recommends minium of 3 servers so that a primary can be elected
    node /^db\d+/ inherits galeracluster {
    }

Managing the server:

    # First node needs to be started in boostrap mode to set as primary server
    ssh db01
    /etc/init.d/mysql bootstrap

    # Remaining nodes can be started normally
    ssh db02
    /etc/init.d/mysql start
    exit

    ssh db03
    /etc/init.d/mysql start
    exit


