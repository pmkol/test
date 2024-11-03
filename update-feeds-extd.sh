#!/bin/bash

# backup feeds
shopt -s extglob
mv extd /tmp
mkdir -p extd
cd extd

# download feeds
git clone https://github.com/openwrt/luci openwrt/luci -b openwrt-23.05 --depth 1
git clone https://github.com/openwrt/packages openwrt/packages -b openwrt-23.05 --depth 1
git clone https://github.com/immortalwrt/luci immortalwrt/luci -b master --depth 1
git clone https://github.com/immortalwrt/packages immortalwrt/packages -b master --depth 1
git clone https://github.com/sirpdboy/luci-app-ddns-go openwrt-ddns-go --depth 1
git clone https://github.com/sbwml/openwrt_pkgs --depth 1
git clone https://github.com/sbwml/luci-app-alist openwrt-alist --depth 1
git clone https://github.com/sbwml/luci-app-airconnect openwrt-airconnect --depth 1
git clone https://github.com/sbwml/luci-app-mentohust openwrt-mentohust --depth 1
git clone https://github.com/sbwml/luci-app-mosdns openwrt-mosdns --depth 1
git clone https://github.com/sbwml/luci-app-qbittorrent openwrt-qbittorrent --depth 1
git clone https://github.com/sbwml/luci-theme-argon openwrt-argon --depth 1
git clone https://github.com/sbwml/OpenAppFilter openwrt-oaf --depth 1
git clone https://github.com/sbwml/feeds_packages_libs_liburing liburing --depth 1
git clone https://github.com/sbwml/feeds_packages_net_samba4 samba4 --depth 1
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic --depth 1
git clone https://github.com/asvow/luci-app-tailscale --depth 1
git clone https://github.com/pmkol/openwrt-aria2 --depth 1
git clone https://github.com/pmkol/openwrt-eqosplus --depth 1
git clone https://github.com/pmkol/packages_utils_containerd containerd --depth 1
git clone https://github.com/pmkol/packages_utils_docker docker --depth 1
git clone https://github.com/pmkol/packages_utils_dockerd dockerd --depth 1
git clone https://github.com/pmkol/packages_utils_runc runc --depth 1
git clone https://github.com/pmkol/packages_net_miniupnpd miniupnpd --depth 1
git clone https://github.com/pmkol/luci-app-upnp --depth 1
git clone https://github.com/pmkol/packages_net_qosmate qosmate --depth 1
git clone https://github.com/pmkol/luci-app-qosmate --depth 1
rm -rf openwrt_pkgs/bash-completion
rm -rf openwrt-ddns-go/luci-app-ddns-go/README.md
rm -rf liburing/.git
rm -rf samba4/{.git,README.md}
rm -rf containerd/.git
rm -rf docker/.git
rm -rf dockerd/.git
rm -rf runc/.git
rm -rf luci-app-unblockneteasemusic/{.git,.github,LICENSE,README.md}
rm -rf luci-app-tailscale/{.git,.gitignore,LICENSE,README.md}
rm -rf miniupnpd/{.git,.github}
rm -rf luci-app-upnp/{.git,.github}
rm -rf qosmate/{.git,LICENSE,README.md}
rm -rf luci-app-qosmate/{.git,LICENSE,README.md}

# download patch
curl -s https://raw.githubusercontent.com/pmkol/openwrt-plus/master/openwrt/patch/docker/0001-dockerd-fix-bridge-network.patch > patch-dockerd-fix-bridge-network.patch
curl -s https://raw.githubusercontent.com/pmkol/openwrt-plus/master/openwrt/patch/docker/0002-docker-add-buildkit-experimental-support.patch > patch-dockerd-add-buildkit-experimental-support.patch
curl -s https://raw.githubusercontent.com/pmkol/openwrt-plus/master/openwrt/patch/docker/0003-dockerd-disable-ip6tables-for-bridge-network-by-defa.patch > patch-dockerd-disable-ip6tables-for-bridge-network-by-defa.patch
curl -s https://raw.githubusercontent.com/pmkol/openwrt-plus/master/openwrt/patch/luci/applications/luci-app-frpc/001-luci-app-frpc-hide-token-openwrt-23.05.patch > patch-luci-app-frpc-hide-token.patch
curl -s https://raw.githubusercontent.com/pmkol/openwrt-plus/master/openwrt/patch/luci/applications/luci-app-frpc/002-luci-app-frpc-add-enable-flag-openwrt-23.05.patch > patch-luci-app-frpc-add-enable-flag.patch

