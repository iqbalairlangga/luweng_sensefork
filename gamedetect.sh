#!/system/bin/sh
# LuwengSense Pro v3.2 - Auto Detect (Game + Screen)
# Gaming: FPS stability & efficient rendering
# Balanced: Multitasking & scrolling efficiency
# Battery: Stable power saving

MODDIR=${0%/*}
LOGFILE=/data/adb/luwengsense_pro.log
GAME_LIST="$MODDIR/games.conf"
CURRENT_MODE_FILE="/data/adb/luwengsense_mode"
LAST_SCREEN_STATE="on"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOGFILE
}

DEFAULT_GAMES="com.mobile.legends com.miHoYo.GenshinImpact com.tencent.ig com.pubg.krmobile com.varena.codmobile com.supercell.clashofclans com.supercell.clashroyale com.supercell.brawlstars com.ea.gp.fifamobile com.garena.game.codm com.activision.callofduty.shooter com.epicgames.fortnite com.riotgames.league.wildrift com.riotgames.league.teamfighttactics com.tencent.tmgp.codmobile com.roblox.client com.mojang.minecraftpe com.dts.freefireth com.supercell.hayday com.innersloth.spacemafia com.kiloo.subwaysurfers com.imangi.templerun2 com.outfit7.mytalkingtom2 com.miniclip.eightballpool com.moonton.magicrush com.mobilelegends.cod"

if [ ! -f "$GAME_LIST" ]; then
    echo "$DEFAULT_GAMES" > "$GAME_LIST"
    log "Created default game list"
fi

# ==========================================
# GAMING MODE v3.2 (FPS Stability + Rendering)
# ==========================================
apply_gaming_mode() {
    log "GAMING MODE v3.2: Activating..."

    # CPU: Performance + locked high freq
    GOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)
    if echo "$GOVS" | grep -q "performance"; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "performance" > "$cpu" 2>/dev/null
        done
    fi

    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        if [ -f "$policy/cpuinfo_max_freq" ] && [ -f "$policy/scaling_min_freq" ]; then
            MAX=$(cat "$policy/cpuinfo_max_freq")
            MIN_CPU=$(( MAX * 85 / 100 ))
            echo "$MIN_CPU" > "$policy/scaling_min_freq" 2>/dev/null
            echo "$MAX" > "$policy/scaling_max_freq" 2>/dev/null
        fi
    done

    # CPU Boost full
    if [ -d /dev/stune/top-app ]; then
        echo 100 > /dev/stune/top-app/schedtune.boost 2>/dev/null
        echo 1 > /dev/stune/top-app/schedtune.prefer_idle 2>/dev/null
    fi
    if [ -d /dev/cpuset/top-app ]; then
        echo 0-7 > /dev/cpuset/top-app/cpus 2>/dev/null
    fi
    log "CPU: MAXIMUM PERFORMANCE v3.2"

    # GPU: MAX + frame pacing optimized (v3.2)
    for gpu in /sys/class/kgsl/kgsl-3d0/devfreq /sys/devices/platform/*.gpu/devfreq; do
        if [ -d "$gpu" ] && [ -f "$gpu/max_freq" ]; then
            MAX_FREQ=$(cat "$gpu/max_freq")
            echo "$MAX_FREQ" > "$gpu/min_freq" 2>/dev/null
            echo performance > "$gpu/governor" 2>/dev/null
        fi
    done

    # Adreno MAX
    if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
        echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/busy_wait 2>/dev/null
        echo 1 > /sys/class/kgsl/kgsl-3d0/force_clk_on 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/idle_timer 2>/dev/null
        echo 1 > /sys/class/kgsl/kgsl-3d0/force_rail_on 2>/dev/null
        echo 300 > /sys/class/kgsl/kgsl-3d0/max_pwrlevel 2>/dev/null
        log "GPU: Adreno MAXIMUM v3.2"
    fi

    # Mali MAX (all methods)
    for mali in /sys/devices/platform/mali.0 /sys/class/misc/mali0 /sys/devices/platform/soc/*.mali /sys/devices/platform/*.mali; do
        if [ -d "$mali" ]; then
            echo performance > "$mali/devfreq/governor" 2>/dev/null
            echo 1 > "$mali/force_clk_on" 2>/dev/null
            echo 1 > "$mali/force_rail_on" 2>/dev/null
            echo 0 > "$mali/idle_timer" 2>/dev/null
        fi
    done
    for devfreq in /sys/class/devfreq/*.mali /sys/class/devfreq/mali*; do
        if [ -d "$devfreq" ]; then
            echo performance > "$devfreq/governor" 2>/dev/null
            MAX_FREQ=$(cat "$devfreq/max_freq" 2>/dev/null)
            [ -n "$MAX_FREQ" ] && echo "$MAX_FREQ" > "$devfreq/min_freq" 2>/dev/null
        fi
    done
    if [ -f /sys/module/mali_kbase/parameters/gpu_clock_speed ]; then
        MAX_SPEED=$(cat /sys/module/mali_kbase/parameters/gpu_clock_speed 2>/dev/null)
        echo "$MAX_SPEED" > /sys/module/mali_kbase/parameters/gpu_clock_speed 2>/dev/null
    fi
    if [ -d /sys/devices/platform/exynos5-devfreq/gpu ]; then
        echo performance > /sys/devices/platform/exynos5-devfreq/gpu/governor 2>/dev/null
    fi
    log "GPU: ALL TYPES MAXIMUM v3.2"

    # v3.2: Frame pacing props for anti-framedrop
    setprop debug.sf.latch_unsignaled 1
    setprop debug.hwui.render_dirty_regions true
    setprop debug.sf.disable_backpressure false
    setprop debug.hwui.draw_non_rect_clip true
    setprop debug.hwui.use_hint_manager false
    setprop persist.sys.ui.hw true
    setprop debug.egl.hw 1
    setprop debug.gralloc.enable_fb_ubwc 1
    log "Rendering: Frame pacing optimized v3.2"

    # Network: Ultra low latency
    echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
    sysctl -w net.ipv4.tcp_fastopen=3 2>/dev/null
    sysctl -w net.ipv4.tcp_low_latency=1 2>/dev/null
    sysctl -w net.ipv4.tcp_notsent_lowat=16384 2>/dev/null
    sysctl -w net.ipv4.tcp_window_scaling=1 2>/dev/null
    sysctl -w net.ipv4.tcp_mtu_probing=1 2>/dev/null
    sysctl -w net.ipv4.tcp_sack=1 2>/dev/null
    sysctl -w net.ipv4.tcp_synack_retries=2 2>/dev/null
    sysctl -w net.ipv4.tcp_syn_retries=2 2>/dev/null
    log "Network: LOW LATENCY v3.2"

    # I/O: Maximum
    for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue /sys/block/dm-*/queue; do
        echo none > "$queue/scheduler" 2>/dev/null || echo noop > "$queue/scheduler" 2>/dev/null
        echo 4096 > "$queue/read_ahead_kb" 2>/dev/null
        echo 256 > "$queue/nr_requests" 2>/dev/null
        echo 2 > "$queue/rq_affinity" 2>/dev/null
        echo 0 > "$queue/add_random" 2>/dev/null
        echo 0 > "$queue/iostats" 2>/dev/null
    done
    log "I/O: MAXIMUM v3.2"

    # VM: Low swap for gaming
    sysctl -w vm.swappiness=10 2>/dev/null
    sysctl -w vm.dirty_ratio=5 2>/dev/null
    sysctl -w vm.dirty_background_ratio=2 2>/dev/null
    sysctl -w vm.vfs_cache_pressure=20 2>/dev/null
    sysctl -w vm.min_free_kbytes=16384 2>/dev/null
    log "VM: GAMING v3.2"

    # Disable logging
    setprop persist.logd.size 0
    setprop persist.traced.enable 0

    # Thermal: raised for sustained gaming
    for thermal in /sys/class/thermal/thermal_zone*/trip_point_*_temp; do
        echo "95000" > "$thermal" 2>/dev/null
    done
    log "Thermal: Gaming v3.2"

    echo "gaming" > "$CURRENT_MODE_FILE"
    log "GAMING MODE v3.2: ACTIVE"
}

