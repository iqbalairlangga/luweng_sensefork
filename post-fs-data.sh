#!/system/bin/sh
# LuwengSense Pro - post-fs-data.sh
# Runs before zygote - apply early tweaks

MODDIR=${0%/*}

# Reset LMK properties to sane defaults
resetprop -n ro.lmk.low 1001
resetprop -n ro.lmk.medium 1001
resetprop -n ro.lmk.critical 1001
resetprop -n ro.lmk.critical_upgrade false
resetprop -n ro.lmk.upgrade_pressure 100
resetprop -n ro.lmk.downgrade_pressure 100
resetprop -n ro.lmk.kill_heaviest_task false
resetprop -n ro.lmk.kill_timeout_ms 30
resetprop -n ro.lmk.use_psi true
resetprop -n ro.lmk.psi_partial_stall_ms 750
resetprop -n ro.lmk.psi_complete_stall_ms 1600
resetprop -n ro.lmk.swap_util_max 100
resetprop -n ro.lmk.thrashing_limit 30
resetprop -n ro.lmk.thrashing_limit_decay 50

# Disable debug tracing for performance
resetprop -n debug.atrace.tags.enableflags 0
resetprop -n persist.traced.enable 0