# add pkgs
mv openwrt_pkgs/*/ ./
rm -rf openwrt_pkgs

# add luci-app-alist
mv openwrt-alist/*/ ./
rm -rf openwrt-alist

# add luci-app-airconnect
mv openwrt-airconnect/*/ ./
rm -rf openwrt-airconnect

# add luci-app-aria2
mv openwrt-aria2/*/ ./
rm -rf openwrt-aria2

# add luci-app-ddns-go
mv openwrt-ddns-go/*/ ./
rm -rf openwrt-ddns-go

# add luci-app-dufs
mv immortalwrt/luci/applications/luci-app-dufs ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-dufs/Makefile
mv immortalwrt/packages/net/dufs ./
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' dufs/Makefile

# add luci-app-eqosplus
mv openwrt-eqosplus/*/ ./
rm -rf openwrt-eqosplus

# add luci-app-frpc
mv openwrt/luci/applications/luci-app-frpc ./
patch -p4 -f -s < patch-luci-app-frpc-hide-token.patch
patch -p4 -f -s < patch-luci-app-frpc-add-enable-flag.patch
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-frpc/Makefile
sed -i 's,frp 客户端,FRP 客户端,g' luci-app-frpc/po/zh_Hans/frpc.po
rm -rf luci-app-frpc/po/!(templates|zh_Hans)
mv openwrt/packages/net/frp ./
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' frp/Makefile
sed -i 's/procd_set_param stdout $stdout/procd_set_param stdout 0/g' frp/files/frpc.init
sed -i 's/procd_set_param stderr $stderr/procd_set_param stderr 0/g' frp/files/frpc.init
sed -i 's/stdout stderr //g' frp/files/frpc.init
sed -i '/stdout:bool/d;/stderr:bool/d' frp/files/frpc.init
sed -i '/stdout/d;/stderr/d' frp/files/frpc.config
sed -i 's/env conf_inc/env conf_inc enable/g' frp/files/frpc.init
sed -i "s/'conf_inc:list(string)'/& \\\\/" frp/files/frpc.init
sed -i "/conf_inc:list/a\\\t\t\'enable:bool:0\'" frp/files/frpc.init
sed -i '/procd_open_instance/i\\t\[ "$enable" -ne 1 \] \&\& return 1\n' frp/files/frpc.init

# add luci-app-mentohust
mv openwrt-mentohust/*/ ./
rm -rf openwrt-mentohust

# add luci-app-mosdns
mv openwrt-mosdns/*/ ./
rm -rf openwrt-mosdns

# add luci-app-msd_lite
mv immortalwrt/luci/applications/luci-app-msd_lite ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-msd_lite/Makefile
mv immortalwrt/packages/net/msd_lite ./

# add luci-app-nlbwmon
mv openwrt/packages/net/nlbwmon ./
sed -i 's/stderr 1/stderr 0/g' nlbwmon/files/nlbwmon.init
mv openwrt/luci/applications/luci-app-nlbwmon ./
rm -rf luci-app-nlbwmon/po/!(templates|zh_Hans)
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-nlbwmon/Makefile
sed -i 's/services/network/g' luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's/services/network/g' luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js

# add luci-app-oaf
mv openwrt-oaf/*/ ./
rm -rf openwrt-oaf

# add luci-app-qbittorrent
mv openwrt-qbittorrent/*/ ./
rm -rf openwrt-qbittorrent

