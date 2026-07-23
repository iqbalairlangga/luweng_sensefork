#!/system/bin/sh
# LuwengSense Pro - Installer
# Clean, real tweaks for signal & gaming

SKIPUNZIP=1

# Print functions
ui_print() { echo "$1"; }
print_error() { ui_print "Error: $1"; exit 1; }

# Check root
if [ ! -d "/data/adb" ]; then
    print_error "Magisk/KernelSU not detected"
fi

ui_print "╔═══════════════════════════════════════╗"
ui_print "║    LuwengSense Pro v2.0 Installer    ║"
ui_print "╚═══════════════════════════════════════╝"
ui_print ""

# Extract files
ui_print "- Extracting files..."
unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >/dev/null

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

# Profile selection
ui_print "- Select Profile:"
ui_print "  1) Balanced (Recommended)"
ui_print "  2) Gaming (Max Performance)"
ui_print "  3) Battery (Max Efficiency)"
ui_print ""
ui_print "  Default: 1 (Balanced)"
ui_print ""
ui_print "  Press Vol+ to continue with default"
ui_print ""

# Wait for selection
KEYTIMEOUT=5
KEYS=""

while true; do
    if getevent -l -t /dev/input/event2 | grep -q "KEY_VOLUMEUP"; then
        echo "1" > "$MODPATH/profile.conf"
        ui_print "  > Balanced profile selected"
        break
    elif getevent -l -t /dev/input/event2 | grep -q "KEY_VOLUMEDOWN"; then
        echo "2" > "$MODPATH/profile.conf"
        ui_print "  > Gaming profile selected"
        break
    fi
done

ui_print ""

# Set permissions
ui_print "- Setting permissions..."
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/handler.sh" 0 0 0755
set_perm_recursive "$MODPATH/webroot" 0 0 0755 0644

ui_print ""
ui_print "╔═══════════════════════════════════════╗"
ui_print "║      Installation Complete!           ║"
ui_print "║                                       ║"
ui_print "║  Reboot to apply tweaks               ║"
ui_print "╚═══════════════════════════════════════╝"
ui_print ""