# ==========================================
# BALANCED MODE v3.2 (Multitasking + Scrolling)
# ==========================================
apply_balanced_mode() {
    log "BALANCED MODE v3.2: Activating..."

    # CPU: schedutil for smooth multitasking
    GOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)
    if echo "$GOVS" | grep -q "schedutil"; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "schedutil" > "$cpu" 2>/dev/null
        done
    fi

    # CPU: 60% min for better multitasking (v3.2 increased from 50%)
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        if [ -f "$policy/cpuinfo_min_freq" ] && [ -f "$policy/scaling_min_freq" ]; then
            MIN=$(cat "$policy/cpuinfo_min_freq")
            MAX=$(cat "$policy/cpuinfo_max_freq")
            BALANCED_MIN=$(( MAX * 60 / 100 ))
            [ "$BALANCED_MIN" -gt "$MIN" ] && echo "$BALANCED_MIN" > "$policy/scaling_min_freq" 2>/dev/null
        fi
    done

    # CPU: Moderate boost
    if [ -d /dev/stune/top-app ]; then
        echo 30 > /dev/stune/top-app/schedtune.boost 2>/dev/null
        echo 1 > /dev/stune/top-app/schedtune.prefer_idle 2>/dev/null
    fi
    log "CPU: Balanced multitasking v3.2"

    # GPU: Balanced (not too low, not max)
    for gpu in /sys/class/kgsl/kgsl-3d0/devfreq /sys/devices/platform/*.gpu/devfreq; do
        if [ -d "$gpu" ] && [ -f "$gpu/min_freq" ] && [ -f "$gpu/max_freq" ]; then
            MAX_FREQ=$(cat "$gpu/max_freq")
            MID=$(( MAX_FREQ * 60 / 100 ))
            echo "$MID" > "$gpu/min_freq" 2>/dev/null
            echo msm-adreno-tz > "$gpu/governor" 2>/dev/null
        fi
    done

    if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
        echo msm-adreno-tz > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/force_clk_on 2>/dev/null
    fi
    log "GPU: Balanced v3.2"

    # v3.2: Smooth scrolling & social media rendering
    setprop debug.hwui.render_dirty_regions true
    setprop debug.hwui.scroll_per_frame 0
    setprop ro.surface_flinger.max_frame_buffer_acquired_buffers 3
    setprop debug.sf.latch_unsignaled 1
    log "Rendering: Smooth scrolling v3.2"

    # Network: Normal
    sysctl -w net.ipv4.tcp_low_latency=0 2>/dev/null

    # I/O: bfq for multitasking (v3.2 increased read_ahead)
    for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue /sys/block/dm-*/queue; do
        echo bfq > "$queue/scheduler" 2>/dev/null || echo cfq > "$queue/scheduler" 2>/dev/null
        echo 512 > "$queue/read_ahead_kb" 2>/dev/null
        echo 128 > "$queue/nr_requests" 2>/dev/null
    done
    log "I/O: Balanced v3.2 (read_ahead 512KB)"

    # VM: Balanced
    sysctl -w vm.swappiness=40 2>/dev/null
    sysctl -w vm.dirty_ratio=10 2>/dev/null
    sysctl -w vm.vfs_cache_pressure=30 2>/dev/null

    # v3.2: Increase background app limit for multitasking
    setprop persist.sys.frozen_bg_disable 1
    setprop ro.oom.kill_uploading_tasks false
    log "Memory: Multitasking optimized v3.2"

    # Restore logging
    setprop persist.logd.size 262144

    # Thermal: Normal
    for thermal in /sys/class/thermal/thermal_zone*/trip_point_*_temp; do
        echo "85000" > "$thermal" 2>/dev/null
    done

    # Animation: Smooth
    settings put global window_animation_scale 0.5 2>/dev/null
    settings put global transition_animation_scale 0.5 2>/dev/null
    settings put global animator_duration_scale 0.5 2>/dev/null

    echo "balanced" > "$CURRENT_MODE_FILE"
    log "BALANCED MODE v3.2: ACTIVE"
}

