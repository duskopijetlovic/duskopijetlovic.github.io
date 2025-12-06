---
layout: post
title: "X11 DPI Reference"
date: 2025-11-22 15:22:17 -0700 
categories: x11 xorg xterm config dotfiles howto font freebsd utf8 unicode unix 
            cli terminal shell tip c programming tutorial howto
---

# X11 DPI & Font Scaling: Essential Reference

My environment:

* FreeBSD 14.3
* Shell: csh
* WM (window manager): FVWM3
* No DE (Desktop Environment)

## TL;DR
- For my 14-inch laptop, set **Xft.dpi: 120** in `~/.Xresources` to match the external monitor scaling.
- Physical DPI (from EDID): use `xdpyinfo | grep dimensions` -> compute with `(pixels/mm) × 25.4`.
- Logical DPI (what apps use): check with `xrdb -query | grep Xft.dpi`.
- `xdpyinfo` shows **X server DPI** (rarely used by modern apps).
- Modern apps (GTK, Qt, Firefox, Thunderbird) need their own scaling settings.
- Xft.dpi can be changed **live** (`xrdb -merge`). X server DPI **cannot**.
- Scaling on X11 is per-toolkit; no universal scaling unless inside a Desktop Environment.
- For Firefox/Thunderbird, use `layout.css.devPixelsPerPx = 1.0` for 1× scaling.
- `xterm` for *bitmap* fonts (**XLFD**) uses its own font sizes, independent of DPI.

---

## 1. Core Terms

**Physical dimensions** - The size of the display in millimeters, usually read from EDID.

**Physical DPI** - Pixels per inch computed from physical size; often inaccurate on laptops.

**Logical DPI** - The DPI value X uses for UI and font scaling; controlled by `Xft.dpi` or XSETTINGS.

**Global Xft.dpi** - A logical DPI value that affects all applications using Xft/Fontconfig (not XLFD).

**X Server DPI (xdpyinfo DPI)** - The DPI value determined by the X server at startup, based on EDID or defaulting to 96.

**EDID** - A small data block from the display that reports resolution, size, and capabilities.

---

## 2. What Each Command Shows

**`xdpyinfo`** - Shows what the *X server* believes: physical size, resolution, and the X server's DPI.

**`xrandr`** - Shows physical size and resolution per output, as reported via EDID.

**`xrdb -query`** - Shows the current logical DPI (`Xft.dpi`) used by Xft/Fontconfig-based apps.

**`/var/log/Xorg.0.log`** - Shows EDID-reported millimeter size and the DPI computed by Xorg at startup.

**`xdpi` (external tool)** - Shows physical DPI per display using EDID values.

---

## 3. Commands

**Show X server DPI**
```
xdpyinfo | grep -i dots
```

**Show Xft.dpi (logical DPI for modern font rendering)**
```
xrdb -query | grep -i dpi
```

**Show physical dimensions and resolution**
```
xdpyinfo | grep dimensions
xrandr | grep -w connected
```

**Show EDID-derived dimensions from Xorg**
```
grep -i "dimension" /var/log/Xorg.0.log
```

---

## 4. DPI Formulas

**Physical DPI:**
```
(pixels / millimeters) × 25.4
```

**Logical DPI** - no formula; it's whatever you set in:
- `~/.Xresources` (Xft.dpi)
- `xrdb -merge`
- A desktop environment's XSETTINGS daemon

---

## 5. Examples

**Example laptop:**
```
Resolution: 1920 × 1200
Size:       301 × 188 mm
```

Physical DPI:
```
(1200 / 188) × 25.4 = 162.05
(1920 / 301) × 25.4 = 161.79
≈ 162 DPI
```

If `Xft.dpi` is set to 120 (in `~/.Xresources`):
```
xrdb -query | grep Xft.dpi -> 120 
xdpyinfo -> still shows 162 (X server DPI)
```

This is normal because X server DPI does **not** change **automatically** when `Xft.dpi` changes.

---

