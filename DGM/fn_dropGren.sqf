/*
	Name: DGM_fnc_dropGren

	Example: 
		[_this, "rhs_vog25"] call DGM_fnc_dropGren;
*/

#include "includes\defines.h"

params["_drone", "_grenClass"];

["DGM_detachGrenEvent", [_drone, _grenClass, objNull, 0]] call CBA_fnc_globalEvent;