# ==========================================
# BATTERY MODE v3.2 (Stable + Extreme Saving)
# ==========================================
apply_battery_mode() {
    log "BATTERY MODE v3.2: Activating..."

    # CPU: Powersave + lowest freq (v3.2 more aggressive)
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

    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        if [ -f "$policy/cpuinfo_min_freq" ] && [ -f "$policy/scaling_min_freq" ]; then
            MIN=$(cat "$policy/cpuinfo_min_freq")
            echo "$MIN" > "$policy/scaling_min_freq" 2>/dev/null
        fi
    done

    # CPU: No boost
    if [ -d /dev/stune/top-app ]; then
        echo 0 > /dev/stune/top-app/schedtune.boost 2>/dev/null
    fi
    log "CPU: Battery saving v3.2"

    # GPU: Lowest freq (v3.2 more aggressive)
    for gpu in /sys/class/kgsl/kgsl-3d0/devfreq /sys/devices/platform/*.gpu/devfreq; do
        if [ -d "$gpu" ] && [ -f "$gpu/min_freq" ] && [ -f "$gpu/max_freq" ]; then
            MIN_FREQ=$(cat "$gpu/min_freq")
            MAX_FREQ=$(cat "$gpu/max_freq")
            LOW=$(( MIN_FREQ + (MAX_FREQ - MIN_FREQ) / 6 ))
            echo "$LOW" > "$gpu/min_freq" 2>/dev/null
        fi
    done

    if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
        echo powersave > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/force_clk_on 2>/dev/null
    fi
    log "GPU: Battery saving v3.2"

    # v3.2: Disable GPU rendering extras
    setprop debug.egl.hw 0
    setprop debug.gralloc.enable_fb_ubwc 0
    log "Rendering: Power saving v3.2"

    # Disable WiFi/BT scan
    settings put global wifi_scan_always_enabled 0 2>/dev/null
    settings put global bluetooth_on 0 2>/dev/null

    # I/O: Power saving (v3.2 lower read_ahead)
    for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue /sys/block/dm-*/queue; do
        echo cfq > "$queue/scheduler" 2>/dev/null || echo bfq > "$queue/scheduler" 2>/dev/null
        echo 64 > "$queue/read_ahead_kb" 2>/dev/null
        echo 64 > "$queue/nr_requests" 2>/dev/null
    done
    log "I/O: Battery saving v3.2"

    # VM: Max swap for RAM savings (v3.2)
    sysctl -w vm.swappiness=80 2>/dev/null
    sysctl -w vm.dirty_ratio=20 2>/dev/null
    sysctl -w vm.dirty_background_ratio=10 2>/dev/null
    sysctl -w vm.vfs_cache_pressure=80 2>/dev/null
    log "VM: Battery saving v3.2"

    # Disable animations
    settings put global window_animation_scale 0 2>/dev/null
    settings put global transition_animation_scale 0 2>/dev/null
    settings put global animator_duration_scale 0 2>/dev/null

    # Enable Doze (v3.2 enhanced)
    settings put global doze_enabled 1 2>/dev/null
    settings put global adaptive_battery_saver_enabled 1 2>/dev/null
    settings put global battery_saver_enabled 1 2>/dev/null
    settings put global background_activity 0 2>/dev/null

    # v3.2: Reduce wake intervals
    settings put global wifi_sleep_policy 2 2>/dev/null
    settings put global ntp_server pool.ntp.org 2>/dev/null

    # Thermal: Low for battery life
    for thermal in /sys/class/thermal/thermal_zone*/trip_point_*_temp; do
        echo "75000" > "$thermal" 2>/dev/null
    done
    log "Thermal: Battery optimized v3.2"

    echo "battery" > "$CURRENT_MODE_FILE"
    log "BATTERY MODE v3.2: ACTIVE"
}

