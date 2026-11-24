/*
    Function: DGM_fnc_allowSetCharge

    Example:
        [_drone, true] call DGM_fnc_allowSetCharge;
*/

#include "defines.hpp"

params [["_drone", objNull], ["_allow", true]];
if !(IS_DROP_DEVICE(_drone)) exitWith {false};

if (isServer) then {
    ["allowSetCharge", [_allow]] CALL_OBJCLASS("DropDevice", _drone)
} else {
    ["DGM_allowSetChargeServer", [_drone, _allow]] call CBA_fnc_serverEvent;
    true
}
