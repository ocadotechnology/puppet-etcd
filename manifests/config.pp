# == Class etcd::config
#
class etcd::config {
  case $::osfamily {
    'RedHat' : {
      file { '/etc/sysconfig/etcd':
        ensure  => present,
        owner   => $etcd::user,
        group   => $etcd::group,
        mode    => '0644',
        content => template('etcd/etcd.config.erb'),
      }
    }
    'Debian' : {
      file { '/etc/default/etcd':
        ensure  => file,
        owner   => $etcd::user,
        group   => $etcd::group,
        mode    => '0644',
        content => template('etcd/etcd.config.erb'),
      }
    }
    default  : {
      fail("OSFamily ${::osfamily} not supported.")
    }
  }
}
