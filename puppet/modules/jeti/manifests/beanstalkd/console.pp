# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::beanstalkd::console
{
  $target = '/var/www/beanstalkd_console'

  vcsrepo {$target:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/ptrofimov/beanstalk_console.git',
    revision => '9a2153bc7e101f5820826fe1e01bddef0a3b1611'
  }

  exec {'chown-beanstalkd_console':
    command => "/bin/chown -R vagrant:vagrant $target",
    unless  => "/usr/bin/test `stat -c '%U' $target` = vagrant",
    require => Vcsrepo[$target]
  }

  nginx::resource::location {'default:beanstalkd-redirect':
    ensure              => present,
    priority            => 510,
    vhost               => 'default',
    www_root            => "$target/public",
    location            => '~ ^/beanstalkd?$',
    location_cfg_append => {
      'return 301' => '/beanstalkd/'
    }
  }

  nginx::resource::location {'default:beanstalkd-index':
    require   => Vcsrepo[$target],
    ensure    => present,
    priority  => 512,
    vhost     => 'default',
    www_root  => "$target/public",
    location  => '= /beanstalkd/index.php',
    try_files => ['$uri', '@beanstalkd']
  }

  nginx::resource::location {'default:beanstalkd-admin':
    require   => Vcsrepo[$target],
    ensure    => present,
    priority  => 514,
    vhost     => 'default',
    www_root  => "$target/public",
    location  => '~ "/beanstalkd(?<path>.*)"',
    try_files => ['$path', '@beanstalkd']
  }

  nginx::resource::location {'default:beanstalkd-admin-backend':
    require        => Vcsrepo[$target],
    ensure         => present,
    priority       => 516,
    vhost          => 'default',
    www_root       => "$target/public",
    location       => '@beanstalkd',
    fastcgi        => 'unix:/var/run/php5-fpm.sock',
    fastcgi_script => '$document_root/index.php'
  }

  exec {'add-localhost':
    command => "/bin/sed -i 's_/\\*\\([^*]*\\)\\*/_\\1_' $target/config.php",
    require => Vcsrepo[$target]
  }
}
