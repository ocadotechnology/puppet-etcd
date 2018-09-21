# == Class etcd::gateway
#
class etcd::gateway (
  Boolean   $migration = $::etcd_service_active,
) {

  $binary_location  = $etcd::binary_location
  $user             = $etcd::user

  # Switch service details based on osfamily
  case $::osfamily {
    'Debian' : {
      $gateway_service_file_location = '/etc/systemd/system/etcd-gateway.service'
      $gateway_service_file_contents = template('etcd/etcd-gateway.service.erb')
      $gateway_service_file_mode     = '0644'
    }
    default  : {
      fail("OSFamily ${::osfamily} not supported.")
    }

  }


  file { $gateway_service_file_location:
    ensure  => present,
    mode    => $gateway_service_file_mode,
    owner   => 'root',
    group   => 'root',
    content => $gateway_service_file_contents,
    notify  => Service['etcd-gateway']
  } ~>
  exec {'etcd-gateway_systemd_reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    before      => Service['calico-dhcp-agent'],
  }



  # Set service status
  service {'etcd-gateway':
    ensure => $etcd::service_ensure,
    enable => $etcd::service_enable,
  }

  service {'etcd':
    ensure => stopped,
    enable => false,
  }


  if $migration }

    exec {'etcd_service_type_migrate':
      command  => '/bin/systemctl stop etcd.service ; /bin/systemctl start etcd-gateway.service',
      provider => 'shell',
      onlyif   => '/bin/systemctl is-active etcd.service',
    }

    Exec['etcd_service_type_migrate'] -> Service<| tag == 'etcd' |>

  }


}
