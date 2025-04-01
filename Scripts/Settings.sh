#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_FILE="./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
#修改WIFI名称
sed -i "s/ImmortalWrt/$WRT_SSID/g" $WIFI_FILE
#修改WIFI加密
sed -i "s/encryption=.*/encryption='sae-mixed'/g" $WIFI_FILE
#修改WIFI密码
sed -i "/set wireless.default_\${dev}.encryption='sae-mixed'/a \\\t\t\t\t\t\set wireless.default_\${dev}.key='$WRT_WORD'" $WIFI_FILE

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

# 调整为512布局
CFG_DTS="./target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek/mt7986a-xiaomi-redmi-router-ax6000.dts"
sed -i "s/reg = <0x600000 0x6e00000>/reg = <0x600000 0x1ea00000>/g" $CFG_DTS

# 更改菜单名字
echo -e "\nmsgid \"MosDNS\"" >> package/mosdns/luci-app-mosdns/po/zh_Hans/mosdns.po
echo -e "msgstr \"转发分流\"" >> package/mosdns/luci-app-mosdns/po/zh_Hans/mosdns.po

echo -e "\nmsgid \"Lucky\"" >> package/lucky/luci-app-lucky/po/zh_Hans/lucky.po
echo -e "msgstr \"大吉大利\"" >> package/lucky/luci-app-lucky/po/zh_Hans/lucky.po

#echo -e "\nmsgid \"AList\"" >> package/alist/luci-app-alist/po/zh_Hans/alist.po
#echo -e "msgstr \"聚合网盘\"" >> package/alist/luci-app-alist/po/zh_Hans/alist.po

echo -e "\nmsgid \"Tailscale\"" >> package/luci-app-tailscale/po/zh_Hans/tailscale.po
echo -e "msgstr \"虚拟组网\"" >> package/luci-app-tailscale/po/zh_Hans/tailscale.po

echo -e "\nmsgid \"Nikki\"" >> package/nikki/luci-app-nikki/po/zh_Hans/nikki.po
echo -e "msgstr \"科学上网\"" >> package/nikki/luci-app-nikki/po/zh_Hans/nikki.po

echo -e "\nmsgid \"UPnP\"" >> package/mtk/applications/luci-app-upnp-mtk-adjust/po/zh_Hans/upnp.po
echo -e "msgstr \"即插即用\"" >> package/mtk/applications/luci-app-upnp-mtk-adjust/po/zh_Hans/upnp.po

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config
echo "CONFIG_TARGET_OPTIONS=y" >> ./.config
echo "CONFIG_TARGET_OPTIMIZATION=\"-O2 -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53\"" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi

#调整mtk系列配置
sed -i '/TARGET.*mediatek/d' ./.config
sed -i '/TARGET_MULTI_PROFILE/d' ./.config
sed -i '/TARGET_PER_DEVICE_ROOTFS/d' ./.config
cat $GITHUB_WORKSPACE/Config/$WRT_CONFIG.txt >> .config

#安装误删argon2
./scripts/feeds install node-argon2
