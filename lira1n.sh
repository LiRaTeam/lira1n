#!/bin/bash
set -e

if [[ $1 = -y ]]; then
    AUTO=yes
fi

if [ $(uname) = "Darwin" ]; then
    product=$(sw_vers -productName 2>/dev/null)
    if [ "$product" != "macOS" ] && [ "$product" != "Mac OS X" ]; then
        echo ""
        if [[ $AUTO != yes ]]; then
            read -p "Press enter to continue"
        fi
        ARM=yes
    fi
fi

if [[ $ARM == yes ]]; then
    VER=$(/binpack/usr/bin/plutil -key ProductVersion /System/Library/CoreServices/SystemVersion.plist)
elif [[ $AUTO == yes && ! -z $2 ]]; then
    VER=$2
fi

if [[ ! -z $VER ]]; then
    if [[ $VER = 14.* ]]; then
        CFVER=1800
    elif [[ $VER = 13.* ]]; then
        CFVER=1600
    elif [[ $VER = 12.* ]]; then
        CFVER=1500
    else
        echo "${VER} not compatible."
        exit 1
    fi
fi

echo "LiRa1n"
echo "© Copright 2021 LiRa Team"


if [[ $AUTO != yes ]]; then
    read -p "Press enter to continue"
fi

if ! which curl >> /dev/null; then
    echo "Error: curl not found"
    exit 1
fi
if [[ "${ARM}" != yes ]]; then
    if which iproxy >> /dev/null; then
        iproxy 42264 44 >> /dev/null 2>/dev/null &
        trap 'killall iproxy 2>/dev/null' ERR
    else
        echo "Error: iproxy not found"
        exit 1
    fi

    if [[ -z $SSHPASS ]]; then
        read -s SSHPASS -p "Enter the root password (default is “alpine”): "
        echo
    fi
    if [[ $SSHPASS = "" ]]; then
        SSHPASS=alpine
    fi
fi
rm -rf LiRa-tmp
mkdir LiRa-tmp
cd LiRa-tmp

cat > lira1n.sh <<EOT
#!/bin/bash
set -e

function cleanup() {
    rm -f bootstrap*.tar*
    rm -f org.swift.libswift_5.0-electra2_iphoneos-arm.deb
    rm -f lirastuti_1.0_iphoneos-arm.deb
    rm -f safemode_2.1_iphoneos-arm.deb
    rm -f lira1n.sh
}
trap cleanup ERR

if [ \$(uname -p) = "arm" ] || [ \$(uname -p) = "arm64" ]; then
    ARM=yes
fi
if [[ ! "\${ARM}" = yes ]]; then
    cd /var/root
fi
if [[ -f "/.bootstrapped" ]]; then
    mkdir -p /LiRa && mv migration /LiRa
    chmod 0755 /LiRay/migration
    /LiRa/migration
    rm -rf /LiRa
else
    VER=\$(/binpack/usr/bin/plutil -key ProductVersion /System/Library/CoreServices/SystemVersion.plist)
    if [[ ! -z \$VER ]]; then
        if [[ \$VER = 14.* ]]; then
            CFVER=1700
        elif [[ \$VER = 13.* ]]; then
            CFVER=1600
        elif [[ \$VER = 12.* ]]; then
            CFVER=1500
        else
            echo "\${VER} not compatible."
            exit 1
        fi
    fi
    gzip -d bootstrap-\${CFVER}.tar.gz
    mount -uw -o union /dev/disk0s1s1
    rm -rf /etc/profile
    rm -rf /etc/profile.d
    rm -rf /etc/alternatives
    rm -rf /etc/apt
    rm -rf /etc/ssl
    rm -rf /etc/ssh
    rm -rf /etc/dpkg
    rm -rf /Library/dpkg
    rm -rf /var/cache
    rm -rf /var/lib
    tar --preserve-permissions -xkf BootStrap-\${CFVER}.tar -C /
    SNAPSHOT=\$(snappy -s | cut -d ' ' -f 3 | tr -d '\n')
    snappy -f / -r \$SNAPSHOT -t orig-fs
fi
/prep_bootstrap.sh
mkdir -p /etc/apt/sources.list.d/
echo "Types: deb" > /etc/apt/sources.list.d/lira1n.sources
echo "URIs: https://lirateam.github.io/apt/" >> /etc/apt/sources.list.d/lira1n.sources
echo "Suites: ./" >> /etc/apt/sources.list.d/lira1n.sources
echo "Components: " >> /etc/apt/sources.list.d/lira1n.sources
echo "" >> /etc/apt/sources.list.d/lira1n.sources
mkdir -p /etc/apt/preferences.d/
echo "Package: *" > /etc/apt/preferences.d/lira1n
echo "Pin: release n=lira1n-ios" >> /etc/apt/preferences.d/lira1n
echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/lira1n
echo "" >> /etc/apt/preferences.d/lira1n
if [[ \$VER = 12.1* ]] || [[ \$VER = 12.0* ]]; then
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games dpkg -i org.swift.libswift_5.0-electra2_iphoneos-arm.deb
fi
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games dpkg -i lirastuti_1.0_iphoneos-arm.deb safemode_2.1_iphoneos-arm.deb
uicache  /Applications/Zebra.app
echo -n "" > /var/lib/dpkg/available
touch /.mount_rw
touch /.installed_LiRa1n
cleanup
EOT

echo "Downloading Resources..."
curl -#L \
    -O https://lirateam.github.io/lira1n/lirastuti_1.0_iphoneos-arm.deb \
    -O https://lirateam.github.io/lira1n/safemode_2.1_iphoneos-arm.deb \

if [[ ! -z $CFVER ]]; then
    curl -#L \
        -O https://lirateam.github.io/lira1n/Bootstrap-${CFVER}.tar.gz

    if [[ $VER = 12.1* ]] || [[ $VER = 12.0* ]]; then
        curl -#L \
            -O https://github.com/coolstar/odyssey-bootstrap/raw/master/org.swift.libswift_5.0-electra2_iphoneos-arm.deb
    fi
else
    curl -#L \
        -O https://lirateam.github.io/lira1n/bootstrap-1500.tar.gz \
        -O https://lirateam.github.io/lira1n/bootstrap-1600.tar.gz \
        -O https://lirateam.github.io/lira1n/Bootstrap-1700.tar.gz \
        -O https://lirateam.github.io/lira1n/BootStrap-1800.tar.gz \
       
fi

if [[ ! "${ARM}" = yes ]]; then
    echo "Copying Files to your device"
    sshpass -e scp -P42264 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" \
        bootstrap-*.tar.gz \
        lirastuti_1.0_iphoneos-arm.deb \
        safemode_2.1_iphoneos-arm.deb \
        lira1n.sh \
        root@127.0.0.1:/var/root/

    if [[ -f org.swift.libswift_5.0-electra2_iphoneos-arm.deb ]]; then
        sshpass -e scp -P42264 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" \
            org.swift.libswift_5.0-electra2_iphoneos-arm.deb \
            root@127.0.0.1:/var/root/
    fi
fi
echo "Installingbootstrap"
if [[ "${ARM}" = yes ]]; then
    bash ./lira1n.sh
else
    sshpass -e ssh -p42264 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" root@127.0.0.1 "bash /var/root/lira1n.sh"
    echo "All Done!"
    killall iproxy
fi
