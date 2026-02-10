# Koumarianos Appearance

A complete **FiveM ESX** clothing and character creator with **local KVP persistence** (no database required).

---

## ✨ Features

- ✅ **Complete Character Creator** (heritage, face features, hair, overlays, eyes)
- ✅ **Full Clothing System** (all 12 components + 5 props)
- ✅ **Outfit Management** (save/load/delete multiple outfits)
- ✅ **Default Appearance** (auto-apply on spawn)
- ✅ **Model Switching** (save and load any ped model)
- ✅ **Local KVP Storage** (data stored on player's PC, no SQL)
- ✅ **Stable Persistence** (uses ESX license identifier)
- ✅ **Modern Black/White UI** (compact, responsive)
- ✅ **Camera System** (rotate, zoom, focus)
- ✅ **No Database Required**

---

## 📦 Installation

1. **Download** and place in your `resources` folder:
   ```
   resources/koumarianos_appearance/
   ```

2. **Add to `server.cfg`**:
   ```cfg
   ensure koumarianos_appearance
   ```

3. **Restart** your server or:
   ```
   restart koumarianos_appearance
   ```

---

## 🎮 Usage

### Controls

- **Press M** - Open appearance menu
- **ESC** - Close menu

### Commands

```lua
/clothing      -- Open clothing menu (if enabled in config)
/charcreator   -- Open character creator (if enabled in config)
```

### Configuration

Edit `config.lua`:

```lua
Config.OpenMenuKey = 'M'              -- Key to open menu
Config.AllowAnyModelSave = false      -- Allow saving any ped model
Config.Debug = true                   -- Enable debug logging
Config.RequireDefaultOnFirstJoin = false
```

---

## 🔧 Exports

```lua
-- Open menus
exports['koumarianos_appearance']:OpenClothingMenu()
exports['koumarianos_appearance']:OpenCharacterCreator(false)

-- Save/Load
exports['koumarianos_appearance']:SetDefaultFromCurrent()  -- returns true/false
exports['koumarianos_appearance']:ApplyDefaultIfExists()   -- returns true/false

-- Check if player has default
local hasDefault = exports['koumarianos_appearance']:HasDefault()

-- Get current appearance
local appearance = exports['koumarianos_appearance']:GetCurrentAppearance()

-- Apply appearance
local success = exports['koumarianos_appearance']:ApplyAppearance(appearance)
```

---

## 🔒 How Persistence Works

- Uses **FiveM Resource KVP** (client-side key-value storage)
- Data stored on **player's PC** (like vMenu)
- Keys are scoped by:
  - **ESX License Identifier** (stable across reconnects)
  - Data type (default, outfit, etc.)

**Example KVP keys:**
```
koumarianos_appearance:license:xxxxx:default
koumarianos_appearance:license:xxxxx:outfit:casual
koumarianos_appearance:license:xxxxx:hasDefault
```

**NO server-side database or MySQL required!**

---

## 🐛 Troubleshooting

### Clothing not saving
- Check F8 console for errors
- Ensure `Config.Debug = true` to see save/load logs
- Verify ESX identifier is being received (check console on join)

### Menu not opening
- Check if another resource is using M key
- Try changing `Config.OpenMenuKey` in config
- Ensure ESX is loaded before this resource

### Model keeps changing
- Only freemode models are allowed by default
- Set `Config.AllowAnyModelSave = true` to allow any model
- Check model enforcement thread in config

---

## 📝 Technical Details

### JSON Key Normalization

This resource solves a critical issue with JSON serialization:

**Problem**: Lua uses 0-based indices for GTA natives (components 0..11, overlays 0..11).  
When saved with `json.encode`, these MAY become string keys: `{"0":x,"1":y}`.  
When loaded with `json.decode`, keys remain strings, breaking Apply (which reads numeric keys).

**Solution**: `Appearance.Normalize()` converts ALL string numeric keys to proper numeric keys,  
fills missing indices with defaults, and ensures type safety.

**Call order**:
1. `Capture()` - reads current ped (numeric keys)
2. `Normalize()` - converts string keys to numeric
3. `Validate()` - checks permissions
4. `Apply()` - applies to ped (requires numeric keys)

### NUI Safety

- Model hash **MUST** be sent to NUI as **STRING** (prevents msgpack crashes)
- Model hash **MUST** be stored in Lua/KVP as **NUMBER** (for proper Apply)
- `SanitizeAppearanceForNUI()` handles conversion

---

## 📜 License

Free to use and modify for your FiveM server.

---

## 🤝 Credits

- **Developed by**: Koumarianos
- **Framework**: ESX Legacy
- **Inspired by**: vMenu (TomGrobbe)

---

## 🔗 Support

For issues or questions, open an issue on GitHub.

Enjoy your new appearance system! 🎉