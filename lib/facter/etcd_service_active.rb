Facter.add('etcd_service_active') do
  confine :kernel => 'Linux'
  setcode do

    output = Facter::Util::Resolution.exec('/bin/systemctl is-active etcd.service 2>/dev/null')

    output == 'active' ? true : false

  end
end
