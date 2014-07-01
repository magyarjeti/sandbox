# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::mysql
{
  $version = $jeti::config['mysql.version']

  apt::source {'percona':
    location    => 'http://repo.percona.com/apt',
    release     => 'precise',
    repos       => 'main',
    include_src => false,
    key         => '1C4CBDCDCD2EFD2A',
    key_server  => 'keys.gnupg.net'
  }

  class {'::mysql::server':
    root_password    => $jeti::config['mysql.password'],
    package_name     => "percona-server-server-$version",
    override_options => {
      'mysqld' => {
        'bind-address' => '0.0.0.0'
      }
    }
  }

  mysql_grant {'root@%/*.*':
    ensure     => present,
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => '*.*',
    user       => 'root@%'
  }

  if $jeti::config['mysql.admin'] {
    include jeti::nginx
    include jeti::php
    ensure_resource('php::module', 'mysql')
    include jeti::adminer
  }

  package {'percona-toolkit':
    ensure => present
  }
}
