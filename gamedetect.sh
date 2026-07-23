#!/system/bin/sh
# LuwengSense Pro - Auto Detect (Game + Screen)
# MAXIMUM PERFORMANCE mode switching

MODDIR=${0%/*}
LOGFILE=/data/adb/luwengsense_pro.log
GAME_LIST="$MODDIR/games.conf"
CURRENT_MODE_FILE="/data/adb/luwengsense_mode"
LAST_SCREEN_STATE="on"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOGFILE
}

# Default game list (popular games)
DEFAULT_GAMES="com.mobile.legends com.miHoYo.GenshinImpact com.tencent.ig com.pubg.krmobile com.varena.codmobile com.supercell.clashofclans com.supercell.clashroyale com.supercell.brawlstars com.ea.gp.fifamobile com.garena.game.codm com.activision.callofduty.shooter com.epicgames.fortnite com.riotgames.league.wildrift com.moonton.magicrush com.gameloft.android.ANMP.GoftDMA6 com.mobilelegends.cod com.riotgames.league.teamfighttactics com.tencent.tmgp.codmobile com.roblox.client com.mojang.minecraftpe com.dts.freefireth com.supercell.hayday com.innersloth.spacemafia com.kiloo.subwaysurfers com.imangi.templerun2 com.outfit7.mytalkingtom2 com.miniclip.eightballpool"

# Create game list if not exists
if [ ! -f "$GAME_LIST" ]; then
    echo "$DEFAULT_GAMES" > "$GAME_LIST"
    log "Created default game list"
fi

# ==========================================
# GAMING MODE (MAXIMUM PERFORMANCE)
# ==========================================
apply_gaming_mode() {
    log "GAMING MODE: Activating MAXIMUM..."
    
    # --- CPU: Performance Governor ---
    GOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)
    if echo "$GOVS" | grep -q "performance"; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "performance" > "$cpu" 2>/dev/null
        done
    fi
    
    # --- CPU: Max Frequency ---
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        if [ -f "$policy/cpuinfo_max_freq" ] && [ -f "$policy/scaling_min_freq" ]; then
            MAX=$(cat "$policy/cpuinfo_max_freq")
            # 85% of max for minimum
            AGGRESSIVE_MIN=$(( MAX * 85 / 100 ))
            echo "$AGGRESSIVE_MIN" > "$policy/scaling_min_freq" 2>/dev/null
            echo "$MAX" > "$policy/scaling_max_freq" 2>/dev/null
        fi
    done
    
    # --- CPU: Boost ---
    if [ -d /dev/stune/top-app ]; then
        echo 100 > /dev/stune/top-app/schedtune.boost 2>/dev/null
        echo 1 > /dev/stune/top-app/schedtune.prefer_idle 2>/dev/null
    fi
    if [ -d /dev/cpuset/top-app ]; then
        echo 0-7 > /dev/cpuset/top-app/cpus 2>/dev/null
    fi
    log "CPU: Set to MAXIMUM PERFORMANCE"
    
    # --- GPU: Maximum Frequency ---
    for gpu in /sys/class/kgsl/kgsl-3d0/devfreq /sys/devices/platform/*.gpu/devfreq; do
        if [ -d "$gpu" ]; then
            if [ -f "$gpu/max_freq" ]; then
                MAX_FREQ=$(cat "$gpu/max_freq")
                echo "$MAX_FREQ" > "$gpu/min_freq" 2>/dev/null
            fi
            # Set governor to performance
            echo performance > "$gpu/governor" 2>/dev/null
        fi
    done
    
    # --- Adreno GPU (Qualcomm) MAX ---
    if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
        echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/busy_wait 2>/dev/null
        echo 1 > /sys/class/kgsl/kgsl-3d0/force_clk_on 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/idle_timer 2>/dev/null
        echo 1 > /sys/class/kgsl/kgsl-3d0/force_rail_on 2>/dev/null
        echo 300 > /sys/class/kgsl/kgsl-3d0/max_pwrlevel 2>/dev/null
        log "GPU: Adreno MAXIMUM"
    fi
    
    # --- Mali GPU (MediaTek/Exynos/ARM) MAX ---
    # Method 1: Mali via mali.0
    if [ -d /sys/devices/platform/mali.0 ]; then
        echo performance > /sys/devices/platform/mali.0/devfreq/governor 2>/dev/null
        echo 1 > /sys/devices/platform/mali.0/force_clk_on 2>/dev/null
        echo 1 > /sys/devices/platform/mali.0/force_rail_on 2>/dev/null
        echo 0 > /sys/devices/platform/mali.0/idle_timer 2>/dev/null
        log "GPU: Mali (mali.0) MAXIMUM"
    fi
    
    # Method 2: Mali via mali0
    if [ -d /sys/class/misc/mali0 ]; then
        echo 1 > /sys/class/misc/mali0/force_clk_on 2>/dev/null
        echo 1 > /sys/class/misc/mali0/force_rail_on 2>/dev/null
        echo 0 > /sys/class/misc/mali0/idle_timer 2>/dev/null
        log "GPU: Mali (mali0) MAXIMUM"
    fi
    
    # Method 3: Mali via device tree
    for mali in /sys/devices/platform/soc/*.mali /sys/devices/platform/*.mali; do
        if [ -d "$mali" ]; then
            echo performance > "$mali/devfreq/governor" 2>/dev/null
            echo 1 > "$mali/force_clk_on" 2>/dev/null
            echo 1 > "$mali/force_rail_on" 2>/dev/null
            echo 0 > "$mali/idle_timer" 2>/dev/null
            log "GPU: Mali (device tree) MAXIMUM"
        fi
    done
    
    # Method 4: Mali via devfreq
    for devfreq in /sys/class/devfreq/*.mali /sys/class/devfreq/mali*; do
        if [ -d "$devfreq" ]; then
            echo performance > "$devfreq/governor" 2>/dev/null
            MAX_FREQ=$(cat "$devfreq/max_freq" 2>/dev/null)
            if [ -n "$MAX_FREQ" ]; then
                echo "$MAX_FREQ" > "$devfreq/min_freq" 2>/dev/null
            fi
            log "GPU: Mali (devfreq) MAXIMUM"
        fi
    done
    
    # Method 5: Mali via kernel driver
    if [ -f /sys/module/mali_kbase/parameters/gpu_clock_speed ]; then
        MAX_SPEED=$(cat /sys/module/mali_kbase/parameters/gpu_clock_speed 2>/dev/null)
        echo "$MAX_SPEED" > /sys/module/mali_kbase/parameters/gpu_clock_speed 2>/dev/null
        log "GPU: Mali kernel driver MAXIMUM"
    fi
    
    # --- Samsung Exynos GPU MAX ---
    if [ -d /sys/devices/platform/exynos5-devfreq/gpu ]; then
        echo performance > /sys/devices/platform/exynos5-devfreq/gpu/governor 2>/dev/null
        log "GPU: Exynos MAXIMUM"
    fi
    
    # --- Generic GPU MAX ---
    for gpu_dev in /sys/devices/platform/soc/*.gpu /sys/devices/platform/*.gpu; do
        if [ -d "$gpu_dev" ]; then
            echo performance > "$gpu_dev/devfreq/governor" 2>/dev/null
            echo 1 > "$gpu_dev/force_clk_on" 2>/dev/null
            log "GPU: Generic MAXIMUM"
        fi
    done
    
    log "GPU: ALL TYPES MAXIMUM (Adreno + Mali)"
    
    # --- Network: Ultra Low Latency ---
    echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
    sysctl -w net.ipv4.tcp_fastopen=3 2>/dev/null
    sysctl -w net.ipv4.tcp_low_latency=1 2>/dev/null
    sysctl -w net.ipv4.tcp_notsent_lowat=16384 2>/dev/null
    sysctl -w net.ipv4.tcp_window_scaling=1 2>/dev/null
    sysctl -w net.ipv4.tcp_mtu_probing=1 2>/dev/null
    sysctl -w net.ipv4.tcp_sack=1 2>/dev/null
    sysctl -w net.ipv4.tcp_timestamps=1 2>/dev/null
    sysctl -w net.ipv4.tcp_no_metrics_save=1 2>/dev/null
    sysctl -w net.ipv4.tcp_abort_on_overflow=0 2>/dev/null
    sysctl -w net.ipv4.tcp_synack_retries=2 2>/dev/null
    sysctl -w net.ipv4.tcp_syn_retries=2 2>/dev/null
    log "Network: LOW LATENCY mode"
    
    # --- I/O: Maximum Performance ---
    for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue /sys/block/dm-*/queue; do
        echo none > "$queue/scheduler" 2>/dev/null || echo noop > "$queue/scheduler" 2>/dev/null
        echo 4096 > "$queue/read_ahead_kb" 2>/dev/null
        echo 256 > "$queue/nr_requests" 2>/dev/null
        echo 2 > "$queue/rq_affinity" 2>/dev/null
        echo 0 > "$queue/add_random" 2>/dev/null
        echo 0 > "$queue/iostats" 2>/dev/null
        echo 0 > "$queue/random" 2>/dev/null
    done
    log "I/O: Set to MAXIMUM PERFORMANCE"
    
    # --- VM: Aggressive ---
    sysctl -w vm.swappiness=10 2>/dev/null
    sysctl -w vm.dirty_ratio=5 2>/dev/null
    sysctl -w vm.dirty_background_ratio=2 2>/dev/null
    sysctl -w vm.vfs_cache_pressure=20 2>/dev/null
    sysctl -w vm.min_free_kbytes=16384 2>/dev/null
    log "VM: Set to PERFORMANCE mode"
    
    # --- Disable Logging ---
    setprop persist.logd.size 0
    setprop log.tag VERBOSE
    setprop persist.traced.enable 0
    log "Logging: Disabled for performance"
    
    # --- Thermal: Raise Limits ---
    for thermal in /sys/class/thermal/thermal_zone*/trip_point_*_temp; do
        echo "95000" > "$thermal" 2>/dev/null
    done
    log "Thermal: Limits raised for gaming"
    
    echo "gaming" > "$CURRENT_MODE_FILE"
    log "GAMING MODE: MAXIMUM ACTIVE"
}

