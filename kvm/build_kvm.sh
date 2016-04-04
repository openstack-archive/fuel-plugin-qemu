#!/bin/bash

quirks() {
	# Workaround build bug on Ubuntu 14.04
	cat <<EOF > arch/x86/boot/install.sh
#!/bin/sh
cp -a -- "\$2" "\$4/vmlinuz-\$1"
EOF

	# Add deprecated XFS delaylog option back in
	cat <<EOF | patch -p2
diff --git a/kernel/fs/xfs/xfs_super.c b/kernel/fs/xfs/xfs_super.c
index 65a4537..b73ca67 100644
--- a/kernel/fs/xfs/xfs_super.c
+++ b/kernel/fs/xfs/xfs_super.c
@@ -109,6 +109,7 @@ static struct xfs_kobj xfs_dbg_kobj;	/* global debug sysfs attrs */
 #define MNTOPT_GQUOTANOENF "gqnoenforce"/* group quota limit enforcement */
 #define MNTOPT_PQUOTANOENF "pqnoenforce"/* project quota limit enforcement */
 #define MNTOPT_QUOTANOENF  "qnoenforce"	/* same as uqnoenforce */
+#define MNTOPT_DELAYLOG    "delaylog"	/* Delayed logging enabled */
 #define MNTOPT_DISCARD	   "discard"	/* Discard unused blocks */
 #define MNTOPT_NODISCARD   "nodiscard"	/* Do not discard unused blocks */
 
@@ -359,6 +360,9 @@ xfs_parseargs(
 		} else if (!strcmp(this_char, MNTOPT_GQUOTANOENF)) {
 			mp->m_qflags |= (XFS_GQUOTA_ACCT | XFS_GQUOTA_ACTIVE);
 			mp->m_qflags &= ~XFS_GQUOTA_ENFD;
+		} else if (!strcmp(this_char, MNTOPT_DELAYLOG)) {
+			xfs_warn(mp,
+		"delaylog is the default now, option is deprecated.");
 		} else if (!strcmp(this_char, MNTOPT_DISCARD)) {
 			mp->m_flags |= XFS_MOUNT_DISCARD;
 		} else if (!strcmp(this_char, MNTOPT_NODISCARD)) {
-- 
1.9.1

EOF
}

KVM_COMMIT=""
OVS_COMMIT=""
KEEP=no
for i
do
	case $i in

	-k)	KEEP=yes
		shift
		;;

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

