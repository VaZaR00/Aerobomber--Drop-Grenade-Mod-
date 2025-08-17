#include "..\includes\defines.h"

/*
    Класс: OO_DROP_DEVICE

    Управляет состоянием системы сброса предметов с дрона (бекенд).
    Все переменные класса — глобальные и синхронизируются через методы класса.
    Локальные переменные интерфейса (например, ActionIds) должны храниться на объекте дрона локально.
*/

CLASS("OO_DROP_DEVICE") // IOO_DROP_DEVICE

    PUBLIC VARIABLE("object", "Drone");              // дрон
    PUBLIC VARIABLE("scalar", "SlotNum");            // количество слотов
    PUBLIC VARIABLE("scalar", "SlotsOccupied");      // количество занятых слотов
    PUBLIC VARIABLE("bool", "SpawnWithGren");        // спавнить ли с гранатой
    PUBLIC VARIABLE("array", "AddedItems");          // список добавленных предметов
    PUBLIC VARIABLE("bool", "AllowOnlyListed");          
    PUBLIC VARIABLE("bool", "RemoveListed");          
    PUBLIC VARIABLE("bool", "RemoveChemlights");          
    PUBLIC VARIABLE("bool", "RemoveSmokes");          
    PUBLIC VARIABLE("array", "AllowedGrenList");     // 

    PRIVATE VARIABLE("hashmap", "DroneGrenList");     // [класс гранаты] = [кол-во]
    PRIVATE VARIABLE("scalar", "Z_offset");            // z offset
    PRIVATE VARIABLE("bool", "SpawnGren");          // 
    PRIVATE VARIABLE("object", "TempAttachedGren");          // 
    PRIVATE VARIABLE("scalar", "TempAttachGrenOffset");          // 
    PRIVATE VARIABLE("object", "TempDropGren");          // 
    PRIVATE VARIABLE("code", "MenuInstance");          // 


    PUBLIC FUNCTION("array", "constructor") { // execute globaly
        PR _drone = _this#0;
        params[
            "_drone",
            ["_slotNum", D_GET_VAR("Amount_of_slots_t", 1)],
            ["_spawnWithGren", D_GET_VAR("spawn_with_gren", true)],
            ["_addedItems", D_GET_VAR("list_of_grens", "")],
            ["_allowOnlyListed", D_GET_VAR("allow_only_list", false)],
            ["_removeListed", D_GET_VAR("remove_list_grens", false)],
            ["_removeChemlights", D_GET_VAR("remove_chemlights", true)],
            ["_removeSmokes", D_GET_VAR("remove_smokes", true)]
        ];

        _addedItems = _addedItems splitString ";,: ";

		_drone setVariable ["DGM_deviceInstance", _instance];
		_drone setVariable [MAX_SLOTS, _slotNum];
		_drone setVariable [CURR_SLOTS, 0];

        MEMBER("Drone", _drone);
        MEMBER("SlotNum", _slotNum);
        MEMBER("SlotsOccupied", 0);
        MEMBER("SpawnWithGren", _spawnWithGren);
        MEMBER("AddedItems", _addedItems);
        MEMBER("TempDropGren", objNull);

        MEMBER("DroneGrenList", createHashMap);
        /*
            DroneGrenList Element Structure

            Type: hashmap
            [
                "Name": string,
                "Amount": int,
                "DropId": int, 
                "DetachId": int 
            ]
        */

        PR _menuInstance = NEW(OO_DROP_MENU, [_drone]);
        MEMBER("MenuInstance", _menuInstance);

        MEMBER("DefineAttachParams", nil);
        MEMBER("DefineAllowedGrens", nil);

        if (_spawnWithGren && (local _drone)) then {
            MEMBER("SpawnAttachedGren", _addedItems select 0);
            ["DGM_attachGrenEvent", [_drone, (_addedItems#0), objNull, _slotNum]] call CBA_fnc_globalEvent;
        };
    };

    PUBLIC FUNCTION("array", "deconstructor") { // execute globaly
		MEMBER("DeleteAttachedGren", nil);

        ["delete"] call (_drone GV ["DGM_menuInstance", {}]);

		_drone setVariable ["DGM_deviceInstance", nil];
    };

    PUBLIC FUNCTION("ANY", "DefineAttachParams") {
        PR _spwnDef = if (SELF_VAR("SlotNum") == 1) then {true} else {false};
        PR _drType = (typeOf _drone);
        PR _values = switch (true) do {
            case ("UAV_01" in _drType): {
                [_spwnDef, -0.12, -0.3]
            };
            case ("mavik" in _drType): {
                [_spwnDef, -0.075, -0.3]
            };
            default {
                [false, -0.2, -0.45]
            };
        };
        _values params ["_spawnGrenObj", "_z_offsetAttach", "_z_offsetDrop"];

        MEMBER("SpawnGren", _spawnGrenObj);
        MEMBER("TempAttachGrenOffset", _z_offsetAttach);
        MEMBER("Z_offset", _z_offsetDrop);
    };

    PUBLIC FUNCTION("ANY", "DefineAllowedGrens") {
        (MEMBER("GetConfigData", nil)) params [["_expArr", [], [[]]], ["_cfgAmmoList", [], [[]]]];

        if (_expArr isEqualTo []) EX;
        if (_cfgAmmoList isEqualTo []) EX;

        PR _addedItemsArr = [];

        PR _grenList = +_expArr;
        if (SELF_VAR("AllowOnlyListed")) then {
            _grenList = [];
            MEMBER("RemoveListed", false);
        };

        // adding\removing gren classes from "List of things you want to attach"
        PR _addArr = SELF_VAR("AddedItems");

        if (count _addArr > 0) then {
            {	
                PR _el = _x;
                //if ammo classes written to custom list
                if (_el in _cfgAmmoList) then {
                    PR _magsOfAmmoCfg = "(_x >> 'ammo') == _el;" configClasses (configFile >> "CfgMagazines");
                    PR _magsOfAmmoCfgEl = _magsOfAmmoCfg select 0;
                    PR _magsOfAmmo = configName _magsOfAmmoCfgEl;
                    if (_removeListed) then {
                        _grenList = _grenList - [_magsOfAmmo];
                    }else{
                        _addedItemsArr pushBack _magsOfAmmo;
                    };
                }else { 
                    //if magazine classes written to custom list
                    if (_removeListed) then {
                        _grenList = _grenList - [_el];
                    }else{
                        _addedItemsArr pushBack _el;
                    };
                };
            } forEach _addArr;
        };

        //removing chemlights
        if (_removeChemlights) then {
            {
                PR _el = _x;
                if (("hemlight" in _el) || ("HandFlare" in _el)) then {
                    _grenList = _grenList - [_el];
                };
            } forEach _grenList;
        };

        //removing smokes
        if (_removeSmokes) then {
            PR _rmvSmokeArr = [];
            PR _rmvSmokeArrCfgs = "'moke' in getText(_x >> 'displayNameShort');" configClasses (configFile >> "CfgMagazines");
            {
                PR _el = configName _x;
                _rmvSmokeArr pushBack _el;
            }forEach _rmvSmokeArrCfgs;
            {
                PR _el = _x;
                if (
                    ("smoke" in _el) or
                    ("m18" in _el) or
                    ("83" in _el) or
                    ("m8h" in _el) or
                    ("DM32" in _el) or
                    ("nsp" in _el) or
                    ("rdg" in _el)
                ) then {
                    if (_el in _cfgAmmoList) then {
                        PR _magsOfAmmoCfg = "getText(_x >> 'ammo') == _el;" configClasses (configFile >> "CfgMagazines");
                        PR _magsOfAmmoCfgEl = _magsOfAmmoCfg select 0;
                        PR _magsOfAmmo = configName _magsOfAmmoCfgEl;
                        _grenList = _grenList - [_magsOfAmmo];
                    }else{
                        _grenList = _grenList - [_el];
                    };
                };
            } forEach _grenList;
            _grenList = _grenList - _rmvSmokeArr;
        };

        CLR_DUPS(_grenList);

        MEMBER("AllowedGrenList", _grenList);

        _grenList
    };

    PUBLIC FUNCTION("ANY", "GetConfigData") {
        PR _expArr = MGVAR "DGM_var_expArr";
        PR _ammoCfg = MGVAR "DGM_var_ammoCfg";
        if (isNil "_expArr") exitWith {
            [] call DGM_fnc_getAllExp;
        };
        [_expArr, _ammoCfg]
    };

    PUBLIC FUNCTION("array", "addGrenade") {
        params ["_grenClass", ["_amount", 1]];

        private _droneGrenList = SELF_VAR("DroneGrenList");
        private _info = MEMBER("getGrenadeData", _grenClass);
        private _num = _info getOrDefault ["Amount", 0];
	    
        _info set ["Amount", _num + _amount];
        _droneGrenList set [_grenClass, _info];

        MEMBER_GLOBAL("DroneGrenList", _droneGrenList);
        MEMBER("SpawnAttachedGren", _grenClass);

        // update slots count
        PR _drone = SELF_VAR("Drone");
        PR _newSlotsAmount = SELF_VAR("SlotsOccupied") + _amount;
        
        MEMBER_GLOBAL("SlotsOccupied", _newSlotsAmount);
		DSVAR [CURR_SLOTS, _newSlotsAmount, true];
    };

    PUBLIC FUNCTION("array", "removeGrenade") {
        params ["_grenClass", ["_amount", 1]];

        private _droneGrenList = SELF_VAR("DroneGrenList");
        private _info = MEMBER("getGrenadeData", _grenClass);
        private _num = _info getOrDefault ["Amount", 0];

        if (_num <= _amount) then {
            _droneGrenList deleteAt _grenClass;
        } else {
            _info set ["Amount", _num - _amount];
            _droneGrenList set [_grenClass, _info];
        };
        MEMBER_GLOBAL("DroneGrenList", _droneGrenList);

        PR _tempGren = SELF_VAR("TempAttachedGren");
        PR _grenAmount = MEMBER("getGrenAmount", _grenClass);

        // delete temp object
        if ((_grenClass == (SELF_VAR("Drone") GV ["DGM_tempGrenClassname", ""])) && (_grenAmount == 0)) then {
            MEMBER("DeleteAttachedGren", nil);
        };

        // update slots count
        PR _drone = SELF_VAR("Drone");
        PR _newSlotsAmount = SELF_VAR("SlotsOccupied") - _amount;
        
        MEMBER_GLOBAL("SlotsOccupied", _newSlotsAmount);
		DSVAR [CURR_SLOTS, _newSlotsAmount, true];
    };

    PUBLIC FUNCTION("string", "Drop") {
        PR _drone = SELF_VAR("Drone");
        PR _item = _this;

        ITEM_DATA(_item);
        

        if ("mavik" in (typeOf _drone)) then {
            [missionNamespace, "DB_mavic_showMessage", []] call BIS_fnc_callScriptedEventHandler;
        };

        PR _droneVelocity = velocity _drone;
        PR _pos = _drone modelToWorld [0,0, SELF_VAR("Z_offset")];
        PR _gren = _itemAmmo createvehicle _pos;
        [_gren, [_drone, player]] remoteExec ["setShotParents", 2];

        PR _velCoef = 1.5;

        if (
            (missionNamespace getVariable ["DGM_shoot_rockets", true]) &&
            {("PG7" in _item) or
            ("OG7" in _item) or
            ("TPG7" in _item) or
            ("type6" in _item) or
            ("RPG32" in _item) or
            ("Vorona" in _item) or
            ("fgm" in _item) or
            ("itan" in _item)}
        ) then {
            _gren setVectorDirandUp [vectorDir _drone,[0.1,0.1,1]];
            if ("OG7" in _item) then {
                _gren setVelocityModelSpace [0, 70 ,0];
            } else {
                _gren setVelocity [0, 0 ,0];
            };
        } else {
            _gren setVectorDirandUp [[0,0,-1],[0.1,0.1,1]];
            _gren setVelocity [(_droneVelocity select 0) / _velCoef, (_droneVelocity select 1) / _velCoef ,-2];
        };
        _drone setVariable ["DGM_tempGren", _gren, true];

        MEMBER_GLOBAL("TempDropGren", _gren);

		SHOW_HINT TXT_DROPED;

        _gren
    }; 

    PUBLIC FUNCTION("string", "SpawnAttachedGren") {
        PR _item = _this;
        
        if !(SELF_VAR("TempAttachedGren") isEqualTo objNull) EX;

        PR _drone = SELF_VAR("Drone");

        ITEM_DATA(_item);

        PR _zOffset = SELF_VAR("TempAttachGrenOffset");
        //for specific grens on mavik there is special offset
        if ("mavik" in (typeOf _drone)) then {
            if (
                ("og25" in _item) or
                ("433" in _item) or
                ("441" in _item) or
                ("Rnd_HE" in _item) or
                ("M58" in _item) or
                ("M66" in _item) or
                ("M71" in _item) or
                ("VG40" in _item) or
                ("Mavic_F1" in _item)
            ) then {
                _zOffset = -0.04;
            };
        };
        PR _gren = createSimpleObject [_itemModel, [0,0,0]];
        _gren attachTo [_drone, [0,0,_zOffset]];

        MEMBER_GLOBAL("TempAttachedGren", _gren);
        _drone setVariable ["DGM_TempAttachedGren", _gren, true];
        _drone setVariable ["DGM_tempGrenClassname", _item, true];

        _gren
    }; 

    PUBLIC FUNCTION("ANY", "DeleteAttachedGren") {
        PR _tempGren = SELF_VAR("TempAttachedGren");

        if (_tempGren isEqualTo objNull) EX;

        PR _drone = SELF_VAR("Drone");

        deleteVehicle _tempGren;

        MEMBER_GLOBAL("TempAttachedGren", objNull);
        _drone setVariable ["DGM_TempAttachedGren", objNull, true];
        _drone setVariable ["DGM_tempGrenClassname", "", true];
    }; 

    PUBLIC FUNCTION("string", "getGrenadeData") {
        private _droneGrenList = SELF_VAR("DroneGrenList");
        (_droneGrenList getOrDefault [_this, createHashMap])
    };

    PUBLIC FUNCTION("string", "getGrenAmount") {
        private _droneGrenList = SELF_VAR("DroneGrenList");
        if (isNil "_droneGrenList") exitWith {0};
        (_droneGrenList getOrDefault [_this, createHashMap]) getOrDefault ["Amount", 0];
    }; 

    PUBLIC FUNCTION("string", "grenadeAvailable") {
        if (_this == "") exitWith {false};

        private _drone = SELF_VAR("Drone");
        private _amount = MEMBER("getGrenAmount", _this);

        if ((isNil "_amount") || {_amount <= 0}) exitWith {
            false
        };

        true
    };

    PUBLIC FUNCTION("scalar", "setSlotsNumber") {
        if (_this <= 0) exitWith {
            SHOW_HINT LBL_SLOTS_NOT_ENOUGH;
        };

        PR _drone = SELF_VAR("Drone");

        MEMBER_GLOBAL("SlotNum", _this);
		DSVAR [MAX_SLOTS, _this, true];
    };

ENDCLASS;