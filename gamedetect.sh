#!/system/bin/sh
# LuwengSense Pro - Auto Detect (Game + Screen)
# Runs in background, detects foreground app and screen state

MODDIR=${0%/*}
LOGFILE=/data/adb/luwengsense_pro.log
GAME_LIST="$MODDIR/games.conf"
CURRENT_MODE_FILE="/data/adb/luwengsense_mode"
LAST_SCREEN_STATE="on"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOGFILE
}

# Default game list (popular games)
DEFAULT_GAMES="com.mobile.legends com.miHoYo.GenshinImpact com.tencent.ig com.pubg.krmobile com.varena.codmobile com.supercell.clashofclans com.supercell.clashroyale com.supercell.brawlstars com.ea.gp.fifamobile com.garena.game.codm com.activision.callofduty.shooter com.epicgames.fortnite com.riotgames.league.wildrift com.moonton.magicrush com.gameloft.android.ANMP.GoftDMA6 com.mobilelegends.cod com.riotgames.league.teamfighttactics com.tencent.tmgp.codmobile com.roblox.client com.mojang.minecraftpe com.dts.freefireth"

# Create game list if not exists
if [ ! -f "$GAME_LIST" ]; then
    echo "$DEFAULT_GAMES" > "$GAME_LIST"
    log "Created default game list"
fi

# ==========================================
# MODE FUNCTIONS
# ==========================================

# Gaming Mode
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
    
    # Network - Optimize for gaming
    echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
    sysctl -w net.ipv4.tcp_fastopen=3 2>/dev/null
    sysctl -w net.ipv4.tcp_low_latency=1 2>/dev/null
    
    # Disable logging
    setprop persist.logd.size 0
    
    echo "gaming" > "$CURRENT_MODE_FILE"
    log "GAMING MODE: Active"
}

# Balanced Mode
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
            MAX_FREQ=$(cat "$gpu/max_freq")
            MIN_FREQ=$(cat "$gpu/min_freq" 2>/dev/null || echo 0)
            MID=$(( MAX_FREQ / 2 ))
            echo "$MID" > "$gpu/min_freq" 2>/dev/null
        fi
    done
    
    # Network - Normal
    sysctl -w net.ipv4.tcp_low_latency=0 2>/dev/null
    
    # Restore logging
    setprop persist.logd.size 262144
    
    echo "balanced" > "$CURRENT_MODE_FILE"
    log "BALANCED MODE: Active"
}

# Battery Mode (Screen Off)
apply_battery_mode() {
    log "BATTERY MODE: Screen off - Activating..."
    
    # CPU - Power saving
    GOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)
    if echo "$GOVS" | grep -q "powersave"; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "powersave" > "$cpu" 2>/dev/null
        done
    elif echo "$GOVS" | grep -q "schedutil"; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "schedutil" > "$cpu" 2>/dev/null
        done
    fi
    
    # Set min freq to lowest
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        if [ -f "$policy/cpuinfo_min_freq" ] && [ -f "$policy/scaling_min_freq" ]; then
            MIN=$(cat "$policy/cpuinfo_min_freq")
            echo "$MIN" > "$policy/scaling_min_freq" 2>/dev/null
        fi
    done
    
    # GPU - Lowest frequency
    for gpu in /sys/class/kgsl/kgsl-3d0/devfreq /sys/devices/platform/*.gpu/devfreq; do
        if [ -d "$gpu" ] && [ -f "$gpu/min_freq" ] && [ -f "$gpu/max_freq" ]; then
            MIN_FREQ=$(cat "$gpu/min_freq")
            MAX_FREQ=$(cat "$gpu/max_freq")
            LOW=$(( MIN_FREQ + (MAX_FREQ - MIN_FREQ) / 4 ))
            echo "$LOW" > "$gpu/min_freq" 2>/dev/null
        fi
    done
    
    # Disable WiFi scan
    settings put global wifi_scan_always_enabled 0 2>/dev/null
    
    # Reduce background activity
    sysctl -w vm.dirty_ratio=5 2>/dev/null
    sysctl -w vm.dirty_background_ratio=2 2>/dev/null
    
    # Disable animations
    settings put global window_animation_scale 0 2>/dev/null
    settings put global transition_animation_scale 0 2>/dev/null
    settings put global animator_duration_scale 0 2>/dev/null
    
    # Enable doze mode
    settings put global doze_enabled 1 2>/dev/null
    
    echo "battery" > "$CURRENT_MODE_FILE"
    log "BATTERY MODE: Active"
}

# ==========================================
# DETECTION FUNCTIONS
# ==========================================

# Check screen state (1 = on, 0 = off)
get_screen_state() {
    # Method 1: Check display power
    if dumpsys power 2>/dev/null | grep -q "mScreenOn=false"; then
        echo 0
        return
    fi
    
    # Method 2: Check screen brightness
    if [ -f /sys/class/leds/lcd-backlight/brightness ]; then
        BRIGHTNESS=$(cat /sys/class/leds/lcd-backlight/brightness 2>/dev/null)
        if [ "$BRIGHTNESS" = "0" ]; then
            echo 0
            return
        fi
    fi
    
    # Method 3: Check power state
    if dumpsys display 2>/dev/null | grep -q "mScreenState=OFF"; then
        echo 0
        return
    fi
    
    echo 1
}

# Get foreground app
get_foreground_app() {
    FOCUSED=""
    
    # Method 1: dumpsys activity
    FOCUSED=$(dumpsys activity activities 2>/dev/null | grep "mResumedActivity" | awk '{print $NF}' | cut -d'/' -f1 | sed 's/}//' | sed 's/^ *//')
    
    # Method 2: dumpsys window
    if [ -z "$FOCUSED" ]; then
        FOCUSED=$(dumpsys window 2>/dev/null | grep -E "mCurrentFocus|mFocusedApp" | head -1 | grep -oP '[a-zA-Z0-9_.]+/[a-zA-Z0-9_.]+' | head -1 | cut -d'/' -f1)
    fi
    
    echo "$FOCUSED"
}

