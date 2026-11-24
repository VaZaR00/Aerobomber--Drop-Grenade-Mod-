/*
    Function: DGM_fnc_dropGren

    Description:
        Programmatically drops grenades of the given class (or first available class if empty) from a drone.

    Example:
        [_drone, "rhs_VOG25", 1] call DGM_fnc_dropGren;
*/

#include "defines.hpp"

params [["_drone", objNull], ["_grenClass", ""], ["_num", 1], ["_instigator", objNull]];
if (!IS_DROP_DEVICE(_drone) || {_num <= 0}) exitWith {false};

["DGM_requestDropGren", [_drone, _grenClass, _num, _instigator]] call CBA_fnc_serverEvent;
true
