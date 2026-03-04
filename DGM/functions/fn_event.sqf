#include "defines.h"

params ["_event", "_args", ["_target", 0], ["_jip", true]];

if (_event isEqualType "") then {
	_event = missionNamespace getVariable [_event, {}];
};
if !(_event isEqualType {}) exitWith {};
if (_event isEqualTo {}) exitWith {};

[_event, _args] remoteExec ["DGM_fnc_remoteCall", _target, _jip];