# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::redis
{
  class {'::redis': }

  if $jeti::config['redis.admin'] {
    include jeti::nginx
    include jeti::php
    ensure_resource('package', 'php5-redis')
    include jeti::redis::phpredmin
  }
}