# ==========================================
# BALANCED MODE
# ==========================================
apply_balanced_mode() {
    log "BALANCED MODE: Activating..."
    
    # --- CPU: Balanced Governor ---
    GOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)
    if echo "$GOVS" | grep -q "schedutil"; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "schedutil" > "$cpu" 2>/dev/null
        done
    fi
    
    # --- CPU: Reset Min Freq ---
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        if [ -f "$policy/cpuinfo_min_freq" ] && [ -f "$policy/scaling_min_freq" ]; then
            MIN=$(cat "$policy/cpuinfo_min_freq")
            MAX=$(cat "$policy/cpuinfo_max_freq")
            # 50% of max
            BALANCED_MIN=$(( MAX * 50 / 100 ))
            [ "$BALANCED_MIN" -gt "$MIN" ] && echo "$BALANCED_MIN" > "$policy/scaling_min_freq" 2>/dev/null
        fi
    done
    
    # --- CPU: Reset Boost ---
    if [ -d /dev/stune/top-app ]; then
        echo 0 > /dev/stune/top-app/schedtune.boost 2>/dev/null
    fi
    
    # --- GPU: Balanced ---
    for gpu in /sys/class/kgsl/kgsl-3d0/devfreq /sys/devices/platform/*.gpu/devfreq; do
        if [ -d "$gpu" ]; then
            if [ -f "$gpu/min_freq" ] && [ -f "$gpu/max_freq" ]; then
                MIN_FREQ=$(cat "$gpu/min_freq")
                MAX_FREQ=$(cat "$gpu/max_freq")
                MID=$(( MAX_FREQ / 2 ))
                echo "$MID" > "$gpu/min_freq" 2>/dev/null
            fi
        fi
    done
    
    # --- Adreno GPU Balanced ---
    if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
        echo msm-adreno-tz > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/force_clk_on 2>/dev/null
    fi
    
    # --- Network: Normal ---
    sysctl -w net.ipv4.tcp_low_latency=0 2>/dev/null
    sysctl -w net.ipv4.tcp_notsent_lowat=-1 2>/dev/null
    
    # --- I/O: Balanced ---
    for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue /sys/block/dm-*/queue; do
        echo bfq > "$queue/scheduler" 2>/dev/null || echo cfq > "$queue/scheduler" 2>/dev/null
        echo 128 > "$queue/read_ahead_kb" 2>/dev/null
        echo 128 > "$queue/nr_requests" 2>/dev/null
    done
    
    # --- VM: Balanced ---
    sysctl -w vm.swappiness=40 2>/dev/null
    sysctl -w vm.dirty_ratio=10 2>/dev/null
    sysctl -w vm.vfs_cache_pressure=30 2>/dev/null
    
    # --- Restore Logging ---
    setprop persist.logd.size 262144
    
    # --- Thermal: Normal ---
    for thermal in /sys/class/thermal/thermal_zone*/trip_point_*_temp; do
        echo "85000" > "$thermal" 2>/dev/null
    done
    
    echo "balanced" > "$CURRENT_MODE_FILE"
    log "BALANCED MODE: Active"
}

