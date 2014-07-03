# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti
{
  $user_cnf = loadyaml('/vagrant/config.yml')
  $defaults = loadyaml('/vagrant/puppet/defaults.yml')

  $services = keys($user_cnf)

  $config = merge(smooth($defaults), smooth($user_cnf))

  Class['apt::update'] -> Package <| title != "apt" |>

  Exec {
    path => [
      "/bin/",
      "/sbin/",
      "/usr/bin/",
      "/usr/sbin/",
      "/usr/local/bin/"
    ]
  }

  include augeas

  class {'ntp':
    servers => ['ntp.ubuntu.com', 'pool.ntp.org']
  }

  class {'timezone':
    timezone => $config['timezone']
  }

  class {'jeti::locale':
    locales => $config['locales']
  }

  package {'vim':
    name   => 'vim-nox',
    ensure => installed
  }

  package {'unzip':
    ensure => present
  }

  class {'apt':
    always_apt_update => false
  }

  #--------------------------------------------------------
  #  Install and configure Git
  #--------------------------------------------------------

  package {'git':
    name   => 'git-core',
    ensure => installed
  }

  file {'/etc/gitconfig':
    ensure => present,
    source => 'puppet:///modules/jeti/gitconfig'
  }

  class {'jeti::zsh':
    theme => 'flazz'
  }

  class {'staging':
    path  => '/var/www',
    owner => 'vagrant',
    group => 'vagrant'
  }

  if member($services, 'nginx') {
    include jeti::nginx
  }

  if member($services, 'php') {
    include jeti::php
  }

  if member($services, 'mysql') {
    include jeti::mysql
  }

  if member($services, 'mongodb') {
    include jeti::mongodb
  }

  if member($services, 'redis') {
    include jeti::redis
  }

  if member($services, 'nodejs') {
    include jeti::nodejs
  }

  if member($services, 'beanstalkd') {
    include jeti::beanstalkd
  }

  if member($services, 'elasticsearch') {
    include jeti::elasticsearch
  }

  if member($services, 'sass') {
    package {'sass':
      ensure   => present,
      provider => 'gem'
    }
  }
}