# ==========================================
# DETECTION FUNCTIONS
# ==========================================
get_screen_state() {
    if dumpsys power 2>/dev/null | grep -q "mScreenOn=false"; then
        echo 0
        return
    fi
    if [ -f /sys/class/leds/lcd-backlight/brightness ]; then
        BRIGHTNESS=$(cat /sys/class/leds/lcd-backlight/brightness 2>/dev/null)
        if [ "$BRIGHTNESS" = "0" ]; then
            echo 0
            return
        fi
    fi
    if dumpsys display 2>/dev/null | grep -q "mScreenState=OFF"; then
        echo 0
        return
    fi
    echo 1
}

get_foreground_app() {
    FOCUSED=""
    FOCUSED=$(dumpsys activity activities 2>/dev/null | grep "mResumedActivity" | awk '{print $NF}' | cut -d'/' -f1 | sed 's/}//' | sed 's/^ *//')
    if [ -z "$FOCUSED" ]; then
        FOCUSED=$(dumpsys window 2>/dev/null | grep -E "mCurrentFocus|mFocusedApp" | head -1 | grep -oP '[a-zA-Z0-9_.]+/[a-zA-Z0-9_.]+' | head -1 | cut -d'/' -f1)
    fi
    echo "$FOCUSED"
}

# ==========================================
# MAIN LOOP
# ==========================================
log "Auto-detect v3.2 service started"

