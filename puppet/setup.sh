#!/bin/bash

#------------------------------------------------
#  Install puppet
#------------------------------------------------

dpkg --get-selections | grep puppet | grep install >/dev/null

if [ $? -ne 0 ]; then
    wget -q http://apt.puppetlabs.com/puppetlabs-release-precise.deb
    dpkg -i puppetlabs-release-precise.deb >/dev/null
    apt-get update -q >/dev/null
    apt-get install puppet -y -q >/dev/null
fi

mkdir -p /etc/puppet/modules

# Suppress deprecation message on module install.
sed -i 's/^\(templatedir\)/#\1/' /etc/puppet/puppet.conf

#------------------------------------------------
#  Install puppet modules
#------------------------------------------------

modules=(
    "puppetlabs/stdlib~4.1.0"
    "camptocamp/augeas~0.0.1"
    "puppetlabs/apt~1.4.0"
    "example42/php~2.0.15"
    "puppetlabs/ntp~3.0.1"
    "saz/timezone~1.2.0"
    "puppetlabs/mysql~2.2.3"
    "example42/redis~2.0.8"
    "jfryman/nginx~0.0.6"
    "puppetlabs/nodejs~0.4.0"
    "saz/locales~2.1.0"
    "acme/ohmyzsh~0.1.1"
    "nanliu/staging~0.4.0"
    "maestrodev/wget~1.4.1"
    "magyarjeti/ylib~0.1.0"
    "puppetlabs/vcsrepo~0.2.0"
)

modulepath="/vagrant/puppet/modules"

for i in "${modules[@]}"
do
    IFS='~' read -r package version <<< "$i"

    installed=($(puppet module list --modulepath=$modulepath | grep '(' | awk '{ print $2} ' | sed s:-:/:))

    if [[ ! ${installed[*]} =~ $package ]]
    then
        if [ -n "$version" ]; then
            version="--version $version"
        fi
        puppet module install $package $version --modulepath=$modulepath
    fi
done
