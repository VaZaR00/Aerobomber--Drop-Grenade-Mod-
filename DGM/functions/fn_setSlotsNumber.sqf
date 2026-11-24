/*
    Function: DGM_fnc_setSlotsNumber

    Example:
        [_drone, 2] call DGM_fnc_setSlotsNumber;
*/

#include "defines.hpp"

params [["_drone", objNull], ["_num", 1]];
if !(IS_DROP_DEVICE(_drone)) exitWith {false};

if (_num <= 0) exitWith {
    SHOW_HINT(DGM_STR_SLOTS_NOT_ENOUGH);
    false
};

if (isServer) then {
    ["setSlotsNumber", [_num]] CALL_OBJCLASS("DropDevice", _drone)
} else {
    ["DGM_setSlotsNumberServer", [_drone, _num]] call CBA_fnc_serverEvent;
    true
}
