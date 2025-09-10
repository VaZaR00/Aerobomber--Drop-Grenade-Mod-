# DGM - Drone Grenade Mod

DGM (Drone Grenade Mod) is an Arma 3 scripting system that enables drones to carry, attach, detach, and drop grenades or other compatible items.

Steam: https://steamcommunity.com/sharedfiles/filedetails/?id=3144481988

## Features

- Attach, detach, and drop grenades from drones via in-game Actions Menu.
- Supports multiple grenade types and custom item whitelists/blacklists.
- Handles multiplayer synchronization and remote execution (Multiplayer compitable).
- Highly configurable via script parameters and mission attributes.
- Localized stringtable for multi-language support.


## Usage

# Add Drop device

Call DGM_fnc_dropDevice on drone with parameters:
- **` drone`** `(Object)`  
    The drone object to which the drop device system will be attached.

- **` slotNum`** `(Number, default: 1)`  
    Number of grenade/item slots available on the drone.

- **` spawnWithGren`** `(String, default: "HandGrenade")`  
    If not empty, the drone will spawn with gren class (first) already attached.

- **` addedItems`** `(String, default: "")`  
    List of allowed grenade/item classnames, separated by `;`, `,`, `:`, or space.

- **` removedItems`** `(String, default: "")`  
    List of restricted grenade/item classnames, separated by `;`, `,`, `:`, or space.

- **` spawnTempGren`** `(Boolean, default: true)`  
    If true, a decorative (visual) grenade object will be spawned and attached to the drone.

- **` allowOnlyListed`** `(Boolean, default: false)`  
    If true, only items listed in Custom list can be attached to the drone.

- **` removeChemlights`** `(Boolean, default: true)`  
    If true, chemlights and flares will be excluded from the allowed items.

- **` removeSmokes`** `(Boolean, default: true)`  
    If true, smoke grenades will be excluded from the allowed items.

Example: 
    [this, 1, "rhs_VOG25"] call DGM_fnc_dropDevice;

# Remove Drop device

Call DGM_fnc_removeDropDevice on drone:
- **` drone`** `(Object)`  
    The drone object on which you want to remove Drop Device.

# Set custom Drop device slots number

Call DGM_fnc_setSlotsNumber on drone:
- **` drone`** `(Object)`  
    The drone object on which you want to remove Drop Device.

- **` slotNum`** `(Number, default: 1)`  
    Number of grenade/item slots available on the drone.


## Dependencies

- [CBA_A3](https://github.com/CBATeam/CBA_A3) (for macros and event handling)
- Arma 3 v2.00 or later

## Credits

- Author: Vazar