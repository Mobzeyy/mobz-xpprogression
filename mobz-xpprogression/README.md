# ⚔️ XP Progression XP System with Dynamic UI Bar  (QB-Core + ox_lib) for FiveM

A complete **XP Leveling and Progression System** built for **Heroes vs Villains** and other RP or action servers. It features a sleek dynamic XP bar, secure XP management, admin tools, and full QB-Core metadata support.

## 🎯 Features

### 🧬 Dynamic XP Bar
* ✅ Toggleable XP bar using a keybind (default: `Z`)
* ✅ XP stored in player metadata
* ✅ Dynamically colored XP bar based on level
* ✅ Smooth level-up scaling
  ```
  🛡️ Level 2
  [█████░░░░░░░░░] 50 / 100 XP
  ```

### 🔁 XP Progression Logic
- XP stored in QB-Core `metadata["xplevel"]`.
- Every 100 XP = +1 Level (configurable).
- XP saves and loads automatically.

### 🎮 Player Controls
- Players can toggle XP bar with a **keybind** (default: `Z`).
- Responsive and does not interfere with gameplay.

### 🧠 Secure Exports
- Other scripts can safely **request** XP changes:
  ```lua
  exports["xp_progression"]:RequestAddXP(25)
  exports["xp_progression"]:RequestRemoveXP(10)
  ```
- XP can only be changed **from server-side** for security.

### 📢 Level-Up Notifications
- On leveling up, players see a:
  - 📣 **ox_lib notify**
  - 🔊 **Sound effect** (InteractSound or default GTA)
  - 💃 **Optional emote** (cheering)

### 🔐 Admin Control Panel
- Command: `/xpadmin`
- Shows full **ox_lib menu** of all online players:
  - View current XP + level
  - Add XP
  - Remove XP
  - Set XP
  - Teleport to player
- Admin-only (`group = "admin"` in QB-Core)

### ⚙️ Advanced Config
- Easily customize:
  - XP per level
  - UI color per level
  - Toggle emotes
  - UI position
  - Enable/disable keybind toggle
  - Level-up sound type


## 🔧 Installation

1. Drop this resource into your `resources/[your-folder]/xp_progression`
2. Ensure `ox_lib` and `qb-core` are started BEFORE this resource
3. If using **InteractSound**, place `levelup.ogg` into your sound folder and add it to `fxmanifest.lua`
4. Start it in your `server.cfg`:
   ```
   ensure xp_progression
```

# XP System with Dynamic UI Bar

## Overview

This script adds an XP (Experience Points) system for players in a FiveM server using the QBCore framework. It includes a customizable and dynamically colored XP progress bar displayed on the UI, which updates as the player gains XP.


## Features

* ✅ Toggleable XP bar using a keybind (default: `Z`)
* ✅ XP stored in player metadata
* ✅ Dynamically colored XP bar based on level
* ✅ Smooth level-up scaling
* ✅ Configurable UI settings



* The default key to show/hide the XP bar (rebindable via `RegisterKeyMapping`).


* **position**: Where the bar appears on the screen.
* **colorByLevel**: Enable/disable color changing by level.
* **getColorForLevel**: Function that returns a hex color based on level.


Used to generate dynamic color codes from HSL values.


## Customization Ideas

* 🔥 Use fire-themed colors for battle-focused servers
* 🌿 Use green tones for roleplay/farming progression
* 🌈 Enable full rainbow for arcade-style themes

Change the XP color generation in `getColorForLevel()`.




## Installation

1. **Place the resource folder** into your `resources` directory.
2. **Add to your server config**:
3. **Add to qb-core/config 

- add metadata table `xp = 0,` or wont work to qb-core/config 
 
xp = 0,	

3. **Ensure dependencies**:

* QBCore framework is installed and working