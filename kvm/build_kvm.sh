#!/bin/bash

COMMIT="00bbfcd8f77b0379efa999a290b0edd1de7ed07d"
if [ x$1 = x-c ]
then
	COMMIT=$2
	shift;shift
fi

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

	# Get the KVM for NFV kernel sources
	if [ ! -d kvmfornfv ]
	then
		git clone https://gerrit.opnfv.org/gerrit/kvmfornfv
	fi
	cd kvmfornfv
	git pull
	if [ x$COMMIT != x ]
	then
		git checkout $COMMIT
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
	make oldconfig </dev/null

	# Build the kernel deb's
	make-kpkg clean
	fakeroot make-kpkg --initrd --revision=$VERSION kernel_image kernel_headers
	git checkout arch/x86/boot/install.sh
)

mv $SRC/kvmfornfv/*.deb .

