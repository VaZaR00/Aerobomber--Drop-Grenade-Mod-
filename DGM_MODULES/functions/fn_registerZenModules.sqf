#include "defines.hpp"

/*
    Function: DGM_fnc_registerZenModules

    Description:
        Registers DGM Drop Device modules in Zeus Enhanced (ZEN).
*/

if (!hasInterface) exitWith {};
if (isNil "zen_custom_modules_fnc_register") exitWith {};
if (missionNamespace getVariable ["DGM_zenModulesRegistered", false]) exitWith {};
missionNamespace setVariable ["DGM_zenModulesRegistered", true];

private _category = localize "STR_DGM_Module_CategoryName";
if (_category isEqualTo "") then {_category = "DGM - Drone Grenade Mod"};

private _addName = localize "STR_DGM_Module_Device_FactionName";
if (_addName isEqualTo "") then {_addName = "Grenade Drop Device"};

private _removeName = localize "STR_DGM_Module_RemoveDeviceName";
if (_removeName isEqualTo "") then {_removeName = "Remove Drop Device"};

// 1. Add / Configure Grenade Drop Device
[
    _category,
    _addName,
    {
        params ["_pos", "_target"];
        ["DGM_Device", _pos, _target] call DGM_fnc_openZenModuleDialog;
    },
    "a3\ui_f\data\gui\rsc\rscdisplayarsenal\cargothrow_ca.paa"
] call zen_custom_modules_fnc_register;

// 2. Remove Grenade Drop Device
[
    _category,
    _removeName,
    {
        params ["", "_target"];
        if (!IS_OBJ(_target) || {!(_target getVariable ["DGM_isDropDevice", false])}) exitWith {
            private _errMsg = localize "STR_DGM_Module_ErrNoDropDevice";
            if (_errMsg isEqualTo "") then {_errMsg = "Select a drone with an active Drop Device"};
            [objNull, _errMsg] call BIS_fnc_showCuratorFeedbackMessage;
        };
        [_target] call DGM_fnc_removeDropDevice;
        private _okMsg = localize "STR_DGM_Module_MsgRemovedDropDevice";
        if (_okMsg isEqualTo "") then {_okMsg = "Drop Device removed"};
        [objNull, _okMsg] call BIS_fnc_showCuratorFeedbackMessage;
    },
    "\a3\3den\data\displays\display3den\panelleft\entitylist_delete_ca.paa"
] call zen_custom_modules_fnc_register;
