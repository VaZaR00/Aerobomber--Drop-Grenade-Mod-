#include "includes\defines.h"
#include "Classes\DROP_DEVICE.sqf"
#include "Classes\DROP_MENU.sqf"

FUNC(attachGrenEvent) = {
	["attachGrenEvent", _this] RLOG
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
	
	METHOD(_menuInst, "UpdateMenu", nil);
};
FUNC(detachGrenEvent) = {
	["detachGrenEvent", _this] RLOG
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
	METHOD(_menuInst, "UpdateMenu", nil);
};
FUNC(dropGrenEvent) = {
	["dropGrenEvent", _this] RLOG
	params["_drone", "_grenClass", ["_caller", player, [player]]];

	PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
	PR _menuInst = _drone GV ["DGM_menuInstance", {}];

	if (local _drone) then {
		METHOD(_deviceInst, "removeGrenade", [_grenClass]);
	};
	if (_caller == player) then {
		METHOD(_deviceInst, "Drop", _grenClass);

        PR _itemName = ITEM_NAME(_grenClass);

		hint LBL_DROPED_GREN;
	};
	METHOD(_menuInst, "removeGrenActions", _grenClass);
	METHOD(_menuInst, "UpdateMenu", nil);
};

VAR(attachGrenEventHandler_id) = [QPREF(attachGrenEvent), FUNC(attachGrenEvent)] call CBA_fnc_addEventHandler;
VAR(detachGrenEventHandler_id) = [QPREF(detachGrenEvent), FUNC(detachGrenEvent)] call CBA_fnc_addEventHandler;
VAR(dropGrenEventHandler_id) = [QPREF(dropGrenEvent), FUNC(dropGrenEvent)] call CBA_fnc_addEventHandler;