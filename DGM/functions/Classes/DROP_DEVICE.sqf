#include "..\defines.h"

/*
    Класс: OO_DROP_DEVICE

    Управляет состоянием системы сброса предметов с дрона (бекенд).
    Все переменные класса — глобальные и синхронизируются через методы класса.
    Локальные переменные интерфейса (например, ActionIds) должны храниться на объекте дрона локально.
*/

#ifdef CLASS_MAIN_OBJ
	#define CLASS_MAIN_OBJ "Drone"
#endif

CLASS("OO_DROP_DEVICE") // IOO_DROP_DEVICE

    PUBLIC VARIABLE("object", "Drone");              // дрон
    PUBLIC VARIABLE("bool", "SpawnTempGren");        // спавнить ли декоративную гранату
    PUBLIC VARIABLE("array", "AddedItems");          // список добавленных предметов
    PUBLIC VARIABLE("array", "RemovedItems");        // список запрещенных предметов
    PUBLIC VARIABLE("array", "CustomList");        // список кастомных предметов       
    PUBLIC VARIABLE("bool", "AllowOnlyListed");        
    PUBLIC VARIABLE("bool", "RemoveChemlights");          
    PUBLIC VARIABLE("bool", "RemoveSmokes");          
    PUBLIC VARIABLE("array", "AllowedGrenList");     
    PUBLIC VARIABLE("scalar", "Z_offset");            
    PUBLIC VARIABLE("scalar", "TempAttachGrenOffset");  
    PUBLIC VARIABLE("code", "MenuInstance");         


    PUBLIC FUNCTION("array", "constructor") { 
        // execute localy
        PR _drone = _this#0;
        params[
            "_drone",
            ["_slotNum", D_GET_VAR("Amount_of_slots_t", 1)],
            ["_spawnWithGren", D_GET_VAR("spawn_with_gren", "HandGrenade")],
            ["_addedItems", D_GET_VAR("list_of_grens", "")],
            ["_removedItems", D_GET_VAR("removedItems", "")],
            ["_allowSetCharge", D_GET_VAR("allowSetCharge", false)],
            ["_spawnTempGren", D_GET_VAR("spawn_temp_gren", true)],
            ["_allowOnlyListed", D_GET_VAR("allow_only_list", false)],
            ["_removeChemlights", D_GET_VAR("remove_chemlights", true)],
            ["_removeSmokes", D_GET_VAR("remove_smokes", true)]
        ];

        PR _customList = _spawnWithGren splitString ";,: ";
        _spawnWithGren = if (ARR_EMPTY(_customList)) then {""} else {_customList#0};

        _addedItems = _addedItems splitString ";,: ";
        _removedItems = _removedItems splitString ";,: ";

		_drone setVariable ["DGM_deviceInstance", _instance];

        MEMBER("Drone", _drone);
        MEMBER("SpawnTempGren", _spawnTempGren);
        MEMBER("AddedItems", _addedItems);
        MEMBER("RemovedItems", _removedItems);
        MEMBER("CustomList", _customList);
        MEMBER("AllowOnlyListed", _allowOnlyListed);
        MEMBER("RemoveChemlights", _removeChemlights);
        MEMBER("RemoveSmokes", _removeSmokes);
        MEMBER("CanSetCharge", _allowSetCharge);

        ARGS [_customList, _addedItems, _removedItems, _allowOnlyListed, _removeChemlights, _removeSmokes];
        MEMBER("DefineAttachParams", nil);
        MEMBER("DefineAllowedGrens", _args);

        PR _menuInstance = NEW(OO_DROP_MENU, [_drone]);
        MEMBER("MenuInstance", _menuInstance);

        _drone SV [VAR_MAX_SLOTS, _slotNum];

        if (local _drone) then {
            MEMBER(MAX_SLOTS, _slotNum);

            if !(_spawnWithGren isEqualTo "") then {
                if (_spawnTempGren) then {
                    MEMBER("SpawnAttachedGren", _spawnWithGren);
                };
                ["DGM_attachGrenEvent", [_drone, _spawnWithGren, objNull, _slotNum, 0]] call CBA_fnc_globalEvent;
            };

            // Killed Event Handler to call deconstructor
            private _MPKilledId = _drone addMPEventHandler ["MPKilled", {
                params ["_drone", "_killer", "_instigator", "_useEffects"];

                PR _deviceInst = DGVAR ["DGM_deviceInstance", {}];

                DELETE(_deviceInst);
            }];

            MEMBER('MPKilledId', _MPKilledId);
        };
    };

    PUBLIC FUNCTION("any", "deconstructor") { 
        // execute localy

        PR _drone = SELF_VAR('Drone');

        if (local _drone) then {
		    MEMBER("DeleteAttachedGren", nil);
        };

        // call DROP_MENU deconstructor
        ["delete"] call (_drone GV ["DGM_menuInstance", {}]);

		_drone setVariable ["DGM_deviceInstance", nil];
    };

    // VARIABLE SETTERS

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
    PUBLIC VAR_SETTER("hashmap", "DroneGrenList", createHashMap);

    PUBLIC VAR_SETTER("object", "TempAttachedGren", objNull);

    PUBLIC VAR_SETTER("string", "TempAttachedGrenClass", "");

    PUBLIC VAR_SETTER("object", "TempDropGren", objNull);

    PUBLIC VAR_SETTER("scalar", MAX_SLOTS, 1);

    PUBLIC VAR_SETTER("scalar", CURR_SLOTS, 0);

    PUBLIC VAR_SETTER("scalar", "MPKilledId", -1);

    PUBLIC VAR_SETTER("bool", "CanSetCharge", false);

    PUBLIC VAR_SETTER("scalar", "DropCharge", 1);

    // METHODS

    PUBLIC FUNCTION("ANY", "DefineAttachParams") {
        PR _spwnDef = if (SELF_VAR(MAX_SLOTS) isEqualTo 1) then {true} else {false};
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

        MEMBER("SpawnTempGren", _spawnGrenObj);
        MEMBER("TempAttachGrenOffset", _z_offsetAttach);
        MEMBER("Z_offset", _z_offsetDrop);
    };

    PUBLIC FUNCTION("ANY", "DefineAllowedGrens") {
        params[
            ['_customList', []], 
            ['_addedItems', []], 
            ['_removedItems', []], 
            ['_allowOnlyListed', false], 
            ['_removeChemlights', true], 
            ['_removeSmokes', true]
        ];

        (MEMBER("GetConfigData", nil)) params [["_expArr", [], [[]]], ["_cfgAmmoList", [], [[]]]];
        
        MEMBER("AllowedGrenList", _customList);

        if (_expArr isEqualTo []) EX;
        if (_cfgAmmoList isEqualTo []) EX;


        if (_allowOnlyListed) exitWith {
            _customList
        };
        PR _grenList = +_expArr;

        // adding gren classes from Add Items list
        PR _addedItemsArr = [];
        PR _addArr = _addedItems;

        if (count _addArr > 0) then {
            {	
                PR _el = _x;
                //if ammo classes written to custom list
                if (_el in _cfgAmmoList) then {
                    PR _magsOfAmmoCfg = "(_x >> 'ammo') == _el;" configClasses (configFile >> "CfgMagazines");
                    PR _magsOfAmmoCfgEl = _magsOfAmmoCfg select 0;
                    PR _magsOfAmmo = configName _magsOfAmmoCfgEl;
                    _addedItemsArr pushBack _magsOfAmmo;
                }else { 
                    //if magazine classes written to custom list
                    _addedItemsArr pushBack _el;
                };
            } forEach _addArr;
        };

        _grenList append _addedItemsArr;

        // removing gren classes from Remove Items list
        PR _remArr = _removedItems;

        if (count _remArr > 0) then {
            {	
                PR _el = _x;
                //if ammo classes written to custom list
                if (_el in _cfgAmmoList) then {
                    PR _magsOfAmmoCfg = "(_x >> 'ammo') == _el;" configClasses (configFile >> "CfgMagazines");
                    PR _magsOfAmmoCfgEl = _magsOfAmmoCfg select 0;
                    PR _magsOfAmmo = configName _magsOfAmmoCfgEl;
                    _grenList = _grenList - [_magsOfAmmo];
                }else { 
                    //if magazine classes written to custom list
                    _grenList = _grenList - [_el];
                };
            } forEach _remArr;
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
        // executed where the drone is local
        params ["_grenClass", ["_amount", 1]];

        PR _droneGrenList = SELF_VAR("DroneGrenList");
        PR _info = MEMBER("getGrenadeData", _grenClass);
        PR _num = _info getOrDefault ["Amount", 0];
        PR _grenAmount = _num + _amount;
        PR _drone = SELF_VAR("Drone");
	    
        _info set ["Amount", _grenAmount];
        _droneGrenList set [_grenClass, _info];

        MEMBER("DroneGrenList", _droneGrenList);

        if (SELF_VAR("SpawnTempGren")) then {
            MEMBER("SpawnAttachedGren", _grenClass);
        };


        // update slots count
        PR _newSlotsAmount = SELF_VAR(CURR_SLOTS) + _amount;
        
        MEMBER(CURR_SLOTS, _newSlotsAmount);
    };

    PUBLIC FUNCTION("array", "removeGrenade") {
        // executed where the drone is local
        params ["_grenClass", ["_amount", 1]];

        PR _droneGrenList = SELF_VAR("DroneGrenList");
        PR _info = MEMBER("getGrenadeData", _grenClass);
        PR _num = _info getOrDefault ["Amount", 0];
        PR _grenAmount = _num - _amount;
        PR _drone = SELF_VAR("Drone");

        if (_grenAmount <= 0) then {
            _droneGrenList deleteAt _grenClass;
        } else {
            _info set ["Amount", _grenAmount];
            _droneGrenList set [_grenClass, _info];
        };
        MEMBER("DroneGrenList", _droneGrenList);

        PR _tempGren = SELF_VAR("TempAttachedGren");
        PR _tempGrenClass = SELF_VAR("TempAttachedGrenClass");

        // delete temp object
        if ((LWR(_grenClass) == LWR(_tempGrenClass)) && (_grenAmount == 0)) then {
            MEMBER("DeleteAttachedGren", nil);
        };

        // update slots count
        PR _newSlotsAmount = SELF_VAR(CURR_SLOTS) - _amount;
        
        MEMBER(CURR_SLOTS, _newSlotsAmount);
    };

    PUBLIC FUNCTION("array", "Drop") {
        params["_item", ["_num", 1]];

        // executed where the drone is local
        PR _drone = SELF_VAR("Drone");

        ITEM_DATA(_item);
        

        if ("mavik" in (typeOf _drone)) then {
            [missionNamespace, "DB_mavic_showMessage", []] call BIS_fnc_callScriptedEventHandler;
        };

        PR _droneVelocity = velocity _drone;
        PR _zOffset = SELF_VAR("Z_offset");
        PR _velCoef = 1.5;
        PR _vectorDirUp = [];
        PR _velocity = [];
        PR _velocityModelSpace = [];
        PR _gren = objNull;

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
            _vectorDirUp = [vectorDir _drone,[0.1,0.1,1]];
            if ("OG7" in _item) then {
                _velocityModelSpace = [0, 70 ,0];
            } else {
                _velocity = [0, 0 ,0];
            };
        } else {
            _vectorDirUp = [[0,0,-1],[0.1,0.1,1]];
            _velocity = [(_droneVelocity select 0) / _velCoef, (_droneVelocity select 1) / _velCoef ,-2];
        };

        PR _randPos = [0,0];
        PR _originVelocity = +_velocity;

        FOR_I(_num) {
            PR _pos = _drone modelToWorld [_randPos#0,_randPos#0, _zOffset];
            _gren = _itemAmmo createvehicle _pos;
            [_gren, [_drone, player]] remoteExec ["setShotParents", 2];

            if !(_velocityModelSpace isEqualTo []) then {
                _gren setVelocityModelSpace _velocityModelSpace;
            } else {
                _gren setVelocity _velocity;
            };
            _gren setVectorDirandUp _vectorDirUp;

            if ((_num > 1) && (_i < _num)) then {
                PR _randVel = (MGVAR ["DGM_randomVelocity", 0.15]);
                PR _randOffset = (MGVAR ["DGM_randomOffset", 0.05]);
                PR _dropDelay = (MGVAR ["DGM_randomDropDelay", 0.05]);

                _randPos = [random [-_randOffset, 0, _randOffset], random [-_randOffset, 0, _randOffset]];
                _velocity = _originVelocity vectorAdd [random [-_randVel, 0, _randVel], random [-_randVel, 0, _randVel], 0];

                sleep (random [_dropDelay - (_dropDelay/3), _dropDelay, _dropDelay + (_dropDelay/3)]);
            };
        };

        MEMBER("TempDropGren", _gren);

		SHOW_HINT TXT_DROPED;

        _gren
    }; 

    PUBLIC FUNCTION("string", "SpawnAttachedGren") {
        // executed where the drone is local
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


        MEMBER("TempAttachedGren", _gren);
        MEMBER("TempAttachedGrenClass", _item);

        _gren
    }; 

    PUBLIC FUNCTION("ANY", "DeleteAttachedGren") {
        // executed where the drone is local
        PR _tempGren = SELF_VAR("TempAttachedGren");


        if (_tempGren isEqualTo objNull) EX;

        PR _drone = SELF_VAR("Drone");

        deleteVehicle _tempGren;

        MEMBER("TempAttachedGren", objNull);
        MEMBER("TempAttachedGrenClass", "");
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

        MEMBER(MAX_SLOTS, _this);
    };

    PUBLIC FUNCTION("scalar", "setCharge") {
        if (_this <= 0) exitWith {
            SHOW_HINT LBL_ABOVE_ZERO;
        };

        MEMBER("DropCharge", _this);
    };

    PUBLIC FUNCTION("any", "ChangeCharge") {
        PR _currentCharge = SELF_VAR("DropCharge");

        PR _newCharge = if ((_currentCharge >= 9) || (_currentCharge < 1)) then {
            1
        } else {
            _currentCharge + 1
        };

        MEMBER("setCharge", _newCharge);
    };

    PUBLIC FUNCTION("bool", "AllowSetCharge") {
        if (_this) then {
            PR _menuInstance = SELF_VAR("MenuInstance");

            METHOD(_menuInstance, "addActionCharge", nil);
        };
        MEMBER("CanSetCharge", _this);
    };

ENDCLASS;