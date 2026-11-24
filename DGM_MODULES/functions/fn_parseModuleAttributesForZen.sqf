#include "defines.hpp"

/*
    Function: DGM_fnc_parseModuleAttributesForZen

    Description:
        Parses DGM_Device module attributes from CfgVehicles into controls for zen_dialog_fnc_create.
        Caches parsed definitions in parsingNamespace. Includes a script-mode fallback when
        testing in a mission without DGM_MODULES.pbo loaded.
*/

params [["_moduleClass", "DGM_Device", [""]], ["_checkUseInZen", true]];

if (_moduleClass isEqualTo "") then {
    _moduleClass = "DGM_Device";
};

private _cacheVar = format ["DGM_zenAttributes_%1", _moduleClass];
private _cached = parsingNamespace getVariable _cacheVar;
if (!isNil "_cached") exitWith {_cached};

private _fnc_loc = {
    params ["_str", ["_fallback", ""]];
    if (_str isEqualTo "") exitWith {_fallback};
    if ((_str select [0, 1]) isEqualTo "$") then {
        private _res = localize (_str select [1]);
        if (_res isEqualTo "") then {_fallback} else {_res}
    } else {
        _str
    }
};

private _modConfig = configFile >> "CfgVehicles" >> _moduleClass;
private _zenControls = [];
private _argNames = [];
private _argTypes = [];

if (isClass _modConfig) then {
    private _argsConfig = _modConfig >> "Arguments";
    if (!isClass _argsConfig) then {
        _argsConfig = _modConfig >> "Attributes";
    };
    if (!isClass _argsConfig) exitWith {};

    private _argClasses = "true" configClasses _argsConfig;
    {
        private _argCfg = _x;
        private _argName = configName _argCfg;
        if (_argName in ["Units", "ModuleDescription"]) then {continue};
        if (_checkUseInZen && {(getNumber (_argCfg >> "useInZen")) isEqualTo 0} && {isNumber (_argCfg >> "useInZen")}) then {continue};

        private _displayName = [getText (_argCfg >> "displayName"), _argName] call _fnc_loc;
        private _description = [getText (_argCfg >> "description"), ""] call _fnc_loc;
        private _typeName = toUpper (getText (_argCfg >> "typeName"));

        private _defaultValue = if (isNumber (_argCfg >> "defaultValue")) then {
            getNumber (_argCfg >> "defaultValue")
        } else {
            getText (_argCfg >> "defaultValue")
        };

        private _valuesCfg = _argCfg >> "values";
        if (isClass _valuesCfg) then {
            private _valClasses = "true" configClasses _valuesCfg;
            private _values = [];
            private _prettyNames = [];
            {
                private _valName = [getText (_x >> "name"), configName _x] call _fnc_loc;
                private _val = if (isNumber (_x >> "value")) then {
                    getNumber (_x >> "value")
                } else {
                    getText (_x >> "value")
                };
                _values pushBack _val;
                _prettyNames pushBack _valName;
            } forEach _valClasses;

            private _defaultIdx = _values find _defaultValue;
            if (_defaultIdx < 0) then {_defaultIdx = 0};

            _zenControls pushBack ["COMBO", [_displayName, _description], [_values, _prettyNames, _defaultIdx]];
            _argNames pushBack _argName;
            _argTypes pushBack "COMBO";
        } else {
            if (_typeName isEqualTo "BOOL") then {
                private _defaultBool = (_defaultValue isEqualTo 1) || {_defaultValue isEqualTo "true"} || {_defaultValue isEqualTo true};
                _zenControls pushBack ["CHECKBOX", [_displayName, _description], _defaultBool];
                _argNames pushBack _argName;
                _argTypes pushBack "BOOL";
            } else {
                private _defaultStr = if (_defaultValue isEqualType 0) then {str _defaultValue} else {_defaultValue};
                _zenControls pushBack ["EDIT", [_displayName, _description], _defaultStr];
                _argNames pushBack _argName;
                _argTypes pushBack "EDIT";
            };
        };
    } forEach _argClasses;
} else {
    // Fallback when running unpacked in mission dev mode without DGM_MODULES.pbo
    private _yesTxt = ["$STR_DGM_Module_Device_Yes", "Yes"] call _fnc_loc;
    private _noTxt  = ["$STR_DGM_Module_Device_No", "No"] call _fnc_loc;

    private _fallbackSpecs = [
        ["Object", "EDIT", ""],
        ["slotNum", "EDIT", "1"],
        ["spawnWithGren", "EDIT", "HandGrenade"],
        ["addedItems", "EDIT", ""],
        ["removedItems", "EDIT", ""],
        ["allowSetCharge", "COMBO", 1],
        ["spawnTempGren", "COMBO", 0],
        ["allowOnlyListed", "COMBO", 1],
        ["removeChemlights", "COMBO", 0],
        ["removeSmokes", "COMBO", 0]
    ];

    {
        _x params ["_name", "_kind", "_def"];
        private _disp = [format ["$STR_DGM_Module_Device_%1", _name], _name] call _fnc_loc;
        private _desc = [format ["$STR_DGM_Module_Device_DESC_%1", _name], ""] call _fnc_loc;
        if (_kind isEqualTo "COMBO") then {
            _zenControls pushBack ["COMBO", [_disp, _desc], [[1, 0], [_yesTxt, _noTxt], _def]];
        } else {
            _zenControls pushBack ["EDIT", [_disp, _desc], _def];
        };
        _argNames pushBack _name;
        _argTypes pushBack _kind;
    } forEach _fallbackSpecs;
};

parsingNamespace setVariable [_cacheVar, _zenControls];
parsingNamespace setVariable [format ["DGM_zenArgNames_%1", _moduleClass], _argNames];
parsingNamespace setVariable [format ["DGM_zenArgTypes_%1", _moduleClass], _argTypes];

_zenControls
