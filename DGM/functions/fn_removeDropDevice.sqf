/*
	Name: DGM_fnc_removeDropDevice
*/

#include "defines.h"

params["_drone"];

// Ensure the function is only executed where the object is local on mission init
if !(local _drone) exitWith {
	// if mission time is less than 1 second, we assume its init and all clients are executing it including server
	if (time > 1) exitWith {
		_this remoteExec ["DGM_fnc_removeDropDevice", OBJ_OWNER(_drone)];
		true
	}; 
	false
};

PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];

DELETE(_deviceInst);

true