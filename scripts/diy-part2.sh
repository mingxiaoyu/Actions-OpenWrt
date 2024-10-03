#!/bin/bash
#

set -e  # Optional: still set this to exit on other errors

# Function to download files with error handling
download() {
    local url="$1"
    local output="$2"
    if ! wget -O "$output" "$url"; then
        echo "Warning: Failed to download $output from $url"
    fi
}

# Modify default IP
sed -i 's/192.168.1.1/192.168.3.1/g' package/base-files/files/bin/config_generate

# Modify hostname
# sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate


mkdir -p package/community

pushd package/community
popd

# 预置openclash内核
mkdir -p files/etc/openclash/core

# Meta内核版本
# CLASH_META_URL="https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-arm64.tar.gz"
CLASH_META_URL="https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-arm64.tar.gz"

# wget -qO- $CLASH_TUN_URL | tar xOvz > files/etc/openclash/core/clash_tun
if ! wget -qO- "$CLASH_META_URL" | tar xOvz > files/etc/openclash/core/clash_meta; then
    echo "Warning: Failed to download clash_meta"
fi

# 给内核权限
chmod +x files/etc/openclash/core/clash*

# meta 要GeoIP.dat 和 GeoSite.dat
GEOIP_URL="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat"
GEOSITE_URL="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
download "$GEOIP_URL" "files/etc/openclash/GeoIP.dat"
download "$GEOSITE_URL" "files/etc/openclash/GeoSite.dat"

chmod -R +x files

# Check if zzz-default-settings file exists before modifying
if [[ -f package/lean/default-settings/files/zzz-default-settings ]]; then
    # Openwrt version
    version=$(grep "DISTRIB_REVISION=" package/lean/default-settings/files/zzz-default-settings | awk -F"'" '{print $2}')
    sed -i '/DISTRIB_REVISION/d' package/lean/default-settings/files/zzz-default-settings
    sed -i "/exit 0/i echo \"DISTRIB_REVISION='${version} $(TZ=UTC-8 date "+%Y.%m.%d") Compiled by mingxiaoyu'\" >> /etc/openwrt_release" package/lean/default-settings/files/zzz-default-settings
else
    echo "Warning: zzz-default-settings file not found."
fi
