/*
	Name: DGM_fnc_dropDevice

	Example: 
		[this, 1, true, "rhs_VOG25"] call DGM_fnc_dropDevice;
*/

#include "includes\defines.h"

FILE_ONLY_SPAWN

WAIT_THIS_SCRIPT

PR _obj = _this select 0;

sleep 0.1; // wait for mission fully initialized

// Ensure the function is only executed where the object is local on mission init
if !(local _obj) exitWith {
	// if mission time is less than 1 second, we assume its init and all clients are executing it including server
	if (time > 1) then {
		_this remoteExec ["DGM_fnc_dropDevice", OBJ_OWNER(_obj)];
	}; 
};

PR _deviceInstance = NEW(OO_DROP_DEVICE, _this);

_deviceInstance