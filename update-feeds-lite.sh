#!/bin/bash

# backup feeds
mv lite /tmp
mkdir -p lite
cd lite

# download feeds
git clone https://github.com/immortalwrt/luci immortalwrt/luci -b master --depth 1
git clone https://github.com/immortalwrt/packages immortalwrt/packages -b master --depth 1
git clone https://github.com/immortalwrt/homeproxy immortalwrt/luci-app-homeproxy --depth 1
git clone https://github.com/sbwml/openwrt_helloworld --depth 1
git clone https://github.com/pmkol/openwrt-mihomo --depth 1
git clone https://github.com/pmkol/v2ray-geodata --depth 1
rm -rf immortalwrt/luci-app-homeproxy/{LICENSE,README}
rm -rf openwrt_helloworld/{luci-app-homeproxy,luci-app-mihomo,mihomo,v2ray-geodata}
rm -rf openwrt-daed/PIC
mv -f openwrt_helloworld/*.patch ./

# add helloworld
mv openwrt_helloworld/*/ ./
rm -rf openwrt_helloworld

# luci-app-dae
mv immortalwrt/luci/applications/luci-app-dae ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-dae/Makefile
mv immortalwrt/packages/net/dae ./
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' dae/Makefile

# add luci-app-mihomo
mv openwrt-mihomo/*/ ./
rm -rf openwrt-mihomo

# add luci-app-passwall
PASSWALL_VERSION=$(curl -s "https://api.github.com/repos/xiaorouji/openwrt-passwall/tags" | jq -r '.[0].name')
if [ "$(grep ^PKG_VERSION luci-app-passwall/Makefile | cut -d '=' -f 2 | tr -d ' ')" != "$PASSWALL_VERSION" ]; then
    rm -rf luci-app-passwall
    git clone https://github.com/xiaorouji/openwrt-passwall.git -b "$PASSWALL_VERSION" --depth 1
    patch -p1 -f -s -d openwrt-passwall < patch-luci-app-passwall.patch
    if [ $? -eq 0 ]; then
        rm -rf luci-app-passwall
        mv openwrt-passwall/luci-app-passwall ./
        rm -rf openwrt-passwall
    else
        rm -rf openwrt-passwall
    fi
fi

# haproxy
mv immortalwrt/packages/net/haproxy ./

rm -rf immortalwrt

# create packages list
cd ../
ls -d ./lite/*/ | awk -F'/' '{print $3}' | paste -sd ' ' - > packages-lite.txt