## 6. Changing DPI

### Change logical DPI (affects fonts/UI in modern apps)
```
printf "Xft.dpi: 120" | xrdb -merge
```
Effective immediately for most apps (you'll probably need to restart them).

### Change X server DPI (rare, requires restart)
```
startx -- -dpi 120 
```
Or add to Xorg config.

Changing X server DPI *live* is generally **not** supported.

---

## 7. Q&A

**Q: How do I check *physical* DPI?**  
A: `xdpyinfo | grep dimensions` or `xrandr`, then compute using the formula.

**Q: How do I check *logical* DPI?**  
A: `xrdb -query | grep Xft.dpi`.

**Q: Why do xdpyinfo DPI and Xft.dpi differ?**  
A: `xdpyinfo` shows **X server DPI**; `Xft.dpi` is a **separate logical DPI** for modern font systems.

**Q: Is Xft.dpi global?**  
A: Yes - global for all Xft/Fontconfig-based applications; does not affect legacy XLFD apps.

**Q: Can I change Xft.dpi live?**  
A: Yes, using `xrdb -merge`.

**Q: Can I change the X server DPI live?**  
A: No, it requires restarting X.

**Q: How can I verify whether EDID-reported millimeters are correct?**  
A: Compare `xrandr` or `xdpyinfo` millimeter values with the actual physical measurement of the screen.

---

## 8. Additional Answers for FreeBSD + FVWM3 Environment

**What DPI should I set on my laptop?**  
To match a 94-DPI external monitor, set **Xft.dpi: 120** so all Fontconfig/Xft applications scale similarly.

**Can this be set globally?**  
Yes: put `Xft.dpi: 120` in `~/.Xresources` and load with `xrdb -merge`.
Some toolkits (GTK, Qt, Firefox, Thunderbird) still need separate per-toolkit scaling.

**Is today's scaling situation per-application?**  
Yes. There is no universal scaling across X11; each toolkit may require overrides.

**Font scaling vs. full scaling**  
Font scaling affects *text size only*.
Full scaling enlarges *entire UI elements* (buttons, icons, padding, windows), typically via toolkit DPI multipliers.

**Do I need fractional scaling?**  
No. Since you want ~120 DPI, set `Xft.dpi: 120` and adjust toolkit settings; fractional scaling is mostly needed for DEs (Desktop Environments)

**Do apps render at their own resolution?**  
Yes. Applications draw at native resolution unless toolkit scaling is applied.

**Why is scaling difficult?**  
Because each toolkit (GTK, Qt, Xlib, Xft) uses its own environment variables and X settings.

**Which tools give DPI?**  
- Physical DPI: `xdpyinfo`, `xrandr`, Xorg logs, `xdpi`.  
- Logical DPI: `xrdb -query` (Xft.dpi).  
- Real DPI: same as *physical DPI*.  
`xrandr` shows physical size but does *not* compute DPI.

**DPI vs PPI?**  
DPI originated from printing; PPI is correct for screens.
In practice, DPI ~= PPI.

**Can Xft.dpi be changed live?**  
Yes: `printf "Xft.dpi: 120" | xrdb -merge`.  
Toolkit-specific DPI (Qt, GTK) can also be changed live via environment variables.

**What do `xdpi` and `qtdpi` report?**  
`xdpi` reports EDID-based physical DPI.
`qtdpi` reports logical DPI per screen (Qt's internal interpretation).

**Toolkits you need to configure:**  
- GTK2: `~/.gtkrc-2.0` (font sizes). 
- GTK3: `~/.config/gtk-3.0/settings.ini` (scaling + font sizes).  
- Qt5/Qt6: env vars (`QT_SCALE_FACTOR`, `QT_FONT_DPI`, etc.).  
- Firefox/Thunderbird: set `layout.css.devPixelsPerPx = 1.0` for 1× scaling.

**xterm scaling (for bitmap fonts)**  
*Bitmap fonts*: use **XLFD names** in `~/.Xresources`. 

