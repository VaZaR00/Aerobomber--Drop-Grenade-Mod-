#include "defines.hpp"

#define LOG_CBA_EVENT
// #define LOG_CBA_EVENT [_NIL(_eventName), time, _NIL(_this), clientOwner] DLOG

// ============================================================================
// OOP Runtime Network Events
// ============================================================================

[OOP_SPREF(callClassInstance), {
    LOG_CBA_EVENT
    _this call FUNC(callClassInstance)
}] call CBA_fnc_addEventHandler;

[OOP_SPREF(pushBack), {
    LOG_CBA_EVENT
    params ["_namespace", "_varname", "_element", ["_unique", true]];
    if (isNil "_namespace" || {isNil "_varname"} || {isNil "_element"}) exitWith {};
    if !(_namespace isEqualTypeAny [objNull, missionNamespace, grpNull, locationNull, displayNull, controlNull, teamMemberNull, taskNull]) exitWith {};
    private _array = _namespace getVariable [_varname, []];
    if !(_array isEqualType []) then {_array = []};
    if (_unique) then {
        _array pushBackUnique _element;
    } else {
        _array pushBack _element;
    };
    _namespace setVariable [_varname, _array];
}] call CBA_fnc_addEventHandler;

[OOP_SPREF(removeFromArray), {
    LOG_CBA_EVENT
    params ["_namespace", "_varname", "_element"];
    if (isNil "_namespace" || {isNil "_varname"} || {isNil "_element"}) exitWith {};
    if !(_namespace isEqualTypeAny [objNull, missionNamespace, grpNull, locationNull, displayNull, controlNull, teamMemberNull, taskNull]) exitWith {};
    private _array = _namespace getVariable [_varname, []];
    if !(_array isEqualType []) exitWith {};
    _namespace setVariable [_varname, _array - [_element]];
}] call CBA_fnc_addEventHandler;


// ============================================================================
// Client Menu Lifecycle & Sync Events
// ============================================================================

["DGM_initDropMenu", {
    LOG_CBA_EVENT
    if !(hasInterface) exitWith {};
    params [["_drone", objNull]];
    if !(IS_OBJ(_drone)) exitWith {};

    if (isNil "DGM_inited") exitWith {
        [_drone] spawn {
            params ["_d"];
            waitUntil {sleep 0.1; !(isNil "DGM_inited")};
            if (!IS_OBJ(_d) || {!(DGM_GVAR(_d, "isDropDevice", false))}) exitWith {};
            [_d, []] NEW_OBJINSTANCE("DropMenu");
        };
    };

    if !(DGM_GVAR(_drone, "isDropDevice", false)) exitWith {};
    [_drone, []] NEW_OBJINSTANCE("DropMenu");
}] call CBA_fnc_addEventHandler;

["DGM_removeDropMenu", {
    LOG_CBA_EVENT
    if !(hasInterface) exitWith {};
    params [["_drone", objNull]];
    if !(IS_OBJ(_drone)) exitWith {};
    [] DELETE_OBJCLASS("DropMenu", _drone);
}] call CBA_fnc_addEventHandler;

["DGM_syncMenuState", {
    LOG_CBA_EVENT
    if !(hasInterface) exitWith {};
    params [["_drone", objNull], ["_grenList", nil], ["_slotsOccupied", nil]];
    if !(IS_OBJ(_drone)) exitWith {};

    if !(isNil "_grenList") then {
        DGM_SVAR(_drone, "droneGrenList", _grenList);
    };
    if !(isNil "_slotsOccupied") then {
        DGM_SVAR(_drone, "slotsOccupied", _slotsOccupied);
    };

    ["syncFromDevice", []] CALL_OBJCLASS("DropMenu", _drone);
}] call CBA_fnc_addEventHandler;

