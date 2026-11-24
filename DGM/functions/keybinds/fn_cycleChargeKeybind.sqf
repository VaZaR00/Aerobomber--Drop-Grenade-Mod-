#include "defines.hpp"

if !(hasInterface) exitWith {false};

private _drone = call FUNC(getControlledDrone);
if !(IS_OBJ(_drone)) then {
    private _cursor = cursorObject;
    if (IS_DROP_DEVICE(_cursor) && {MENU_GVAR(_cursor, "isMenuActive", false)} && {(_cursor distance PLAYER_) <= GET_ACTION_RADIUS}) then {
        _drone = _cursor;
    };
};

if (!IS_DROP_DEVICE(_drone) || {!(alive _drone)}) exitWith {false};
if !(DGM_GVAR(_drone, "canSetCharge", false)) exitWith {false};

["DGM_requestChangeCharge", [_drone, PLAYER_]] call CBA_fnc_serverEvent;
true
