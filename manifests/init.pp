# == Class: etcd
#
# Installs and configures etcd.
#
# === Parameters
#
# === Examples
#
#  class { etcd: }
#
# === Authors
#
# Kyle Anderson <kyle@xkyle.com>
# Mathew Finch <finchster@gmail.com>
# Gavin Williams <fatmcgav@gmail.com>
#
class etcd (
  $binary_location             = $etcd::params::etcd_binary_location,

  $service_ensure              = $etcd::params::etcd_service_ensure,
  $service_enable              = $etcd::params::etcd_service_enable,
  $manage_service_file         = $etcd::params::etcd_manage_service_file,

  $package_ensure              = $etcd::params::etcd_package_ensure,
  $package_name                = $etcd::params::etcd_package_name,

  $manage_user                 = $etcd::params::etcd_manage_user,
  $user                        = $etcd::params::etcd_user,
  $group                       = $etcd::params::etcd_group,

  $manage_log_dir              = $etcd::params::etcd_manage_log_dir,
  $data_dir                    = $etcd::params::etcd_data_dir,

  $manage_data_dir             = $etcd::params::etcd_manage_data_dir,
  $log_dir                     = $etcd::params::etcd_log_dir,

  $node_name                   = $etcd::params::etcd_node_name,
  $listen_peer_url             = $etcd::params::etcd_listen_peer_url,
  $listen_client_url           = $etcd::params::etcd_listen_client_url,
  $election_timeout            = $etcd::params::etcd_election_timeout,
  $heartbeat_interval          = $etcd::params::etcd_heartbeat_interval,
  $snapshot_count              = $etcd::params::etcd_snapshot_count,
  $max_snapshots               = $etcd::params::etcd_max_snapshots,
  $max_wals                    = $etcd::params::etcd_max_wals,
  $cors                        = $etcd::params::etcd_cors,

  $initial_advertise_peer_urls = $etcd::params::etcd_initial_advertise_peer_urls,
  $initial_cluster             = $etcd::params::etcd_initial_cluster,
  $initial_cluster_state       = $etcd::params::etcd_initial_cluster_state,
  $initial_cluster_token       = $etcd::params::etcd_initial_cluster_token,
  $advertise_client_urls       = $etcd::params::etcd_advertise_client_urls,

  $discovery                   = $etcd::params::etcd_discovery,
  $discovery_endpoint          = $etcd::params::etcd_discovery_endpoint,
  $discovery_srv_record        = $etcd::params::etcd_discovery_srv_record,
  $discovery_fallback          = $etcd::params::etcd_discovery_fallback,
  $discovery_proxy             = $etcd::params::etcd_discovery_proxy,

  $mode                        = $etcd::params::etcd_mode,
  $proxy                       = $etcd::params::etcd_proxy,

  $peer_ca_file                = $etcd::params::etcd_peer_ca_file,
  $peer_cert_file              = $etcd::params::etcd_peer_cert_file,
  $peer_key_file               = $etcd::params::etcd_peer_key_file) inherits etcd::params {

  # Select cluster type
  #
  # We need a cluster token:
  validate_string($initial_cluster_token)
  validate_bool($cluster_node)

  case $mode {

    # Proxy mode (default)
    'proxy': {
      validate_string($discovery_srv_record)
      if ($discovery_srv_record == '') {
        fail('Invalid discovery srv record, please set it in manifest')
      }
    }

    # Cluster mode
    'cluster': {
      case $discovery {
        # Use DNS SRV record
        'dns': {
          validate_string($discovery_srv_record)
          if ($discovery_srv_record == '') {
            fail('Invalid discovery srv record specified')
          }
          $use_dns_discovery = true
        }
        # Static cluster
        'initial-cluster': {
          validate_array($initial_cluster)
          $use_static_discover = true
        }
        # Default, discovery url (public and custom)
        'url': {
          validate_string($discovery_endpoint)
          if ($discovery_endpoint == '') {
            fail('Invalid discovery endpoint specified')
          }
          $use_url_discovery = true
        }
        default: {}
      }
    }
    default: { fail('No mode set') }
  }

  # Validate other params
  validate_bool($manage_user)
  validate_bool($manage_data_dir)
  validate_bool($manage_service_file)

  anchor { 'etcd::begin': } ->
  class { '::etcd::install': } ->
  class { '::etcd::config': } ~>
  class { '::etcd::service': } ->
  anchor { 'etcd::end': }
}
