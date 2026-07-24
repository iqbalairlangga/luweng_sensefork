#!/system/bin/sh
# LuwengSense Pro v3.2 - post-fs-data.sh
# Runs before zygote - apply early tweaks

MODDIR=${0%/*}

# LMK tuned v3.2
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

# v3.2: Additional early resets
resetprop -n debug.atrace.tags.enableflags 0
resetprop -n persist.traced.enable 0
resetprop -n persist.logd.size 262144
resetprop -n dalvik.vm.dex2oat-threads 8
resetprop -n dalvik.vm.image-dex2oat-threads 8
