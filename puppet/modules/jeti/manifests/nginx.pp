# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::nginx
{
  $root = $jeti::config['nginx.root']

  class {'::nginx':
    confd_purge => true
  }

  nginx::resource::vhost {'default':
    ensure               => present,
    www_root             => "/vagrant/$root",
    try_files            => ['$uri', '$uri/', '/index.php?$args'],
    vhost_cfg_append     => {
      'sendfile' => 'off'
    }
  }

  if member($::services, 'php') or defined(Class['jeti::php']) {
    include jeti::nginx::fastcgi
  }
}
