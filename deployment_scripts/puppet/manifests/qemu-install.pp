$fuel_settings = parseyaml(file('/etc/compute.yaml'))
$qemu_version = "1:2.4+dfsg-4ubuntu1"
if $operatingsystem == 'Ubuntu' {
        if $fuel_settings['fuel-plugin-qemu']['use_kvm'] {
                package { 'linux-headers-4.1.10-rt10nfv':
                        ensure => "1.0.OPNFV",
                } ->
                package { 'linux-image-4.1.10-rt10nfv':
                        ensure => "1.0.OPNFV",
                } ->
                exec {'reboot':
                       command => "reboot",
                       path   => "/usr/bin:/usr/sbin:/bin:/sbin",
                }
        } else {
                package { 'qemu-block-extra':
                        ensure => "${qemu_version}",
                }
                package { 'qemu-utils':
                        ensure => "${qemu_version}",
                }
                package { 'qemu-system-common':
                        ensure => "${qemu_version}",
                }
                package { 'qemu-system-arm':
                        ensure => "${qemu_version}",
                }
                package { 'qemu-system-mips':
                        ensure => "${qemu_version}",
                }
                package { 'qemu-system-misc':
                        ensure => "${qemu_version}",
                }
                package { 'qemu-system-sparc':
                        ensure => "${qemu_version}",
                }
                package { 'qemu-system-x86':
                        ensure => "${qemu_version}",
                }
                package { 'qemu-system-ppc':
                        ensure => "${qemu_version}",
                }
                package { 'qemu-user':
                        ensure => "${qemu_version}",
                }
                package { 'qemu-system':
                        ensure => "${qemu_version}",
                }
                package { 'qemu':
                        ensure => "${qemu_version}",
                }
        }
} elsif $operatingsystem == 'CentOS' {
}
