# == Class: galera
#
# Full description of class galera here.
#
# === Parameters
#
# [*package_set*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { galera:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class galera (
  $package_set             = '',
  $config_file             = $galera::params::config_file,
  $manage_config_file      = $galera::params::manage_config_file,
  $old_root_password       = $galera::params::old_root_password,
  $override_options        = {},
  $package_ensure          = $galera::params::server_package_ensure,
  $package_name            = $galera::params::server_package_name,
  $purge_conf_dir          = $galera::params::purge_conf_dir,
  $remove_default_accounts = false,
  $restart                 = $galera::params::restart,
  $root_group              = $galera::params::root_group,
  $root_password           = $galera::params::root_password,
  $service_enabled         = $galera::params::server_service_enabled,
  $service_manage          = $galera::params::server_service_manage,
  $service_name            = $galera::params::server_service_name,
  $service_provider        = $galera::params::server_service_provider,
  $users                   = {},
  $grants                  = {},
  $databases               = {},
) inherits galera::params {


}