# add luci-app-samba4
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' samba4/Makefile
sed -i '/workgroup/a \\n\t## enable multi-channel' samba4/files/smb.conf.template
sed -i '/enable multi-channel/a \\tserver multi channel support = yes' samba4/files/smb.conf.template
sed -i 's/#aio read size = 0/aio read size = 0/g' samba4/files/smb.conf.template
sed -i 's/#aio write size = 0/aio write size = 0/g' samba4/files/smb.conf.template
sed -i 's/invalid users = root/#invalid users = root/g' samba4/files/smb.conf.template
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' samba4/files/smb.conf.template
sed -i 's/#create mask/create mask/g' samba4/files/smb.conf.template
sed -i 's/#directory mask/directory mask/g' samba4/files/smb.conf.template
sed -i 's/0666/0644/g;s/0777/0755/g' samba4/files/samba.config
sed -i 's/0666/0644/g;s/0777/0755/g' samba4/files/smb.conf.template
mv openwrt/luci/applications/luci-app-samba4 ./
rm -rf luci-app-samba4/po/!(templates|zh_Hans)
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-samba4/Makefile
sed -i 's/0666/0644/g;s/0744/0755/g;s/0777/0755/g' luci-app-samba4/htdocs/luci-static/resources/view/samba4.js

# add luci-theme-argon
mv openwrt-argon/*/ ./
rm -f luci-theme-argon/htdocs/luci-static/argon/img/bg.webp
cp ../bg.webp luci-theme-argon/htdocs/luci-static/argon/img/bg.webp
rm -rf openwrt-argon

# luci-app-ttyd
mv openwrt/luci/applications/luci-app-ttyd ./
rm -rf luci-app-ttyd/po/!(templates|zh_Hans)
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-ttyd/Makefile
sed -i 's/services/system/g' luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json

# add luci-app-unblockneteasemusic
sed -i 's/解除网易云音乐播放限制/网易云音乐解锁/g' luci-app-unblockneteasemusic/root/usr/share/luci/menu.d/luci-app-unblockneteasemusic.json

# add luci-app-upnp
rm -rf luci-app-upnp/po/!(templates|zh_Hans)
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-upnp/Makefile

# add luci-app-vsftpd
mv immortalwrt/luci/applications/luci-app-vsftpd ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-vsftpd/Makefile

# luci-mod-network
mv openwrt/luci/modules/luci-mod-network ./
sed -i "s/openwrt.org/www.qq.com/g" luci-mod-network/htdocs/luci-static/resources/view/network/diagnostics.js
curl -s https://raw.githubusercontent.com/pmkol/openwrt-plus/openwrt/patch/luci/dhcp/openwrt-23.05-dhcp.js > luci-mod-network/htdocs/luci-static/resources/view/network/dhcp.js

# ddns-scripts
mv immortalwrt/packages/net/ddns-scripts ./

# docker
mv immortalwrt/packages/utils/docker-compose ./
mv immortalwrt/packages/utils/tini ./
patch -p2 -f -s < patch-dockerd-fix-bridge-network.patch
patch -p2 -f -s < patch-dockerd-add-buildkit-experimental-support.patch
patch -p2 -f -s < patch-dockerd-disable-ip6tables-for-bridge-network-by-defa.patch
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' containerd/Makefile
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' docker/Makefile
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' dockerd/Makefile
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' runc/Makefile
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' docker-compose/Makefile

# netdata
mv openwrt/packages/admin/netdata ./
sed -i 's/syslog/none/g' netdata/files/netdata.conf

# iperf3
mv immortalwrt/packages/net/iperf3 ./
sed -i "s/D_GNU_SOURCE/D_GNU_SOURCE -funroll-loops/g" iperf3/Makefile

rm -rf openwrt immortalwrt

cd ../
ls -d ./packages/*/ | awk -F'/' '{print $3}' | paste -sd ' ' - > extd/packages.txt
