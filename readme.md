# DGM - Drone Grenade Mod

DGM (Drone Grenade Mod) is an Arma 3 addon and scripting system that enables drones to carry, attach, detach, and drop grenades or other compatible ordnance.

Steam: https://steamcommunity.com/sharedfiles/filedetails/?id=3144481988

## Features

- Attach, detach, and drop grenades from drones via the in-game Action Menu or configurable CBA Keybinds.
- Supports multiple grenade types simultaneously, salvo drop **Charge**, and custom item whitelists/blacklists (accepts both `CfgMagazines` and `CfgAmmo` classnames).
- Server-authoritative multiplayer synchronization over CBA Events (zero `remoteExec` / `CfgRemoteExec`, automatic JIP cleanup).
- Configurable via Eden `DGM_Device` module, **Zeus Enhanced (ZEN)** custom modules, CBA Settings, and SQF API functions.
- Localized in English, Ukrainian, and Russian.

## Usage

### Eden & Zeus Modules

- **Eden Editor:** Place **Systems (F5) -> DGM -> Grenade Drop Device** and sync it to one or more drones (or specify variable names in the `Drone` attribute).
- **Zeus (with ZEN):** Under **DGM - Drone Grenade Mod**, use **Grenade Drop Device** (click on a drone to configure and attach) or **Remove Drop Device**.

### SQF API

#### Add Drop Device (`DGM_fnc_dropDevice`)

```sqf
[
    _drone,            // Object: target drone
    _slotNum,          // Number (default: 1): number of grenade slots
    _spawnWithGren,    // String (default: "HandGrenade"): initial grenade class (and custom list)
    _addedItems,       // String (default: ""): extra allowed classnames (; , : or space separated)
    _removedItems,     // String (default: ""): restricted classnames (; , : or space separated)
    _allowSetCharge,   // Boolean (default: false): allow operator to change simultaneous drop Charge
    _spawnTempGren,    // Boolean (default: true): attach decorative 3D grenade model under drone
    _allowOnlyListed,  // Boolean (default: false): restrict allowed grenades to custom/added lists only
    _removeChemlights, // Boolean (default: true): exclude chemlights and hand flares
    _removeSmokes      // Boolean (default: true): exclude smoke grenades
] call DGM_fnc_dropDevice;
```

Example:
```sqf
[this, 2, "rhs_VOG25", "", "", true] call DGM_fnc_dropDevice;
```

#### Other Functions

- `[_drone] call DGM_fnc_removeDropDevice;` — Removes the Drop Device, decorative grenade, and client menus from `_drone`.
- `[_drone, _slotNum] call DGM_fnc_setSlotsNumber;` — Updates maximum grenade slots on `_drone`.
- `[_drone, _allow] call DGM_fnc_allowSetCharge;` — Enables or disables simultaneous drop Charge selection on `_drone`.
- `[_drone, _grenClass, _num] call DGM_fnc_attachGren;` — Programmatically loads grenades onto `_drone`.
- `[_drone, _grenClass, _num, _instigator] call DGM_fnc_dropGren;` — Programmatically drops grenades from `_drone`.

### Default Keybinds (CBA Controls -> DGM)

- **Drop Grenade:** `Alt + G`
- **Cycle Drop Charge:** `Alt + C`
- **Switch Active Grenade Type:** `Alt + B`
- **Toggle Drop Device Menu:** *(unbound by default)*

## Dependencies

- [CBA_A3](https://github.com/CBATeam/CBA_A3) (`cba_common`)
- Arma 3 v2.10 or later
- *(Optional)* [Zeus Enhanced (ZEN)](https://github.com/zen-mod/ZEN) for Zeus custom modules

## Credits

- Author: Vazar
