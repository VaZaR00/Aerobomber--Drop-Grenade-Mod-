#include "defines.hpp"

params [["_target", objNull]];

(alive _target) &&
{MENU_GVAR(_target, "isMenuActive", false)} &&
{!(call FUNC(isControllingAnyDrone))} &&
{(_target distance PLAYER_) <= GET_ACTION_RADIUS} &&
{(DGM_GVAR(_target, "slotsOccupied", 0)) > 0}