# ==========================================
# BATTERY MODE (MAXIMUM SAVING)
# ==========================================
apply_battery_mode() {
    log "BATTERY MODE: Screen off - MAXIMUM SAVING..."
    
    # --- CPU: Powersave ---
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
    
    # --- CPU: Lowest Frequency ---
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        if [ -f "$policy/cpuinfo_min_freq" ] && [ -f "$policy/scaling_min_freq" ]; then
            MIN=$(cat "$policy/cpuinfo_min_freq")
            echo "$MIN" > "$policy/scaling_min_freq" 2>/dev/null
        fi
    done
    
    # --- GPU: Lowest Frequency ---
    for gpu in /sys/class/kgsl/kgsl-3d0/devfreq /sys/devices/platform/*.gpu/devfreq; do
        if [ -d "$gpu" ] && [ -f "$gpu/min_freq" ] && [ -f "$gpu/max_freq" ]; then
            MIN_FREQ=$(cat "$gpu/min_freq")
            MAX_FREQ=$(cat "$gpu/max_freq")
            # 25% of max
            LOW=$(( MIN_FREQ + (MAX_FREQ - MIN_FREQ) / 4 ))
            echo "$LOW" > "$gpu/min_freq" 2>/dev/null
        fi
    done
    
    # --- Adreno GPU Low ---
    if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
        echo powersave > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/force_clk_on 2>/dev/null
    fi
    
    # --- Disable WiFi Scan ---
    settings put global wifi_scan_always_enabled 0 2>/dev/null
    settings put global wifi_on 0 2>/dev/null
    
    # --- Disable Bluetooth ---
    settings put global bluetooth_on 0 2>/dev/null
    
    # --- I/O: Power Saving ---
    for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue /sys/block/dm-*/queue; do
        echo cfq > "$queue/scheduler" 2>/dev/null || echo bfq > "$queue/scheduler" 2>/dev/null
        echo 64 > "$queue/read_ahead_kb" 2>/dev/null
        echo 64 > "$queue/nr_requests" 2>/dev/null
    done
    
    # --- VM: Power Saving ---
    sysctl -w vm.swappiness=80 2>/dev/null
    sysctl -w vm.dirty_ratio=20 2>/dev/null
    sysctl -w vm.dirty_background_ratio=10 2>/dev/null
    sysctl -w vm.vfs_cache_pressure=80 2>/dev/null
    
    # --- Disable Animations ---
    settings put global window_animation_scale 0 2>/dev/null
    settings put global transition_animation_scale 0 2>/dev/null
    settings put global animator_duration_scale 0 2>/dev/null
    
    # --- Enable Doze ---
    settings put global doze_enabled 1 2>/dev/null
    
    # --- Reduce Background Activity ---
    settings put global background_activity 0 2>/dev/null
    
    echo "battery" > "$CURRENT_MODE_FILE"
    log "BATTERY MODE: MAXIMUM SAVING Active"
}

# ==========================================
# DETECTION FUNCTIONS
# ==========================================

# Check screen state (1 = on, 0 = off)
get_screen_state() {
    # Method 1: dumpsys power
    if dumpsys power 2>/dev/null | grep -q "mScreenOn=false"; then
        echo 0
        return
    fi
    
    # Method 2: screen brightness
    if [ -f /sys/class/leds/lcd-backlight/brightness ]; then
        BRIGHTNESS=$(cat /sys/class/leds/lcd-backlight/brightness 2>/dev/null)
        if [ "$BRIGHTNESS" = "0" ]; then
            echo 0
            return
        fi
    fi
    
    # Method 3: display state
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

log "Auto-detect service started (MAXIMUM PERFORMANCE)"

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
