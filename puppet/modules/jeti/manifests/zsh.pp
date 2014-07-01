# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2

class jeti::zsh ($users = 'vagrant', $theme = '')
{
  class {'::ohmyzsh': }

  ohmyzsh::install {$users: }

  if $theme {
    ohmyzsh::theme {$users:
      theme => $theme
    }
  }

  ohmyzsh::plugins {$users:
    plugins => 'git'
  }
}
