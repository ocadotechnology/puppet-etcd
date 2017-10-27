# == Class etcd::service
#
class etcd::service {

  $binary_location  = $etcd::binary_location
  $group            = $etcd::group
  $log_dir          = $etcd::log_dir
  $user             = $etcd::user

  # Switch service details based on osfamily
  case $::osfamily {
    'RedHat' : {
      $service_file_location = '/etc/init.d/etcd'
      $service_file_contents = template('etcd/etcd.initd.erb')
      $service_file_mode     = '0755'
      $service_provider      = undef
    }
    'Debian' : {
      $service_file_location = '/etc/init/etcd.conf'
      $service_file_contents = template('etcd/etcd.upstart.erb')
      $service_file_mode     = '0444'

      # Ubuntu xenial contains valid systemd service config #
      if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '16') >= 0 {
        $service_provider      = undef
      } else {
        $service_provider      = 'upstart'
      }

    }
    default  : {
      fail("OSFamily ${::osfamily} not supported.")
    }

  }

  # Create the appropriate service file
  if $etcd::manage_service_file {
    file { 'etcd-servicefile':
      ensure  => file,
      path    => $service_file_location,
      owner   => $etcd::user,
      group   => $etcd::group,
      mode    => $service_file_mode,
      content => $service_file_contents,
      notify  => Service['etcd']
    }
  }

  # Set service status
  service { 'etcd':
    ensure   => $etcd::service_ensure,
    enable   => $etcd::service_enable,
    provider => $service_provider,
  }
}
