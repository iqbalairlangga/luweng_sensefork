#!/system/bin/sh
# LuwengSense Pro - Installer

# Print functions
ui_print() { echo "$1"; }

# Detect Magisk or KernelSU
if [ -f /data/adb/magisk/util_functions.sh ]; then
    . /data/adb/magisk/util_functions.sh
    install_module
    exit 0
elif [ -f /data/adb/ksu/bin/ksud ]; then
    # KernelSU
    ui_print "- KernelSU detected"
else
    ui_print "! Unsupported root manager"
    exit 1
fi

ui_print ""
ui_print "╔═══════════════════════════════════════╗"
ui_print "║    LuwengSense Pro v2.0 Installer    ║"
ui_print "╚═══════════════════════════════════════╝"
ui_print ""

# Get device info
RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
SDK=$(getprop ro.build.version.sdk)
ARCH=$(getprop ro.product.cpu.abi)

ui_print "- Device Info:"
ui_print "  RAM: $((RAM/1024))MB"
ui_print "  SDK: $SDK"
ui_print "  Arch: $ARCH"
ui_print ""

# Analyze kernel capabilities
ui_print "- Analyzing kernel..."

# Check available governors
GOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)
ui_print "  CPU Governors: $GOVS"

# Check available TCP algorithms
TCP=$(cat /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null)
ui_print "  TCP Algorithms: $TCP"

# Check available I/O schedulers
IO=$(cat /sys/block/sda/queue/scheduler 2>/dev/null || cat /sys/block/mmcblk0/queue/scheduler 2>/dev/null)
ui_print "  I/O Schedulers: $IO"

# Check ZRAM
if [ -e /sys/block/zram0 ]; then
    ui_print "  ZRAM: Available"
else
    ui_print "  ZRAM: Not available"
fi

ui_print ""

# Set default profile
echo "balanced" > "$MODPATH/profile.conf"
ui_print "- Default profile: Balanced"
ui_print ""

# Set permissions
ui_print "- Setting permissions..."
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/handler.sh" 0 0 0755

ui_print ""
ui_print "╔═══════════════════════════════════════╗"
ui_print "║      Installation Complete!           ║"
ui_print "║                                       ║"
ui_print "║  Reboot to apply tweaks               ║"
ui_print "╚═══════════════════════════════════════╝"
ui_print ""
