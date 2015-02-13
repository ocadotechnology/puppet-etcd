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
  $etcd_manage_service_file     = true

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

  # Member settings
  $etcd_node_name               = $::fqdn
  $etcd_listen_peer_url         = ["http://${::fqdn}:2380", "http://${::fqdn}:7001"]
  $etcd_client_url              = ["http://${::fqdn}:2379", "http://${::fqdn}:4001"]
  $etcd_election_timeout        = '100'
  $etcd_heartbeat_interval      = '1000'
  $etcd_snapshot_count          = '10000'
  $etcd_max_snapshot            = '5'
  $etcd_max_wals                = '5'
  $etcd_cors                    = []

  # Cluster settings
  $etcd_initial_advertise_peer_urls = ["http://${::fqdn}:2380", "http://${::fqdn}:7001"]
  $etcd_initial_cluster             = ["http://${::fqdn}:2380", "http://${::fqdn}:7001"]
  $etcd_initial_cluster_token       = 'etcd-cluster'
  $etcd_advertise_client_urls       = ["http://${::fqdn}:2379", "http://${::fqdn}:4001"]

  # Discovery support
  $etcd_discovery               = 'url'
  # discovery_endpoing, full url with token, f.exs: 'https://discovery.etcd.io/abcd1234'
  $etcd_discovery_endpoint      = ''
  $etcd_discovery_srv           = false
  $etcd_discovery_srv_record    = ''
  $etcd_discovery_fallback      = 'proxy'
  $etcd_discovery_proxy         = 'none'

  #Proxy
  $etcd_proxy                   = 'off'

  # Security settings
  $etcd_peer_ca_file            = ''
  $etcd_peer_cert_file          = ''
  $etcd_peer_key_file           = ''
}
