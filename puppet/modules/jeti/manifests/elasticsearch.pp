# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::elasticsearch
{
  class {'::elasticsearch':
    version      => '1.2.1',
    repo_version => '1.2',
    manage_repo  => true,
    java_install => true,
    status       => enabled,
    config       => {}
  }

  ::elasticsearch::instance {'es-01': }

  if $jeti::config['elasticsearch.admin'] {
    ::elasticsearch::plugin{'royrusso/elasticsearch-HQ':
      module_dir => 'HQ',
      instances  => 'es-01'
    }

    include jeti::nginx

    nginx::resource::location {'default:elasticsearch':
      ensure              => present,
      vhost               => 'default',
      location            => '= /elasticsearch',
      location_custom_cfg => {
        'return' => '301 $uri/?url=http://$server_addr:9200'
      }
    }

    nginx::resource::location {'default:elasticsearch-proxy':
      ensure   => present,
      vhost    => 'default',
      location => '/elasticsearch/',
      proxy    => 'http://127.0.0.1:9200/_plugin/HQ/'
    }
  }
}
