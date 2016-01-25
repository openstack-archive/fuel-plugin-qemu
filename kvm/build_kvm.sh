#!/bin/bash

KVM_COMMIT=""
OVS_COMMIT=""
for i
do
	case $i in

	-c)	KVM_COMMIT=$2
		shift;shift
		;;

	-o)	OVS_COMMIT=$2
		shift;shift
		;;

	esac
done

SRC=${1:-/root}
CONFIG=${2:-arch/x86/configs/opnfv.config}
VERSION=${3:-1.0.OPNFV}

# Check for necessary build tools
if ! type git >/dev/null 2>/dev/null
then
	echo "Build tools missing, run the command

apt-get install git fakeroot build-essential ncurses-dev xz-utils kernel-package

as root and try again"
	exit 1
fi

# Make sure the source dir exists
if [ ! -d $SRC ]
then
	echo "$SRC: no such directory"
	exit 1
fi

(
	cd $SRC

	# Get the Open VSwitch sources
	if [ ! -d ovs ]
	then
		git clone https://github.com/openvswitch/ovs.git
	fi

	# Get the KVM for NFV kernel sources
	if [ ! -d kvmfornfv ]
	then
		git clone https://gerrit.opnfv.org/gerrit/kvmfornfv
	fi
	cd kvmfornfv
	git pull
	if [ x$KVM_COMMIT != x ]
	then
		git checkout $KVM_COMMIT
	else
		git reset --hard
	fi
	cd kernel

	# Workaround build bug on Ubuntu 14.04
	cat <<EOF > arch/x86/boot/install.sh
#!/bin/sh
cp -a -- "\$2" "\$4/vmlinuz-\$1"
EOF

	# Configure the kernel
	cp $CONFIG .config
	echo "CONFIG_DM_CRYPT=m" >>.config
	echo "CONFIG_DM_MULTIPATH=m" >>.config
	echo "CONFIG_NET_IPGRE=m" >>.config
	echo "CONFIG_NET_IPGRE_DEMUX=m" >>.config
	echo "CONFIG_BONDING=m" >>.config
	echo "CONFIG_VLAN_8021Q=m" >>.config
	echo "CONFIG_NETFILTER_XTABLES=m" >>.config
	echo "CONFIG_NF_TABLES_BRIDGE=m" >>.config
	echo "CONFIG_NF_TABLES_IPV6=m" >>.config
	echo "CONFIG_NF_TABLES=m" >>.config
	echo "CONFIG_NF_DEFRAG_IPV4=m" >>.config
	echo "CONFIG_NF_CONNTRACK_IPV4=m" >>.config
	echo "CONFIG_NF_TABLES_IPV4=m" >>.config
	echo "CONFIG_NFT_REJECT_IPV4=m" >>.config
	echo "CONFIG_NFT_CHAIN_ROUTE_IPV4=m" >>.config
	echo "CONFIG_NFT_CHAIN_NAT_IPV4=m" >>.config
	echo "CONFIG_NF_TABLES_ARP=m" >>.config
	echo "CONFIG_IP_NF_IPTABLES=m" >>.config
	echo "CONFIG_IP_NF_MATCH_AH=m" >>.config
	echo "CONFIG_IP_NF_MATCH_ECN=m" >>.config
	echo "CONFIG_IP_NF_MATCH_RPFILTER=m" >>.config
	echo "CONFIG_IP_NF_MATCH_TTL=m" >>.config
	echo "CONFIG_IP_NF_FILTER=m" >>.config
	echo "CONFIG_IP_NF_TARGET_REJECT=m" >>.config
	echo "CONFIG_IP_NF_TARGET_SYNPROXY=m" >>.config
	echo "CONFIG_IP_NF_TARGET_ULOG=m" >>.config
	echo "CONFIG_NF_NAT_IPV4=m" >>.config
	echo "CONFIG_IP_NF_TARGET_MASQUERADE=m" >>.config
	echo "CONFIG_IP_NF_TARGET_NETMAP=m" >>.config
	echo "CONFIG_IP_NF_TARGET_REDIRECT=m" >>.config
	echo "CONFIG_NF_NAT_SNMP_BASIC=m" >>.config
	echo "CONFIG_NF_NAT_PROTO_GRE=m" >>.config
	echo "CONFIG_NF_NAT_PPTP=m" >>.config
	echo "CONFIG_NF_NAT_H323=m" >>.config
	echo "CONFIG_IP_NF_MANGLE=m" >>.config
	echo "CONFIG_IP_NF_TARGET_CLUSTERIP=m" >>.config
	echo "CONFIG_IP_NF_TARGET_ECN=m" >>.config
	echo "CONFIG_IP_NF_TARGET_TTL=m" >>.config
	echo "CONFIG_IP_NF_RAW=m" >>.config
	echo "CONFIG_IP_NF_SECURITY=m" >>.config
	echo "CONFIG_IP_NF_ARPTABLES=m" >>.config
	echo "CONFIG_IP_NF_ARPFILTER=m" >>.config
	echo "CONFIG_IP_NF_ARP_MANGLE=m" >>.config
	echo "CONFIG_NETFILTER_XT_CONNMARK=m" >>.config
	echo "CONFIG_NETFILTER_XT_SET=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_AUDIT=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_CHECKSUM=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_CONNMARK=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_CT=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_DSCP=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_HL=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_HMARK=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_IDLETIMER=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_LED=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_LOG=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_MARK=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_NETMAP=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_NFLOG=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_NOTRACK=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_RATEEST=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_REDIRECT=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_TEE=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_TPROXY=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_TRACE=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_SECMARK=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_TCPMSS=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_BPF=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_CLUSTER=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_COMMENT=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_CONNLABEL=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_CONNMARK=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_CPU=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_DCCP=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_DEVGROUP=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_DSCP=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_ECN=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_ESP=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_HELPER=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_HL=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_IPRANGE=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_IPVS=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_LENGTH=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_LIMIT=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_MAC=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_MARK=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_NFACCT=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_OSF=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_OWNER=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_POLICY=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_QUOTA=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_RATEEST=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_REALM=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_RECENT=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_SCTP=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_SOCKET=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_STATE=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_STATISTIC=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_STRING=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_TCPMSS=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_TIME=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_U32=m" >>.config
	echo "CONFIG_IP_SET=m" >>.config
	echo "CONFIG_IP_SET_MAX=256" >>.config
	echo "CONFIG_IP_SET_BITMAP_IP=m" >>.config
	echo "CONFIG_IP_SET_BITMAP_IPMAC=m" >>.config
	echo "CONFIG_IP_SET_BITMAP_PORT=m" >>.config
	echo "CONFIG_IP_SET_HASH_IP=m" >>.config
	echo "CONFIG_IP_SET_HASH_IPPORT=m" >>.config
	echo "CONFIG_IP_SET_HASH_IPPORTIP=m" >>.config
	echo "CONFIG_IP_SET_HASH_IPPORTNET=m" >>.config
	echo "CONFIG_IP_SET_HASH_NETPORTNET=m" >>.config
	echo "CONFIG_IP_SET_HASH_NET=m" >>.config
	echo "CONFIG_IP_SET_HASH_NETNET=m" >>.config
	echo "CONFIG_IP_SET_HASH_NETPORT=m" >>.config
	echo "CONFIG_IP_SET_HASH_NETIFACE=m" >>.config
	echo "CONFIG_IP_SET_LIST_SET=m" >>.config
	echo "CONFIG_IP_VS=m" >>.config
	echo "CONFIG_IP_VS_IPV6=y" >>.config
	echo "CONFIG_IP_VS_TAB_BITS=12" >>.config

	make oldconfig </dev/null

	# Build the kernel debs
	make-kpkg clean
	fakeroot make-kpkg --initrd --revision=$VERSION kernel_image kernel_headers
	git checkout arch/x86/boot/install.sh

	# Build OVS kernel modules
	cd ../../ovs
	if [ x$OVS_COMMIT != x ]
	then
		git checkout $OVS_COMMIT
	else
		git reset --hard
	fi
	./boot.sh
	./configure --with-linux=$SRC/kvmfornfv/kernel
	make

	# Add OVS kernel modules to kernel deb
	dpkg-deb -x $SRC/kvmfornfv/linux-image*.deb ovs.$$
	dpkg-deb --control $SRC/kvmfornfv/linux-image*.deb ovs.$$/DEBIAN
	cp datapath/linux/*.ko ovs.$$/lib/modules/*/kernel/net/openvswitch
	depmod -b ovs.$$ -a `ls ovs.$$/lib/modules`
	dpkg-deb -b ovs.$$ $SRC/kvmfornfv/linux-image*.deb
	rm -rf ovs.$$
)

mv $SRC/kvmfornfv/*.deb .
