#include "defines.hpp"

params [["_target", objNull]];

(alive _target) &&
{DGM_GVAR(_target, "canSetCharge", false)} &&
{
    ([_target] call FUNC(isControllingDrone)) ||
    {(MENU_GVAR(_target, "isMenuActive", false)) && {(_target distance PLAYER_) <= GET_ACTION_RADIUS}}
}
