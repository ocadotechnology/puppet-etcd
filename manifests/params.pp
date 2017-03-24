# == Class etcd::params
#
class etcd::params {
  # Handle OS Specific config values
  case $::osfamily {
    'Redhat' : { $etcd_binary_location = '/usr/sbin/etcd' }
    'Debian' : { $etcd_binary_location = '/usr/bin/etcd' }
    default  : { fail("Unsupported osfamily ${::osfamily}") }
  }

  # Service settings
  $etcd_service_ensure          = 'running'
  $etcd_service_enable          = true

  # Ubuntu xenial contains valid systemd service config #
  if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '16') >= 0 {
    $etcd_manage_service_file     = true
  } else {
    $etcd_manage_service_file     = false
  }

  # Package settings
  $etcd_package_ensure          = 'installed'
  $etcd_package_name            = 'etcd'

  # User settings
  $etcd_manage_user             = true
  $etcd_user                    = 'etcd'
  $etcd_group                   = 'etcd'

  # Manage Data Dir?
  $etcd_manage_data_dir         = true
  $etcd_data_dir                = '/var/lib/etcd'

  # Manage Log Dir?
  $etcd_manage_log_dir          = true
  $etcd_log_dir                 = '/var/log/etcd'

  # Etcd mode cluster or proxy
  $etcd_mode                    = 'proxy'

  # Member settings
  $etcd_node_name               = $::fqdn
  $etcd_listen_peer_url         = ["http://${::fqdn}:2380"]
  $etcd_listen_client_url       = ["http://0.0.0.0:2379", "http://127.0.0.1:4001"]
  $etcd_election_timeout        = '1000'
  $etcd_heartbeat_interval      = '100'
  $etcd_snapshot_count          = '10000'
  $etcd_max_snapshots           = '5'
  $etcd_max_wals                = '5'
  $etcd_cors                    = []

  # Cluster settings
  $etcd_initial_advertise_peer_urls = ["http://${::fqdn}:2380"]
  $etcd_initial_cluster             = ["${::fqdn}=http://${::fqdn}:2380"]
  $etcd_initial_cluster_state       = 'existing'
  $etcd_initial_cluster_token       = 'etcd-cluster'
  $etcd_advertise_client_urls       = ["http://${::fqdn}:2379"]

  # Discovery support
  $etcd_discovery               = 'none'
  # discovery_endpoint, full url with token, f.exs: 'https://discovery.etcd.io/abcd1234':
  $etcd_discovery_endpoint      = ''
  # where to search for cluster members:
  $etcd_discovery_srv_record    = $::domain
  $etcd_discovery_fallback      = 'proxy'
  $etcd_discovery_proxy         = 'none'

  # Security settings
  $etcd_peer_ca_file            = ''
  $etcd_peer_cert_file          = ''
  $etcd_peer_key_file           = ''
}