["DGM_syncChargeState", {
    LOG_CBA_EVENT
    if !(hasInterface) exitWith {};
    params [["_drone", objNull], ["_dropCharge", nil], ["_canSetCharge", nil]];
    if !(IS_OBJ(_drone)) exitWith {};

    if !(isNil "_dropCharge") then {
        DGM_SVAR(_drone, "dropCharge", _dropCharge);
    };
    if !(isNil "_canSetCharge") then {
        DGM_SVAR(_drone, "canSetCharge", _canSetCharge);
    };

    ["updateChargeLabel", []] CALL_OBJCLASS("DropMenu", _drone);
}] call CBA_fnc_addEventHandler;


// ============================================================================
// Server-Authoritative Action Request Events
// ============================================================================

["DGM_requestAttachGren", {
    LOG_CBA_EVENT
    if !(isServer) exitWith {};
    params [["_drone", objNull], ["_grenClass", ""], ["_num", 1], ["_caller", objNull]];
    if (!IS_DROP_DEVICE(_drone) || {_grenClass isEqualTo ""} || {_num <= 0}) exitWith {};

    private _added = ["addGrenade", [_grenClass, _num], 0] CALL_OBJCLASS("DropDevice", _drone);

    // Refund excess if drone slots filled up concurrently
    if (IS_OBJ(_caller) && {_added < _num}) then {
        private _refund = _num - _added;
        ["DGM_giveGrenade", [_caller, _grenClass, _refund, _drone], _caller] call CBA_fnc_targetEvent;
        ["DGM_showHint", [DGM_STR_CANT_ADD_MORE_GREN, false], _caller] call CBA_fnc_targetEvent;
    };
}] call CBA_fnc_addEventHandler;

["DGM_requestDetachGren", {
    LOG_CBA_EVENT
    if !(isServer) exitWith {};
    params [["_drone", objNull], ["_grenClass", ""], ["_num", 1], ["_caller", objNull]];
    if (!IS_DROP_DEVICE(_drone) || {_grenClass isEqualTo ""} || {_num <= 0}) exitWith {};

    private _removed = ["removeGrenade", [_grenClass, _num], 0] CALL_OBJCLASS("DropDevice", _drone);
    if (_removed > 0 && {IS_OBJ(_caller)}) then {
        ["DGM_giveGrenade", [_caller, _grenClass, _removed, _drone], _caller] call CBA_fnc_targetEvent;
    };
}] call CBA_fnc_addEventHandler;

["DGM_requestDropGren", {
    LOG_CBA_EVENT
    if !(isServer) exitWith {};
    params [["_drone", objNull], ["_grenClass", ""], ["_num", 1], ["_instigator", objNull]];
    if (!IS_DROP_DEVICE(_drone) || {_num <= 0}) exitWith {};

    private _grenList = DGM_GVAR(_drone, "droneGrenList", createHashMap);
    if (count _grenList == 0) exitWith {};

    // Resolve exact grenade key in _grenList (or pick first available if empty)
    private _resolvedClass = _grenClass;
    if (_resolvedClass isEqualTo "" || {!(_resolvedClass in _grenList)}) then {
        if (_resolvedClass isNotEqualTo "") then {
            private _lwr = toLower _resolvedClass;
            {
                if ((toLower _x) isEqualTo _lwr) exitWith {_resolvedClass = _x};
            } forEach _grenList;
        };
        if (_resolvedClass isEqualTo "" || {!(_resolvedClass in _grenList)}) then {
            _resolvedClass = (keys _grenList) param [0, ""];
        };
    };
    if (_resolvedClass isEqualTo "") exitWith {};

    private _removed = ["removeGrenade", [_resolvedClass, _num], 0] CALL_OBJCLASS("DropDevice", _drone);
    if (_removed > 0) then {
        ["DGM_executeDrop", [_drone, _resolvedClass, _removed, _instigator], _drone] call CBA_fnc_targetEvent;
    };
}] call CBA_fnc_addEventHandler;

