#include "..\includes\defines.h"

/*
    Класс: OO_DROP_MENU

    Description:
        All methods and class handling is local
*/

#define IS_MENU_ACTIVE "_target getVariable ['DGM_IsMenuActive', false]"
#define IS_CONTROLLING_DRONE_CODE ((vehicle (remoteControlled player)) isEqualTo _target)
#define IS_CONTROLLING_DRONE STR(IS_CONTROLLING_DRONE_CODE)


CLASS("OO_DROP_MENU") // IOO_DROP_MENU

    PUBLIC VARIABLE("object", "Drone");              // дрон
    PUBLIC VARIABLE("hashmap", "Actions"); // (hashmap) grenclass : (hashmap) [attach: id, detach: id, drop: id]
    PUBLIC VARIABLE("scalar", "MenuAction"); // Menu action
    PUBLIC VARIABLE("scalar", "CloseAction"); // Close Menu action
    PUBLIC VARIABLE("bool", "IsMenuActive");
    PUBLIC VARIABLE("array", "AllActions");


    PUBLIC FUNCTION("array", "constructor") {
        params [
            "_drone"
        ];

        ["OO_DROP_MENU constructor", _this] RLOG

        MEMBER("Drone", _drone);
        MEMBER("Actions", createHashMap);
        MEMBER("AllActions", []);
        MEMBER("IsMenuActive", false);

        MEMBER("addActionMenu", []);
        MEMBER("addActionClose", []);

		_drone setVariable ["DGM_menuInstance", _instance];
    };

    PUBLIC FUNCTION("any", "deconstructor") {
		{
            MEMBER("removeAction", _x)
        } forEach SELF_VAR("AllActions");

		_drone setVariable ["DGM_menuInstance", nil];
    }; 

    PUBLIC FUNCTION("any", "addActionMenu") {
        // Menu Action
        PR _arg = [
            "MenuAction",
            TXT_MENU,
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                _arguments params ["_menuInstance"];
                METHOD(_menuInstance, "SetMenuActive", true);
            },
            [_instance],
            format["!(%1) && !(%2)", IS_MENU_ACTIVE, IS_CONTROLLING_DRONE],
            5
        ];
        MEMBER("addAction", _arg);
    };

    PUBLIC FUNCTION("any", "addActionClose") {
        // Close Menu Action
        PR _arg = [
            "CloseAction",
            TXT_CLOSE_MENU,
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                _arguments params ["_menuInstance"];
                METHOD(_menuInstance, "SetMenuActive", false);
            },
            [_instance],
            format["(%1) && !(%2)", IS_MENU_ACTIVE, IS_CONTROLLING_DRONE],
            5
        ];
        MEMBER("addAction", _arg);
    };

    // for add action funcs argument is grenade class
    
    // Attach Action
    // AttachId
    PUBLIC FUNCTION("array", "addActionAttach") {
        params["_itemClass", "_itemAmount"];

        PR _itemName = ITEM_NAME(_itemClass);
        PR _arg = [
            "AttachId",
            TXT_ATTACH,
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                _arguments params ["_grenClass"];
                ["DGM_attachGrenEvent", [_target, _grenClass, _caller]] call CBA_fnc_globalEvent;
            },
            [_itemClass],
            format["(%1) && !(%2)", IS_MENU_ACTIVE, IS_CONTROLLING_DRONE],
            2,
            _itemClass
        ];
        MEMBER("addAction", _arg);
    };

    // Detach Action
    // DetachId
    PUBLIC FUNCTION("string", "addActionDetach") {
        PR _itemAmount = 1;
        PR _itemName = ITEM_NAME(_this);
        PR _arg = [
            "DetachId",
            TXT_DETACH,
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                _arguments params ["_grenClass"];
                ["DGM_detachGrenEvent", [_target, _grenClass, _caller]] call CBA_fnc_globalEvent;
            },
            [_this],
            format["(%1) && !(%2)", IS_MENU_ACTIVE, IS_CONTROLLING_DRONE],
            4,
            _this
        ];
        MEMBER("addAction", _arg);
    };

    // Drop Action
    // DropId
    PUBLIC FUNCTION("string", "addActionDrop") {
        PR _itemAmount = 1;
        PR _itemName = ITEM_NAME(_this);
        PR _arg = [
            "DropId",
            TXT_DROP,
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                _arguments params ["_grenClass"];
                ["DGM_dropGrenEvent", [_target, _grenClass, remoteControlled _caller]] call CBA_fnc_globalEvent;
            },
            [_this],
            format["(%1)", IS_CONTROLLING_DRONE],
            3,
            _this
        ];
        MEMBER("addAction", _arg);
    };

    PUBLIC FUNCTION("array", "addAction") {
        ["addAction"] RLOG;
        params[["_type", "", [""]], ["_name", "", [""]], ["_code", {}, [{}]], ["_arguments", [], [[]]], ["_condition", "", [""]], ["_priority", 2, [0]], ["_itemClass", "", [""]]];

        if (MEMBER("actionsExists", [_type C _itemClass])) exitWith {
            MEMBER("modifyActions", _itemClass)
        };

        PR _drone = SELF_VAR("Drone");
        ["addAction ADD", SELF_VAR("Drone"), _type, _name, _itemClass, SELF_VAR("AllActions")] RLOG;

        if (isNil "_drone") EX;

		PR _id = _drone addAction
        [
            _name,
            _code,
            _arguments,
            _priority,
            true,
            false,
            "",
            _condition,
            2
        ];
        if (_itemClass != "") then {
            MEMBER("addActionId", [_itemClass C _type C _id]);
        };
        _id
    };

    PUBLIC FUNCTION("scalar", "removeAction") {
        if (_this == -1) EX;

        ["removeAction", _this] RLOG

		PR _drone = SELF_VAR("Drone");

        _drone removeAction _this;
        SELF_VAR("AllActions") - [_this];
    };

    PUBLIC FUNCTION("string", "removeGrenActions") {
		PR _drone = SELF_VAR("Drone");
        PR _grenActions = MEMBER("getGrenActions", _this);   

        ["removeGrenActions", _this, _grenActions] RLOG

        if (MEMBER("grenadeAvailable", _this)) then {
            MEMBER("modifyActions", _this)
        } else {
            MEMBER("removeAction", _grenActions getOrDefault ["DetachId" C -1]);
            _grenActions set ["DetachId", -1];

            MEMBER("removeAction", _grenActions getOrDefault ["DropId" C -1]);
            _grenActions set ["DropId", -1];

            SELF_VAR("Actions") set [_this, _grenActions];
        };
    };

    PUBLIC FUNCTION("string", "getGrenActions") {
        SELF_VAR("Actions") getOrDefault [_this, createHashMap];
    };

    PUBLIC FUNCTION("bool", "SetMenuActive") {
        ["SetMenuActive", _this] RLOG
        MEMBER("IsMenuActive", _this);
        SELF_VAR("Drone") setVariable ["DGM_IsMenuActive", _this];

        if (_this) then {
            MEMBER("LoadGrensMenu", nil);

            PR _this = [SELF_VAR("Drone"), _instance];
            ENSURE_SPAWN_ONCE_START
                ["Keep menu opened"] RLOG
                params ["_target", "_menuInstance"];
                PR _inventoryDisplay = 602;
                waitUntil { 
                    uiSleep 0.1;
                    !(_target getVariable ["DGM_IsMenuActive", false]) || 
                    ((_target distance player) > 3) || 
                    (!(isNull (findDisplay _inventoryDisplay))) ||
                    (IS_CONTROLLING_DRONE_CODE)
                };
                if (_target getVariable ["DGM_IsMenuActive", false]) then {  
                    METHOD(_menuInstance, "SetMenuActive", false);
                };
                ["Force close menu"] RLOG
            ENSURE_SPAWN_ONCE_END
        } else {
            DGM_currentGrenadesListCounts = nil;
        };
    };

    PUBLIC FUNCTION("any", "UpdateMenu") {
        ["UpdateMenu"] RLOG
        MEMBER("SetMenuActive", SELF_VAR("IsMenuActive"));
    };

    PRIVATE FUNCTION("string", "grenadeAvailable") {
        private _drone = SELF_VAR("Drone");
	    private _deviceInst = _drone GV ["DGM_deviceInstance", {}];
        
        METHOD(_deviceInst, "grenadeAvailable", _this);
    };

    PRIVATE FUNCTION("array", "actionsExists") {
        params[["_type", "", [""]], ["_itemClass", "", [""]]];

        if ((_itemClass == "") || (_type == "")) exitWith {false};

        PR _grenActions = SELF_VAR("Actions") get _itemClass;
        if (isNil "_grenActions") exitWith {false};
        ["actionsExists", _type, _itemClass, !((_grenActions getOrDefault [_type, -1]) == -1)] RLOG;
        if ((_grenActions getOrDefault [_type, -1]) == -1) exitWith {false};

        true
    };

    PRIVATE FUNCTION("string", "modifyActions") {
        private _itemClass = _this;
        private _itemName = ITEM_NAME(_this);

        private _drone = SELF_VAR("Drone");
	    private _deviceInst = _drone GV ["DGM_deviceInstance", {}];
        private _amount = METHOD(_deviceInst, "getGrenAmount", _itemClass);
        private _actionsHash = SELF_VAR("Actions") get _itemClass;

        ["modifyActions", _this, _amount] RLOG

        if (isNil "_actionsHash") exitWith {false};

        PR _itemAmount = _amount;

        _drone setUserActionText [_actionsHash getOrDefault ["DetachId", -1], TXT_DETACH];
        _drone setUserActionText [_actionsHash getOrDefault ["DropId", -1], TXT_DROP];
        ["SET modifyActions", _actionsHash getOrDefault ["DetachId", -1], _actionsHash getOrDefault ["DropId", -1], TXT_DETACH, TXT_DROP] RLOG
        
        ["GET PLAYER GREN AMOUNT modifyActions", _itemClass, (MGVAR ["DGM_currentGrenadesListCounts", createHashMap]) get _itemClass, (MGVAR ["DGM_currentGrenadesListCounts", createHashMap])] RLOG
        _itemAmount = (MGVAR ["DGM_currentGrenadesListCounts", createHashMap]) get _itemClass;
        if !(isNil "_itemAmount") then {
            _drone setUserActionText [_actionsHash getOrDefault ["AttachId", -1], TXT_ATTACH];
            ["SET ATTACH ID modifyActions", _itemAmount, _actionsHash getOrDefault ["AttachId", -1], TXT_ATTACH] RLOG
        };

        true
    };

    PRIVATE FUNCTION("array", "addActionId") {
        params[["_itemClass", "", [""]], ["_name", "", [""]], ["_id", -1, [0]]];

        if ((_id == -1) || (_name == "")) EX;

        ["addActionId", _this] RLOG

        switch (_name) do {
            case "MenuAction": {
                MEMBER("MenuAction", _id);
            };
            case "CloseAction": {
                MEMBER("CloseAction", _id);
            };
            default {
                // get variables
                PR _actions = SELF_VAR("Actions");
                PR _grenHash = _actions getOrDefault [_itemClass, createHashMap];

                // set
                _grenHash set [_name, _id];

                // save
                _actions set [_itemClass, _grenHash];
                MEMBER("Actions", _actions);
            };
        };

        SELF_VAR("AllActions") pushBack _id;
    };

    PRIVATE FUNCTION("any", "LoadGrensMenu") {
        // Load attach actions 

        DGM_currentGrenadesListCounts = nil;

	    PR _drone = SELF_VAR("Drone");
	    PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
	    PR _actions = SELF_VAR("Actions");
	    PR _currentMenuGrenades = keys _actions;

        PR _playerGrens = createHashMap;
        PR _playerMags = (itemsWithMagazines player);
        PR _allowedgrens = INSTANCE_VAR(_deviceInst, "AllowedGrenList");

        {
            PR _el = _x;
            if !(_el in _allowedgrens) then {SKIP};
            _playerGrens set [_el, ({_el == _x} count _playerMags), true];
        } forEach _playerMags;

        ["LoadGrensMenu", _playerGrens] RLOG

        if (count _playerGrens == 0) exitWith {
            hint LBL_DONT_HAVE_GRENS;
        };

        DGM_currentGrenadesListCounts =  _playerGrens;

        {
            MEMBER("addActionAttach", [_x C _y]);
        } forEach _playerGrens;

        (_currentMenuGrenades select {!(_x in _playerGrens)}) apply {
            PR _grenActions = MEMBER("getGrenActions", _x); 
            MEMBER("removeAction", _grenActions getOrDefault ["AttachId" C -1]);
        };

        _playerGrens
    };

ENDCLASS;