$qemu_version = "1:2.4+dfsg-4ubuntu1"
if $operatingsystem == 'Ubuntu' {
        package { 'qemu-block-extra':
                ensure => "${qemu_version}",
        }
        package { 'qemu-utils':
                ensure => "${qemu_version}",
                require => Package['qemu-block-extra'],
        }
        package { 'qemu-system':
                ensure => "${qemu_version}",
        }
        package { 'qemu-user':
                ensure => "${qemu_version}",
        }
	package { 'qemu':
		ensure => "${qemu_version}",
                require => Package['qemu-utils','qemu-system','qemu-user'],
	}
} elsif $operatingsystem == 'CentOS' {
	package { 'qemu':
		ensure => "2.4.0.1-1",
	}
}
