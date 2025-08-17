/*
	Name: DGM_fnc_attachGren

	Example: 
		[_this, "rhs_vog25", 1] call DGM_fnc_attachGren;
*/

#include "includes\defines.h"

params["_drone", "_grenClass", "_num"];

["DGM_attachGrenEvent", [_drone, _grenClass, objNull, _num, 0]] call CBA_fnc_globalEvent;