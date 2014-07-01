# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::nodejs ($packages = [])
{
  $packages = $jeti::config['nodejs.packages']

  apt::source {'chrislea':
    location    => 'http://ppa.launchpad.net/chris-lea/node.js/ubuntu',
    release     => 'precise',
    repos       => 'main',
    include_src => false,
    key         => 'C7917B12',
    key_server  => 'keys.gnupg.net'
  }

  class {'::nodejs': }

  if is_array($packages) and !empty($packages) {
    package {$packages:
      ensure   => present,
      provider => 'npm',
      require  => Class['::nodejs']
    }

    if member($packages, 'phantomjs') {
      package {'libfontconfig1':
        ensure => present
      }
    }
  }
}
