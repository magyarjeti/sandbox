# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::nginx::fastcgi
{
  $root  = $jeti::config['nginx.root']

  nginx::resource::location {'default:php':
    ensure         => present,
    priority       => 590,
    vhost          => 'default',
    www_root       => "/vagrant/$root",
    location       => '~ \.php$',
    fastcgi        => 'unix:/var/run/php5-fpm.sock',
    fastcgi_script => '$document_root$fastcgi_script_name',
  }
}
