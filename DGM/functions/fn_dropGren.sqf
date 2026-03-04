/*
	Name: DGM_fnc_dropGren

	Example: 
		[_this, "rhs_vog25"] call DGM_fnc_dropGren;
*/

#include "defines.h"

params["_drone", "_grenClass", ["_num", 1]];

["DGM_fnc_dropGrenEvent", [_drone, _grenClass, _num, objNull, 0], 0, _drone] call DGM_fnc_event;