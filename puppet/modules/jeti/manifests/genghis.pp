# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::genghis
{
  staging::file {'genghis.zip':
    source => 'https://github.com/bobthecow/genghis/archive/v2.3.11.zip'
  }

  staging::extract {'genghis.zip':
    target  => '/var/www',
    creates => '/var/www/genghis-2.3.11',
    require => Staging::File['genghis.zip']
  }

  nginx::resource::location {'default:mongo-admin':
    require             => Staging::Extract['genghis.zip'],
    ensure              => present,
    vhost               => 'default',
    www_root            => '/var/www/genghis-2.3.11',
    location            => '~ "/mongodb(?<path>.*)"',
    fastcgi             => 'unix:/var/run/php5-fpm.sock',
    fastcgi_script      => '$document_root/genghis.php',
    location_cfg_append => {
      'fastcgi_param SCRIPT_NAME' => '/mongodb/genghis.php',
      'fastcgi_param PATH_INFO'   => '$path',
      'rewrite /genghis.php'      => '/ permanent'
    }
  }
}
