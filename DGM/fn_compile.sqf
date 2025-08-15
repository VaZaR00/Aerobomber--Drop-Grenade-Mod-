#include "includes\defines.h"

FUNC(attachGrenEvent) = {
	params["_drone", "_grenClass", ["_caller", player]];

	PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
	PR _menuInst = _drone GV ["DGM_menuInstance", {}];

	if (local _drone) then {
		METHOD(_deviceInst, "addGrenade", [_grenClass]);
	};
	if (player == _caller) then {
		_caller removeItem _grenClass;
	};
	METHOD(_menuInst, "addActionDrop", _grenClass);
	METHOD(_menuInst, "addActionDetach", _grenClass);
};
FUNC(detachGrenEvent) = {
	params["_drone", "_grenClass", ["_caller", player, [player]]];

	PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
	PR _menuInst = _drone GV ["DGM_menuInstance", {}];

	if (local _drone) then {
		METHOD(_deviceInst, "removeGrenade", [_grenClass]);
	};
	if (_caller == player) then {
		_caller addItem _grenClass;
	};
	METHOD(_menuInst, "removeGrenActions", _grenClass);
};
FUNC(dropGrenEvent) = {
	params["_drone", "_grenClass", ["_caller", player, [player]]];

	PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
	PR _menuInst = _drone GV ["DGM_menuInstance", {}];

	if (local _drone) then {
		METHOD(_deviceInst, "removeGrenade", [_grenClass]);
	};
	if (_caller == player) then {
		METHOD(_deviceInst, "Drop", _grenClass);
	};
	METHOD(_menuInst, "removeGrenActions", _grenClass);
};
