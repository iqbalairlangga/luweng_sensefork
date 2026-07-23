#!/system/bin/sh
# LuwengSense Pro - WebUI Handler (API)

MODDIR=${0%/*}
DATA_DIR="/data/adb/luwengsense_pro"
GAME_LIST="$MODDIR/games.conf"
MODE_FILE="/data/adb/luwengsense_mode"

# Create data directory
mkdir -p "$DATA_DIR"

# API Handler
case "$1" in
    "get_status")
        # Return module status
        MODE=$(cat "$MODE_FILE" 2>/dev/null || echo "balanced")
        echo "{"
        echo "  \"module\": \"LuwengSense Pro\","
        echo "  \"version\": \"2.0\","
        echo "  \"active\": true,"
        echo "  \"mode\": \"$MODE\","
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
        
    "get_mode")
        # Get current mode
        MODE=$(cat "$MODE_FILE" 2>/dev/null || echo "balanced")
        echo "{ \"mode\": \"$MODE\" }"
        ;;
        
    "get_autogame")
        # Get auto-game status
        if [ -f "$MODDIR/autogame.conf" ] && [ "$(cat "$MODDIR/autogame.conf")" = "1" ]; then
            echo "{ \"enabled\": true }"
        else
            echo "{ \"enabled\": false }"
        fi
        ;;
        
    "set_autogame")
        # Set auto-game status
        ENABLED=$2
        if [ "$ENABLED" = "1" ]; then
            echo "1" > "$MODDIR/autogame.conf"
            echo "{ \"status\": \"ok\", \"enabled\": true }"
        else
            echo "0" > "$MODDIR/autogame.conf"
            echo "{ \"status\": \"ok\", \"enabled\": false }"
        fi
        ;;
        
    "get_games")
        # Get game list
        if [ -f "$GAME_LIST" ]; then
            echo "["
            FIRST=1
            for game in $(cat "$GAME_LIST"); do
                [ "$FIRST" = "0" ] && echo ","
                echo "  \"$game\""
                FIRST=0
            done
            echo "]"
        else
            echo "[]"
        fi
        ;;
        
    "add_game")
        # Add game to list
        PACKAGE=$2
        if [ -n "$PACKAGE" ]; then
            if [ -f "$GAME_LIST" ]; then
                if ! grep -q "$PACKAGE" "$GAME_LIST"; then
                    echo "$PACKAGE" >> "$GAME_LIST"
                fi
            else
                echo "$PACKAGE" > "$GAME_LIST"
            fi
            echo "{ \"status\": \"ok\", \"package\": \"$PACKAGE\" }"
        else
            echo "{ \"error\": \"No package name provided\" }"
        fi
        ;;
        
    "remove_game")
        # Remove game from list
        PACKAGE=$2
        if [ -n "$PACKAGE" ] && [ -f "$GAME_LIST" ]; then
            sed -i "/$PACKAGE/d" "$GAME_LIST"
            echo "{ \"status\": \"ok\", \"removed\": \"$PACKAGE\" }"
        else
            echo "{ \"error\": \"Package not found\" }"
        fi
        ;;
        
    "get_foreground")
        # Get current foreground app
        FOCUSED=$(dumpsys activity activities | grep "mResumedActivity" | awk '{print $NF}' | cut -d'/' -f1 | sed 's/}//')
        echo "{ \"app\": \"$FOCUSED\" }"
        ;;
        
    *)
        echo "{ \"error\": \"Unknown command\" }"
        ;;
esac