# ==========================================
# MAIN LOOP
# ==========================================

log "Auto-detect service started"

while true; do
    SCREEN_STATE=$(get_screen_state)
    CURRENT_MODE=$(cat "$CURRENT_MODE_FILE" 2>/dev/null || echo "balanced")
    
    # --- SCREEN OFF DETECTION ---
    if [ "$SCREEN_STATE" = "0" ]; then
        if [ "$LAST_SCREEN_STATE" = "on" ]; then
            log "Screen turned OFF"
            LAST_SCREEN_STATE="off"
            
            # Switch to battery mode
            if [ "$CURRENT_MODE" != "battery" ]; then
                apply_battery_mode
            fi
        fi
        sleep 5
        continue
    fi
    
    # --- SCREEN ON ---
    if [ "$LAST_SCREEN_STATE" = "off" ]; then
        log "Screen turned ON"
        LAST_SCREEN_STATE="on"
        
        # Return to balanced mode
        if [ "$CURRENT_MODE" = "battery" ]; then
            apply_balanced_mode
        fi
    fi
    
    # --- GAME DETECTION (Only when screen is on) ---
    if [ -f "$MODDIR/autogame.conf" ] && [ "$(cat "$MODDIR/autogame.conf")" = "1" ]; then
        FOCUSED_APP=$(get_foreground_app)
        
        # Check if it's a game
        IS_GAME=0
        for game in $(cat "$GAME_LIST"); do
            if echo "$FOCUSED_APP" | grep -q "$game"; then
                IS_GAME=1
                break
            fi
        done
        
        # Apply mode
        if [ "$IS_GAME" = "1" ] && [ "$CURRENT_MODE" != "gaming" ]; then
            apply_gaming_mode
        elif [ "$IS_GAME" = "0" ] && [ "$CURRENT_MODE" = "gaming" ]; then
            apply_balanced_mode
        fi
    fi
    
    sleep 3
done
