#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.3.1/g' package/base-files/files/bin/config_generate

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

sed -i '$a CONFIG_PHY_ROCKCHIP_INNO_USB3=y' target/linux/rockchip/armv8/config-5.4
sed -i '$a CONFIG_PHY_ROCKCHIP_INNO_USB3=y' target/linux/rockchip/armv8/config-5.10
sed -i '$a CONFIG_PHY_ROCKCHIP_INNO_USB3=y' target/linux/rockchip/armv8/config-5.15
sed -i '$a CONFIG_PHY_ROCKCHIP_INNO_USB3=y' target/linux/rockchip/armv8/config-6.1
sed -i '$a CONFIG_PHY_ROCKCHIP_INNO_USB3=y' target/linux/rockchip/armv8/config-6.6

mkdir package/community

pushd package/community


popd

# passwall2 singbox
mkdir -p files/usr/share/singbox
wget -O files/usr/share/singbox/geoip.db  https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.db 
wget -O files/usr/share/singbox/geosite.db https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.db  

# 预置openclash内核
mkdir -p files/etc/openclash/core

# openclash 的 TUN内核
CLASH_TUN_VERSION=$(curl -sL https://github.com/vernesong/OpenClash/raw/core/master/core_version | head -n 2 | tail -n 1)
CLASH_TUN_URL="https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux-arm64-$CLASH_TUN_VERSION.gz"

# Meta内核版本
#CLASH_META_URL="https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-arm64.tar.gz"
CLASH_META_URL="https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz"

# wget -qO- $CLASH_TUN_URL  | tar xOvz > files/etc/openclash/core/clash_tun
wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta

# 给内核权限
chmod +x files/etc/openclash/core/clash*

# meta 要GeoIP.dat 和 GeoSite.dat
GEOIP_URL=https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat
GEOSITE_URL=https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat
wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat

# Country.mmdb
COUNTRY_FULL_URL=https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb
wget -qO- $COUNTRY_FULL_URL > files/etc/openclash/Country.mmdb

chmod -R +x files
