# == Class etcd::config
#
class etcd::config {

  $advertise_client_urls        = $etcd::advertise_client_urls
  $cors                         = $etcd::cors
  $data_dir                     = $etcd::data_dir
  $discovery                    = $etcd::discovery
  $discovery_fallback           = $etcd::discovery_fallback
  $discovery_proxy              = $etcd::discovery_proxy
  $discovery_srv_record         = $etcd::discovery_srv_record
  $election_timeout             = $etcd::election_timeout
  $heartbeat_interval           = $etcd::heartbeat_interval
  $initial_advertise_peer_urls  = $etcd::initial_advertise_peer_urls
  $initial_cluster              = $etcd::initial_cluster
  $initial_cluster_state        = $etcd::initial_cluster_state
  $initial_cluster_token        = $etcd::initial_cluster_token
  $listen_client_url            = $etcd::listen_client_url
  $listen_peer_url              = $etcd::listen_peer_url
  $log_dir                      = $etcd::log_dir
  $max_snapshots                = $etcd::max_snapshots
  $max_wals                     = $etcd::max_wals
  $mode                         = $etcd::mode
  $node_name                    = $etcd::node_name
  $peer_ca_file                 = $etcd::peer_ca_file
  $peer_cert_file               = $etcd::peer_cert_file
  $peer_key_file                = $etcd::peer_key_file
  $proxy                        = $etcd::proxy
  $snapshot_count               = $etcd::snapshot_count
  $gateway_endpoints            = $etcd::gateway_endpoints
  $gateway_listen_addr          = $etcd::gateway_listen_addr


  if $gateway_endpoints {
    $_gateway_endpoints = $gateway_endpoints
  } else {
    $_gateway_endpoints = regsubst($initial_cluster, '(.*)=http(s)?://.*$', '\1:2379')
  }


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
      file { '/etc/default/etcd-gateway':
        ensure  => file,
        owner   => $etcd::user,
        group   => $etcd::group,
        mode    => '0644',
        content => template('etcd/etcd-gateway.config.erb'),
      }
    }
    default  : {
      fail("OSFamily ${::osfamily} not supported.")
    }
  }
}
