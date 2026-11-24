#include "defines.hpp"

/*
    Function: DGM_fnc_openZenModuleDialog

    Description:
        Opens the ZEN configuration dialog for DGM_Device and initializes the drop device on confirmation.
*/

params [
    ["_moduleClass", "DGM_Device", [""]],
    ["_pos", [0, 0, 0], [[]]],
    ["_target", objNull, [objNull]]
];

if (_moduleClass isEqualTo "") exitWith {};
if (isNil "zen_dialog_fnc_create") exitWith {};

private _content = parsingNamespace getVariable [format ["DGM_zenAttributes_%1", _moduleClass], []];
if (_content isEqualTo []) then {
    _content = [_moduleClass] call DGM_fnc_parseModuleAttributesForZen;
};
if (_content isEqualTo []) exitWith {};

_content = +_content;

private _argNames = parsingNamespace getVariable [format ["DGM_zenArgNames_%1", _moduleClass], []];
private _argTypes = parsingNamespace getVariable [format ["DGM_zenArgTypes_%1", _moduleClass], []];

// Pre-populate target drone variable name if Zeus clicked directly onto an object
private _targetIdx = _argNames find "Object";
if (_targetIdx != -1 && {!isNull _target}) then {
    private _targetName = vehicleVarName _target;
    if (_targetName isEqualTo "") then {
        _targetName = format ["DGM_zenTarget_%1_%2", typeOf _target, round (diag_tickTime * 1000)];
        _target setVehicleVarName _targetName;
        missionNamespace setVariable [_targetName, _target, true];
    };
    private _ctrl = +(_content select _targetIdx);
    _ctrl set [2, _targetName];
    _content set [_targetIdx, _ctrl];
};

private _title = getText (configFile >> "CfgVehicles" >> _moduleClass >> "displayName");
if (_title isNotEqualTo "" && {(_title select [0, 1]) isEqualTo "$"}) then {
    _title = localize (_title select [1]);
};
if (_title isEqualTo "") then {
    _title = localize "STR_DGM_Module_Device_FactionName";
    if (_title isEqualTo "") then {_title = "Grenade Drop Device"};
};

[
    _title,
    _content,
    {
        params ["_dialogValues", "_args"];
        _args params ["_moduleClass", "_pos", "_target", "_argNames"];

        private _logicClass = if (isClass (configFile >> "CfgVehicles" >> _moduleClass)) then {_moduleClass} else {"Logic"};
        private _group = createGroup sideLogic;
        private _logic = _group createUnit [_logicClass, _pos, [], 0, "CAN_COLLIDE"];
        _logic setPosWorld (AGLToASL _pos);

        if (!isNull _target) then {
            _logic attachTo [_target];
            _logic setVariable ["bis_fnc_curatorAttachObject_object", _target, true];
        };

        {
            private _varName = _argNames select _forEachIndex;
            _logic setVariable [_varName, _x, true];
        } forEach _dialogValues;

        _logic setVariable ["DGM_zenInitialized", true, true];

        if (isServer) then {
            [_logic, [], true] call DGM_fnc_initModuleDropDevice;
        } else {
            ["DGM_initModuleDropDevice", [_logic, [], true]] call CBA_fnc_serverEvent;
        };
    },
    {},
    [_moduleClass, _pos, _target, _argNames, _argTypes]
] call zen_dialog_fnc_create;
