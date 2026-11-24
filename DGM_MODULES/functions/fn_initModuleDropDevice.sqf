#include "defines.hpp"

#define LGVAR _logic GV
#define MOD_BOOL(var, def) (call {private _v = LGVAR [var, def]; (_v isEqualTo 1) || {_v isEqualTo true}})

params [
    ["_logic", objNull, [objNull]],
    ["_units", [], [[]]],
    ["_activated", true, [true]]
];

if !(_activated) exitWith {};
if (is3DEN) exitWith {};
if !(isServer) exitWith {};
if !(IS_OBJ(_logic)) exitWith {};

[_logic, _units] spawn {
    params ["_logic", ["_units", []]];

    if (_logic getVariable ["DGM_modInitExecuted", false]) exitWith {};
    _logic setVariable ["DGM_modInitExecuted", true];

    sleep 0.05;

    private _fnc_getCuratorTarget = {
        params ["_l"];
        private _tgt = _l getVariable ["bis_fnc_curatorAttachObject_object", objNull];
        if (!isNull _tgt) exitWith {_tgt};
        _tgt = attachedTo _l;
        if (!isNull _tgt) exitWith {_tgt};
        private _att = attachedObjects _l;
        if (_att isNotEqualTo []) exitWith {_att select 0};
        objNull
    };

    private _syncedObjs = +(synchronizedObjects _logic);

    private _curatorTarget = [_logic] call _fnc_getCuratorTarget;
    if (IS_OBJ(_curatorTarget) && {!(_curatorTarget isKindOf "Logic")}) then {
        _syncedObjs pushBackUnique _curatorTarget;
    };

    {
        if (IS_OBJ(_x) && {!(_x isKindOf "Logic")}) then {
            _syncedObjs pushBackUnique _x;
        };
    } forEach _units;

    private _objNamesStr = LGVAR ["Object", ""];
    if (_objNamesStr isEqualType "") then {
        {
            private _namedObj = missionNamespace getVariable [_x, objNull];
            if (IS_OBJ(_namedObj) && {!(_namedObj isKindOf "Logic")}) then {
                _syncedObjs pushBackUnique _namedObj;
            };
        } forEach (_objNamesStr splitString SPLIT_CHARACTERS);
    };

    private _drones = _syncedObjs select {
        IS_OBJ(_x) && {!(_x isKindOf "Logic")}
    };

    if (_drones isEqualTo []) exitWith {
        format ["DGM_fnc_initModuleDropDevice: ZERO DRONES. Synced objects given: %1", _syncedObjs] WARN;
    };

    private _slotNum = LGVAR ["slotNum", 1];
    if (_slotNum isEqualType "") then {
        _slotNum = (parseNumber _slotNum) max 1;
    };

    {
        [
            _x,
            _slotNum,
            LGVAR ["spawnWithGren", "HandGrenade"],
            LGVAR ["addedItems", ""],
            LGVAR ["removedItems", ""],
            MOD_BOOL("allowSetCharge", 0),
            MOD_BOOL("spawnTempGren", 1),
            MOD_BOOL("allowOnlyListed", 0),
            MOD_BOOL("removeChemlights", 1),
            MOD_BOOL("removeSmokes", 1)
        ] call DGM_fnc_dropDevice;
    } forEach _drones;
};
