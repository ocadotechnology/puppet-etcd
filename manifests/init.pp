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
  String                                          $binary_location             = $etcd::params::etcd_binary_location,

  Enum['stopped', 'running']                      $service_ensure              = $etcd::params::etcd_service_ensure,
  Boolean                                         $service_enable              = $etcd::params::etcd_service_enable,
  Boolean                                         $manage_service_file         = $etcd::params::etcd_manage_service_file,

  String                                          $package_ensure              = $etcd::params::etcd_package_ensure,
  String                                          $package_name                = $etcd::params::etcd_package_name,

  Boolean                                         $manage_user                 = $etcd::params::etcd_manage_user,
  String                                          $user                        = $etcd::params::etcd_user,
  String                                          $group                       = $etcd::params::etcd_group,

  Boolean                                         $manage_log_dir              = $etcd::params::etcd_manage_log_dir,
  String                                          $data_dir                    = $etcd::params::etcd_data_dir,

  Boolean                                         $manage_data_dir             = $etcd::params::etcd_manage_data_dir,
  String                                          $log_dir                     = $etcd::params::etcd_log_dir,

  String                                          $node_name                   = $etcd::params::etcd_node_name,
  Array                                           $listen_peer_url             = $etcd::params::etcd_listen_peer_url,
  Array                                           $listen_client_url           = $etcd::params::etcd_listen_client_url,
  String                                          $election_timeout            = $etcd::params::etcd_election_timeout,
  String                                          $heartbeat_interval          = $etcd::params::etcd_heartbeat_interval,
  String                                          $snapshot_count              = $etcd::params::etcd_snapshot_count,
  String                                          $max_snapshots               = $etcd::params::etcd_max_snapshots,
  String                                          $max_wals                    = $etcd::params::etcd_max_wals,
  Array                                           $cors                        = $etcd::params::etcd_cors,

  Array                                           $initial_advertise_peer_urls = $etcd::params::etcd_initial_advertise_peer_urls,
  Array                                           $initial_cluster             = $etcd::params::etcd_initial_cluster,
  String                                          $initial_cluster_state       = $etcd::params::etcd_initial_cluster_state,
  String                                          $initial_cluster_token       = $etcd::params::etcd_initial_cluster_token,
  Array                                           $advertise_client_urls       = $etcd::params::etcd_advertise_client_urls,

  Enum['none', 'dns', 'initial-cluster', 'url']   $discovery                   = $etcd::params::etcd_discovery,
  String                                          $discovery_endpoint          = $etcd::params::etcd_discovery_endpoint,
  String                                          $discovery_srv_record        = $etcd::params::etcd_discovery_srv_record,
  String                                          $discovery_fallback          = $etcd::params::etcd_discovery_fallback,
  String                                          $discovery_proxy             = $etcd::params::etcd_discovery_proxy,

  Enum['cluster', 'proxy', 'gateway']             $mode                        = $etcd::params::etcd_mode,

  String                                          $peer_ca_file                = $etcd::params::etcd_peer_ca_file,
  String                                          $peer_cert_file              = $etcd::params::etcd_peer_cert_file,
  String                                          $peer_key_file               = $etcd::params::etcd_peer_key_file

  Optional[String]                                $gateway_endpoints           = $etcd::params::gateway_endpoints,
  String                                          $gateway_listen_addr         = $etcd::params::gateway_listen_addr,

) inherits etcd::params {


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

  $proxy = $mode ? {
    'proxy'   => 'on',
    'cluster' => 'off',
    default   => 'NA',
  }

  # etcd cluster and the gateway are mutually exclused for our purposes #
  if $mode == 'gateway' {
    $service_class = '::etcd::gateway'
  } else {
    $service_class = '::etcd::service'
  }

  anchor { 'etcd::begin': } ->
  class { '::etcd::install': } ->
  class { '::etcd::config': } ~>
  class { "${service_class}": } ->
  anchor { 'etcd::end': }
}
