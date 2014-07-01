# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::beanstalkd
{
  package {'beanstalkd':
    ensure => present
  }

  service {'beanstalkd':
    ensure  => running,
    require => Augeas['beanstalkd']
  }

  augeas {'beanstalkd':
    context => '/files/etc/default/beanstalkd',
    changes => 'set START yes',
    require => Package['beanstalkd']
  }

  if $jeti::config['beanstalkd.admin'] {
    include jeti::nginx
    include jeti::php
    include jeti::beanstalkd::console
  }
}
