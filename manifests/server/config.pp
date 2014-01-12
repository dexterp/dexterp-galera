class galera::server::config {
  if ! defined( Group['mysql'] ) {
    group {
      'mysql':
        gid => 498,
        system => true;
    }
  }
  if ! defined( User['mysql'] ) {
    user {
      'mysql':
        uid => 497,
        gid => 498,
        require => Group[ 'mysql' ],
        system => true;
    }
  }
  file {
    '/var/run/mysqld':
      ensure => directory,
      owner  => mysql,
      group  => mysql,
      require => User[ 'mysql' ],
      mode   => 755;
  }
  exec {
    '/bin/touch /var/run/mysqld/mysqld.pid':
      user => mysql,
      unless => '/usr/bin/test -f /var/run/mysqld/mysqld.pid',
      require => File[ '/var/run/mysqld' ]
  }
}