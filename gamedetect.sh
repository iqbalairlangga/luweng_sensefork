#!/system/bin/sh
# LuwengSense Pro - Game Auto-Detect
# Runs in background, detects foreground app and switches to gaming mode

MODDIR=${0%/*}
LOGFILE=/data/adb/luwengsense_pro.log
GAME_LIST="$MODDIR/games.conf"
CURRENT_MODE_FILE="/data/adb/luwengsense_mode"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOGFILE
}

# Default game list (popular games)
DEFAULT_GAMES="com.mobile.legends com.miHoYo.GenshinImpact com.tencent.ig com.pubg.krmobile com.varena.codmobile com.supercell.clashofclans com.supercell.clashroyale com.supercell.brawlstars com.ea.gp.fifamobile com.garena.game.codm com.activision.callofduty.shooter com.epicgames.fortnite com.riotgames.league.wildrift com.moonton.magicrush com.gameloft.android.ANMP.GoftDMA6 com.mobilelegends.cod com.riotgames.league.teamfighttactics com.tencent.tmgp.codmobile"

# Create game list if not exists
if [ ! -f "$GAME_LIST" ]; then
    echo "$DEFAULT_GAMES" > "$GAME_LIST"
    log "Created default game list"
fi

# Function to apply gaming mode
apply_gaming_mode() {
    log "GAMING MODE: Activating..."
    
    # CPU - Performance
    GOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)
    if echo "$GOVS" | grep -q "performance"; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "performance" > "$cpu" 2>/dev/null
        done
    fi
    
    # Set min freq higher
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        if [ -f "$policy/cpuinfo_min_freq" ] && [ -f "$policy/scaling_min_freq" ]; then
            MAX=$(cat "$policy/cpuinfo_max_freq")
            MIN=$(cat "$policy/cpuinfo_min_freq")
            # 70% of max
            NEW_MIN=$(( MAX * 70 / 100 ))
            [ "$NEW_MIN" -gt "$MIN" ] && echo "$NEW_MIN" > "$policy/scaling_min_freq" 2>/dev/null
        fi
    done
    
    # GPU - Max frequency
    for gpu in /sys/class/kgsl/kgsl-3d0/devfreq /sys/devices/platform/*.gpu/devfreq; do
        if [ -d "$gpu" ] && [ -f "$gpu/max_freq" ]; then
            MAX_FREQ=$(cat "$gpu/max_freq")
            echo "$MAX_FREQ" > "$gpu/min_freq" 2>/dev/null
        fi
    done
    
    # Disable thermal mitigation (if controllable)
    for thermal in /sys/class/thermal/thermal_zone*/trip_point_*_temp; do
        echo "95000" > "$thermal" 2>/dev/null
    done
    
    # Network - Optimize for gaming
    echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
    sysctl -w net.ipv4.tcp_fastopen=3 2>/dev/null
    sysctl -w net.ipv4.tcp_low_latency=1 2>/dev/null
    
    # Disable logging
    setprop persist.logd.size 0
    setprop log.tag VERBOSE
    
    # Set mode file
    echo "gaming" > "$CURRENT_MODE_FILE"
    log "GAMING MODE: Active"
}

# Function to apply balanced mode
apply_balanced_mode() {
    log "BALANCED MODE: Activating..."
    
    # CPU - Balanced
    GOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)
    if echo "$GOVS" | grep -q "schedutil"; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "schedutil" > "$cpu" 2>/dev/null
        done
    fi
    
    # Reset min freq
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        if [ -f "$policy/cpuinfo_min_freq" ] && [ -f "$policy/scaling_min_freq" ]; then
            MIN=$(cat "$policy/cpuinfo_min_freq")
            echo "$MIN" > "$policy/scaling_min_freq" 2>/dev/null
        fi
    done
    
    # GPU - Balanced
    for gpu in /sys/class/kgsl/kgsl-3d0/devfreq /sys/devices/platform/*.gpu/devfreq; do
        if [ -d "$gpu" ] && [ -f "$gpu/min_freq" ]; then
            MIN_FREQ=$(cat "$gpu/min_freq")
            MAX_FREQ=$(cat "$gpu/max_freq")
            MID=$(( (MIN_FREQ + MAX_FREQ) / 2 ))
            echo "$MID" > "$gpu/min_freq" 2>/dev/null
        fi
    done
    
    # Network - Normal
    sysctl -w net.ipv4.tcp_low_latency=0 2>/dev/null
    
    # Restore logging
    setprop persist.logd.size 262144
    
    # Set mode file
    echo "balanced" > "$CURRENT_MODE_FILE"
    log "BALANCED MODE: Active"
}

# Main detection loop
log "Game detector started"

while true; do
    # Check if auto-detect is enabled
    if [ -f "$MODDIR/autogame.conf" ] && [ "$(cat "$MODDIR/autogame.conf")" = "1" ]; then
        # Get foreground app
        FOCUSED_APP=""
        
        # Android 10+
        if [ -f /proc/$(pidof system_server)/task/*/children ]; then
            FOCUSED_APP=$(dumpsys window | grep -E "mCurrentFocus|mFocusedApp" | head -1 | grep -oP 'u0a\d+' | head -1)
        fi
        
        # Fallback method
        if [ -z "$FOCUSED_APP" ]; then
            FOCUSED_APP=$(dumpsys activity activities | grep "mResumedActivity" | awk '{print $NF}' | cut -d'/' -f1 | sed 's/}//')
        fi
        
        # Check if it's a game
        IS_GAME=0
        for game in $(cat "$GAME_LIST"); do
            if echo "$FOCUSED_APP" | grep -q "$game"; then
                IS_GAME=1
                break
            fi
        done
        
        # Apply mode
        CURRENT_MODE=$(cat "$CURRENT_MODE_FILE" 2>/dev/null || echo "balanced")
        
        if [ "$IS_GAME" = "1" ] && [ "$CURRENT_MODE" != "gaming" ]; then
            apply_gaming_mode
        elif [ "$IS_GAME" = "0" ] && [ "$CURRENT_MODE" = "gaming" ]; then
            apply_balanced_mode
        fi
    fi
    
    sleep 3
done
