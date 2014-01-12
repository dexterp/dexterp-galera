# Class: galera::server:  See README.md for documentation.
class galera::server (
  $wsrep_sst_auth          = false,
  $wsrep_cluster_address   = $galera::params::wsrep_cluster_address,
  $wsrep_cluster_name      = $galera::params::wsrep_cluster_name,
  $wsrep_node_address      = $galera::params::wsrep_node_address,
  $wsrep_sst_method        = $galera::params::wsrep_sst_method,
  $wsrep_provider          = $galera::params::wsrep_provider,
  $config_file             = $galera::params::config_file,
  $manage_config_file      = $galera::params::manage_config_file,
  $old_root_password       = $galera::params::old_root_password,
  $override_options        = {},
  $package_distribution    = $galera::params::package_distribution,
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

  $real_service_enabled = $service_enabled
  $real_service_manage = $service_manage

  case $::galera::server::package_distribution {
    'native' : {
      $real_package_name = $::galera::server::package_name
      $real_client_package_name = $::galera::params::client_package_name
      $real_service_name = $::galera::server::service_name
    }
    'mariadborg',default : {
      $real_package_name = $::galera::params::mariadborg_server_package_name
      $real_client_package_name = $::galera::params::mariadborg_client_package_name
      $real_service_name = $::galera::params::mariadborg_service_name
    }
  }

  if $wsrep_sst_auth {
    $real_wsrep_sst_auth = $wsrep_sst_auth
  }
  else {
    $real_wsrep_sst_auth = "root:${root_password}"
  }
  $override_wsrep_sst_auth = {
    'mysqld' => {
      'wsrep_sst_auth' => $real_wsrep_sst_auth,
      'wsrep_cluster_address' => $wsrep_cluster_address,
      'wsrep_cluster_name' => $wsrep_cluster_name,
      'wsrep_node_address' => $wsrep_node_address,
      'wsrep_sst_method' => $wsrep_sst_method,
      'wsrep_provider' => $wsrep_provider,
    }
  }

  # Create a merged together set of options.  Rightmost hashes win over left.
  $options = mysql_deepmerge($galera::params::default_options, $override_options, $override_wsrep_sst_auth)

  anchor { 'galera::server::start': }
  anchor { 'galera::server::end': }

  if $::osfamily == 'RedHat' and ! defined( Class['mysql::client'] ) {
    include '::galera::server::install'
    include '::galera::server::config'
    class {
      'mysql::client':
        package_name         => $::galera::server::real_client_package_name,
        package_ensure       => $::galera::server::package_ensure,
        package_distribution => $::galera::server::package_distribution
    }
  }
  class {
    'mysql::server':
      override_options        => $options,
      config_file             => $config_file,
      manage_config_file      => $manage_config_file,
      old_root_password       => $old_root_password,
      package_ensure          => $package_ensure,
      package_name            => $real_package_name,
      purge_conf_dir          => $purge_conf_dir,
      remove_default_accounts => $remove_default_accounts,
      restart                 => $restart,
      root_group              => $root_group,
      root_password           => $root_password,
      service_enabled         => $service_enable,
      service_manage          => $service_manage,
      service_name            => $real_service_name,
      service_provider        => $server_service_provider,
      users                   => $users,
      grants                  => $grants,
      databases               => $databases,
  }

  case $::osfamily {
    'RedHat' : {
      Anchor [ 'galera::server::start' ] ->
      Class[ galera::server::install ] ->
      Class[ galera::server::config ] ->
      Class[ mysql::client ] ->
      Class[ mysql::server ] ->
      Anchor [ 'galera::server::end' ]
    }
    default : {
      Anchor [ 'galera::server::start' ] ->
      Class[ mysql::server ] ->
      Anchor [ 'galera::server::end' ]
    }
  }
}
