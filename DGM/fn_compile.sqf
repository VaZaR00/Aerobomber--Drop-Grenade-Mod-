#include "includes\defines.h"
#include "Classes\DROP_DEVICE.sqf"
#include "Classes\DROP_MENU.sqf"

FUNC(attachGrenEvent) = {
	_this spawn {
		params["_drone", "_grenClass", ["_caller", objNull], ["_num", 1]];

		["WAIT END attachGrenEvent", _this] MP_RLOG;
		WAIT_SCRIPT_END(DGM_attachGrenEvent);
		["attachGrenEvent", _drone] MP_RLOG;

		// on mission init its better to wait until device instance created
		// because server may do it faster and trigger event before instance created localy
		waitUntil { !(isNil {DGVAR "DGM_deviceInstance"}) && !(isNil {DGVAR "DGM_menuInstance"}) };

		PR _deviceInst = DGVAR ["DGM_deviceInstance", {}];
		PR _menuInst = DGVAR ["DGM_menuInstance", {}];
		PR _currentAmount = METHOD(_deviceInst, "getGrenAmount", _grenClass);

		if (local _drone) then {
			METHOD(_deviceInst, "addGrenade", [_grenClass C _num]);
		};
		if (player == _caller) then {
			FOR_I(_num) {
				_caller removeItem _grenClass;
			};
		};

		["attachGrenEvent WAIT", _drone, if !(isNil "_currentAmount") then {_currentAmount}, METHOD(_deviceInst, "getGrenAmount", _grenClass)] MP_RLOG;
		// wait until amount updated globaly
		waitUntil { !(isNil "_currentAmount") && {(METHOD(_deviceInst, "getGrenAmount", _grenClass) != _currentAmount)} };

		["attachGrenEvent WAITED", _drone, _grenClass, _currentAmount] MP_RLOG;

		FOR_I(_num) {
			METHOD(_menuInst, "addActionDrop", _grenClass);
			METHOD(_menuInst, "addActionDetach", _grenClass);
		};
		METHOD(_menuInst, "UpdateMenu", nil);
	};
};
FUNC(detachGrenEvent) = {
	_this spawn {
		WAIT_SCRIPT_END(DGM_detachGrenEvent);

		["detachGrenEvent", _this] MP_RLOG;
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
};
FUNC(dropGrenEvent) = {
	_this spawn {
		WAIT_SCRIPT_END(DGM_dropGrenEvent);

		["dropGrenEvent", _this] MP_RLOG;
		params["_drone", "_grenClass", ["_caller", player, [player]]];

		PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
		PR _menuInst = _drone GV ["DGM_menuInstance", {}];
		PR _currentAmount = METHOD(_deviceInst, "getGrenAmount", _grenClass);

		if (local _drone) then {
			METHOD(_deviceInst, "removeGrenade", [_grenClass]);
		};
		if (_caller == player) then {
			METHOD(_deviceInst, "Drop", _grenClass);
		};

		// wait until amount updated globaly
		waitUntil { !(isNil "_currentAmount") && {(METHOD(_deviceInst, "getGrenAmount", _grenClass) != _currentAmount)} };

		METHOD(_menuInst, "removeGrenActions", _grenClass);
		METHOD(_menuInst, "UpdateMenu", nil);
	};
};

VAR(attachGrenEventHandler_id) = [QPREF(attachGrenEvent), FUNC(attachGrenEvent)] call CBA_fnc_addEventHandler;
VAR(detachGrenEventHandler_id) = [QPREF(detachGrenEvent), FUNC(detachGrenEvent)] call CBA_fnc_addEventHandler;
VAR(dropGrenEventHandler_id) = [QPREF(dropGrenEvent), FUNC(dropGrenEvent)] call CBA_fnc_addEventHandler;