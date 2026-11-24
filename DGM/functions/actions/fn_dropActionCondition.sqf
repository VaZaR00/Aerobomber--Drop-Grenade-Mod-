#include "defines.hpp"

params [["_target", objNull]];

(alive _target) &&
{(DGM_GVAR(_target, "slotsOccupied", 0)) > 0} &&
{[_target] call FUNC(isControllingDrone)}
