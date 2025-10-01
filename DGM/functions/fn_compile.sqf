#include "defines.h"
#include "Classes\DROP_DEVICE.sqf"
#include "Classes\DROP_MENU.sqf"

FUNC(attachGrenEvent) = {
	ENSURE_SPAWN_ONCE_START
		params["_drone", "_grenClass", ["_caller", objNull], ["_num", 1], ["_currentCount", -1]];

		WAIT_SCRIPT_END(DGM_attachGrenEvent);

		// on mission init its better to wait until device instance created
		// because server may do it faster and trigger event before instance created localy
		waitUntil { !(isNil {DGVAR QPREF(deviceInstance)}) && !(isNil {DGVAR "DGM_menuInstance"}) };

		PR _deviceInst = DGVAR [QPREF(deviceInstance), {}];
		PR _menuInst = DGVAR ["DGM_menuInstance", {}];

		if (local _drone) then {
			METHOD(_deviceInst, "addGrenade", [_grenClass C _num]);
		};
		if (player == _caller) then {
			FOR_I(_num) {
				_caller removeItem _grenClass;
			};
		};

		// wait until amount updated globaly
		waitUntil { (METHOD(_deviceInst, "getGrenAmount", _grenClass)) != _currentCount };
		
		FOR_I(_num) {
			METHOD(_menuInst, "addActionDrop", _grenClass);
			METHOD(_menuInst, "addActionDetach", _grenClass);
		};
		METHOD(_menuInst, "UpdateMenu", nil);
	ENSURE_SPAWN_ONCE_END
};
FUNC(detachGrenEvent) = {
	ENSURE_SPAWN_ONCE_START
		WAIT_SCRIPT_END(DGM_detachGrenEvent);

		params["_drone", "_grenClass", ["_num", 1], ["_caller", player, [player]], ["_currentCount", -1]];

		PR _deviceInst = _drone GV [QPREF(deviceInstance), {}];
		PR _menuInst = _drone GV ["DGM_menuInstance", {}];

		if (local _drone) then {
			ARGS [_grenClass, _num];
			METHOD(_deviceInst, "removeGrenade", _args);
		};
		if (_caller == player) then {
			FOR_I(_num) {
				_caller addItem _grenClass;
			};
		};

		// wait until amount updated globaly
		waitUntil { (METHOD(_deviceInst, "getGrenAmount", _grenClass)) != _currentCount };
		
		METHOD(_menuInst, "removeGrenActions", _grenClass);
		METHOD(_menuInst, "UpdateMenu", nil);
	ENSURE_SPAWN_ONCE_END
};
FUNC(dropGrenEvent) = {
	ENSURE_SPAWN_ONCE_START
		WAIT_SCRIPT_END(DGM_dropGrenEvent);

		params["_drone", "_grenClass", ["_num", 1], ["_caller", player, [player]], ["_currentCount", -1]];

		PR _deviceInst = _drone GV [QPREF(deviceInstance), {}];
		PR _menuInst = _drone GV ["DGM_menuInstance", {}];

		if (local _drone) then {
			ARGS [_grenClass, _num];
			METHOD(_deviceInst, "removeGrenade", _args);
		};
		if (_caller == player) then {
			SPAWN_METHOD(_deviceInst, "Drop", [_grenClass C _num]);
		};

		// wait until amount updated globaly
		waitUntil { (METHOD(_deviceInst, "getGrenAmount", _grenClass)) != _currentCount };

		METHOD(_menuInst, "removeGrenActions", _grenClass);
		METHOD(_menuInst, "UpdateMenu", nil);
	ENSURE_SPAWN_ONCE_END
};

VAR(attachGrenEventHandler_id) = [QPREF(attachGrenEvent), FUNC(attachGrenEvent)] call CBA_fnc_addEventHandler;
VAR(detachGrenEventHandler_id) = [QPREF(detachGrenEvent), FUNC(detachGrenEvent)] call CBA_fnc_addEventHandler;
VAR(dropGrenEventHandler_id) = [QPREF(dropGrenEvent), FUNC(dropGrenEvent)] call CBA_fnc_addEventHandler;