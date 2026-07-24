#!/system/bin/sh
# LuwengSense Pro v3.2 - Installer

ui_print() { echo "$1"; }

if [ -f /data/adb/magisk/util_functions.sh ]; then
    . /data/adb/magisk/util_functions.sh
    install_module
    exit 0
elif [ -f /data/adb/ksu/bin/ksud ]; then
    ui_print "- KernelSU detected"
else
    ui_print "! Unsupported root manager"
    exit 1
fi

ui_print ""
ui_print "╔═══════════════════════════════════════╗"
ui_print "║    LuwengSense Pro v3.2 Installer    ║"
ui_print "╚═══════════════════════════════════════╝"
ui_print ""
ui_print "- What's New in v3.2:"
ui_print "  * Gaming: Significant FPS stability & rendering"
ui_print "  * Balanced: Improved multitasking & scrolling"
ui_print "  * Battery: More stable power saving"
ui_print ""

RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
SDK=$(getprop ro.build.version.sdk)
ARCH=$(getprop ro.product.cpu.abi)

ui_print "- Device Info:"
ui_print "  RAM: $((RAM/1024))MB"
ui_print "  SDK: $SDK"
ui_print "  Arch: $ARCH"
ui_print ""

ui_print "- Analyzing kernel..."
GOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)
ui_print "  CPU Governors: $GOVS"
TCP=$(cat /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null)
ui_print "  TCP Algorithms: $TCP"
IO=$(cat /sys/block/sda/queue/scheduler 2>/dev/null || cat /sys/block/mmcblk0/queue/scheduler 2>/dev/null)
ui_print "  I/O Schedulers: $IO"
if [ -e /sys/block/zram0 ]; then
    ui_print "  ZRAM: Available"
else
    ui_print "  ZRAM: Not available"
fi
ui_print ""

echo "balanced" > "$MODPATH/profile.conf"
echo "1" > "$MODPATH/autogame.conf"
ui_print "- Default profile: Balanced"
ui_print "- Auto Gaming: Enabled"
ui_print ""

ui_print "- Setting permissions..."
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/handler.sh" 0 0 0755
set_perm "$MODPATH/gamedetect.sh" 0 0 0755

ui_print ""
ui_print "╔═══════════════════════════════════════╗"
ui_print "║   LuwengSense Pro v3.2 Installed!    ║"
ui_print "║                                       ║"
ui_print "║   Reboot to apply v3.2 tweaks        ║"
ui_print "╚═══════════════════════════════════════╝"
ui_print ""
