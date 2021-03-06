class salt::master(
    $salt_interface = undef,
    $salt_worker_threads = undef,
    $salt_runner_dirs = '/srv/runners',
    $salt_file_roots = '/srv/salt',
    $salt_pillar_roots = '/srv/pillar',
    $salt_ext_pillar = {},
    $salt_reactor_root = '/srv/reactors',
    $salt_reactor = {},
    $salt_auto_accept = false,
    $salt_peer = {},
    $salt_peer_run = {},
    $salt_nodegroups = {},
    $salt_state_roots = '/srv/salt',
    $salt_module_roots = '/srv/salt/_modules',
    $salt_returner_roots = '/srv/salt/_returners',
) {
    package { 'salt-master':
        ensure => 'installed',
    }

    service { 'salt-master':
        ensure  => running,
        enable  => true,
        require => Package['salt-master'],
    }

    file { '/etc/salt/master':
        content => template('salt/master.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        notify  => Service['salt-master'],
        require => Package['salt-master'],
    }

    file { $salt_runner_dirs:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file { "${salt_runner_dirs}/keys.py":
        ensure => present,
        source => 'puppet:///modules/salt/keys.py',
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file { $salt_reactor_root:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }


    # this also is the same as $salt_state_roots
    file { $salt_file_roots:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file { $salt_pillar_roots:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file { $salt_module_roots:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file { $salt_returner_roots:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    sysctl::parameters { 'salt-master':
        values => {
            'net.core.somaxconn'          => 4096,
            'net.core.netdev_max_backlog' => 4096,
            'net.ipv4.tcp_mem'            => '16777216 16777216 16777216',
        }
    }

    # Reducing permissions on the master cache, by default is 0755
    file { '/var/cache/salt/master':
        ensure => directory,
        mode   => '0750',
        owner  => 'root',
        group  => 'root',
    }
}