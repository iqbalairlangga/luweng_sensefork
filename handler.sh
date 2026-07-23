#!/system/bin/sh
# LuwengSense Pro - WebUI Handler (API)

MODDIR=${0%/*}
DATA_DIR="/data/adb/luwengsense_pro"

# Create data directory
mkdir -p "$DATA_DIR"

# API Handler
case "$1" in
    "get_status")
        # Return module status
        echo "{"
        echo "  \"module\": \"LuwengSense Pro\","
        echo "  \"version\": \"2.0\","
        echo "  \"active\": true,"
        echo "  \"uptime\": $(cat /proc/uptime | awk '{print int($1)}')"
        echo "}"
        ;;
        
    "get_network")
        # Return network info
        TCP=$(cat /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null)
        DNS=$(settings get global private_dns_specifier 2>/dev/null)
        echo "{"
        echo "  \"tcp_algorithm\": \"$TCP\","
        echo "  \"dns\": \"$DNS\""
        echo "}"
        ;;
        
    "get_cpu")
        # Return CPU info
        FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)
        GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
        echo "{"
        echo "  \"frequency\": $FREQ,"
        echo "  \"governor\": \"$GOV\""
        echo "}"
        ;;
        
    "get_memory")
        # Return memory info
        TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        FREE=$(grep MemFree /proc/meminfo | awk '{print $2}')
        AVAIL=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        echo "{"
        echo "  \"total\": $((TOTAL/1024)),"
        echo "  \"free\": $((FREE/1024)),"
        echo "  \"available\": $((AVAIL/1024))"
        echo "}"
        ;;
        
    "get_gpu")
        # Return GPU info if available
        if [ -f /sys/class/kgsl/kgsl-3d0/gpuclk ]; then
            FREQ=$(cat /sys/class/kgsl/kgsl-3d0/gpuclk 2>/dev/null)
            echo "{ \"frequency\": $FREQ }"
        else
            echo "{ \"frequency\": 0 }"
        fi
        ;;
        
    "set_profile")
        # Set performance profile
        PROFILE=$2
        echo "$PROFILE" > "$MODDIR/profile.conf"
        echo "{ \"status\": \"ok\", \"profile\": \"$PROFILE\" }"
        ;;
        
    "get_profile")
        # Get current profile
        if [ -f "$MODDIR/profile.conf" ]; then
            PROFILE=$(cat "$MODDIR/profile.conf")
        else
            PROFILE="balanced"
        fi
        echo "{ \"profile\": \"$PROFILE\" }"
        ;;
        
    *)
        echo "{ \"error\": \"Unknown command\" }"
        ;;
esac
