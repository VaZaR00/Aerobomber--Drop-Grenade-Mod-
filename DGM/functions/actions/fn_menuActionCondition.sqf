#include "defines.hpp"

params [["_target", objNull]];

(alive _target) &&
{IS_DROP_DEVICE(_target)} &&
{!(MENU_GVAR(_target, "isMenuActive", false))} &&
{!(call FUNC(isControllingAnyDrone))} &&
{isNull (objectParent PLAYER_)} &&
{(_target distance PLAYER_) <= GET_ACTION_RADIUS}
