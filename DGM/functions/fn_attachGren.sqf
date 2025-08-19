/*
	Name: DGM_fnc_attachGren

	Example: 
		[_this, "rhs_vog25", 1] call DGM_fnc_attachGren;
*/

#include "defines.h"

params["_drone", "_grenClass", "_num"];

PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
PR _currentCount = METHOD(_deviceInst, "getGrenAmount", _grenClass);

["DGM_attachGrenEvent", [_drone, _grenClass, objNull, _num, _currentCount]] call CBA_fnc_globalEvent;