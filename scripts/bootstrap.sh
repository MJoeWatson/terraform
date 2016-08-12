#!/usr/bin/env bash

###Installing Puppet for Configuration Management
yum install -y puppet3 git
cat <<'EOF' >/etc/puppet/r10k.yaml
---
:sources:
  control:
    basedir: /etc/puppet/environments
    prefix: false
    remote: https://github.com/MattWatson-/control.git
EOF

gem install r10k
/usr/local/bin/r10k deploy environment master --config /etc/puppet/r10k.yaml

cat <<'EOF' >/etc/puppet/hiera.yaml
---
:logger: console
:backends:
  - yaml

:hierarchy:
  - "role/%{::role}"
  - "module/%{module_name}"
  - "common"

:yaml:
  :datadir: "/etc/puppet/environments/%{environment}/hieradata"
EOF

cat <<'EOF' >/etc/puppet/puppet.conf
[main]
    logdir = /var/log/puppet
    rundir = /var/run/puppet
    ssldir = $vardir/ssl
    hiera_config = /etc/puppet/hiera.yaml
    environment = master

[agent]
    classfile = $vardir/classes.txt
    localconfig = $vardir/localconfig
EOF

cat <<'EOF' >/etc/yum.repos.d/nginx-release.repo
[nginx-release]
name=nginx repo
baseurl=http://nginx.org/packages/rhel/6/$basearch/
enabled=1
gpgcheck=1
gpgkey=http://nginx.org/keys/nginx_signing.key
priority=1
EOF


role=$1

mkdir -p /etc/facter/facts.d
echo "role=$role" > /etc/facter/facts.d/role.txt

puppet apply --modulepath=/etc/puppet/environments/master/modules /etc/puppet/environments/master/manifests/site.pp
if [ $role == 'appserver' ]
then
  /usr/local/bin/consul join $2
fi
