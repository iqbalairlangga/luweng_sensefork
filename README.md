# LuwengSense Pro v3.2

> **Fork dari [LuwengSense](https://github.com/KepalaLuweng/LuwengSense) dengan real tweaks yang terbukti work.**

---

## What's New in v3.2

### Gaming Mode - Significant FPS Stability
- **Frame pacing optimization** via `debug.sf.latch_unsignaled`, `render_dirty_regions`, `disable_backpressure`
- **85% min CPU frequency** locked - prevents frame drops during heavy scenes
- **100% schedtune boost** + all cores assigned to top-app
- **GPU locked to max** (Adreno + Mali all methods)
- **Ultra low latency networking** (BBR + TCP fastopen + low latency)
- **I/O none scheduler** with 4MB read ahead for asset loading
- **VM swappiness=10** to minimize swap thrashing during gaming
- **Thermal raised to 95C** for sustained performance

### Balanced Mode - Improved Multitasking & Scrolling
- **60% min CPU frequency** (up from 50%) for smoother app switching
- **30% schedtune boost** + prefer_idle for responsive social media
- **512KB read ahead** (up from 128KB) for smooth scrolling in feeds
- **GPU 60% frequency** - enough for UI rendering without waste
- **Increased background app limit** (`frozen_bg_disable=1`)
- **Smooth scroll rendering** (`scroll_per_frame=0`, `max_frame_buffer_acquired_buffers=3`)
- **bfq I/O scheduler** for fair multitasking I/O

### Battery Mode - More Stable Power Saving
- **CPU powersave governor** + lowest frequency locked
- **GPU 1/6 max frequency** for minimal power draw
- **Disable EGL/UBWC** rendering to save GPU power
- **80% swappiness** - keep more in compressed RAM
- **Adaptive battery saver enabled** + Doze enhanced
- **WiFi sleep policy** = 2 (disconnect when screen off)
- **Thermal lowered to 75C** for cooler operation
- **Animations fully disabled** (0x scale)

---

## Mode Transitions

```
Screen OFF  ──────────►  Battery Mode (v3.2: Extreme Saving)
Screen ON   ◄──────────  Battery Mode
Normal App  ──────────►  Balanced (v3.2: Smooth Multitasking)
Game Open   ──────────►  Gaming (v3.2: FPS Stability)
Game Close  ──────────►  Balanced
```

---

## Gaming vs Balanced vs Battery (v3.2)

| Component | Balanced | Gaming | Battery |
|-----------|----------|--------|---------|
| CPU Governor | schedutil | performance | powersave |
| CPU Min Freq | **60%** | **85%** | **lowest** |
| CPU Boost | **30%** | **100%** | **0%** |
| GPU | **60%** | **MAX** | **1/6** |
| Render Props | smooth scroll | frame pacing | power save |
| Network | Normal | **Ultra Low Latency** | Normal |
| I/O Scheduler | bfq | **none** | cfq |
| Read Ahead | **512KB** | **4MB** | **64KB** |
| VM Swappiness | 40 | **10** | **80** |
| Thermal | 85C | **95C** | **75C** |
| Animations | 0.5x | 0.5x | **0x** |
| Logging | ON | **OFF** | ON |

---

## Real Tweaks (Not Placebo)

### Network & Signal
| Tweak | Value | Description |
|-------|-------|-------------|
| TCP Congestion | BBR | Best algorithm |
| Network Buffer | 64MB | Large TCP window |
| TCP Fastopen | 3 | Reduce latency |
| DNS | Cloudflare DoT | Fast & secure |
| Low Latency | 1 | For gaming |

### GPU Support
| GPU | Support |
|-----|---------|
| Adreno (Qualcomm) | Full |
| Mali (MediaTek) | Full |
| Mali (Samsung Exynos) | Full |
| Mali (ARM) | Full |
| Generic | Full |

### Auto-Detect
| Feature | Description |
|---------|-------------|
| Auto Gaming | Detect game open/close |
| Auto Battery | Screen off = saving |
| 25+ Games | Pre-configured |
| Custom Games | Add via WebUI |

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

## Games Pre-configured (25+)

```
Mobile Legends, Genshin Impact, PUBG Mobile, PUBG KR,
Call of Duty, Clash of Clans, Clash Royale, Brawl Stars,
FIFA Mobile, Fortnite, Wild Rift, Free Fire,
Roblox, Minecraft, Subway Surfers, Temple Run,
Talking Tom, 8 Ball Pool, Hay Day, Among Us
```

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

**Version:** 3.2
**Last Updated:** July 2026
