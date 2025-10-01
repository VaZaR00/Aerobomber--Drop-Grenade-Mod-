/*
	Name: DGM_fnc_allowSetCharge

	Example: 
		[_this, true] call DGM_fnc_allowSetCharge;
*/

#include "defines.h"

params["_drone", ["_allow", true]];

PR _deviceInst = _drone GV [QPREF(deviceInstance), {}];

METHOD(_deviceInst, "AllowSetCharge", _allow);