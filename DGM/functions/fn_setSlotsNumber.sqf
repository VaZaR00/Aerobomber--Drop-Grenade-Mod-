/*
	Name: DGM_fnc_setSlotsNumber

	Example: 
		[this, 1] call DGM_fnc_setSlotsNumber;
*/

#include "defines.h"

params["_drone", "_num"];

PR _deviceInst = _drone GV [QPREF(deviceInstance), {}];

METHOD(_deviceInst, "setSlotsNumber", _num);