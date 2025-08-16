#include "includes\defines.h"
#include "Classes\DROP_DEVICE.sqf"
#include "Classes\DROP_MENU.sqf"

FUNC(attachGrenEvent) = {
	params["_drone", "_grenClass", ["_caller", objNull]];

	PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
	PR _menuInst = _drone GV ["DGM_menuInstance", {}];
	PR _currentAmount = METHOD(_deviceInst, "getGrenAmount", _grenClass);

	if (local _drone) then {
		METHOD(_deviceInst, "addGrenade", [_grenClass]);
	};
	if (player == _caller) then {
		_caller removeItem _grenClass;
	};

	// wait until amount updated globaly
	waitUntil { !(isNil "_currentAmount") && {(METHOD(_deviceInst, "getGrenAmount", _grenClass) != _currentAmount)} };

	METHOD(_menuInst, "addActionDrop", _grenClass);
	METHOD(_menuInst, "addActionDetach", _grenClass);
	
	METHOD(_menuInst, "UpdateMenu", nil);
};
FUNC(detachGrenEvent) = {
	params["_drone", "_grenClass", ["_caller", player, [player]]];

	PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
	PR _menuInst = _drone GV ["DGM_menuInstance", {}];
	PR _currentAmount = METHOD(_deviceInst, "getGrenAmount", _grenClass);

	if (local _drone) then {
		METHOD(_deviceInst, "removeGrenade", [_grenClass]);
	};
	if (_caller == player) then {
		_caller addItem _grenClass;
	};

	// wait until amount updated globaly
	waitUntil { !(isNil "_currentAmount") && {(METHOD(_deviceInst, "getGrenAmount", _grenClass) != _currentAmount)} };

	METHOD(_menuInst, "removeGrenActions", _grenClass);
	METHOD(_menuInst, "UpdateMenu", nil);
};
FUNC(dropGrenEvent) = {
	params["_drone", "_grenClass", ["_caller", player, [player]]];

	PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
	PR _menuInst = _drone GV ["DGM_menuInstance", {}];
	PR _currentAmount = METHOD(_deviceInst, "getGrenAmount", _grenClass);

	if (local _drone) then {
		METHOD(_deviceInst, "removeGrenade", [_grenClass]);
	};
	if (_caller == player) then {
		METHOD(_deviceInst, "Drop", _grenClass);

        PR _itemName = ITEM_NAME(_grenClass);

		hint LBL_DROPED_GREN;
	};

	// wait until amount updated globaly
	waitUntil { !(isNil "_currentAmount") && {(METHOD(_deviceInst, "getGrenAmount", _grenClass) != _currentAmount)} };

	METHOD(_menuInst, "removeGrenActions", _grenClass);
	METHOD(_menuInst, "UpdateMenu", nil);
};

VAR(attachGrenEventHandler_id) = [QPREF(attachGrenEvent), FUNC(attachGrenEvent)] call CBA_fnc_addEventHandler;
VAR(detachGrenEventHandler_id) = [QPREF(detachGrenEvent), FUNC(detachGrenEvent)] call CBA_fnc_addEventHandler;
VAR(dropGrenEventHandler_id) = [QPREF(dropGrenEvent), FUNC(dropGrenEvent)] call CBA_fnc_addEventHandler;