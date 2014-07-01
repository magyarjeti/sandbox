# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::adminer
{
  wget::fetch {'adminer':
    source      => 'http://downloads.sourceforge.net/adminer/adminer-4.1.0-mysql-en.php',
    destination => '/var/www/adminer.php',
    require     => Class['staging']
  }

  nginx::resource::location {'default:mysql-admin':
    require        => Wget::Fetch['adminer'],
    ensure         => present,
    vhost          => 'default',
    www_root       => '/var/www',
    location       => '/mysql',
    fastcgi        => 'unix:/var/run/php5-fpm.sock',
    fastcgi_script => '$document_root/adminer.php'
  }
}
