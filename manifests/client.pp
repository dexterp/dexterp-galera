#
class galera::client (
  $bindings_enable      = $galera::params::bindings_enable,
  $package_ensure       = $galera::params::client_package_ensure,
  $package_name         = $galera::params::client_package_name,
  $package_distribution = $galera::params::package_distribution
) inherits galera::params {

  case $::galera::client::package_distribution {
    'native' : {
      $real_package_name = $::galera::client::client_package_name
    }
    'mariadborg',default : {
      $real_package_name = $::galera::params::mariadborg_client_package_name
    }
  }

  class {
    'mysql::client':
      bindings_enable => $bindings_enable,
      package_ensure  => $package_ensure,
      package_name    => $real_package_name
  }

  anchor { 'galera::client::start': } ->
    Class['mysql::client'] ->
  anchor { 'galera::client::end': }

}
