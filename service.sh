#!/system/bin/sh
# LuwengSense Pro - service.sh
# Main tweak application - runs after boot completed

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
# NETWORK & SIGNAL STABILITY TWEAKS
# ==========================================
log "Applying network tweaks..."

# --- TCP Congestion Control ---
TCP_AVAIL=$(cat /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null)
if echo "$TCP_AVAIL" | grep -q "bbr"; then
    echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control
    log "TCP: BBR enabled"
elif echo "$TCP_AVAIL" | grep -q "cubic"; then
    echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control
    log "TCP: CUBIC enabled"
fi

# --- Network Buffer Tuning ---
# These are real sysctl tweaks that affect network performance
sysctl -w net.core.rmem_max=16777216 2>/dev/null
sysctl -w net.core.wmem_max=16777216 2>/dev/null
sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216" 2>/dev/null
sysctl -w net.ipv4.tcp_wmem="4096 65536 16777216" 2>/dev/null
sysctl -w net.core.somaxconn=4096 2>/dev/null
sysctl -w net.core.netdev_max_backlog=4096 2>/dev/null
sysctl -w net.ipv4.tcp_fastopen=3 2>/dev/null
sysctl -w net.ipv4.tcp_slow_start_after_idle=0 2>/dev/null
sysctl -w net.ipv4.tcp_mtu_probing=1 2>/dev/null
sysctl -w net.ipv4.tcp_timestamps=1 2>/dev/null
sysctl -w net.ipv4.tcp_sack=1 2>/dev/null
sysctl -w net.ipv4.tcp_window_scaling=1 2>/dev/null
sysctl -w net.ipv4.tcp_no_metrics_save=1 2>/dev/null
sysctl -w net.ipv4.tcp_max_syn_backlog=4096 2>/dev/null
sysctl -w net.ipv4.tcp_fin_timeout=15 2>/dev/null
sysctl -w net.ipv4.tcp_keepalive_time=600 2>/dev/null
sysctl -w net.ipv4.tcp_keepalive_intvl=30 2>/dev/null
sysctl -w net.ipv4.tcp_keepalive_probes=5 2>/dev/null
log "Network buffer tuning applied"

# --- DNS Optimization ---
# Use private DNS on Android 9+
SDK=$(getprop ro.build.version.sdk)
if [ "$SDK" -ge 28 ]; then
    settings put global private_dns_mode hostname
    settings put global private_dns_specifier 1dot1dot1dot1.cloudflare-dns.com
    log "DNS: Cloudflare over TLS enabled"
fi

# --- Mobile Data Signal Optimization ---
# RIL (Radio Interface Layer) tweaks for better signal handling
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
log "RIL signal tweaks applied"

# --- WiFi Optimizations ---
setprop persist.wifi.disable_firmware_roam 0
setprop persist.wifi_VERBOSE_LOGS 0
setprop persist.wifi.turnOnOffOnP2p 0
log "WiFi tweaks applied"

# ==========================================
# GAMING & CPU PERFORMANCE TWEAKS
# ==========================================
log "Applying performance tweaks..."

# --- CPU Governor ---
# Find and set best available governor
GOVS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)
if echo "$GOVS" | grep -q "schedutil"; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "schedutil" > "$cpu" 2>/dev/null
    done
    log "CPU: schedutil governor set"
elif echo "$GOVS" | grep -q "performance"; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$cpu" 2>/dev/null
    done
    log "CPU: performance governor set"
fi

# --- CPU Frequency Scaling ---
# Set minimum frequency higher for better responsiveness
for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    if [ -f "$policy/cpuinfo_min_freq" ] && [ -f "$policy/scaling_min_freq" ]; then
        MIN=$(cat "$policy/cpuinfo_min_freq")
        MAX=$(cat "$policy/cpuinfo_max_freq")
        # Set min to 50% of max for better responsiveness
        MID=$(( (MIN + MAX) / 2 ))
        echo "$MID" > "$policy/scaling_min_freq" 2>/dev/null
    fi
done
log "CPU: Frequency scaling tuned"

# --- GPU Tweaks ---
# Force GPU rendering for smoother UI
setprop debug.hwui.renderer skiagl
setprop debug.renderengine.backend skiaglthreaded
setprop debug.sf.latch_unsignaled 1

# GPU frequency if available
for gpu in /sys/class/kgsl/kgsl-3d0/devfreq /sys/devices/platform/*.gpu/devfreq; do
    if [ -d "$gpu" ]; then
        if [ -f "$gpu/min_freq" ]; then
            MAX_FREQ=$(cat "$gpu/max_freq" 2>/dev/null)
            if [ -n "$MAX_FREQ" ]; then
                MID_FREQ=$(( MAX_FREQ / 2 ))
                echo "$MID_FREQ" > "$gpu/min_freq" 2>/dev/null
            fi
        fi
    fi
done
log "GPU tweaks applied"

# --- I/O Scheduler ---
# Set best available I/O scheduler
IOSCHED=$(cat /sys/block/sda/queue/scheduler 2>/dev/null || cat /sys/block/mmcblk0/queue/scheduler 2>/dev/null)
if echo "$IOSCHED" | grep -q "bfq"; then
    for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue; do
        echo "bfq" > "$queue/scheduler" 2>/dev/null
    done
    log "I/O: bfq scheduler set"
elif echo "$IOSCHED" | grep -q "noop"; then
    for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue; do
        echo "noop" > "$queue/scheduler" 2>/dev/null
    done
    log "I/O: noop scheduler set"
fi

# I/O Read Ahead
for queue in /sys/block/sd*/queue /sys/block/mmcblk*/queue; do
    echo "2048" > "$queue/read_ahead_kb" 2>/dev/null
done
log "I/O: Read ahead set to 2048KB"

# --- Virtual Memory ---
sysctl -w vm.swappiness=60 2>/dev/null
sysctl -w vm.dirty_ratio=15 2>/dev/null
sysctl -w vm.dirty_background_ratio=5 2>/dev/null
sysctl -w vm.vfs_cache_pressure=50 2>/dev/null
sysctl -w vm.min_free_kbytes=4096 2>/dev/null
log "VM tuning applied"

# --- ZRAM ---
if [ -e /sys/block/zram0 ]; then
    swapoff /dev/block/zram0 2>/dev/null
    echo 1 > /sys/block/zram0/reset 2>/dev/null
    sleep 1
    
    TOTAL_RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    ZRAM_SIZE=$(( TOTAL_RAM / 2 ))
    [ "$ZRAM_SIZE" -lt 1024000 ] && ZRAM_SIZE=1024000
    [ "$ZRAM_SIZE" -gt 4194304 ] && ZRAM_SIZE=4194304
    
    echo lz4 > /sys/block/zram0/comp_algorithm 2>/dev/null
    echo "${ZRAM_SIZE}K" > /sys/block/zram0/disksize 2>/dev/null
    mkswap /dev/block/zram0 2>/dev/null
    swapon /dev/block/zram0 2>/dev/null
    log "ZRAM: ${ZRAM_SIZE}K configured"
fi

# --- Scheduler Tuning ---
sysctl -w kernel.sched_autogroup_enabled=0 2>/dev/null
sysctl -w kernel.sched_child_runs_first=0 2>/dev/null
log "Scheduler tweaks applied"

# --- Disable Unnecessary Debugging ---
setprop dalvik.vm.dex2oat-threads 4
setprop dalvik.vm.image-dex2oat-threads 4
log "ART/Dalvik tweaks applied"

log "=== LuwengSense Pro Complete ==="
