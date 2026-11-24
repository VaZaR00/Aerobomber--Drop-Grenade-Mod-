/*
    Function: DGM_fnc_dropDevice

    Description:
        Initializes a grenade drop device on the given drone object (server-side).
        Safe to call from Eden object init fields (automatically exits on clients).

    Example:
        [this, 1, "rhs_VOG25"] call DGM_fnc_dropDevice;
*/

#include "defines.hpp"

if !(isServer) exitWith {false};

params [
    ["_drone", objNull]
];

if !(IS_OBJ(_drone)) exitWith {false};
if (IS_DROP_DEVICE(_drone)) exitWith {true};

private _initArgs = if (count _this > 1) then {_this select [1]} else {[]};

[_drone, _initArgs] NEW_OBJINSTANCE_GLOBAL("DropDevice", true)
