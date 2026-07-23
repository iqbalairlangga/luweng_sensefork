# LuwengSense Pro v2.0

**Fork dari [LuwengSense](https://github.com/KepalaLuweng/LuwengSense) dengan real tweaks yang terbukti work.**

## Apa itu LuwengSense Pro?

LuwengSense Pro adalah fork dari LuwengSense (Original) yang dibersihkan dari tweaks placebo dan fokus pada **2 hal utama**:

1. **Signal & Ping Stability** - Koneksi internet lebih stabil
2. **Gaming Performance** - Performa gaming lebih smooth

---

## Perbedaan dengan Original

| Aspek | LuwengSense (Original) | LuwengSense Pro (Fork) |
|-------|------------------------|------------------------|
| **Thermal Throttle** | Placebo files (tidak work) | Real GPU/SkiaGL tweaks |
| **Memory Cgroup** | Cgroup hacks (ignored kernel) | Proper VM tuning |
| **Sysctl Values** | Banyak yang invalid | Validated & tested |
| **DNS** | `setprop net.dns` (tidak work) | DNS over TLS (real) |
| **Profiles** | 6+ profiles (complex) | 3 profiles (fokus) |
| **WebUI** | Web UI kompleks | iOS-style minimal |
| **Code Size** | ~600+ baris | ~440 baris (lebih clean) |

---

## Apa yang Diubah?

### 1. Dihapus (Placebo/Tidak Work)

```
❌ Thermal placebo files (system/vendor/bin/thermal)
   → File kosong tidak bisa disable thermal asli

❌ Memory cgroup tweaks (/dev/memcg)
   → Kernel modern mengabaikan ini

❌ setprop net.dns1/dns2
   → Tidak work di Android 9+, harus pakai DNS over TLS

❌ Beberapa sysctl values yang tidak ada di kernel
   → Error silently, tidak ada efek
```

### 2. Ditambahkan (Real Tweaks)

```
✅ BBR/CUBIC TCP Congestion Control
   → Algoritma TCP yang benar-benar improve throughput

✅ Network Buffer Tuning
   → TCP window size 16MB, backlog 4096

✅ TCP Fast Open
   → Kurangi latency koneksi pertama

✅ DNS over TLS (Cloudflare)
   → DNS lebih cepat & aman

✅ RIL Optimization
   → Better radio signal handling

✅ CPU Governor (schedutil/performance)
   → Real CPU frequency scaling

✅ GPU SkiaGL Rendering
   → Hardware-accelerated UI

✅ I/O Scheduler (bfq/noop)
   → Faster storage access

✅ ZRAM lz4 Compression
   → Kompresi RAM lebih efisien

✅ Input Sampling 240Hz
   → Touch lebih responsif

✅ VM Tuning
   → swappiness, dirty_ratio, vfs_cache_pressure
```

### 3. WebUI

```
🎨 iOS-style Design
   → Blur effects, SF Pro font, smooth animations

🌙 Dark/Light Mode
   → Auto-detect system theme

📊 Real-time Stats
   → Ping, CPU, RAM, GPU update setiap 2 detik

🔄 Profile Switching
   → Balanced/Gaming/Battery dengan 1 tap

🔘 iOS Toggle Switches
   → Haptic feedback support
```

---

## Profiles

| Profile | Description |
|---------|-------------|
| **Balanced** | Default. Balance antara performance dan battery |
| **Gaming** | Max CPU/GPU performance, low latency |
| **Battery** | Max efficiency, throttling lebih aggressive |

---

## Instalasi

1. Download zip dari Releases
2. Flash via Magisk/KernelSU Manager
3. Reboot
4. Tap tombol **"Action"** untuk buka WebUI

---

## Requirements

- Magisk v20.4+ atau KernelSU
- Android 8.0+ (Oreo - 16)
- ARM/ARM64

---

## Credits

- Original: [KepalaLuweng](https://github.com/KepalaLuweng/LuwengSense)
- Fork & Pro Version: [iqbalairlangga](https://github.com/iqbalairlangga)

---

## License

Module ini mengikuti lisensi dari project original.
Harap cantumkan credit jika menggunakan/memodifikasi.

---

**Version:** 2.0  
**Last Updated:** 2024
