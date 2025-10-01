/*
	Name: DGM_fnc_removeDropDevice
*/

#include "defines.h"

params["_drone"];

// Ensure the function is only executed where the object is local on mission init
if !(local _drone) exitWith {};

PR _deviceInst = _drone GV [QPREF(deviceInstance), {}];

DELETE(_deviceInst);

true