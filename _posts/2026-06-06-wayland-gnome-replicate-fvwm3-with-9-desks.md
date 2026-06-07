---
layout: post
title: "Replicate FVWM3's 9 Desks in Wayland GNOME on RHEL 10.2"
date: 2026-06-06 19:00:13 -0700 
categories: wayland x11 xorg cli terminal shell dotfiles sysadmin howto unix 
---

AKA  Replicate FVWM3 with 9 Virtual Desktops in Wayland GNOME on RHEL 10.2

---

## Fix 9 Static Workspaces

GNOME defaults to dynamic workspaces (creates/destroys them automatically).
Disable that and set to 9 workspaces.

```
$ gsettings set org.gnome.mutter dynamic-workspaces false
$ gsettings set org.gnome.desktop.wm.preferences num-workspaces 9
```


## Set Keyboard Shortcuts to Switch Directly to Each Desk

GNOME only binds a few workspaces by default.
Set all 9:

```
$ for i in $(seq 1 9); do
  gsettings set org.gnome.desktop.wm.keybindings \
    switch-to-workspace-$i "['<Super>$i']"
done
```

## Move a Window to a Specific Workspace (Optional)

```
$ for i in $(seq 1 9); do
  gsettings set org.gnome.desktop.wm.keybindings \
    move-to-workspace-$i "['<Super><Shift>$i']"
done
```

## FvwmPager Equivalent - Visual Pager

### Install GNOME Shell Extension: "Workspace Indicator"

This extension shows the current workspace number/name in the top bar.


```
$ dnf search gnome-shell-extension
. . .
```

Here's what's directly relevant to my 9-workspace setup:

```
$ sudo dnf install \
  gnome-shell-extension-workspace-indicator \
  gnome-shell-extension-dash-to-panel \
  gnome-shell-extension-auto-move-windows \
  gnome-shell-extension-windowsNavigator \
  gnome-extensions-app
```

```
$ gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com
$ gnome-extensions enable dash-to-panel@jderose9.github.com
$ gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com
$ gnome-extensions enable windowsNavigator@gnome-shell-extensions.gcampax.github.com
Extension “workspace-indicator@gnome-shell-extensions.gcampax.github.com” does not exist
Extension “dash-to-panel@jderose9.github.com” does not exist
Extension “auto-move-windows@gnome-shell-extensions.gcampax.github.com” does not exist
Extension “windowsNavigator@gnome-shell-extensions.gcampax.github.com” does not exist
```

The extensions installed fine; however, GNOME Shell hasn't picked up the newly installed extensions yet because they were installed after your session started.

Restart GNOME Shell to load them.
Log out and back in:

```
$ gnome-session-quit --logout
```

Or simply log out from the system menu and log back in.


After logging back in, verify and enable the newly installed GNOME extensions.

See all available extensions (including newly installed ones):

```
$ gnome-extensions list --active
background-logo@fedorahosted.org

$ gnome-extensions list --inactive
auto-move-windows@gnome-shell-extensions.gcampax.github.com
windowsNavigator@gnome-shell-extensions.gcampax.github.com
workspace-indicator@gnome-shell-extensions.gcampax.github.com
dash-to-panel@jderose9.github.com
```

Then, enable each one using the UUID from the output above.

```
$ gnome-extensions enable dash-to-panel@jderose9.github.com
$ gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com
$ gnome-extensions enable windowsNavigator@gnome-shell-extensions.gcampax.github.com
```

Verify:

```
$ gnome-extensions list --active
auto-move-windows@gnome-shell-extensions.gcampax.github.com
windowsNavigator@gnome-shell-extensions.gcampax.github.com
dash-to-panel@jderose9.github.com
background-logo@fedorahosted.org

# Or:

$ gnome-extensions list --enabled
auto-move-windows@gnome-shell-extensions.gcampax.github.com
windowsNavigator@gnome-shell-extensions.gcampax.github.com
dash-to-panel@jderose9.github.com
background-logo@fedorahosted.org
```

Disable dash-to-panel's app shortcuts (keep `Super+N`).  

```
$ gsettings list-recursively org.gnome.shell.extensions.dash-to-panel | grep -i hot | grep -i overlay
org.gnome.shell.extensions.dash-to-panel hotkeys-overlay-combo 'TEMPORARILY'

$ gsettings set org.gnome.shell.extensions.dash-to-panel hotkeys-overlay-combo 'NEVER'

$ gsettings get org.gnome.shell.extensions.dash-to-panel hotkeys-overlay-combo
'NEVER'
```

Temporarily disable `dash-to-panel`. 

```
$ gnome-extensions disable dash-to-panel@jderose9.github.com
```

Disable (clear) all `switch-to-application` bindings:

```
$ for i in $(seq 1 9); do
  gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
done
```

The `hotkeys-overlay-combo` 'NEVER' hides the visual number overlay but it doesn't remove the actual key grabs in this version.



Find dash-to-panel's shortcut settings:

```
$ dconf dump /org/gnome/shell/extensions/dash-to-panel/
---- snip ----
hot-keys=true
---- snip ----
```

The master switch is `hot-keys=true`, and because of that `dash-to-panel`'s `app-hotkey-N` is active and conflicts with workspace and move-to-workspace. 

```
app-hotkey-N       -> <Super>N (conflicts with workspace switching)
app-shift-hotkey-N -> <Shift><Super>N (conflicts with move-to-workspace)
app-ctrl-hotkey-N  -> <Ctrl><Super>N
```

Disable the master switch (`hot-keys`):

```
$ gsettings set org.gnome.shell.extensions.dash-to-panel hot-keys false
```

Re-enable `dash-to-panel`:

```
$ gnome-extensions enable dash-to-panel@jderose9.github.com
```

My final configuration:

```
+---------------------+------------------------------------------------+
| static 9 workspaces | gsettings / mutter                             |
| Super+1–9           | switch to workspace N                          |
| Super+Shift+1–9     | move window to workspace N                     |
| dash-to-panel       | panel with workspace switcher (hot-keys=false) |
| auto-move-windows   | assign apps to specific workspaces             |
| windowsNavigator    | keyboard selection in Activities overview      |
+---------------------+------------------------------------------------+
```


## Remaining Things Worth Configuring

* `auto-move-windows`

Open `gnome-extensions-app`.

```
$ gnome-extensions-app
```

Find Auto Move Windows, click the gear icon, and assign applications to specific workspace numbers.

This is `Style * StartsOnDesk` equivalent (on FVWM3/FVWM).


* Enable Workspace Indicator

Open `gnome-extensions-app`.

```
$ gnome-extensions-app
```

Click on 'Workspace Indicator' - Enable it.
Then, click on the three vertical dots menu (Settings) > Under 'Indicator', select 'Workspace Name'.

* Workspace Names - If You Want Named Desks Like in FVWM3

```
$ gsettings set org.gnome.desktop.wm.preferences workspace-names \
    "['1', '2', '3', '4', '5', '6', '7', '8', '9']"

$ gsettings get org.gnome.desktop.wm.preferences workspace-names
['1', '2', '3', '4', '5', '6', '7', '8', '9']
```

## Export Dash to Panel's Settings

Right-click the panel -> Dash to Panel Settings. 
Click 'About' - under 'Export and Import', click 'Export to file'.

---
