/*
    Function: DGM_fnc_removeDropDevice

    Description:
        Removes the drop device, decorative grenade, event handlers, and all client menus from a drone.
*/

#include "defines.hpp"

params [["_drone", objNull]];
if !(IS_OBJ(_drone)) exitWith {false};
if !(IS_DROP_DEVICE(_drone)) exitWith {false};

if (isServer) then {
    [] DELETE_OBJCLASS_GLOBAL("DropDevice", _drone, true)
} else {
    ["DGM_removeDropDeviceServer", [_drone]] call CBA_fnc_serverEvent;
    true
}
