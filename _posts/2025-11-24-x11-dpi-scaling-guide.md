---
layout: post
title: "X11 DPI Scaling Guide" 
date: 2025-11-24 10:16:11 -0700 
categories: x11 xorg xterm config dotfiles howto font freebsd utf8 unicode unix 
            cli terminal shell tip c programming tutorial howto
---

# X11 DPI, Xft, X Server DPI, and Scaling 

A consolidated, reference for DPI, Xft, X Server DPI, EDID, and scaling in X11 environments - especially for FreeBSD with FVWM3 window manager or any non-DE workflow.

FreeBSD * X11 * FVWM3 * No DE

My environment: FreeBSD 14.3, Shell: csh, WM (window manager): FVWM3, No DE (Desktop Environment), Lenovo ThinkPad T14s Gen 3 (14", Intel) laptop.

---

Scenario: You have a 14-inch laptop, and its built-in screen is a WUXGA (Wide Ultra XGA) (resolution: 1920 x 1200) screen, so even though it's not HiDPI (as HiDPI typically starts at displays with a pixel density greater than 200 pixels per inch (PPI)), it's still a *Very High Pixel Density (140+ PPI)* panel.
When you use it with an external monitor that supports PPI (DPI) of 90-110 DPI, it works fine.
However, when you use the laptop with only its built-in screen, everything appears smaller than it's comfortable for you. (Sharp fonts but microscopic UI elements.)

---

# TL;DR

## What DPI should I use on this laptop?
* Set **Xft.dpi: 120** in `~/.Xresources` 

Explanation:
- Physical DPI on this laptop = *162*. --> See (11a).
- DPI that I like on the extarnal monitor = 94.
- Preferred *effective DPI* ~94. 

To approximate this scaling, I use DPI = **120**, or DPI = **144**, so set `Xft.dpi` to 120 or 144. 

Add either this line:

```
Xft.dpi: 120
```

or this line:

```
Xft.dpi: 144
```

to `~/.Xresources`.

Recommended values:

* **96** = standard
* **120** = ~125% scaling (good for 90-110 DPI screens)
* **144** = ~150% scaling

* Physical DPI (from EDID): use `xdpyinfo | grep dimensions` -> compute with `(pixels/mm) x 25.4`.
* Logical DPI (what apps use): check with `xrdb -query | grep Xft.dpi`.
* `xdpyinfo` shows **X server DPI** (rarely used by modern apps).
* Modern apps (GTK, Qt, Firefox, Thunderbird) need their own scaling settings.
* `Xft.dpi` can be changed **live** (`xrdb -merge`). X server DPI **cannot**.
* Scaling on X11 is per-toolkit; no universal scaling unless inside a Desktop Environment.
* For Firefox/Thunderbird, use `layout.css.devPixelsPerPx = 1.0` for 1x scaling.
* For bitmap (XLFD) fonts, Xterm uses its own font sizes, independent of DPI.

# 1. Check or Compute Physical DPI (from EDID)

aka: **Actual** pixel density of the monitor  
aka: Commands you use for DPI diagnostics

To determine the DPI value that Xorg has set for your display, you can use the `grep` command to search the Xorg log file.

```
$ grep DPI /var/log/Xorg.0.log
```

While this command shows the DPI value Xorg is using, it might not always reflect the physical DPI of your monitor, especially if Xorg is unable to correctly determine the display's physical dimensions or if a default DPI (like 96 DPI) is being applied. 
For a more accurate physical DPI calculation, you need to manually compute it from its actual physical dimensions and resolution (pixels). 

First, find out the monitor's dimensions and pixels (resolution).  

```
$ xdpyinfo | grep dimensions          # gives pixels + mm size
```

Alternatively:

```
$ xrandr --prop | grep -w connected   # gives pixels + mm size
```

Then, compute the physical DPI:

```
(pixels / millimeters) x 25.4
```

For an example of computing physical DPI, see (11a).

NOTE: EDID may sometimes report incorrect millimeter sizes.

# 2. Check X Server DPI (rarely meaningful)

aka: What Xorg calculates *at startup* from EDID or overrides (e.g., overrides by commands 


aka: What Xorg *thinks* your DPI is  
aka: "`xdpyinfo` dots-per-inch" (often physical DPI, not logical DPI)

Shown in:

```
$ xdpyinfo | grep dots
```

For an example of using `xdpyinfo` to get X Server DPI, see (11b).

* Almost never affects anything modern.
* Only very old X11 programs care.
* Cannot be changed live.

# 3. Check Logical DPI (Read X Resources)

aka: `Xft.dpi`   
aka: What apps use   
aka: User-controlled DPI (or Effective user scaling)  

Toolkit DPI, used by Fontconfig/Xft, GTK, Qt, and many modern apps.  

Shown in:

```
$ xrdb -query | grep Xft.dpi
```

Also:

```
$ grep Xft.dpi ~/.Xresources
```

Can be changed live via `xrdb -merge`.

For an example using `xrdb -query` or using `grep` on `.Xresources` to query the logical DPI, see (11c).

### Set Logical DPI (Recommended Workflow)

Logical DPI = `Xft.dpi`, controls *font scaling* for modern apps.

**Where is the logical DPI set?**   
See 3a, 3b, and 3c.

#### 3a. To set logical DPI temporary - during the current X session

```
$ printf "%s\n" "Xft.dpi:  120" | xrdb -merge
```

#### 3b. To set logical DPI permanently

Add the following line to `~/.Xresources`:

```
Xft.dpi: 120
```

#### 3c. To set X server DPI (requires restart) - rarely meaningful

aka: Change logical DPI server-wide  

```
$ startx -- -dpi 120 
```

# 4. Recommended Flexible Workflow

Keep **Xft.dpi = 120 - 144**, and adjust individual toolkits/apps via environment variables instead of relying on a Desktop Environment (DE).
Works well in FVWM3 + FreeBSD.

**Why DPI** of **120** to **144**?

120 DPI = 96 x 1.25, and 144 DPI = 96 x 1.50, which are clean, well-tested 125% and 150% scaling steps.

```
$ printf "%s\n" "scale = 2; 94 * 1.5" | bc
141.0

$ printf "%s\n" "scale = 2; 96 * 1.25" | bc
120.00

$ printf "%s\n" "scale = 2; 96 * 1.5" | bc
144.0
```

In X11, DPI increments historically follow multiples of: 96 (baseline), 120 (scale: 1.25x), 144 (1.5x), 168 (1.75x), 192 (2x), ...
These values have the best support across: Xft, Fontconfig, GTK2/GTK3, Qt, Web engines (Firefox/Chromium), ...

* STEP A - Compute physical DPI (optional but recommended)
  - Use (11a) Example.
* STEP B - Choose a starting logical DPI
  - Based on comfort + physical DPI.
  - Use this table:
  ```
  | Physical DPI | Recommended Xft.dpi |
  | ------------ | ------------------- |
  | 70-90        | 96-110              |
  | 90-110       | 110-132             |
  | 110-140      | 120-144             |
  | 140-180      | 120-168             |
  | >200         | 150-200 (HiDPI zone)|
  ```

  - For *my* preference (90-110 comfortable PPI):
    - Start at `Xft.dpi`: 120.
    - Try 132 or 144 if needed.
* STEP C - Set logical DPI
  - For the current X session:
  ```
  $ printf "%s\n" "Xft.dpi: 120" | xrdb -merge
  ```

  - To survive system restart:
  ```
  $ printf "%s\n" "Xft.dpi: 120" >> ~/.Xresources
  $ xrdb ~/.Xresources
  ```
  - Restart apps.


# 5. Understanding DPI Differences

*Toolkits* use different DPI systems:

```
| Concept      | Command                    | Meaning         | Matches       |
|              |                            |                 | Physical DPI? |
|--------------|----------------------------|-----------------|---------------|
| Physical DPI | xrandr                     | Actual          | Always        |
|              |   or                       | pixel           |               |
|              | xdpyinfo dimensions        | density         |               |
|--------------|----------------------------|-----------------|---------------|
| X Server DPI | xdpyinfo | grep dots       | What Xorg uses  | Sometimes     |
|              |                            | internally      |               |
|--------------|----------------------------|-----------------|---------------|
| Logical DPI  | xrdb -query | grep Xft.dpi | Font/UI scaling | Usually       |
|              |                            | for toolkits    | different     |
```

# 6. Toolkit and Application Notes (Short)

aka: How toolkits and applications *interpret* scaling  

### Xterm

I use *bitmap* fonts (**XLFD**) in Xterm.

* Use XLFD names in `~/.Xresources`.
* Bitmap X core fonts (**XLFD**) - unaffected by DPI changes.
* Xterm with (Fontconfig/Freetype) fonts (OTF/TTF) -> obeys `Xft.dpi`.

### GTK

* GTK2 (font sizes)
Configured via `~/.gtkrc-2.0`.

* GTK3 (scaling + font sizes)
Configured via: `~/.config/gtk-3.0/settings.ini`.

* GDK Environment Variables
```
GDK_SCALE=1
GDK_DPI_SCALE=1
```

* Firefox/Thunderbird
  ```
  layout.css.devPixelsPerPx = 1.0
  ```

NOTE: It's recommanded to install the package `lxappearance` to manage the GTK themes.

### Qt5/Qt6 (e.g. KeePassXC, ReText, etc.) 
Environment variables:
```
QT_SCALE_FACTOR=1.0
QT_FONT_DPI=144
QT_AUTO_SCREEN_SCALE_FACTOR=0
```

---

# 7. Recommended X11 Workflow (Non‑DE)

### Best overall workflow for FVWM3 + FreeBSD

* Set Xft DPI globally:

  ```
  Xft.dpi: 120
  ```

* Leave X Server DPI (`startx -- -dpi 120`) untouched (do not chase it).

* Adjust individual toolkits:
   - `QT_FONT_DPI=120`
   - `GTK_THEME`, `gsettings`, or settings.ini for GTK
   - Firefox/Thunderbird: `layout.css.devPixelsPerPx = 1.0`

* Adjust `xterm` with XLFD font sizes.

This avoids XSETTINGS daemons and keeps scaling predictable.

---

# 8. High-Level Rules

* Rule 1: `Xft.dpi` controls almost all modern GUI apps.
* Rule 2: X server DPI (xdpyinfo dots) rarely matters today.
* Rule 3: Bitmap fonts ignore scaling (hardcoded pixel sizes).
* Rule 4: For laptop screens under 100-110 DPI, typical comfort values:
  * 120-144 DPI (~120%-150% scaling)
* Rule 5: Set `Xft.dpi` in `.Xresources` -> consistent behavior across apps.

---

# 9. Q&A

**What is EDID?**  
EDID = Extended Display Identification Data.
EDID is metadata stored in the display panel firmware that tells the GPU and OS about the display's characteristics. 
These characteristics include: physical dimensions (mm), display name/model, preferred resolution, supported modes.

* X uses EDID to determine physical size -> which determines physical DPI.
* Xorg does *not* measure your screen.
  - It only *reports* what the EDID claims.

**What sets physical DPI?**  
EDID.

**Which DPI do apps use?**  
Logical DPI.

**Is X Server DPI the same as physical DPI?**  
No.
They often match but are not guaranteed to.
Xorg *computes* DPI at *startup* using *EDID* or *policy*.
`xdpyinfo -> dots per inch` may differ from actual monitor DPI.  
If EDID size is wrong or the system forces 96 DPI, `xdpyinfo | grep dots` will not reflect real DPI.

**Is logical DPI the same as X Server DPI?**  
No.
`Xft.dpi` is a separate logical value used by **toolkits**.

**Can logical DPI be changed live?**  
Yes, with: `xrdb -merge`.

**Can X Server DPI be changed live?**  
* No.
* Requires restarting X.  
  - Shut down X: In my case, in the window manager (FVWM3), choose the "Exit" menu item.
  (Alternatively, run `pkill Xorg` from the terminal emulator.) 
  - Then, initialize an X session with this command: `startx -- -dpi 120`.

**Does xrandr show DPI?**  
No. It shows millimeter size; DPI must be computed manually.

**Why does Xorg snap DPI to 96/120/144/etc.?**  
Legacy X11 relies on values divisible by 12 (1/12‑inch granularity).

---

# 10. Terminology: PPI vs DPI vs Pixel Pitch

* PPI (Pixels Per Inch): Number of pixels along one inch of screen - very relevant for monitors.
* DPI (Dots Per Inch): Originally for printing - number of dots of ink per inch.
When used for screens it's often used loosely like "screen DPI" but technically PPI is more appropriate.

* Are PPI and DPI approximately the same?
Yes - when vendors say "DPI" for a monitor, they often mean "PPI".
So for practical purposes you can treat a monitor with ~100 PPI as ~100 DPI. 

* Pixel Pitch: Distance between the centres of two adjacent pixels (usually in mm).
  - Relationship:  `PPI ~= 25.4/pixel‐pitch (mm)`
  - Example: Pixel pitch 0.27 mm => PPI ~= 25.4/0.27 ~= 94.1

```
| Pixel Pitch | PPI (approx.) |
| ----------- | ------------- |
| 0.27 mm     | 94 PPI        |
| 0.25 mm     | 102 PPI       |
| 0.23 mm     | 110 PPI       |
| 0.20 mm     | 127 PPI       |
| 0.16 mm     | 159 PPI       |
| 0.12 mm     | 212 PPI       |
```

So for my use (text, terminal use), aiming for PPI **~90-110** is a good target.

---

# 11. Examples

### 11a. Compute Physical DPI

Physical DPI = `(pixels / millimeters) x 25.4`

```
$ xdpyinfo | grep dimensions
  dimensions:    1920x1200 pixels (301x188 millimeters)
```

Alternatively, with `xrandr`:

```
$ xrandr | grep -w connected
eDP-1 connected primary 1920x1200+0+0 (normal left inverted right x axis y axis) 301mm x 188mm
```

```
$ printf "%s\n" "scale = 2; (1920 / 301) * 25.4" | bc
161.79
 
$ printf "%s\n" "scale = 2; (1200 / 188) * 25.4" | bc
162.05
```

Horizontal physical DPI ~162.
Vertial physical DPI ~162.

**Physical DPI** = **~162**.

### (11b) X Server DPI

```
$ xdpyinfo | grep dots
  resolution:    162x162 dots per inch
```

**X Server DPI** = **162**.

### (11c) Logical DPI 

```
$ xrdb -query | grep Xft.dpi
Xft.dpi:  120 
```

```
$ grep Xft.dpi ~/.Xresources
Xft.dpi:  120 
```

---

# 12. Toolkit Analyzers - xdpi and qtdpi

NOTE: For directions on how to build and install `xdpi` and `qtdpi`, see my post [Building and Using xdpi on FreeBSD - About DPI and HiDPI]({% post_url 2025-11-09-freebsd-x11-xorg-compiling-xdpi-and-about-dpi %}).

`xdpi` and `qtdpi` confirm how toolkits actually perceive DPI.

Useful because toolkits sometimes guess wrong physical DPI. 

---

# Resources and References

* [GitHub - Oblomov/xdpi: X11 DPI information retrieval](https://github.com/Oblomov/xdpi)

* [Mixed DPI and the X Window System](https://wok.oblomov.eu/tecnologia/mixed-dpi-x11/)

* [Display DPI detector - find out DPI of your monitor](https://www.infobyip.com/detectmonitordpi.php)
> A square with 1 inch width and 1 inch height is shown below.
>
> 1" x 1"
> 
> DPI is based on CSS 1" size in pixels and might be inaccurate on some operating systems, notably mobile phones.
> You can easily check if DPI is detected correctly by measuring the black square above with a ruler.
> If it is different from 1" then DPI value should be adjusted accordingly.
> To display a square of a different size please click on one of the buttons below.
>
> 1"  2"  4"  4cm  8cm

* [Screen resolution detector - find out resolution of your monitor](https://www.infobyip.com/detectscreenresolution.php)
> For my 14-inch WUXGA screen:
>
> Your screen resolution and color depth are:
> 1920 x 1200 x 24
> (width x height x color depth)
> Your display aspect ratio is: 8 / 5 = 1.6
> 
> Screen resolution is the number of pixels your monitor have in horizontal and vertical dimensions.
> Another characteristic of the screen resolution is color depth which measures the number of bits representing color of each pixel.
> Higher screen resolution is commonly associated with higher productivity as you can see more information at the same time and don't have to switch between windows frequently.
> As a result increasing your screen resolution is often a better investment than buying a faster processor or more memory.

---

