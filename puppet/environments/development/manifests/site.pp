
node jerry {
  notify { "env": message => "ENVIRONMENT=development" }  

  ### MySQL ###
  class { '::mysql::server':
    config_hash	=> { 'root_password' => 'SRVPW',
                     'bind_address' => '0.0.0.0' }
  }

  ### RabbitMQ ###
  class { 'rabbitmq::server':
    port              => '5672',
    delete_guest_user => false,
   }

  exec { 'set guest pw':
    command	=> "rabbitmqctl change_password guest SRVPW",
    path	=> ["/usr/sbin", "/bin", "/usr/bin"],
    user	=> "root",
    require	=> Class['rabbitmq::server'],
  }

 ### KEYSTONE ###
  class { 'keystone':
    verbose        => True,
    catalog_type   => 'sql',
    admin_token    => 'random_uuid',
    sql_connection => 'mysql://keystone:SRVPW@127.0.0.1/keystone',
  }

  # Adds the admin credential to keystone.
  class { 'keystone::roles::admin':
    email        => 'geirtufte@gmail.com',
    password     => 'SRVPW',
  }

  # Installs the service user endpoint.
  class { 'keystone::endpoint':
    public_address   => '127.0.0.1',
    admin_address    => '127.0.0.1',
    internal_address => '127.0.0.1',
    region           => 'regionOne',
    public_url       => "http://127.0.0.1:8774/v2/%(tenant_id)s",
    admin_url        => "http://127.0.0.1:8774/v2/%(tenant_id)s",
    internal_url     => "http://127.0.0.1:8774/v2/%(tenant_id)s",
  }

  class { 'keystone::db::mysql':
    password      => 'SRVPW',
    allowed_hosts => '%',
  }

  ### GLANCE ###
  class { 'glance::api':
    verbose           => true,
    keystone_tenant   => 'services',
    keystone_user     => 'glance',
    keystone_password => 'SRVPW',
    sql_connection    => 'mysql://glance:SRVPW@127.0.0.1/glance',
  }

  class { 'glance::registry':
    verbose           => true,
    keystone_tenant   => 'services',
    keystone_user     => 'glance',
    keystone_password => 'SRVPW',
    sql_connection    => 'mysql://glance:SRVPW@127.0.0.1/glance',
  }

  class { 'glance::backend::file': }
  
  class { 'glance::db::mysql':
    password      => 'SRVPW',
    allowed_hosts => '%',
  }
  class { 'glance::keystone::auth':
    password         => 'SRVPW',
    email            => 'geirtufte@gmail.com',
    public_address   => '127.0.0.1',
    admin_address    => '127.0.0.1',
    internal_address => '127.0.0.1',
    region           => 'regionOne',
  }

 ##### NOVA    #####

#### NOVA MYSQL DB ####
# Configure a MySQL database for Nova
  class { 'nova::db::mysql':
    user          => 'nova',
    password      => 'SRVPW',
    dbname        => 'nova',
    allowed_hosts => '%',
  }

# Install and configure Nova
  class { 'nova':
    sql_connection     => 'mysql://nova:SRVPW@127.0.0.1/nova',
    rabbit_userid      => 'guest',
    rabbit_password    => 'SRVPW',
    rabbit_host        => '127.0.0.1',
  }

# Install and configure nova-api
  class { 'nova::api':
    enabled        => true,
    admin_password => 'SRVPW',
  }

# Configure various nova subcomponents
  class { 'nova::scheduler': enabled => true }
  class { 'nova::objectstore': enabled => true }
  class { 'nova::cert': enabled => true }
  class { 'nova::vncproxy': enabled => true }
  class { 'nova::consoleauth': enabled => true }

# Configure nova-network
  class { 'nova::network': 
    enabled            => true,
    network_manager    => 'nova.network.manager.VlanManager',
    private_interface  => eth1,
    public_interface   => eth0,
    fixed_range        => '10.0.0.0/8',
    num_networks       => '255',
    config_overrides => {
      vlan_start => '2000',
    }
  }

  # Configure Keystone for Nova
    class { 'nova::keystone::auth':
      password => 'SRVPW',
  }

  Class['mysql::server'] -> Class['nova']
  
 ##### Neutron #####

  class { 'neutron::db::mysql':
    password      => 'SRVPW',
    allowed_hosts => '%',
  }

 # enable the neutron service
  class { '::neutron':
    enabled         => true,
    bind_host       => '0.0.0.0',
    rabbit_host     => '10.0.0.1',
    rabbit_user     => 'guest',
    rabbit_password => 'SRVPW',
    verbose         => false,
    debug           => false,
  }

 # configure authentication
  class { 'neutron::server':
    auth_host       => '10.0.0.1', # the keystone host address
    auth_password   => 'SRVPW',
    sql_connection  => 'mysql://neutron:SRVPW@10.0.0.1/neutron',
  }

 # enable the Open VSwitch plugin server
  class { 'neutron::plugins::ovs':
    tenant_network_type => 'vlan',
    network_vlan_ranges => 'physnet:2000:2999',
  }

  ### HORIZON ###
  class { 'memcached':
    listen_ip => '127.0.0.1',
    tcp_port  => '11211',
    udp_port  => '11211',
  }

  class { '::horizon':
    cache_server_ip     => '127.0.0.1',
    cache_server_port   => '11211',
    secret_key         => '12345',
    swift               => false,
    django_debug        => 'True',
    api_result_limit    => '2000',
  }
}

node bania {
  notify { "env": message => "ENVIRONMENT=development" }
 # enable the neutron service
  class { '::neutron':
    enabled         => true,
    bind_host       => '0.0.0.0',
    rabbit_host     => '10.0.0.1',
    rabbit_user     => 'guest',
    rabbit_password => 'SRVPW',
    verbose         => false,
    debug           => false,
  }

  # configure authentication
  class { 'neutron::server':
    auth_host       => '10.0.0.1', # the keystone host address
    auth_password   => 'SRVPW',
    sql_connection  => 'mysql://neutron:SRVPW@10.0.0.1/neutron',
  }

  # enable the Open VSwitch plugin server
  class { 'neutron::plugins::ovs':
    tenant_network_type => 'vlan',
    network_vlan_ranges => 'physnet:2000:2999',
  }
}

node nostrand {
  notify { "env": message => "ENVIRONMENT=development" }
  class { 'nova':
    database_connection => 'mysql://nova:SRVPW@10.0.0.1/nova',
    rabbit_userid       => 'guest',
    rabbit_password     => 'SRVPW',
    image_service       => 'nova.image.glance.GlanceImageService',
    glance_api_servers  => '10.0.0.1:9292',
    verbose             => false,
    rabbit_host         => '10.0.0.1',
  }

  class { 'nova::compute':
    enabled                       => true,
    vnc_enabled                   => true,
  }
  class { 'nova::conductor':
    enabled        => true,
    ensure_package => 'present'
  }


  class { 'nova::compute::libvirt':
    vncserver_listen  => '0.0.0.0',
    migration_support => true,
  }
}
