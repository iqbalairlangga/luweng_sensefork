#!/system/bin/sh
# LuwengSense Pro - service.sh
# MAXIMUM PERFORMANCE tweaks - runs after boot completed

MODDIR=${0%/*}
LOGFILE=/data/adb/luwengsense_pro.log

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOGFILE
}

# Wait for boot to complete
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 3
done
sleep 10

log "=== LuwengSense Pro Started ==="

# ==========================================
# NETWORK & SIGNAL STABILITY (MAXIMUM)
# ==========================================
log "Applying network tweaks..."

# --- TCP Congestion Control (BBR优先) ---
TCP_AVAIL=$(cat /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null)
if echo "$TCP_AVAIL" | grep -q "bbr"; then
    echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control
    log "TCP: BBR enabled"
elif echo "$TCP_AVAIL" | grep -q "westwood"; then
    echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control
    log "TCP: Westwood enabled"
elif echo "$TCP_AVAIL" | grep -q "cubic"; then
    echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control
    log "TCP: CUBIC enabled"
fi

# --- Network Buffer (MASSIVE) ---
sysctl -w net.core.rmem_max=67108864 2>/dev/null
sysctl -w net.core.wmem_max=67108864 2>/dev/null
sysctl -w net.core.rmem_default=1048576 2>/dev/null
sysctl -w net.core.wmem_default=1048576 2>/dev/null
sysctl -w net.ipv4.tcp_rmem="4096 87380 67108864" 2>/dev/null
sysctl -w net.ipv4.tcp_wmem="4096 65536 67108864" 2>/dev/null
sysctl -w net.core.somaxconn=65535 2>/dev/null
sysctl -w net.core.netdev_max_backlog=65535 2>/dev/null
sysctl -w net.ipv4.tcp_max_syn_backlog=65535 2>/dev/null
sysctl -w net.ipv4.tcp_fastopen=3 2>/dev/null
sysctl -w net.ipv4.tcp_slow_start_after_idle=0 2>/dev/null
sysctl -w net.ipv4.tcp_mtu_probing=1 2>/dev/null
sysctl -w net.ipv4.tcp_timestamps=1 2>/dev/null
sysctl -w net.ipv4.tcp_sack=1 2>/dev/null
sysctl -w net.ipv4.tcp_window_scaling=1 2>/dev/null
sysctl -w net.ipv4.tcp_no_metrics_save=1 2>/dev/null
sysctl -w net.ipv4.tcp_fin_timeout=10 2>/dev/null
sysctl -w net.ipv4.tcp_keepalive_time=300 2>/dev/null
sysctl -w net.ipv4.tcp_keepalive_intvl=15 2>/dev/null
sysctl -w net.ipv4.tcp_keepalive_probes=5 2>/dev/null
sysctl -w net.ipv4.tcp_max_tw_buckets=1440000 2>/dev/null
sysctl -w net.ipv4.tcp_tw_reuse=1 2>/dev/null
sysctl -w net.ipv4.tcp_low_latency=1 2>/dev/null
sysctl -w net.ipv4.tcp_notsent_lowat=16384 2>/dev/null
log "Network buffer tuning applied (MASSIVE)"

# --- DNS Optimization (Cloudflare) ---
SDK=$(getprop ro.build.version.sdk)
if [ "$SDK" -ge 28 ]; then
    settings put global private_dns_mode hostname 2>/dev/null
    settings put global private_dns_specifier 1dot1dot1dot1.cloudflare-dns.com 2>/dev/null
    log "DNS: Cloudflare over TLS enabled"
fi

# --- Mobile Data Signal (AGGRESSIVE) ---
setprop persist.radio.apm_sim_not_pwdn 1
setprop persist.radio.data_con_rprt 1
setprop persist.radio.force_on_dc true
setprop persist.radio.add_power_save 0
setprop persist.radio.data_ltd_sys_ind 1
setprop persist.radio.static_dump_type 1
setprop persist.vendor.radio.apm_sim_not_pwdn 1
setprop persist.vendor.radio.data_con_rprt 1
setprop persist.vendor.radio.force_on_dc true
setprop persist.vendor.radio.add_power_save 0
setprop persist.radio.rild.use.pt 1
setprop persist.radio.apm_sim_not_pwdn 0
setprop persist.radio.sib16_support 1
setprop persist.vendor.radio.customizedecc 1
setprop persist.vendor.radio.jbims 1
setprop persist.vendor.radio.VT_ENABLE 1
setprop persist.vendor.radio.VT_HYBRID_ENABLE 1
setprop persist.vendor.radio.RETURN_NOPABORT 1
log "RIL signal tweaks applied (AGGRESSIVE)"

# --- WiFi Optimizations ---
setprop persist.wifi.disable_firmware_roam 0
setprop persist.wifi_VERBOSE_LOGS 0
setprop persist.wifi.turnOnOffOnP2p 0
setprop persist.wifi.wifiHS2 0
setprop persist.wifi.low_latency_enable 1
log "WiFi tweaks applied"

# ==========================================
# CPU PERFORMANCE (MAXIMUM)
# ==========================================
log "Applying CPU tweaks..."

# --- CPU Governor (Performance First) ---
GOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)
if echo "$GOVS" | grep -q "performance"; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$cpu" 2>/dev/null
    done
    log "CPU: performance governor set (MAXIMUM)"
elif echo "$GOVS" | grep -q "schedutil"; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "schedutil" > "$cpu" 2>/dev/null
    done
    log "CPU: schedutil governor set"
fi

# --- CPU Frequency (AGGRESSIVE) ---
for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    if [ -f "$policy/cpuinfo_min_freq" ] && [ -f "$policy/scaling_min_freq" ]; then
        MIN=$(cat "$policy/cpuinfo_min_freq")
        MAX=$(cat "$policy/cpuinfo_max_freq")
        # Set min to 70% of max for maximum responsiveness
        AGGRESSIVE_MIN=$(( MAX * 70 / 100 ))
        [ "$AGGRESSIVE_MIN" -gt "$MIN" ] && echo "$AGGRESSIVE_MIN" > "$policy/scaling_min_freq" 2>/dev/null
    fi
done
log "CPU: Frequency scaling set to AGGRESSIVE"

# --- CPU Boost (schedtune) ---
if [ -d /dev/stune/top-app ]; then
    echo 1 > /dev/stune/top-app/schedtune.boost 2>/dev/null
    echo 1 > /dev/stune/top-app/schedtune.prefer_idle 2>/dev/null
fi
if [ -d /dev/stune/foreground ]; then
    echo 1 > /dev/stune/foreground/schedtune.boost 2>/dev/null
fi
log "CPU: schedtune boost enabled"

# ==========================================
# GPU PERFORMANCE (MAXIMUM)
# ==========================================
log "Applying GPU tweaks..."

# --- GPU Rendering (Forced) ---
setprop debug.hwui.renderer skiagl
setprop debug.renderengine.backend skiaglthreaded
setprop debug.sf.latch_unsignaled 1
setprop debug.egl.hw 1
setprop debug.overlayui.enable 1
setprop persist.sys.ui.hw true
setprop debug.gralloc.enable_fb_ubwc 1
setprop debug.gpu.renderer skiagl
setprop debug.hwui.use_hint_manager false
setprop debug.hwui.skip_damage_region false
setprop debug.hwui.scudo_options "quarantine_size_kb=0:quarantine_max_chunked_size=0"
log "GPU: Rendering forced to SkiaGL"

# --- GPU Frequency (MAXIMUM) ---
for gpu in /sys/class/kgsl/kgsl-3d0/devfreq /sys/devices/platform/*.gpu/devfreq; do
    if [ -d "$gpu" ]; then
        if [ -f "$gpu/max_freq" ]; then
            MAX_FREQ=$(cat "$gpu/max_freq")
            echo "$MAX_FREQ" > "$gpu/min_freq" 2>/dev/null
            log "GPU: Set to MAX frequency"
        fi
    fi
done

# --- Adreno GPU (Qualcomm) ---
if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
    echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
    echo 0 > /sys/class/kgsl/kgsl-3d0/busy_wait 2>/dev/null
    echo 1 > /sys/class/kgsl/kgsl-3d0/force_clk_on 2>/dev/null
    echo 0 > /sys/class/kgsl/kgsl-3d0/idle_timer 2>/dev/null
    echo 1 > /sys/class/kgsl/kgsl-3d0/force_rail_on 2>/dev/null
    log "GPU: Adreno set to MAXIMUM"
fi
log "GPU tweaks applied (MAXIMUM)"

# ==========================================
# I/O PERFORMANCE (MAXIMUM)
# ==========================================
log "Applying I/O tweaks..."

# --- I/O Scheduler (Fast First) ---
IOSCHED=$(cat /sys/block/sda/queue/scheduler 2>/dev/null || cat /sys/block/mmcblk0/queue/scheduler 2>/dev/null)
if echo "$IOSCHED" | grep -q "none"; then
    for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue /sys/block/dm-*/queue; do
        echo "none" > "$queue/scheduler" 2>/dev/null
    done
    log "I/O: none (noop) scheduler set"
elif echo "$IOSCHED" | grep -q "noop"; then
    for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue /sys/block/dm-*/queue; do
        echo "noop" > "$queue/scheduler" 2>/dev/null
    done
    log "I/O: noop scheduler set"
elif echo "$IOSCHED" | grep -q "deadline"; then
    for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue /sys/block/dm-*/queue; do
        echo "deadline" > "$queue/scheduler" 2>/dev/null
    done
    log "I/O: deadline scheduler set"
fi

# --- I/O Read Ahead (AGGRESSIVE) ---
for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue /sys/block/dm-*/queue; do
    echo 4096 > "$queue/read_ahead_kb" 2>/dev/null
    echo 256 > "$queue/nr_requests" 2>/dev/null
    echo 2 > "$queue/rq_affinity" 2>/dev/null
    echo 0 > "$queue/add_random" 2>/dev/null
    echo 0 > "$queue/iostats" 2>/dev/null
done
log "I/O: Read ahead set to 4096KB (AGGRESSIVE)"

# --- FSTRIM on Boot ---
if [ -x /system/bin/fstrim ]; then
    /system/bin/fstrim -v /data > /dev/null 2>&1
    /system/bin/fstrim -v /cache > /dev/null 2>&1
    /system/bin/fstrim -v /system > /dev/null 2>&1
    log "I/O: FSTRIM executed"
fi

# ==========================================
# MEMORY PERFORMANCE (MAXIMUM)
# ==========================================
log "Applying memory tweaks..."

# --- Virtual Memory (AGGRESSIVE) ---
sysctl -w vm.swappiness=40 2>/dev/null
sysctl -w vm.dirty_ratio=10 2>/dev/null
sysctl -w vm.dirty_background_ratio=3 2>/dev/null
sysctl -w vm.vfs_cache_pressure=30 2>/dev/null
sysctl -w vm.min_free_kbytes=8192 2>/dev/null
sysctl -w vm.extra_free_kbytes=4096 2>/dev/null
sysctl -w vm.overcommit_ratio=80 2>/dev/null
sysctl -w vm.page-cluster=0 2>/dev/null
log "VM: Memory tuned for PERFORMANCE"

# --- ZRAM (AGGRESSIVE) ---
if [ -e /sys/block/zram0 ]; then
    swapoff /dev/block/zram0 2>/dev/null
    echo 1 > /sys/block/zram0/reset 2>/dev/null
    sleep 1
    
    TOTAL_RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    # 75% of RAM for ZRAM
    ZRAM_SIZE=$(( TOTAL_RAM * 75 / 100 ))
    [ "$ZRAM_SIZE" -lt 1024000 ] && ZRAM_SIZE=1024000
    [ "$ZRAM_SIZE" -gt 8388608 ] && ZRAM_SIZE=8388608
    
    # Try lz4 first (fastest)
    echo lz4 > /sys/block/zram0/comp_algorithm 2>/dev/null
    echo "${ZRAM_SIZE}K" > /sys/block/zram0/disksize 2>/dev/null
    echo 160 > /sys/block/zram0/max_comp_streams 2>/dev/null
    mkswap /dev/block/zram0 > /dev/null 2>&1
    swapon /dev/block/zram0 > /dev/null 2>&1
    log "ZRAM: ${ZRAM_SIZE}K configured (AGGRESSIVE)"
fi

# --- Low Memory Killer (LMK) Tuning ---
resetprop -n ro.lmk.low 1001
resetprop -n ro.lmk.medium 1001
resetprop -n ro.lmk.critical 1001
resetprop -n ro.lmk.critical_upgrade false
resetprop -n ro.lmk.upgrade_pressure 100
resetprop -n ro.lmk.downgrade_pressure 100
resetprop -n ro.lmk.kill_heaviest_task false
resetprop -n ro.lmk.kill_timeout_ms 30
resetprop -n ro.lmk.use_psi true
resetprop -n ro.lmk.psi_partial_stall_ms 500
resetprop -n ro.lmk.psi_complete_stall_ms 1000
resetprop -n ro.lmk.swap_util_max 100
resetprop -n ro.lmk.thrashing_limit 20
resetprop -n ro.lmk.thrashing_limit_decay 40
log "LMK: Tuned for PERFORMANCE"

# ==========================================
# SCHEDULER & KERNEL (MAXIMUM)
# ==========================================
log "Applying scheduler tweaks..."

# --- Kernel Scheduler ---
sysctl -w kernel.sched_autogroup_enabled=0 2>/dev/null
sysctl -w kernel.sched_child_runs_first=0 2>/dev/null
sysctl -w kernel.sched_migration_cost_ns=0 2>/dev/null
sysctl -w kernel.sched_min_granularity_ns=1000000 2>/dev/null
sysctl -w kernel.sched_wakeup_granularity_ns=1500000 2>/dev/null
sysctl -w kernel.sched_latency_ns=10000000 2>/dev/null
sysctl -w kernel.sched_nr_migrate=32 2>/dev/null
log "Scheduler: Tuned for LOW LATENCY"

# --- Disable Debugging ---
setprop persist.traced.enable 0
setprop debug.atrace.tags.enableflags 0
setprop dalvik.vm.dex2oat-threads 8
setprop dalvik.vm.image-dex2oat-threads 8
setprop dalvik.vm.dex2oat-filter speed
setprop dalvik.vm.dex2oat-Xms 64m
setprop dalvik.vm.dex2oat-Xmx 512m
setprop dalvik.vm.heapgrowthlimit 512m
setprop dalvik.vm.heapmaxfree 32m
setprop dalvik.vm.heapminfree 8m
setprop dalvik.vm.heaptargetutilization 0.75
log "Dalvik: Tuned for PERFORMANCE"

# --- Disable Unnecessary Services ---
settings put global hidden_api_policy 1 2>/dev/null
settings put global airplane_mode_on 0 2>/dev/null
log "Services: Optimized"

# ==========================================
# THERMAL MANAGEMENT
# ==========================================
log "Applying thermal tweaks..."

# --- Thermal Throttle Points (Higher) ---
for thermal in /sys/class/thermal/thermal_zone*/trip_point_*_temp; do
    echo "90000" > "$thermal" 2>/dev/null
done

# --- CPU Thermal Policy ---
for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    if [ -f "$policy/thermal_sustainable_power" ]; then
        echo "6000" > "$policy/thermal_sustainable_power" 2>/dev/null
    fi
done
log "Thermal: Throttle points raised"

# ==========================================
# ANIMATION & UI (SMOOTH)
# ==========================================
log "Applying UI tweaks..."

# --- Animation Scale (FAST) ---
settings put global window_animation_scale 0.5 2>/dev/null
settings put global transition_animation_scale 0.5 2>/dev/null
settings put global animator_duration_scale 0.5 2>/dev/null

# --- Hardware Rendering ---
settings put global hw_overlay 1 2>/dev/null
settings put global force_gpu_rendering 1 2>/dev/null
settings put global display_content_blur 0 2>/dev/null
log "UI: Animations set to 0.5x (FASTER)"

# ==========================================
# GAME AUTO-DETECT (BACKGROUND)
# ==========================================
log "Starting game detector..."
echo "balanced" > /data/adb/luwengsense_mode
sh "$MODDIR/gamedetect.sh" &

log "=== LuwengSense Pro COMPLETE MAXIMUM ==="
