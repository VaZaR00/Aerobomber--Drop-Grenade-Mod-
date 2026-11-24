#include "defines.hpp"

if !(hasInterface) exitWith {false};
if (call FUNC(isControllingAnyDrone)) exitWith {false};
if !(isNull (objectParent PLAYER_)) exitWith {false};

private _drone = cursorObject;
if (!IS_DROP_DEVICE(_drone) || {!(alive _drone)}) exitWith {false};
if ((_drone distance PLAYER_) > GET_ACTION_RADIUS) exitWith {false};

private _isActive = MENU_GVAR(_drone, "isMenuActive", false);
["setMenuActive", [!_isActive, !_isActive]] CALL_OBJCLASS("DropMenu", _drone);

true