while true; do
    SCREEN_STATE=$(get_screen_state)
    CURRENT_MODE=$(cat "$CURRENT_MODE_FILE" 2>/dev/null || echo "balanced")

    # SCREEN OFF -> Battery
    if [ "$SCREEN_STATE" = "0" ]; then
        if [ "$LAST_SCREEN_STATE" = "on" ]; then
            log "Screen OFF - switching to battery"
            LAST_SCREEN_STATE="off"
            if [ "$CURRENT_MODE" != "battery" ]; then
                apply_battery_mode
            fi
        fi
        sleep 5
        continue
    fi

    # SCREEN ON -> restore
    if [ "$LAST_SCREEN_STATE" = "off" ]; then
        log "Screen ON - restoring mode"
        LAST_SCREEN_STATE="on"
        if [ "$CURRENT_MODE" = "battery" ]; then
            apply_balanced_mode
        fi
    fi

    # GAME DETECTION
    if [ -f "$MODDIR/autogame.conf" ] && [ "$(cat "$MODDIR/autogame.conf")" = "1" ]; then
        FOCUSED_APP=$(get_foreground_app)
        DOTS=$(echo "$FOCUSED_APP" | tr -cd '.' | wc -c)
        if [ "$DOTS" -ge 2 ] && [ -n "$FOCUSED_APP" ]; then
            IS_GAME=0
            for game in $(cat "$GAME_LIST"); do
                if [ "$FOCUSED_APP" = "$game" ]; then
                    IS_GAME=1
                    break
                fi
            done

            if [ "$IS_GAME" = "1" ] && [ "$CURRENT_MODE" != "gaming" ]; then
                apply_gaming_mode
            elif [ "$IS_GAME" = "0" ] && [ "$CURRENT_MODE" = "gaming" ]; then
                apply_balanced_mode
            fi
        fi
    fi

    sleep 3
done
