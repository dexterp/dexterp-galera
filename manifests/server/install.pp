class galera::server::install {
  if ! defined( Package[$::galera::params::nc_package_name] ) {
    package {
      $::galera::params::nc_package_name:
        ensure => installed,
    }
  }
  if ! defined( Package[$::galera::params::rsync_package_name] ) {
    package {
      $::galera::params::rsync_package_name:
        ensure => installed,
    }
  }
}