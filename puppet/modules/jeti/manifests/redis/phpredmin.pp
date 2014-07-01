# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::redis::phpredmin
{
  $target = '/var/www/phpredmin'

  vcsrepo {$target:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/sasanrose/phpredmin.git',
    revision => 'af8354480f9115602387db9abe95e0feb6d421b8'
  }

  exec {'chown-phpredmin':
    command => "/bin/chown -R vagrant:vagrant $target",
    unless  => "/usr/bin/test `stat -c '%U' $target` = vagrant",
    require => Vcsrepo[$target]
  }

  nginx::resource::location {'default:redis-admin':
    require   => Vcsrepo[$target],
    ensure    => present,
    vhost     => 'default',
    www_root  => "$target/public",
    location  => '~ "/redis(?<path>.*)"',
    try_files => ['$path', '@redis']
  }

  nginx::resource::location {'default:redis-admin-backend':
    require             => Vcsrepo[$target],
    ensure              => present,
    vhost               => 'default',
    www_root            => "$target/public",
    location            => '@redis',
    fastcgi             => 'unix:/var/run/php5-fpm.sock',
    fastcgi_script      => '$document_root/index.php',
    location_cfg_append => {
      'fastcgi_param SCRIPT_NAME' => '/redis/index.php'
    }
  }
}
