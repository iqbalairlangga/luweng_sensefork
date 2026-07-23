# LuwengSense Pro v3.0

> **Fork dari [LuwengSense](https://github.com/KepalaLuweng/LuwengSense) dengan real tweaks yang terbukti work.**

---

## Tentang Project Ini

**LuwengSense Pro** adalah versi **fork** dari module Magisk/KernelSU bernama **LuwengSense** (Original) yang dibuat oleh KepalaLuweng.

Project ini dibuat karena versi original memiliki beberapa tweaks yang **placebo** (tidak benar-benar work). LuwengSense Pro dibersihkan dan hanya menggunakan tweaks yang **real** dan **terbukti** meningkatkan performa.

### Fokus Utama

1. **Signal & Ping Stability** - Koneksi internet lebih stabil, ping lebih rendah
2. **Gaming Performance** - Performa gaming lebih smooth, FPS lebih tinggi

---

## Perbedaan dengan Original

| Aspek | LuwengSense (Original) | LuwengSense Pro (Fork) |
|-------|------------------------|------------------------|
| **Thermal Throttle** | Placebo files (tidak work) | Real GPU tweaks |
| **Memory Cgroup** | Cgroup hacks (ignored) | Proper VM tuning |
| **Sysctl Values** | Banyak invalid | Validated & tested |
| **DNS** | `setprop net.dns` (tidak work) | DNS over TLS (real) |
| **Profiles** | 6+ profiles | 3 profiles (fokus) |
| **WebUI** | Kompleks | iOS-style minimal |
| **GPU Support** | Adreno only | Adreno + **Mali** |
| **Auto Detect** | Tidak ada | Game + Screen detect |

---

## Apa yang Dihapus (Placebo)

```
❌ Thermal placebo files
   → File kosong tidak bisa disable thermal asli

❌ Memory cgroup tweaks (/dev/memcg)
   → Kernel modern mengabaikan ini

❌ setprop net.dns1/dns2
   → Tidak work di Android 9+

❌ Sysctl values yang tidak ada
   → Error silently, tidak ada efek
```

---

## Apa yang Ditambahkan (Real Tweaks)

### Network & Signal Stability

| Tweak | Value | Penjelasan |
|-------|-------|------------|
| TCP Congestion | BBR/CUBIC | Algoritma TCP terbaik |
| Network Buffer | 64MB | TCP window besar |
| TCP Fastopen | Enabled | Kurangi latency |
| DNS | Cloudflare DoT | DNS cepat & aman |
| Low Latency | Enabled | Untuk gaming |
| Max Backlog | 65535 | Koneksi lebih banyak |

### CPU Performance

| Tweak | Value | Penjelasan |
|-------|-------|------------|
| Governor | Performance | Forced max performance |
| Min Frequency | 70-85% | CPU tidak pernah turun |
| schedtune Boost | Enabled | Priority boost |
| Dex2OAT Threads | 8 | Fast app compilation |

### GPU Performance

| Tweak | Value | Penjelasan |
|-------|-------|------------|
| **Adreno (Qualcomm)** | Forced | Max frequency locked |
| **Mali (MediaTek)** | Forced | NEW - support semua Mali |
| **Mali (Samsung Exynos)** | Forced | NEW |
| **Mali (ARM)** | Forced | NEW |
| Force Clock On | 1 | GPU tidak sleep |
| Force Rail On | 1 | GPU selalu aktif |
| Idle Timer | 0 | Disable idle timeout |

### I/O Performance

| Tweak | Value | Penjelasan |
|-------|-------|------------|
| Scheduler | none/noop | Minimal overhead |
| Read Ahead | 4MB | Storage cepat |
| Queue Requests | 256 | Parallel I/O |
| FSTRIM | On boot | Storage optimization |

### Memory Management

| Tweak | Value | Penjelasan |
|-------|-------|------------|
| ZRAM Size | 75% RAM | Kompresi agresif |
| Compression | lz4 | Fast compression |
| Swappiness | 40 | RAM optimal |
| Min Free | 16MB | Reserve RAM |

### Auto-Detect Features

| Fitur | Penjelasan |
|-------|------------|
| Auto Gaming Mode | Deteksi game otomatis |
| Auto Battery Mode | Screen off = battery |
| 28+ Games | Pre-configured list |
| Manual Add Game | Custom package name |
| Exact Match | Akurasi tinggi |

### WebUI Features

| Fitur | Penjelasan |
|-------|------------|
| iOS Design | Blur effects, smooth |
| Dark/Light Mode | Auto theme |
| Real-time Stats | Ping, CPU, RAM, GPU |
| Manual Game List | Add/remove games |
| Toast Notifications | Notifikasi semua aksi |
| Profile Tabs | Balanced/Gaming/Battery |
| Toggle Switches | iOS-style |
| Tweak Status | Indicator active |

---

## Mode Transitions

```
┌─────────────────────────────────────────┐
│            MODE TRANSITIONS             │
├─────────────────────────────────────────┤
│                                         │
│   Screen OFF  ──────────►  Battery Mode │
│       │                     (CPU/GPU low)│
│       ▼                                │
│   Screen ON   ◄──────────  Battery Mode │
│       │                                │
│       ▼                                │
│   Normal App  ──────────►  Balanced     │
│       │                     (Normal)    │
│       ▼                                │
│   Game Open   ──────────►  Gaming Mode  │
│       │                     (MAX PERF)  │
│       ▼                                │
│   Game Close  ──────────►  Balanced     │
│                             (Normal)    │
└─────────────────────────────────────────┘
```

---

## Gaming Mode vs Balanced Mode

| Component | Balanced | Gaming |
|-----------|----------|--------|
| CPU Governor | schedutil | performance |
| CPU Min Freq | 50% | **85%** |
| GPU | Balanced | **MAX** |
| Network | Normal | **Ultra Low Latency** |
| I/O | bfq | **noop** |
| Read Ahead | 128KB | **4MB** |
| VM Swappiness | 40 | **10** |
| Thermal | 85°C | **95°C** |
| Logging | ON | **OFF** |

---

## Instalasi

### Requirements
- **Root:** Magisk v20.4+ atau KernelSU
- **Android:** 8.0+ (Oreo - 16)
- **Architecture:** ARM / ARM64

### Steps
1. Download zip dari [Releases](https://github.com/iqbalairlangga/luweng_sensefork/releases)
2. Buka Magisk/KernelSU Manager
3. Tap **Install** → Pilih zip file
4. Tap tombol **"Action"** untuk buka WebUI
5. Enable **Auto Gaming Mode** & **Auto Battery Mode**

---

## Cara Menggunakan WebUI

1. Buka Magisk/KernelSU Manager
2. Tap module **LuwengSense Pro**
3. Tap tombol **"Action"** (atau buka browser ke `http://127.0.0.1:8080`)
4. Di WebUI kamu bisa:
   - Lihat status (Ping, CPU, RAM, GPU)
   - Switch profile (Balanced/Gaming/Battery)
   - Enable/disable Auto Gaming & Auto Battery
   - Add/remove game dari list
   - Lihat semua tweaks yang aktif

---

## Games yang Sudah Terdaftar (28+)

```
Mobile Legends, Genshin Impact, PUBG Mobile, PUBG KR,
Call of Duty, Clash of Clans, Clash Royale, Brawl Stars,
FIFA Mobile, Fortnite, Wild Rift, Free Fire,
Roblox, Minecraft, Subway Surfers, Temple Run,
Talking Tom, 8 Ball Pool, Hay Day, Among Us
```

**Note:** Kamu bisa menambahkan game lain secara manual di WebUI!

---

## Credits

| Role | Name |
|------|------|
| **Original Creator** | [KepalaLuweng](https://github.com/KepalaLuweng/LuwengSense) |
| **Fork & Pro Version** | [iqbalairlangga](https://github.com/iqbalairlangga) |

---

## License

Module ini mengikuti lisensi dari project original.
Harap cantumkan credit jika menggunakan/memodifikasi.

---

**Version:** 3.0  
**Last Updated:** July 2026
