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
    log "GAMING MODE BRUTAL: Activating..."

    # ========== CPU: BRUTAL FULL POWER ==========
    # Force performance governor on ALL cores
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$cpu" 2>/dev/null
    done

    # Lock ALL cores to MAX frequency (min = max = max)
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        if [ -f "$policy/cpuinfo_max_freq" ]; then
            MAX=$(cat "$policy/cpuinfo_max_freq")
            echo "$MAX" > "$policy/scaling_min_freq" 2>/dev/null
            echo "$MAX" > "$policy/scaling_max_freq" 2>/dev/null
            echo "$MAX" > "$policy/scaling_min_freq" 2>/dev/null
        fi
    done
    log "CPU: ALL CORES LOCKED MAX FREQUENCY"

    # Disable CPU hotplug (all cores always online)
    for cpu in /sys/devices/system/cpu/cpu*/online; do
        echo 1 > "$cpu" 2>/dev/null
    done
    # Force all big cores online
    for policy in /sys/devices/system/cpu/cpufreq/policy*/; do
        if [ -f "$policy/related_cpus" ]; then
            BIG_CORES=$(cat "$policy/related_cpus" 2>/dev/null)
            FIRST=$(echo "$BIG_CORES" | awk '{print $1}')
            if [ -f "/sys/devices/system/cpu/cpu${FIRST}/online" ]; then
                echo 1 > "/sys/devices/system/cpu/cpu${FIRST}/online" 2>/dev/null
            fi
        fi
    done
    log "CPU: ALL CORES FORCED ONLINE"

    # Maximum schedtune boost
    if [ -d /dev/stune/top-app ]; then
        echo 100 > /dev/stune/top-app/schedtune.boost 2>/dev/null
        echo 1 > /dev/stune/top-app/schedtune.prefer_idle 2>/dev/null
        echo 1 > /dev/stune/top-app/schedtune.overutilize 2>/dev/null
    fi
    if [ -d /dev/stune/foreground ]; then
        echo 80 > /dev/stune/foreground/schedtune.boost 2>/dev/null
    fi
    if [ -d /dev/stune/background ]; then
        echo 0 > /dev/stune/background/schedtune.boost 2>/dev/null
    fi
    # All CPUs for top-app
    if [ -d /dev/cpuset/top-app ]; then
        echo 0-7 > /dev/cpuset/top-app/cpus 2>/dev/null
    fi
    if [ -d /dev/cpuset/foreground ]; then
        echo 0-7 > /dev/cpuset/foreground/cpus 2>/dev/null
    fi
    # Restrict background apps to little cores only
    if [ -d /dev/cpuset/background ]; then
        echo 0-3 > /dev/cpuset/background/cpus 2>/dev/null
    fi
    if [ -d /dev/cpuset/restricted ]; then
        echo 0-2 > /dev/cpuset/restricted/cpus 2>/dev/null
    fi
    log "CPU: BRUTAL BOOST APPLIED"

    # ========== GPU: ABSOLUTE MAXIMUM ==========
    # Lock GPU to max frequency on ALL platforms
    for gpu in /sys/class/kgsl/kgsl-3d0/devfreq /sys/devices/platform/*.gpu/devfreq; do
        if [ -d "$gpu" ] && [ -f "$gpu/max_freq" ]; then
            MAX_FREQ=$(cat "$gpu/max_freq")
            MIN_FREQ=$(cat "$gpu/min_freq" 2>/dev/null)
            echo "$MAX_FREQ" > "$gpu/min_freq" 2>/dev/null
            echo "$MAX_FREQ" > "$gpu/max_freq" 2>/dev/null
            echo performance > "$gpu/governor" 2>/dev/null
        fi
    done

    # Adreno BRUTAL
    if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
        echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/busy_wait 2>/dev/null
        echo 1 > /sys/class/kgsl/kgsl-3d0/force_clk_on 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/idle_timer 2>/dev/null
        echo 1 > /sys/class/kgsl/kgsl-3d0/force_rail_on 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/force_bus_on 2>/dev/null
        echo 300 > /sys/class/kgsl/kgsl-3d0/max_pwrlevel 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/min_pwrlevel 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/idle_timer 2>/dev/null
        echo 0 > /sys/class/kgsl/kgsl-3d0/gpu_busy_percentage 2>/dev/null
        # Throttling OFF
        echo 0 > /sys/class/kgsl/kgsl-3d0/throttling 2>/dev/null
        echo 1 > /sys/class/kgsl/kgsl-3d0/bus_split 2>/dev/null
        echo 1 > /sys/class/kgsl/kgsl-3d0/clock_speed_toggle 2>/dev/null
        log "GPU: Adreno BRUTAL MAX"
    fi

    # Mali BRUTAL (all methods)
    for mali in /sys/devices/platform/mali.0 /sys/class/misc/mali0 /sys/devices/platform/soc/*.mali /sys/devices/platform/*.mali; do
        if [ -d "$mali" ]; then
            echo performance > "$mali/devfreq/governor" 2>/dev/null
            echo 1 > "$mali/force_clk_on" 2>/dev/null
            echo 1 > "$mali/force_rail_on" 2>/dev/null
            echo 0 > "$mali/idle_timer" 2>/dev/null
            # Try to set max freq as min
            if [ -f "$mali/devfreq/max_freq" ] && [ -f "$mali/devfreq/min_freq" ]; then
                MF=$(cat "$mali/devfreq/max_freq" 2>/dev/null)
                echo "$MF" > "$mali/devfreq/min_freq" 2>/dev/null
            fi
            # Disable power scaling
            echo 0 > "$mali/power_scale" 2>/dev/null
            echo 0 > "$mali/dvfs_enable" 2>/dev/null
        fi
    done
    for devfreq in /sys/class/devfreq/*.mali /sys/class/devfreq/mali*; do
        if [ -d "$devfreq" ]; then
            echo performance > "$devfreq/governor" 2>/dev/null
            MAX_FREQ=$(cat "$devfreq/max_freq" 2>/dev/null)
            [ -n "$MAX_FREQ" ] && echo "$MAX_FREQ" > "$devfreq/min_freq" 2>/dev/null
            [ -n "$MAX_FREQ" ] && echo "$MAX_FREQ" > "$devfreq/max_freq" 2>/dev/null
        fi
    done
    if [ -f /sys/module/mali_kbase/parameters/gpu_clock_speed ]; then
        MAX_SPEED=$(cat /sys/module/mali_kbase/parameters/gpu_clock_speed 2>/dev/null)
        echo "$MAX_SPEED" > /sys/module/mali_kbase/parameters/gpu_clock_speed 2>/dev/null
    fi
    # Samsung Exynos
    if [ -d /sys/devices/platform/exynos5-devfreq/gpu ]; then
        echo performance > /sys/devices/platform/exynos5-devfreq/gpu/governor 2>/dev/null
    fi
    # Spreadtrum/Unisoc
    for gpu_dev in /sys/devices/platform/soc/*.gpu /sys/devices/platform/*.gpu; do
        if [ -d "$gpu_dev" ]; then
            echo performance > "$gpu_dev/devfreq/governor" 2>/dev/null
            echo 1 > "$gpu_dev/force_clk_on" 2>/dev/null
            echo 1 > "$gpu_dev/force_rail_on" 2>/dev/null
            echo 0 > "$gpu_dev/idle_timer" 2>/dev/null
        fi
    done
    log "GPU: ALL TYPES BRUTAL MAX"

    # ========== RENDERING: BRUTAL ANTI-FRAMEDROP ==========
    setprop debug.sf.latch_unsignaled 1
    setprop debug.sf.disable_backpressure 0
    setprop debug.hwui.render_dirty_regions true
    setprop debug.hwui.draw_non_rect_clip true
    setprop debug.hwui.use_hint_manager false
    setprop debug.hwui.skip_damage_region false
    setprop debug.hwui.scudo_options "quarantine_size_kb=0:quarantine_max_chunked_size=0"
    setprop persist.sys.ui.hw true
    setprop debug.egl.hw 1
    setprop debug.gralloc.enable_fb_ubwc 1
    setprop debug.gpu.renderer skiagl
    setprop debug.hwui.renderer skiagl
    setprop debug.renderengine.backend skiaglthreaded
    setprop debug.sf.framebuffer_clear_on_exit false
    setprop debug.hwui.profile false
    setprop debug.hwui.show_dirty_regions false
    # Force HWC composition
    setprop debug.hwc.ver 2
    setprop debug.sf.gpu_comp_tiling 0
    setprop debug.egl.swapinterval 0
    setprop debug.vulkan.layers 0
    # Max framebuffer buffers
    setprop ro.surface_flinger.max_frame_buffer_acquired_buffers 3
    setprop debug.sf.max_acquired_buffer_count 3
    setprop ro.surface_flinger.running_without_sync_framework true
    log "Rendering: BRUTAL anti-framedrop"

    # ========== NETWORK: BRUTAL LOW LATENCY ==========
    TCP_AVAIL=$(cat /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null)
    if echo "$TCP_AVAIL" | grep -q "bbr"; then
        echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
    fi
    sysctl -w net.ipv4.tcp_fastopen=3 2>/dev/null
    sysctl -w net.ipv4.tcp_low_latency=1 2>/dev/null
    sysctl -w net.ipv4.tcp_notsent_lowat=16384 2>/dev/null
    sysctl -w net.ipv4.tcp_window_scaling=1 2>/dev/null
    sysctl -w net.ipv4.tcp_mtu_probing=1 2>/dev/null
    sysctl -w net.ipv4.tcp_sack=1 2>/dev/null
    sysctl -w net.ipv4.tcp_timestamps=1 2>/dev/null
    sysctl -w net.ipv4.tcp_no_metrics_save=1 2>/dev/null
    sysctl -w net.ipv4.tcp_synack_retries=2 2>/dev/null
    sysctl -w net.ipv4.tcp_syn_retries=2 2>/dev/null
    sysctl -w net.ipv4.tcp_abort_on_overflow=0 2>/dev/null
    sysctl -w net.ipv4.tcp_keepalive_time=60 2>/dev/null
    sysctl -w net.ipv4.tcp_keepalive_intvl=10 2>/dev/null
    sysctl -w net.ipv4.tcp_keepalive_probes=3 2>/dev/null
    sysctl -w net.ipv4.tcp_fin_timeout=5 2>/dev/null
    sysctl -w net.ipv4.tcp_max_tw_buckets=50000 2>/dev/null
    sysctl -w net.ipv4.tcp_tw_reuse=1 2>/dev/null
    sysctl -w net.core.rmem_max=67108864 2>/dev/null
    sysctl -w net.core.wmem_max=67108864 2>/dev/null
    sysctl -w net.core.somaxconn=65535 2>/dev/null
    sysctl -w net.core.netdev_max_backlog=65535 2>/dev/null
    sysctl -w net.ipv4.tcp_max_syn_backlog=65535 2>/dev/null
    # Disable WiFi power saving
    settings put global wifi_scan_always_enabled 0 2>/dev/null
    log "Network: BRUTAL LOW LATENCY"

    # ========== I/O: BRUTAL FAST ==========
    for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue /sys/block/dm-*/queue; do
        echo none > "$queue/scheduler" 2>/dev/null || echo noop > "$queue/scheduler" 2>/dev/null
        echo 4096 > "$queue/read_ahead_kb" 2>/dev/null
        echo 512 > "$queue/nr_requests" 2>/dev/null
        echo 2 > "$queue/rq_affinity" 2>/dev/null
        echo 0 > "$queue/add_random" 2>/dev/null
        echo 0 > "$queue/iostats" 2>/dev/null
        echo 0 > "$queue/random" 2>/dev/null
        echo 0 > "$queue/nomerges" 2>/dev/null
        echo 0 > "$queue/writes_starved" 2>/dev/null
    done
    log "I/O: BRUTAL MAX"

    # ========== VM: BRUTAL LOW SWAP ==========
    sysctl -w vm.swappiness=5 2>/dev/null
    sysctl -w vm.dirty_ratio=3 2>/dev/null
    sysctl -w vm.dirty_background_ratio=1 2>/dev/null
    sysctl -w vm.vfs_cache_pressure=10 2>/dev/null
    sysctl -w vm.min_free_kbytes=32768 2>/dev/null
    sysctl -w vm.extra_free_kbytes=8192 2>/dev/null
    sysctl -w vm.overcommit_ratio=90 2>/dev/null
    sysctl -w vm.page-cluster=0 2>/dev/null
    sysctl -w vm.dirty_writeback_centisecs=3000 2>/dev/null
    sysctl -w vm.dirty_expire_centisecs=1500 2>/dev/null
    log "VM: BRUTAL LOW SWAP"

    # ========== KERNAL SCHEDULER: BRUTAL ==========
    sysctl -w kernel.sched_autogroup_enabled=0 2>/dev/null
    sysctl -w kernel.sched_child_runs_first=1 2>/dev/null
    sysctl -w kernel.sched_migration_cost_ns=0 2>/dev/null
    sysctl -w kernel.sched_min_granularity_ns=500000 2>/dev/null
    sysctl -w kernel.sched_wakeup_granularity_ns=500000 2>/dev/null
    sysctl -w kernel.sched_latency_ns=5000000 2>/dev/null
    sysctl -w kernel.sched_nr_migrate=64 2>/dev/null
    sysctl -w kernel.sched_migration_dump 0 2>/dev/null
    log "Kernel: BRUTAL LOW LATENCY"

    # ========== DISABLE ALL BACKGROUND NOISE ==========
    setprop persist.logd.size 0
    setprop persist.traced.enable 0
    setprop persist.log.tag VERBOSE
    setprop log.tag VERBOSE
    setprop persist.sys.dalvik.vm.lib.2 libart.so
    # Kill unnecessary background processes
    for proc in $(ps -A -o NAME= 2>/dev/null | grep -E "logd|traced|traced_probes|perfetto" | head -5); do
        killall "$proc" 2>/dev/null
    done
    log "Background: NOISE KILLED"

    # ========== THERMAL: BRUTAL OVERRIDE ==========
    for thermal in /sys/class/thermal/thermal_zone*/trip_point_*_temp; do
        echo "110000" > "$thermal" 2>/dev/null
    done
    # Disable thermal mitigation if possible
    for thermal in /sys/class/thermal/thermal_zone*/mode; do
        echo "disabled" > "$thermal" 2>/dev/null
    done
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        if [ -f "$policy/thermal_sustainable_power" ]; then
            echo "99999" > "$policy/thermal_sustainable_power" 2>/dev/null
        fi
        if [ -f "$policy/thermal_max_freq" ]; then
            MAX=$(cat "$policy/cpuinfo_max_freq" 2>/dev/null)
            echo "$MAX" > "$policy/thermal_max_freq" 2>/dev/null
        fi
    done
    log "Thermal: BRUTAL OVERRIDE"

    # ========== DALVIK: BRUTAL PERFORMANCE ==========
    setprop dalvik.vm.dex2oat-threads 8
    setprop dalvik.vm.image-dex2oat-threads 8
    setprop dalvik.vm.dex2oat-filter speed
    setprop dalvik.vm.dex2oat-Xms 128m
    setprop dalvik.vm.dex2oat-Xmx 1024m
    setprop dalvik.vm.heapgrowthlimit 1024m
    setprop dalvik.vm.heapmaxfree 64m
    setprop dalvik.vm.heapminfree 16m
    setprop dalvik.vm.heaptargetutilization 0.85
    setprop dalvik.vm.heapsize 1024m
    setprop dalvik.vm.heaptargetutilization 0.75
    log "Dalvik: BRUTAL PERFORMANCE"

    # ========== MISC: BRUTAL ==========
    # Disable animations completely
    settings put global window_animation_scale 0 2>/dev/null
    settings put global transition_animation_scale 0 2>/dev/null
    settings put global animator_duration_scale 0 2>/dev/null
    settings put global hw_overlay 1 2>/dev/null
    settings put global force_gpu_rendering 1 2>/dev/null
    settings put global display_content_blur 0 2>/dev/null
    settings put global hidden_api_policy 1 2>/dev/null
    # Disable battery saver
    settings put global battery_saver_enabled 0 2>/dev/null
    # Disable auto brightness adjustment
    settings put system screen_brightness_mode 0 2>/dev/null
    log "Misc: BRUTAL"

    echo "gaming" > "$CURRENT_MODE_FILE"
    log "GAMING MODE BRUTAL: ACTIVE - ALL SYSTEMS MAXIMUM"
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