["DGM_requestChangeCharge", {
    LOG_CBA_EVENT
    if !(isServer) exitWith {};
    params [["_drone", objNull], ["_notifyUnit", objNull]];
    if !(IS_DROP_DEVICE(_drone)) exitWith {};
    if !(DGM_GVAR(_drone, "canSetCharge", false)) exitWith {};

    private _newCharge = ["changeCharge", [], 1] CALL_OBJCLASS("DropDevice", _drone);
    if (IS_OBJ(_notifyUnit) && {isPlayer _notifyUnit}) then {
        ["DGM_showHint", [format [DGM_STR_SET_CHARGE, _newCharge], false], _notifyUnit] call CBA_fnc_targetEvent;
    };
}] call CBA_fnc_addEventHandler;


// ============================================================================
// Targeted Execution & Server API Forwarding Events
// ============================================================================

["DGM_executeDrop", {
    LOG_CBA_EVENT
    params [["_drone", objNull], ["_grenClass", ""], ["_num", 1], ["_instigator", objNull]];
    if !(IS_OBJ(_drone)) exitWith {};
    ["drop", [_grenClass, _num, _instigator]] SPAWN_OBJCLASS("DropDevice", _drone);
}] call CBA_fnc_addEventHandler;

["DGM_giveGrenade", {
    LOG_CBA_EVENT
    params [["_unit", objNull], ["_grenClass", ""], ["_count", 1], ["_drone", objNull]];
    if !(IS_OBJ(_unit)) exitWith {};
    [_unit, _grenClass, _count] call FUNC(giveOrDropItemToUnit);

    if (hasInterface && {IS_OBJ(_drone)} && {MENU_GVAR(_drone, "isMenuActive", false)}) then {
        ["refreshAttachActions", []] CALL_OBJCLASS("DropMenu", _drone);
    };
}] call CBA_fnc_addEventHandler;

["DGM_showHint", {
    LOG_CBA_EVENT
    if !(hasInterface) exitWith {};
    params [["_text", ""], ["_isDropHint", false]];
    if (_text isEqualTo "") exitWith {};
    if (_isDropHint) then {
        SHOW_DROP_HINT(_text);
    } else {
        SHOW_HINT(_text);
    };
}] call CBA_fnc_addEventHandler;

["DGM_setShotParents", {
    LOG_CBA_EVENT
    if !(isServer) exitWith {};
    params [["_gren", objNull], ["_drone", objNull], ["_instigator", objNull]];
    if !(IS_OBJ(_gren)) exitWith {};
    _gren setShotParents [_drone, _instigator];
}] call CBA_fnc_addEventHandler;

["DGM_setupVampirePylon", {
    LOG_CBA_EVENT
    params [["_drone", objNull]];
    if (!IS_OBJ(_drone) || {!local _drone}) exitWith {};
    _drone setPylonLoadout [1, "", true];
    _drone setPylonLoadout [1, "MMM_Pylon_Vampire_120mm_1x", true];
    _drone setAmmoOnPylon [1, 0];
}] call CBA_fnc_addEventHandler;

["DGM_removeDropDeviceServer", {
    LOG_CBA_EVENT
    if !(isServer) exitWith {};
    params [["_drone", objNull]];
    if !(IS_OBJ(_drone)) exitWith {};
    [] DELETE_OBJCLASS_GLOBAL("DropDevice", _drone, true);
}] call CBA_fnc_addEventHandler;

["DGM_setSlotsNumberServer", {
    LOG_CBA_EVENT
    if !(isServer) exitWith {};
    params [["_drone", objNull], ["_num", 1]];
    if !(IS_DROP_DEVICE(_drone)) exitWith {};
    ["setSlotsNumber", [_num]] CALL_OBJCLASS("DropDevice", _drone);
}] call CBA_fnc_addEventHandler;

["DGM_allowSetChargeServer", {
    LOG_CBA_EVENT
    if !(isServer) exitWith {};
    params [["_drone", objNull], ["_allow", true]];
    if !(IS_DROP_DEVICE(_drone)) exitWith {};
    ["allowSetCharge", [_allow]] CALL_OBJCLASS("DropDevice", _drone);
}] call CBA_fnc_addEventHandler;
