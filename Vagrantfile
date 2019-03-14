
common_vars = {
  'master1' => {
    'box_name' => 'ubuntu/bionic64',
    'cpus' => 2,
    'memory' => 2048,
    'public_ip' => '192.168.0.17',
    'provision_script' => './scripts/master.sh',
    'kub_admin_user' => 'asadmin',
    'kub_admin_pass' => 'east',
    'kub_admin_group' => 'asadmin'
  },
  'node1' => {
    'box_name' => 'ubuntu/bionic64',
    'cpus' => 2,
    'memory' => 2048,
    'public_ip' => '192.168.0.18',
    'provision_script' => './scripts/node.sh',
    'kub_admin_user' => 'asadmin',
      'kub_admin_pass' => 'east',
    'kub_admin_group' => 'asadmin'
  }
}

Vagrant.configure(2) do |config|
  %w(master1 node1).each do |environment_basebox_name|
  # %w(control1 control2 worker1 worker2).each do |environment_basebox_name|
    config.vm.define environment_basebox_name do |v|
      v.vm.provider "virtualbox" do |p|
        p.gui = false
        p.cpus = "#{ common_vars[environment_basebox_name]['cpus'] }"
        p.memory = "#{ common_vars[environment_basebox_name]['memory'] }"
        p.name = environment_basebox_name
      end
      v.ssh.insert_key = false
      v.ssh.pty = false

      v.vm.box = "#{ common_vars[environment_basebox_name]['box_name'] }"
      v.vm.box_check_update = false

      v.vm.synced_folder ".", "/vagrant"
      v.vm.hostname = "#{environment_basebox_name}.my.local"

      v.vm.network "public_network", ip: "#{ common_vars[environment_basebox_name]['public_ip'] }", bridge: [
       "enp0s31f6",
       "en0: Wi-Fi (Wireless)"
      ]
      # You can generate key and log in without password
      # v.vm.provision "file", source: "kubadmin.pub", destination: "/tmp/kubadmin.pub"

      v.vm.provision "shell" do |s|
        s.name = "#{ common_vars[environment_basebox_name]['provision_script'] }"
        s.path = "#{ common_vars[environment_basebox_name]['provision_script'] }"
        s.privileged = true
        s.env = common_vars[environment_basebox_name]
      end

      v.vm.post_up_message = "VM -> #{environment_basebox_name} <- is ready !!!"
    end
  end
end
