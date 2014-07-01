# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::mongodb
{
  apt::source {'10gen':
    location    => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
    release     => 'dist',
    repos       => '10gen',
    include_src => false,
    key         => '7F0CEB10',
    key_server  => 'keys.gnupg.net'
  }

  package {'mongodb-10gen':
    require => Apt::Source['10gen']
  }

  if $jeti::config['mongodb.admin'] {
    include jeti::nginx
    include jeti::php
    include jeti::genghis
  }
}
