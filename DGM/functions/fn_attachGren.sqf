/*
    Function: DGM_fnc_attachGren

    Description:
        Programmatically attaches grenades onto a drone (without consuming from a unit's inventory).

    Example:
        [_drone, "rhs_VOG25", 1] call DGM_fnc_attachGren;
*/

#include "defines.hpp"

params [["_drone", objNull], ["_grenClass", ""], ["_num", 1]];
if (!IS_DROP_DEVICE(_drone) || {_grenClass isEqualTo ""} || {_num <= 0}) exitWith {0};

if (isServer) then {
    ["addGrenade", [_grenClass, _num], 0] CALL_OBJCLASS("DropDevice", _drone)
} else {
    ["DGM_requestAttachGren", [_drone, _grenClass, _num, objNull]] call CBA_fnc_serverEvent;
    _num
}
