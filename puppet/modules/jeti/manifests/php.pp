# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::php
{
  $modules = $jeti::config['php.modules']

  $with_fpm = member($::services, 'nginx') or defined(Class['jeti::nginx'])

  case $config['php.version'] {
    '5.3': {
    }

    '5.4': {
      apt::source {'ondrej-php54':
        location    => 'http://ppa.launchpad.net/ondrej/php5-oldstable/ubuntu',
        release     => 'precise',
        repos       => 'main',
        include_src => false,
        key         => 'E5267A6C',
        key_server  => 'keyserver.ubuntu.com'
      }
    }

    '5.5', 'latest': {
      apt::source {'ondrej-php55':
        location    => 'http://ppa.launchpad.net/ondrej/php5/ubuntu/',
        release     => 'precise',
        repos       => 'main',
        include_src => false,
        key         => 'E5267A6C',
        key_server  => 'keyserver.ubuntu.com'
      }
    }

    default: {
      fail('Invalid PHP version')
    }
  }

  $php_package = $with_fpm ? {
    true  => 'php5-fpm',
    false => 'php5-cli'
  }

  if $with_fpm {
    package {'php5-cli':
      ensure => present,
    }
  }

  class {'::php':
    package => $php_package,
    service => 'nginx',
    service_autorestart => $with_fpm
  }

  php::augeas {'php-date_timezone':
    entry   => 'Date/date.timezone',
    value   => $jeti::config['timezone'],
    target  => '/etc/php5/cli/php.ini',
    require => Package['php5-cli']
  }

  if $with_fpm {
    service {'php5-fpm':
      enable  => true,
      ensure  => running,
      require => Class['::php']
    }

    php::augeas {'fpm-date_timezone':
      entry   => 'Date/date.timezone',
      value   => $jeti::config['timezone'],
      target  => '/etc/php5/fpm/php.ini',
      require => Class['::php']
    }

    php::augeas {'upload_limit':
      entry   => 'PHP/upload_max_filesize',
      value   => '0',
      target  => '/etc/php5/fpm/php.ini',
      require => Class['::php'],
      notify  => Service['php5-fpm']
    }

    php::augeas {'post_limit':
      entry   => 'PHP/post_max_size',
      value   => '0',
      target  => '/etc/php5/fpm/php.ini',
      require => Class['::php'],
      notify  => Service['php5-fpm']
    }

    php::augeas {'fpm-user':
      entry   => 'www/user',
      value   => 'vagrant',
      target  => '/etc/php5/fpm/pool.d/www.conf',
      require => Class['::php'],
      notify  => Service['php5-fpm']
    }

    php::augeas {'fpm-group':
      entry   => 'www/group',
      value   => 'vagrant',
      target  => '/etc/php5/fpm/pool.d/www.conf',
      require => Class['::php'],
      notify  => Service['php5-fpm']
    }

    include jeti::nginx::fastcgi
  }

  if is_array($modules) and !empty($modules) {
    if member($modules, 'mongo') or defined(Class['jeti::mongodb']) {
      $rest_modules = delete($modules, 'mongo')

      ::php::module {$rest_modules: }

      ::php::pecl::module {'mongo':
        use_package => false
      }

      $mongo_ini = '/etc/php5/mods-available/mongo.ini'

      file {$mongo_ini:
        ensure  => present,
        content => 'extension=mongo.so',
        mode    => '0644',
        require => [Class['::php'], Php::Pecl::Module['mongo']]
      }

      $mongo_confd = $with_fpm ? {
        true  => [ '/etc/php5/cli/conf.d/20-mongo.ini', '/etc/php5/fpm/conf.d/20-mongo.ini' ],
        false => [ '/etc/php5/cli/conf.d/20-mongo.ini' ]
      }

      file {$mongo_confd:
        ensure  => link,
        target  => $mongo_ini,
        require => File[$mongo_ini],
        notify  => Service['php5-fpm']
      }
    } else {
      ::php::module {$modules: }
    }
  }
}