apt-get install git fakeroot build-essential ncurses-dev xz-utils kernel-package automake

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

	quirks

	# Configure the kernel
	cp $CONFIG .config
	echo "CONFIG_AUDIT=y" >>.config
	echo "CONFIG_AUDITSYSCALL=y" >>.config
	echo "CONFIG_AUDIT_WATCH=y" >>.config
	echo "CONFIG_AUDIT_TREE=y" >>.config
	echo "CONFIG_ACPI_PROCESSOR_AGGREGATOR=m" >>.config
	echo "CONFIG_HOTPLUG_PCI_SHPC=m" >>.config
	echo "CONFIG_NET_IPGRE_DEMUX=m" >>.config
	echo "CONFIG_NET_IPGRE=m" >>.config
	echo "CONFIG_NET_IPGRE_BROADCAST=y" >>.config
	echo "CONFIG_NET_FOU=m" >>.config
	echo "CONFIG_NET_FOU_IP_TUNNELS=y" >>.config
	echo "CONFIG_NETFILTER_ADVANCED=y" >>.config
	echo "CONFIG_BRIDGE_NETFILTER=y" >>.config
	echo "# CONFIG_NETFILTER_NETLINK_ACCT is not set" >>.config
	echo "# CONFIG_NETFILTER_NETLINK_QUEUE is not set" >>.config
	echo "# CONFIG_NF_CONNTRACK_MARK is not set" >>.config
	echo "CONFIG_NF_CONNTRACK_ZONES=y" >>.config
	echo "# CONFIG_NF_CONNTRACK_EVENTS is not set" >>.config
	echo "# CONFIG_NF_CONNTRACK_TIMEOUT is not set" >>.config
	echo "# CONFIG_NF_CONNTRACK_TIMESTAMP is not set" >>.config
	echo "# CONFIG_NF_CT_PROTO_DCCP is not set" >>.config
	echo "CONFIG_NF_CT_PROTO_GRE=m" >>.config
	echo "# CONFIG_NF_CT_PROTO_SCTP is not set" >>.config
	echo "# CONFIG_NF_CT_PROTO_UDPLITE is not set" >>.config
	echo "# CONFIG_NF_CONNTRACK_AMANDA is not set" >>.config
	echo "# CONFIG_NF_CONNTRACK_H323 is not set" >>.config
	echo "# CONFIG_NF_CONNTRACK_SNMP is not set" >>.config
	echo "CONFIG_NF_CONNTRACK_PPTP=m" >>.config
	echo "# CONFIG_NF_CONNTRACK_SANE is not set" >>.config
	echo "# CONFIG_NF_CONNTRACK_TFTP is not set" >>.config
	echo "# CONFIG_NF_CT_NETLINK_TIMEOUT is not set" >>.config
	echo "CONFIG_NF_NAT_REDIRECT=m" >>.config
	echo "CONFIG_NF_TABLES=m" >>.config
	echo "CONFIG_NF_TABLES_INET=m" >>.config
	echo "CONFIG_NFT_EXTHDR=m" >>.config
	echo "CONFIG_NFT_META=m" >>.config
	echo "CONFIG_NFT_CT=m" >>.config
	echo "CONFIG_NFT_RBTREE=m" >>.config
	echo "CONFIG_NFT_HASH=m" >>.config
	echo "CONFIG_NFT_COUNTER=m" >>.config
	echo "CONFIG_NFT_LOG=m" >>.config
	echo "CONFIG_NFT_LIMIT=m" >>.config
	echo "CONFIG_NFT_MASQ=m" >>.config
	echo "CONFIG_NFT_REDIR=m" >>.config
	echo "CONFIG_NFT_NAT=m" >>.config
	echo "CONFIG_NFT_REJECT=m" >>.config
	echo "CONFIG_NFT_REJECT_INET=m" >>.config
	echo "CONFIG_NFT_COMPAT=m" >>.config
	echo "CONFIG_NETFILTER_XTABLES=m" >>.config
	echo "# CONFIG_NETFILTER_XT_CONNMARK is not set" >>.config
	echo "CONFIG_NETFILTER_XT_SET=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_AUDIT=m" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_CHECKSUM is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_CLASSIFY is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_CONNMARK is not set" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_CT=m" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_DSCP is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_HL is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_HMARK is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_IDLETIMER is not set" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_LED=m" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_MARK is not set" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_NETMAP=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_NFLOG=m" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_NFQUEUE is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_NOTRACK is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_RATEEST is not set" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_REDIRECT=m" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_TEE is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_TPROXY is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_TRACE is not set" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_SECMARK=m" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_TCPMSS=m" >>.config
	echo "# CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_BPF is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_CGROUP is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_CLUSTER is not set" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_COMMENT=m" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_CONNBYTES is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_CONNLABEL is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_CONNLIMIT is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_CONNMARK is not set" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_CPU is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_DCCP is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_DEVGROUP is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_DSCP is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_ECN is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_ESP is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_HASHLIMIT is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_HELPER is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_HL is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_IPCOMP is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_IPRANGE is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_IPVS is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_L2TP is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_LENGTH is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_LIMIT is not set" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_MAC=m" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_MARK is not set" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_NFACCT is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_OSF is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_OWNER is not set" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_POLICY=m" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_PKTTYPE is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_QUOTA is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_RATEEST is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_REALM is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_RECENT is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_SCTP is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_SOCKET is not set" >>.config
	echo "CONFIG_NETFILTER_XT_MATCH_STATE=m" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_STATISTIC is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_STRING is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_TCPMSS is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_TIME is not set" >>.config
	echo "# CONFIG_NETFILTER_XT_MATCH_U32 is not set" >>.config
	echo "CONFIG_IP_SET=m" >>.config
	echo "CONFIG_IP_SET_MAX=256" >>.config
	echo "CONFIG_IP_SET_BITMAP_IP=m" >>.config
	echo "CONFIG_IP_SET_BITMAP_IPMAC=m" >>.config
	echo "CONFIG_IP_SET_BITMAP_PORT=m" >>.config
	echo "CONFIG_IP_SET_HASH_IP=m" >>.config
	echo "CONFIG_IP_SET_HASH_IPMARK=m" >>.config
	echo "CONFIG_IP_SET_HASH_IPPORT=m" >>.config
	echo "CONFIG_IP_SET_HASH_IPPORTIP=m" >>.config
	echo "CONFIG_IP_SET_HASH_IPPORTNET=m" >>.config
	echo "CONFIG_IP_SET_HASH_MAC=m" >>.config
	echo "CONFIG_IP_SET_HASH_NETPORTNET=m" >>.config
	echo "CONFIG_IP_SET_HASH_NET=m" >>.config
	echo "CONFIG_IP_SET_HASH_NETNET=m" >>.config
	echo "CONFIG_IP_SET_HASH_NETPORT=m" >>.config
	echo "CONFIG_IP_SET_HASH_NETIFACE=m" >>.config
	echo "CONFIG_IP_SET_LIST_SET=m" >>.config
	echo "CONFIG_IP_VS=m" >>.config
	echo "CONFIG_IP_VS_IPV6=y" >>.config
	echo "# CONFIG_IP_VS_DEBUG is not set" >>.config
	echo "CONFIG_IP_VS_TAB_BITS=12" >>.config
	echo "CONFIG_IP_VS_PROTO_TCP=y" >>.config
	echo "CONFIG_IP_VS_PROTO_UDP=y" >>.config
	echo "CONFIG_IP_VS_PROTO_AH_ESP=y" >>.config
	echo "CONFIG_IP_VS_PROTO_ESP=y" >>.config
	echo "CONFIG_IP_VS_PROTO_AH=y" >>.config
	echo "CONFIG_IP_VS_PROTO_SCTP=y" >>.config
	echo "CONFIG_IP_VS_RR=m" >>.config
	echo "CONFIG_IP_VS_WRR=m" >>.config
	echo "CONFIG_IP_VS_LC=m" >>.config
	echo "CONFIG_IP_VS_WLC=m" >>.config
	echo "CONFIG_IP_VS_FO=m" >>.config
	echo "CONFIG_IP_VS_LBLC=m" >>.config
	echo "CONFIG_IP_VS_LBLCR=m" >>.config
	echo "CONFIG_IP_VS_DH=m" >>.config
	echo "CONFIG_IP_VS_SH=m" >>.config
	echo "CONFIG_IP_VS_SED=m" >>.config
	echo "CONFIG_IP_VS_NQ=m" >>.config
	echo "CONFIG_IP_VS_SH_TAB_BITS=8" >>.config
	echo "CONFIG_IP_VS_FTP=m" >>.config
	echo "CONFIG_IP_VS_NFCT=y" >>.config
	echo "CONFIG_IP_VS_PE_SIP=m" >>.config
	echo "CONFIG_NF_DEFRAG_IPV4=m" >>.config
	echo "CONFIG_NF_CONNTRACK_IPV4=m" >>.config
	echo "CONFIG_NF_TABLES_IPV4=m" >>.config
	echo "CONFIG_NFT_CHAIN_ROUTE_IPV4=m" >>.config
	echo "CONFIG_NFT_REJECT_IPV4=m" >>.config
	echo "CONFIG_NF_TABLES_ARP=m" >>.config
	echo "CONFIG_NFT_CHAIN_NAT_IPV4=m" >>.config
	echo "CONFIG_NFT_MASQ_IPV4=m" >>.config
	echo "CONFIG_NFT_REDIR_IPV4=m" >>.config
	echo "CONFIG_NF_NAT_PROTO_GRE=m" >>.config
	echo "CONFIG_NF_NAT_PPTP=m" >>.config
	echo "CONFIG_IP_NF_IPTABLES=m" >>.config
	echo "# CONFIG_IP_NF_MATCH_AH is not set" >>.config
	echo "# CONFIG_IP_NF_MATCH_ECN is not set" >>.config
	echo "# CONFIG_IP_NF_MATCH_RPFILTER is not set" >>.config
	echo "# CONFIG_IP_NF_MATCH_TTL is not set" >>.config
	echo "CONFIG_IP_NF_FILTER=m" >>.config
	echo "CONFIG_IP_NF_TARGET_REJECT=m" >>.config
	echo "# CONFIG_IP_NF_TARGET_SYNPROXY is not set" >>.config
	echo "# CONFIG_IP_NF_TARGET_NETMAP is not set" >>.config
	echo "# CONFIG_IP_NF_TARGET_REDIRECT is not set" >>.config
	echo "CONFIG_IP_NF_MANGLE=m" >>.config
	echo "# CONFIG_IP_NF_TARGET_CLUSTERIP is not set" >>.config
	echo "# CONFIG_IP_NF_TARGET_ECN is not set" >>.config
	echo "# CONFIG_IP_NF_TARGET_TTL is not set" >>.config
	echo "CONFIG_IP_NF_RAW=m" >>.config
	echo "# CONFIG_IP_NF_SECURITY is not set" >>.config
	echo "# CONFIG_IP_NF_ARPTABLES is not set" >>.config
	echo "CONFIG_NF_TABLES_IPV6=m" >>.config
	echo "CONFIG_NFT_CHAIN_ROUTE_IPV6=m" >>.config
	echo "CONFIG_NFT_REJECT_IPV6=m" >>.config
	echo "# CONFIG_NF_NAT_IPV6 is not set" >>.config
	echo "# CONFIG_IP6_NF_MATCH_AH is not set" >>.config
	echo "# CONFIG_IP6_NF_MATCH_EUI64 is not set" >>.config
	echo "# CONFIG_IP6_NF_MATCH_FRAG is not set" >>.config
	echo "# CONFIG_IP6_NF_MATCH_OPTS is not set" >>.config
	echo "# CONFIG_IP6_NF_MATCH_HL is not set" >>.config
	echo "# CONFIG_IP6_NF_MATCH_MH is not set" >>.config
	echo "# CONFIG_IP6_NF_MATCH_RPFILTER is not set" >>.config
	echo "# CONFIG_IP6_NF_MATCH_RT is not set" >>.config
	echo "# CONFIG_IP6_NF_TARGET_HL is not set" >>.config
	echo "# CONFIG_IP6_NF_TARGET_SYNPROXY is not set" >>.config
	echo "CONFIG_IP6_NF_RAW=m" >>.config
	echo "# CONFIG_IP6_NF_SECURITY is not set" >>.config
	echo "# CONFIG_IP6_NF_NAT is not set" >>.config
	echo "CONFIG_NF_TABLES_BRIDGE=m" >>.config
	echo "CONFIG_NFT_BRIDGE_META=m" >>.config
	echo "CONFIG_NFT_BRIDGE_REJECT=m" >>.config
	echo "CONFIG_NF_LOG_BRIDGE=m" >>.config
	echo "CONFIG_IP_SCTP=m" >>.config
	echo "CONFIG_NET_SCTPPROBE=m" >>.config
	echo "# CONFIG_SCTP_DBG_OBJCNT is not set" >>.config
	echo "# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set" >>.config
	echo "CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1=y" >>.config
	echo "# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set" >>.config
	echo "CONFIG_SCTP_COOKIE_HMAC_MD5=y" >>.config
	echo "CONFIG_SCTP_COOKIE_HMAC_SHA1=y" >>.config
	echo "CONFIG_GARP=m" >>.config
	echo "CONFIG_MRP=m" >>.config
	echo "CONFIG_BRIDGE_VLAN_FILTERING=y" >>.config
	echo "CONFIG_VLAN_8021Q=m" >>.config
	echo "CONFIG_VLAN_8021Q_GVRP=y" >>.config
	echo "CONFIG_VLAN_8021Q_MVRP=y" >>.config
	echo "CONFIG_NET_EMATCH_IPSET=m" >>.config
	echo "CONFIG_OPENVSWITCH_GRE=m" >>.config
	echo "CONFIG_MAC80211_LEDS=y" >>.config
	echo "CONFIG_RFKILL_LEDS=y" >>.config
	echo "CONFIG_REGMAP_I2C=m" >>.config
	echo "CONFIG_BLK_DEV_DRBD=m" >>.config
	echo "# CONFIG_DRBD_FAULT_INJECTION is not set" >>.config
	echo "CONFIG_BLK_DEV_NBD=m" >>.config
	echo "CONFIG_INTEL_MEI=m" >>.config
	echo "CONFIG_INTEL_MEI_ME=m" >>.config
	echo "# CONFIG_INTEL_MEI_TXE is not set" >>.config
	echo "CONFIG_SCSI_DH=m" >>.config
	echo "CONFIG_SCSI_DH_RDAC=m" >>.config
	echo "CONFIG_SCSI_DH_HP_SW=m" >>.config
	echo "CONFIG_SCSI_DH_EMC=m" >>.config
	echo "CONFIG_SCSI_DH_ALUA=m" >>.config
	echo "CONFIG_MD_LINEAR=m" >>.config
	echo "CONFIG_MD_RAID0=m" >>.config
	echo "CONFIG_MD_RAID1=m" >>.config
	echo "CONFIG_MD_RAID10=m" >>.config
	echo "CONFIG_MD_RAID456=m" >>.config
	echo "CONFIG_MD_MULTIPATH=m" >>.config
	echo "CONFIG_MD_FAULTY=m" >>.config
	echo "CONFIG_MD_CLUSTER=m" >>.config
	echo "CONFIG_DM_CRYPT=m" >>.config
	echo "CONFIG_DM_MULTIPATH=m" >>.config
	echo "CONFIG_DM_MULTIPATH_QL=m" >>.config
	echo "CONFIG_DM_MULTIPATH_ST=m" >>.config
	echo "CONFIG_BONDING=m" >>.config
	echo "CONFIG_MACVLAN=m" >>.config
	echo "CONFIG_MACVTAP=m" >>.config
	echo "CONFIG_VETH=m" >>.config
	echo "CONFIG_VHOST_NET=m" >>.config
	echo "CONFIG_VHOST_RING=m" >>.config
	echo "CONFIG_VHOST=m" >>.config
	echo "CONFIG_KS8842=m" >>.config
	echo "CONFIG_INPUT_SPARSEKMAP=m" >>.config
	echo "CONFIG_INPUT_JOYDEV=m" >>.config
	echo "CONFIG_KEYBOARD_LM8323=m" >>.config
	echo "CONFIG_INPUT_APANEL=m" >>.config
	echo "CONFIG_INPUT_IMS_PCU=m" >>.config
	echo "CONFIG_W1=m" >>.config
	echo "CONFIG_W1_CON=y" >>.config
	echo "CONFIG_W1_MASTER_MATROX=m" >>.config
	echo "CONFIG_W1_MASTER_DS2490=m" >>.config
	echo "CONFIG_W1_MASTER_DS2482=m" >>.config
	echo "CONFIG_W1_MASTER_DS1WM=m" >>.config
	echo "CONFIG_W1_SLAVE_THERM=m" >>.config
	echo "CONFIG_W1_SLAVE_SMEM=m" >>.config
	echo "CONFIG_W1_SLAVE_DS2408=m" >>.config
	echo "CONFIG_W1_SLAVE_DS2408_READBACK=y" >>.config
	echo "# CONFIG_W1_SLAVE_DS2413 is not set" >>.config
	echo "CONFIG_W1_SLAVE_DS2406=m" >>.config
	echo "CONFIG_W1_SLAVE_DS2423=m" >>.config
	echo "CONFIG_W1_SLAVE_DS2431=m" >>.config
	echo "CONFIG_W1_SLAVE_DS2433=m" >>.config
	echo "# CONFIG_W1_SLAVE_DS2433_CRC is not set" >>.config
	echo "CONFIG_W1_SLAVE_DS2760=m" >>.config
	echo "CONFIG_W1_SLAVE_DS2780=m" >>.config
	echo "CONFIG_W1_SLAVE_DS2781=m" >>.config
	echo "CONFIG_W1_SLAVE_DS28E04=m" >>.config
	echo "CONFIG_W1_SLAVE_BQ27000=m" >>.config
	echo "CONFIG_POWER_SUPPLY=y" >>.config
	echo "# CONFIG_POWER_SUPPLY_DEBUG is not set" >>.config
	echo "CONFIG_PDA_POWER=m" >>.config
	echo "# CONFIG_TEST_POWER is not set" >>.config
	echo "CONFIG_BATTERY_DS2760=m" >>.config
	echo "CONFIG_BATTERY_DS2780=m" >>.config
	echo "CONFIG_BATTERY_DS2781=m" >>.config
	echo "CONFIG_BATTERY_DS2782=m" >>.config
	echo "CONFIG_BATTERY_SBS=m" >>.config
	echo "CONFIG_BATTERY_BQ27x00=m" >>.config
	echo "CONFIG_BATTERY_BQ27X00_I2C=y" >>.config
	echo "CONFIG_BATTERY_BQ27X00_PLATFORM=y" >>.config
	echo "CONFIG_BATTERY_MAX17040=m" >>.config
	echo "CONFIG_BATTERY_MAX17042=m" >>.config
	echo "CONFIG_CHARGER_MAX8903=m" >>.config
	echo "CONFIG_CHARGER_LP8727=m" >>.config
	echo "CONFIG_CHARGER_BQ2415X=m" >>.config
	echo "CONFIG_CHARGER_SMB347=m" >>.config
	echo "CONFIG_BATTERY_GAUGE_LTC2941=m" >>.config
	echo "CONFIG_POWER_RESET=y" >>.config
	echo "CONFIG_POWER_RESET_RESTART=y" >>.config
	echo "CONFIG_SENSORS_CORETEMP=m" >>.config
	echo "CONFIG_SENSORS_ACPI_POWER=m" >>.config
	echo "CONFIG_INTEL_POWERCLAMP=m" >>.config
	echo "CONFIG_WATCHDOG_CORE=y" >>.config
	echo "CONFIG_MFD_CORE=m" >>.config
	echo "CONFIG_LPC_ICH=m" >>.config
	echo "CONFIG_HID_GT683R=m" >>.config
	echo "CONFIG_HID_SONY=m" >>.config
	echo "CONFIG_SONY_FF=y" >>.config
	echo "CONFIG_HID_THINGM=m" >>.config
	echo "CONFIG_HID_WIIMOTE=m" >>.config
	echo "CONFIG_USB_LED_TRIG=y" >>.config
	echo "CONFIG_NEW_LEDS=y" >>.config
	echo "CONFIG_LEDS_CLASS=m" >>.config
	echo "CONFIG_LEDS_CLASS_FLASH=m" >>.config
	echo "CONFIG_LEDS_LM3530=m" >>.config
	echo "CONFIG_LEDS_LM3642=m" >>.config
	echo "CONFIG_LEDS_PCA9532=m" >>.config
	echo "CONFIG_LEDS_LP3944=m" >>.config
	echo "CONFIG_LEDS_LP55XX_COMMON=m" >>.config
	echo "CONFIG_LEDS_LP5521=m" >>.config
	echo "CONFIG_LEDS_LP5523=m" >>.config
	echo "CONFIG_LEDS_LP5562=m" >>.config
	echo "CONFIG_LEDS_LP8501=m" >>.config
	echo "CONFIG_LEDS_LP8860=m" >>.config
	echo "CONFIG_LEDS_CLEVO_MAIL=m" >>.config
	echo "CONFIG_LEDS_PCA955X=m" >>.config
	echo "CONFIG_LEDS_PCA963X=m" >>.config
	echo "CONFIG_LEDS_BD2802=m" >>.config
	echo "CONFIG_LEDS_INTEL_SS4200=m" >>.config
	echo "CONFIG_LEDS_DELL_NETBOOKS=m" >>.config
	echo "CONFIG_LEDS_TCA6507=m" >>.config
	echo "CONFIG_LEDS_LM355x=m" >>.config
	echo "CONFIG_LEDS_BLINKM=m" >>.config
	echo "CONFIG_LEDS_PM8941_WLED=m" >>.config
	echo "CONFIG_LEDS_TRIGGERS=y" >>.config
	echo "CONFIG_LEDS_TRIGGER_TIMER=m" >>.config
	echo "CONFIG_LEDS_TRIGGER_ONESHOT=m" >>.config
	echo "CONFIG_LEDS_TRIGGER_HEARTBEAT=m" >>.config
	echo "CONFIG_LEDS_TRIGGER_BACKLIGHT=m" >>.config
	echo "CONFIG_LEDS_TRIGGER_DEFAULT_ON=m" >>.config
	echo "CONFIG_LEDS_TRIGGER_TRANSIENT=m" >>.config
	echo "CONFIG_LEDS_TRIGGER_CAMERA=m" >>.config
	echo "CONFIG_INTEL_IOATDMA=m" >>.config
	echo "CONFIG_DMA_ENGINE=y" >>.config
	echo "# CONFIG_ASYNC_TX_DMA is not set" >>.config
	echo "CONFIG_DMATEST=m" >>.config
	echo "CONFIG_DMA_ENGINE_RAID=y" >>.config
	echo "CONFIG_DCA=m" >>.config
	echo "CONFIG_ACER_WMI=m" >>.config
	echo "CONFIG_ALIENWARE_WMI=m" >>.config
	echo "CONFIG_DELL_WMI=m" >>.config
	echo "CONFIG_DELL_WMI_AIO=m" >>.config
	echo "CONFIG_HP_WMI=m" >>.config
	echo "CONFIG_COMPAL_LAPTOP=m" >>.config
	echo "CONFIG_ASUS_WMI=m" >>.config
	echo "CONFIG_ASUS_NB_WMI=m" >>.config
	echo "CONFIG_EEEPC_WMI=m" >>.config
	echo "CONFIG_ACPI_WMI=m" >>.config
	echo "CONFIG_MSI_WMI=m" >>.config
	echo "CONFIG_ACPI_TOSHIBA=m" >>.config
	echo "CONFIG_MXM_WMI=m" >>.config
	echo "CONFIG_OCFS2_FS=m" >>.config
	echo "CONFIG_OCFS2_FS_O2CB=m" >>.config
	echo "CONFIG_OCFS2_FS_USERSPACE_CLUSTER=m" >>.config
	echo "CONFIG_OCFS2_FS_STATS=y" >>.config
	echo "CONFIG_OCFS2_DEBUG_MASKLOG=y" >>.config
	echo "# CONFIG_OCFS2_DEBUG_FS is not set" >>.config
	echo "CONFIG_CONFIGFS_FS=m" >>.config
	echo "CONFIG_DLM=m" >>.config
	echo "# CONFIG_DLM_DEBUG is not set" >>.config
	echo "CONFIG_ASYNC_RAID6_TEST=m" >>.config
	echo "CONFIG_SECURITYFS=y" >>.config
	echo "CONFIG_SECURITY_PATH=y" >>.config
	echo "CONFIG_LSM_MMAP_MIN_ADDR=0" >>.config
	echo "CONFIG_SECURITY_SELINUX=y" >>.config
	echo "CONFIG_SECURITY_SELINUX_BOOTPARAM=y" >>.config
	echo "CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=0" >>.config
	echo "CONFIG_SECURITY_SELINUX_DISABLE=y" >>.config
	echo "CONFIG_SECURITY_SELINUX_DEVELOP=y" >>.config
	echo "CONFIG_SECURITY_SELINUX_AVC_STATS=y" >>.config
	echo "CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1" >>.config
	echo "# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set" >>.config
	echo "CONFIG_SECURITY_APPARMOR=y" >>.config
	echo "CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1" >>.config
	echo "CONFIG_SECURITY_APPARMOR_HASH=y" >>.config
	echo "CONFIG_INTEGRITY_AUDIT=y" >>.config
	echo "# CONFIG_DEFAULT_SECURITY_SELINUX is not set" >>.config
	echo "CONFIG_DEFAULT_SECURITY_APPARMOR=y" >>.config
	echo "# CONFIG_DEFAULT_SECURITY_DAC is not set" >>.config
	echo "CONFIG_DEFAULT_SECURITY=\"apparmor\"" >>.config
	echo "CONFIG_XOR_BLOCKS=m" >>.config
	echo "CONFIG_ASYNC_CORE=m" >>.config
	echo "CONFIG_ASYNC_MEMCPY=m" >>.config
	echo "CONFIG_ASYNC_XOR=m" >>.config
	echo "CONFIG_ASYNC_PQ=m" >>.config
	echo "CONFIG_ASYNC_RAID6_RECOV=m" >>.config
	echo "CONFIG_CRYPTO_CRYPTD=m" >>.config
	echo "CONFIG_CRYPTO_ABLK_HELPER=m" >>.config
	echo "CONFIG_CRYPTO_GLUE_HELPER_X86=m" >>.config
	echo "CONFIG_CRYPTO_LRW=m" >>.config
	echo "CONFIG_CRYPTO_XTS=m" >>.config
	echo "CONFIG_CRYPTO_CRC32C_INTEL=m" >>.config
	echo "CONFIG_CRYPTO_CRC32=m" >>.config
	echo "CONFIG_CRYPTO_CRC32_PCLMUL=m" >>.config
	echo "CONFIG_CRYPTO_CRCT10DIF=m" >>.config
	echo "CONFIG_CRYPTO_CRCT10DIF_PCLMUL=m" >>.config
	echo "CONFIG_CRYPTO_AES_X86_64=m" >>.config
	echo "CONFIG_CRYPTO_AES_NI_INTEL=m" >>.config
	echo "CONFIG_KVM_AMD=y" >>.config
	echo "CONFIG_RAID6_PQ=m" >>.config
	echo "CONFIG_CRC_T10DIF=m" >>.config
	echo "CONFIG_LRU_CACHE=m" >>.config
	echo "CONFIG_BLK_DEV_BSGLIB=y" >>.config
	echo "CONFIG_BRIDGE_NF_EBTABLES=m" >>.config
	echo "CONFIG_BRIDGE_EBT_BROUTE=m" >>.config
	echo "CONFIG_BRIDGE_EBT_T_FILTER=m" >>.config
	echo "CONFIG_BRIDGE_EBT_T_NAT=m" >>.config
	echo "CONFIG_BRIDGE_EBT_802_3=m" >>.config
	echo "CONFIG_BRIDGE_EBT_AMONG=m" >>.config
	echo "CONFIG_BRIDGE_EBT_ARP=m" >>.config
	echo "CONFIG_BRIDGE_EBT_IP=m" >>.config
	echo "CONFIG_BRIDGE_EBT_IP6=m" >>.config
	echo "CONFIG_BRIDGE_EBT_LIMIT=m" >>.config
	echo "CONFIG_BRIDGE_EBT_MARK=m" >>.config
	echo "CONFIG_BRIDGE_EBT_PKTTYPE=m" >>.config
	echo "CONFIG_BRIDGE_EBT_STP=m" >>.config
	echo "CONFIG_BRIDGE_EBT_VLAN=m" >>.config
	echo "CONFIG_BRIDGE_EBT_ARPREPLY=m" >>.config
	echo "CONFIG_BRIDGE_EBT_DNAT=m" >>.config
	echo "CONFIG_BRIDGE_EBT_MARK_T=m" >>.config
	echo "CONFIG_BRIDGE_EBT_REDIRECT=m" >>.config
	echo "CONFIG_BRIDGE_EBT_SNAT=m" >>.config
	echo "CONFIG_BRIDGE_EBT_LOG=m" >>.config
	echo "CONFIG_BRIDGE_EBT_NFLOG=m" >>.config
	echo "CONFIG_RDS=m" >>.config
	echo "CONFIG_RDS_RDMA=m" >>.config
	echo "CONFIG_RDS_TCP=m" >>.config
	echo "# CONFIG_RDS_DEBUG is not set" >>.config
	echo "CONFIG_SCSI_ISCSI_ATTRS=m" >>.config
	echo "CONFIG_SCSI_SRP_ATTRS=m" >>.config
	echo "CONFIG_ENIC=m" >>.config
	echo "CONFIG_BE2NET=m" >>.config
	echo "CONFIG_BE2NET_VXLAN=y" >>.config
	echo "CONFIG_MLX4_CORE=m" >>.config
	echo "CONFIG_MLX4_DEBUG=y" >>.config
	echo "CONFIG_MLX5_CORE=m" >>.config
	echo "CONFIG_SERIO_RAW=m" >>.config
	echo "CONFIG_SND_HWDEP=m" >>.config
	echo "CONFIG_SND_HDA=m" >>.config
	echo "CONFIG_SND_HDA_INTEL=m" >>.config
	echo "CONFIG_SND_HDA_CODEC_REALTEK=m" >>.config
	echo "CONFIG_SND_HDA_CODEC_HDMI=m" >>.config
	echo "CONFIG_SND_HDA_GENERIC=m" >>.config
	echo "CONFIG_SND_HDA_CORE=m" >>.config
	echo "CONFIG_INFINIBAND=m" >>.config
	echo "CONFIG_INFINIBAND_USER_MAD=m" >>.config
	echo "CONFIG_INFINIBAND_USER_ACCESS=m" >>.config
	echo "CONFIG_INFINIBAND_USER_MEM=y" >>.config
	echo "CONFIG_INFINIBAND_ON_DEMAND_PAGING=y" >>.config
	echo "CONFIG_INFINIBAND_ADDR_TRANS=y" >>.config
	echo "CONFIG_INFINIBAND_MTHCA=m" >>.config
	echo "CONFIG_INFINIBAND_MTHCA_DEBUG=y" >>.config
	echo "CONFIG_INFINIBAND_IPATH=m" >>.config
	echo "CONFIG_INFINIBAND_QIB=m" >>.config
	echo "CONFIG_INFINIBAND_QIB_DCA=y" >>.config
	echo "CONFIG_INFINIBAND_AMSO1100=m" >>.config
	echo "# CONFIG_INFINIBAND_AMSO1100_DEBUG is not set" >>.config
	echo "CONFIG_MLX4_INFINIBAND=m" >>.config
	echo "CONFIG_MLX5_INFINIBAND=m" >>.config
	echo "CONFIG_INFINIBAND_NES=m" >>.config
	echo "# CONFIG_INFINIBAND_NES_DEBUG is not set" >>.config
	echo "CONFIG_INFINIBAND_OCRDMA=m" >>.config
	echo "CONFIG_INFINIBAND_USNIC=m" >>.config
	echo "CONFIG_INFINIBAND_IPOIB=m" >>.config
	echo "CONFIG_INFINIBAND_IPOIB_CM=y" >>.config
	echo "CONFIG_INFINIBAND_IPOIB_DEBUG=y" >>.config
	echo "# CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set" >>.config
	echo "CONFIG_INFINIBAND_SRP=m" >>.config
	echo "CONFIG_INFINIBAND_ISER=m" >>.config
	echo "CONFIG_BTRFS_FS=m" >>.config
	echo "CONFIG_BTRFS_FS_POSIX_ACL=y" >>.config
	echo "# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set" >>.config
	echo "# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set" >>.config
	echo "# CONFIG_BTRFS_DEBUG is not set" >>.config
	echo "# CONFIG_BTRFS_ASSERT is not set" >>.config
	echo "CONFIG_SUNRPC_XPRT_RDMA_CLIENT=m" >>.config
	echo "CONFIG_SUNRPC_XPRT_RDMA_SERVER=m" >>.config
	echo "CONFIG_ZLIB_DEFLATE=m" >>.config
	echo "CONFIG_PARPORT=m" >>.config
	echo "# CONFIG_PARPORT_PC is not set" >>.config
	echo "# CONFIG_PARPORT_GSC is not set" >>.config
	echo "# CONFIG_PARPORT_AX88796 is not set" >>.config
	echo "# CONFIG_PARPORT_1284 is not set" >>.config
	echo "# CONFIG_ATP is not set" >>.config
	echo "# CONFIG_PLIP is not set" >>.config
	echo "# CONFIG_JOYSTICK_DB9 is not set" >>.config
	echo "# CONFIG_JOYSTICK_GAMECON is not set" >>.config
	echo "# CONFIG_JOYSTICK_TURBOGRAFX is not set" >>.config
	echo "# CONFIG_JOYSTICK_WALKERA0701 is not set" >>.config
	echo "# CONFIG_SERIO_PARKBD is not set" >>.config
	echo "CONFIG_PRINTER=m" >>.config
	echo "# CONFIG_LP_CONSOLE is not set" >>.config
	echo "# CONFIG_PPDEV is not set" >>.config
	echo "# CONFIG_I2C_PARPORT is not set" >>.config
	echo "# CONFIG_PPS_CLIENT_PARPORT is not set" >>.config
	echo "# CONFIG_SND_MTS64 is not set" >>.config
	echo "# CONFIG_SND_PORTMAN2X4 is not set" >>.config
	echo "# CONFIG_USB_USS720 is not set" >>.config
	echo "CONFIG_NETFILTER_XT_TARGET_CHECKSUM=m" >>.config
	echo "CONFIG_BLK_DEV_INTEGRITY=y" >>.config
	echo "CONFIG_BLK_DEV_OSD=m" >>.config
	echo "CONFIG_EEPROM_93CX6=m" >>.config
	echo "CONFIG_RAID_ATTRS=m" >>.config
	echo "CONFIG_SCSI_SAS_ATTRS=m" >>.config
	echo "CONFIG_SCSI_SAS_LIBSAS=m" >>.config
	echo "# CONFIG_SCSI_SAS_ATA is not set" >>.config
	echo "CONFIG_SCSI_SAS_HOST_SMP=y" >>.config
	echo "CONFIG_SCSI_LOWLEVEL=y" >>.config
	echo "CONFIG_ISCSI_TCP=m" >>.config
	echo "CONFIG_ISCSI_BOOT_SYSFS=m" >>.config
	echo "CONFIG_SCSI_CXGB3_ISCSI=m" >>.config
	echo "CONFIG_SCSI_CXGB4_ISCSI=m" >>.config
	echo "CONFIG_SCSI_BNX2_ISCSI=m" >>.config
	echo "CONFIG_BE2ISCSI=m" >>.config
	echo "CONFIG_BLK_DEV_3W_XXXX_RAID=m" >>.config
	echo "CONFIG_SCSI_HPSA=m" >>.config
	echo "CONFIG_SCSI_3W_9XXX=m" >>.config
	echo "CONFIG_SCSI_3W_SAS=m" >>.config
	echo "CONFIG_SCSI_ACARD=m" >>.config
	echo "CONFIG_SCSI_AACRAID=m" >>.config
	echo "CONFIG_SCSI_AIC7XXX=m" >>.config
	echo "CONFIG_AIC7XXX_CMDS_PER_DEVICE=8" >>.config
	echo "CONFIG_AIC7XXX_RESET_DELAY_MS=15000" >>.config
	echo "# CONFIG_AIC7XXX_DEBUG_ENABLE is not set" >>.config
	echo "CONFIG_AIC7XXX_DEBUG_MASK=0" >>.config
	echo "CONFIG_AIC7XXX_REG_PRETTY_PRINT=y" >>.config
	echo "CONFIG_SCSI_AIC79XX=m" >>.config
	echo "CONFIG_AIC79XX_CMDS_PER_DEVICE=32" >>.config
	echo "CONFIG_AIC79XX_RESET_DELAY_MS=5000" >>.config
	echo "# CONFIG_AIC79XX_DEBUG_ENABLE is not set" >>.config
	echo "CONFIG_AIC79XX_DEBUG_MASK=0" >>.config
	echo "CONFIG_AIC79XX_REG_PRETTY_PRINT=y" >>.config
	echo "CONFIG_SCSI_AIC94XX=m" >>.config
	echo "# CONFIG_AIC94XX_DEBUG is not set" >>.config
	echo "CONFIG_SCSI_MVSAS=m" >>.config
	echo "# CONFIG_SCSI_MVSAS_DEBUG is not set" >>.config
	echo "# CONFIG_SCSI_MVSAS_TASKLET is not set" >>.config
	echo "CONFIG_SCSI_MVUMI=m" >>.config
	echo "CONFIG_SCSI_DPT_I2O=m" >>.config
	echo "CONFIG_SCSI_ADVANSYS=m" >>.config
	echo "CONFIG_SCSI_ARCMSR=m" >>.config
	echo "CONFIG_SCSI_ESAS2R=m" >>.config
	echo "CONFIG_MEGARAID_NEWGEN=y" >>.config
	echo "CONFIG_MEGARAID_MM=m" >>.config
	echo "CONFIG_MEGARAID_MAILBOX=m" >>.config
	echo "CONFIG_MEGARAID_LEGACY=m" >>.config
	echo "CONFIG_MEGARAID_SAS=m" >>.config
	echo "CONFIG_SCSI_MPT2SAS=m" >>.config
	echo "CONFIG_SCSI_MPT2SAS_MAX_SGE=128" >>.config
	echo "# CONFIG_SCSI_MPT2SAS_LOGGING is not set" >>.config
	echo "CONFIG_SCSI_MPT3SAS=m" >>.config
	echo "CONFIG_SCSI_MPT3SAS_MAX_SGE=128" >>.config
	echo "# CONFIG_SCSI_MPT3SAS_LOGGING is not set" >>.config
	echo "CONFIG_SCSI_UFSHCD=m" >>.config
	echo "CONFIG_SCSI_UFSHCD_PCI=m" >>.config
	echo "CONFIG_SCSI_UFSHCD_PLATFORM=m" >>.config
	echo "CONFIG_SCSI_HPTIOP=m" >>.config
	echo "CONFIG_SCSI_BUSLOGIC=m" >>.config
	echo "CONFIG_SCSI_FLASHPOINT=y" >>.config
	echo "CONFIG_VMWARE_PVSCSI=m" >>.config
	echo "CONFIG_SCSI_DMX3191D=m" >>.config
	echo "CONFIG_SCSI_EATA=m" >>.config
	echo "CONFIG_SCSI_EATA_TAGGED_QUEUE=y" >>.config
	echo "CONFIG_SCSI_EATA_LINKED_COMMANDS=y" >>.config
	echo "CONFIG_SCSI_EATA_MAX_TAGS=16" >>.config
	echo "CONFIG_SCSI_FUTURE_DOMAIN=m" >>.config
	echo "CONFIG_SCSI_GDTH=m" >>.config
	echo "CONFIG_SCSI_ISCI=m" >>.config
	echo "CONFIG_SCSI_IPS=m" >>.config
	echo "CONFIG_SCSI_INITIO=m" >>.config
	echo "CONFIG_SCSI_INIA100=m" >>.config
	echo "CONFIG_SCSI_STEX=m" >>.config
	echo "CONFIG_SCSI_SYM53C8XX_2=m" >>.config
	echo "CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1" >>.config
	echo "CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16" >>.config
	echo "CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64" >>.config
	echo "CONFIG_SCSI_SYM53C8XX_MMIO=y" >>.config
	echo "CONFIG_SCSI_IPR=m" >>.config
	echo "# CONFIG_SCSI_IPR_TRACE is not set" >>.config
	echo "# CONFIG_SCSI_IPR_DUMP is not set" >>.config
	echo "CONFIG_SCSI_QLOGIC_1280=m" >>.config
	echo "CONFIG_SCSI_QLA_ISCSI=m" >>.config
	echo "CONFIG_SCSI_DC395x=m" >>.config
	echo "CONFIG_SCSI_AM53C974=m" >>.config
	echo "CONFIG_SCSI_WD719X=m" >>.config
	echo "CONFIG_SCSI_DEBUG=m" >>.config
	echo "CONFIG_SCSI_PMCRAID=m" >>.config
	echo "CONFIG_SCSI_PM8001=m" >>.config
	echo "CONFIG_SCSI_VIRTIO=m" >>.config
	echo "CONFIG_SCSI_LOWLEVEL_PCMCIA=y" >>.config
	echo "CONFIG_PCMCIA_AHA152X=m" >>.config
	echo "CONFIG_PCMCIA_FDOMAIN=m" >>.config
	echo "CONFIG_PCMCIA_QLOGIC=m" >>.config
	echo "CONFIG_PCMCIA_SYM53C500=m" >>.config
	echo "CONFIG_SCSI_OSD_INITIATOR=m" >>.config
	echo "CONFIG_SCSI_OSD_ULD=m" >>.config
	echo "CONFIG_SCSI_OSD_DPRINT_SENSE=1" >>.config
	echo "# CONFIG_SCSI_OSD_DEBUG is not set" >>.config
	echo "CONFIG_BNX2=m" >>.config
	echo "CONFIG_CNIC=m" >>.config
	echo "CONFIG_CHELSIO_T3=m" >>.config
	echo "CONFIG_CHELSIO_T4=m" >>.config
	echo "CONFIG_INFINIBAND_CXGB3=m" >>.config
	echo "# CONFIG_INFINIBAND_CXGB3_DEBUG is not set" >>.config
	echo "CONFIG_INFINIBAND_CXGB4=m" >>.config
	echo "CONFIG_PM_DEVFREQ=y" >>.config
	echo "CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=m" >>.config
	echo "CONFIG_DEVFREQ_GOV_PERFORMANCE=m" >>.config
	echo "CONFIG_DEVFREQ_GOV_POWERSAVE=m" >>.config
	echo "CONFIG_DEVFREQ_GOV_USERSPACE=m" >>.config
	echo "# CONFIG_PM_DEVFREQ_EVENT is not set" >>.config
	echo "CONFIG_EXOFS_FS=m" >>.config
	echo "# CONFIG_EXOFS_DEBUG is not set" >>.config
	echo "CONFIG_ORE=m" >>.config
	echo "CONFIG_CRYPTO_CRCT10DIF=y" >>.config
	echo "CONFIG_CRC_T10DIF=y" >>.config
	echo "CONFIG_GENERIC_ALLOCATOR=y" >>.config
	echo "CONFIG_IOSF_MBI=m" >>.config
	echo "# CONFIG_IOSF_MBI_DEBUG is not set" >>.config
	echo "# CONFIG_INTEL_SOC_DTS_THERMAL is not set" >>.config
	echo "CONFIG_POWERCAP=y" >>.config
	echo "CONFIG_INTEL_RAPL=m" >>.config
	echo "CONFIG_HW_RANDOM_TPM=m" >>.config
	echo "CONFIG_TCG_TPM=y" >>.config
	echo "CONFIG_TCG_TIS=m" >>.config
	echo "CONFIG_TCG_TIS_I2C_ATMEL=m" >>.config
	echo "CONFIG_TCG_TIS_I2C_INFINEON=m" >>.config
	echo "CONFIG_TCG_TIS_I2C_NUVOTON=m" >>.config
	echo "CONFIG_TCG_NSC=m" >>.config
	echo "CONFIG_TCG_ATMEL=m" >>.config
	echo "CONFIG_TCG_INFINEON=m" >>.config
	echo "CONFIG_TCG_CRB=m" >>.config
	echo "CONFIG_TRUSTED_KEYS=m" >>.config
	echo "CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=m" >>.config
	echo "CONFIG_KVM=m" >>.config
	echo "CONFIG_KVM_INTEL=m" >>.config
	echo "CONFIG_KVM_AMD=m" >>.config
	echo "CONFIG_PATA_ACPI=m" >>.config
	echo "CONFIG_CRC_ITU_T=m" >>.config
	echo "CONFIG_FIREWIRE=y" >>.config
	echo "CONFIG_FIREWIRE_OHCI=m" >>.config
	echo "CONFIG_FIREWIRE_SBP2=m" >>.config
	echo "CONFIG_FIREWIRE_NET=m" >>.config
	echo "# CONFIG_SND_FIREWIRE is not set" >>.config
	echo "CONFIG_EDAC_MM_EDAC=m" >>.config
	echo "CONFIG_EDAC_AMD64=m" >>.config
	echo "# CONFIG_EDAC_AMD64_ERROR_INJECTION is not set" >>.config
	echo "CONFIG_EDAC_E752X=m" >>.config
	echo "CONFIG_EDAC_I82975X=m" >>.config
	echo "CONFIG_EDAC_I3000=m" >>.config
	echo "CONFIG_EDAC_I3200=m" >>.config
	echo "CONFIG_EDAC_IE31200=m" >>.config
	echo "CONFIG_EDAC_X38=m" >>.config
	echo "CONFIG_EDAC_I5400=m" >>.config
	echo "CONFIG_EDAC_I7CORE=m" >>.config
	echo "CONFIG_EDAC_I5000=m" >>.config
	echo "CONFIG_EDAC_I5100=m" >>.config
	echo "CONFIG_EDAC_I7300=m" >>.config
	echo "CONFIG_PCI_MMCONFIG=y" >>.config
	echo "CONFIG_EDAC_SBRIDGE=m" >>.config
	echo "CONFIG_CEPH_LIB=m" >>.config
	echo "# CONFIG_CEPH_LIB_PRETTYDEBUG is not set" >>.config
	echo "CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y" >>.config
	echo "CONFIG_CEPH_FS=m" >>.config
	echo "CONFIG_CEPH_FS_POSIX_ACL=y" >>.config
	echo "CONFIG_XFS_RT=y" >>.config
	echo "CONFIG_CRYPTO_ECB=y" >>.config
	echo "CONFIG_CRYPTO_CRC32C_INTEL=y" >>.config
	echo "CONFIG_CRYPTO_SHA512=y" >>.config
	echo "CONFIG_CRYPTO_LZO=y" >>.config
	echo "CONFIG_CRYPTO_DEV_PADLOCK=y" >>.config
	echo "CONFIG_CRYPTO_DEV_PADLOCK_AES=m" >>.config
	echo "CONFIG_CRYPTO_DEV_PADLOCK_SHA=m" >>.config

	make oldconfig </dev/null

	# Build the kernel debs
	if [ $KEEP = no ]
	then
		make-kpkg clean
	fi
	fakeroot make-kpkg --initrd --revision=$VERSION kernel_image kernel_headers
	git checkout arch/x86/boot/install.sh
	git checkout fs/xfs/xfs_super.c

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
