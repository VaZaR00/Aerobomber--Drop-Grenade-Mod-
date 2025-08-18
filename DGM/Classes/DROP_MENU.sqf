#include "..\includes\defines.h"

/*
    Класс: OO_DROP_MENU

    Description:
        All methods and class handling is LOCAL
*/

#define IS_MENU_ACTIVE format["(_target getVariable ['%1', false])", SPREF("IsMenuActive")]
#define IS_CONTROLLING_DRONE_CODE ((vehicle (remoteControlled player)) isEqualTo _target)
#define IS_CONTROLLING_DRONE STR(IS_CONTROLLING_DRONE_CODE)
#define SLOTS_AVAILABLE_CODE ((_target GV [CURR_SLOTS, 0]) < (_target GV [MAX_SLOTS, 0]))

// LOCAL
CLASS("OO_DROP_MENU") // IOO_DROP_MENU

    PUBLIC VARIABLE("object", "Drone");              // дрон
    PUBLIC VARIABLE("hashmap", "Actions"); // (hashmap) grenclass : (hashmap) [attach: id, detach: id, drop: id]
    PUBLIC VARIABLE("scalar", "MenuAction"); // Menu action
    PUBLIC VARIABLE("scalar", "CloseAction"); // Close Menu action
    PUBLIC VARIABLE("array", "AllActions");


    PUBLIC FUNCTION("array", "constructor") {
        params [
            "_drone"
        ];

        if !(hasInterface) exitWith {
		    _drone setVariable ["DGM_menuInstance", {}];
            {}
        };

        MEMBER("Drone", _drone);
        MEMBER("Actions", createHashMap);
        MEMBER("AllActions", []);
        MEMBER("IsMenuActive", false);

        MEMBER("addActionMenu", nil);
        MEMBER("addActionClose", nil);

		_drone setVariable ["DGM_menuInstance", _instance];
    };

    PUBLIC FUNCTION("any", "deconstructor") {
		{
            MEMBER("removeAction", _x)
        } forEach SELF_VAR("AllActions");

		_drone setVariable ["DGM_menuInstance", nil];
    }; 

    PUBLIC SETTER("bool", "IsMenuActive") {
        PR _drone = SELF_VAR("Drone");
        IF_SET {
            _drone SV [SPREF("IsMenuActive"), _this];
        } 
        IF_GET {
            _drone GV [SPREF("IsMenuActive"), false];
        }
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

                if !((_target GV [CURR_SLOTS, 0]) < (_target GV [MAX_SLOTS, 0])) exitWith {
                    SHOW_HINT LBL_CANT_ADD_MORE_GREN;
                };

		        PR _deviceInst = _target GV ["DGM_deviceInstance", {}];
                PR _currentCount = METHOD(_deviceInst, "getGrenAmount", _grenClass);

                ["DGM_attachGrenEvent", [_target, _grenClass, _caller, 1, _currentCount]] call CBA_fnc_globalEvent;
            },
            [_itemClass],
            format["(%1) && !(%2) && (call %3)", IS_MENU_ACTIVE, IS_CONTROLLING_DRONE, {SLOTS_AVAILABLE_CODE}],
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

		        PR _deviceInst = _target GV ["DGM_deviceInstance", {}];
                PR _currentCount = METHOD(_deviceInst, "getGrenAmount", _grenClass);

                ["DGM_detachGrenEvent", [_target, _grenClass, _caller, _currentCount]] call CBA_fnc_globalEvent;
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

		        PR _deviceInst = _target GV ["DGM_deviceInstance", {}];
                PR _currentCount = METHOD(_deviceInst, "getGrenAmount", _grenClass);

                ["DGM_dropGrenEvent", [_target, _grenClass, remoteControlled _caller, _currentCount]] call CBA_fnc_globalEvent;
            },
            [_this],
            format["(%1)", IS_CONTROLLING_DRONE],
            3,
            _this
        ];
        MEMBER("addAction", _arg);
    };

    PUBLIC FUNCTION("array", "addAction") {
        params[["_type", "", [""]], ["_name", "", [""]], ["_code", {}, [{}]], ["_arguments", [], [[]]], ["_condition", "", [""]], ["_priority", 2, [0]], ["_itemClass", "", [""]]];

        if (MEMBER("actionsExists", [_type C _itemClass])) exitWith {
            MEMBER("modifyActions", _itemClass)
        };

        PR _drone = SELF_VAR("Drone");

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

		PR _drone = SELF_VAR("Drone");

        _drone removeAction _this;
        SELF_VAR("AllActions") - [_this];
    };

    PUBLIC FUNCTION("string", "removeGrenActions") {
		PR _drone = SELF_VAR("Drone");
        PR _grenActions = MEMBER("getGrenActions", _this);   

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
        MEMBER("IsMenuActive", _this);

        if (_this) then {
            MEMBER("LoadGrensMenu", nil);

            PR _this = [SELF_VAR("Drone"), _instance];
            ENSURE_SPAWN_ONCE_START
                params ["_target", "_menuInstance"];
                PR _inventoryDisplay = 602;
                waitUntil { 
                    uiSleep 0.1;
                    !(_target getVariable [SPREF("IsMenuActive"), false]) || 
                    ((_target distance player) > 3) || 
                    (!(isNull (findDisplay _inventoryDisplay))) ||
                    (IS_CONTROLLING_DRONE_CODE)
                };
                if (_target getVariable [SPREF("IsMenuActive"), false]) then {  
                    METHOD(_menuInstance, "SetMenuActive", false);
                };
            ENSURE_SPAWN_ONCE_END
        } else {
            DGM_currentGrenadesListCounts = nil;
        };
    };

    PUBLIC FUNCTION("any", "UpdateMenu") {
        MEMBER("SetMenuActive", SELF_VAR("IsMenuActive"));
    };

    PUBLIC FUNCTION("string", "grenadeAvailable") {
        private _drone = SELF_VAR("Drone");
	    private _deviceInst = _drone GV ["DGM_deviceInstance", {}];
        
        METHOD(_deviceInst, "grenadeAvailable", _this);
    };

    PUBLIC FUNCTION("string", "getGrenAmount") {
        private _drone = SELF_VAR("Drone");
	    private _deviceInst = _drone GV ["DGM_deviceInstance", {}];
        
        METHOD(_deviceInst, "getGrenAmount", _this);
    };

    PUBLIC FUNCTION("array", "actionsExists") {
        params[["_type", "", [""]], ["_itemClass", "", [""]]];

        if ((_itemClass == "") || (_type == "")) exitWith {false};

        PR _grenActions = SELF_VAR("Actions") get _itemClass;
        if (isNil "_grenActions") exitWith {false};
        
        if ((_grenActions getOrDefault [_type, -1]) == -1) exitWith {false};

        true
    };

    PUBLIC FUNCTION("string", "modifyActions") {
        private _itemClass = _this;
        private _itemName = ITEM_NAME(_this);

        private _drone = SELF_VAR("Drone");
        private _amount = MEMBER("getGrenAmount", _itemClass);
        private _actionsHash = SELF_VAR("Actions") get _itemClass;

        if (isNil "_actionsHash") exitWith {false};

        PR _itemAmount = _amount;

        _drone setUserActionText [_actionsHash getOrDefault ["DetachId", -1], TXT_DETACH];
        _drone setUserActionText [_actionsHash getOrDefault ["DropId", -1], TXT_DROP];

        
        _itemAmount = (MGVAR ["DGM_currentGrenadesListCounts", createHashMap]) get _itemClass;
        if !(isNil "_itemAmount") then {
            _drone setUserActionText [_actionsHash getOrDefault ["AttachId", -1], TXT_ATTACH];
        };

        true
    };

    PUBLIC FUNCTION("array", "addActionId") {
        params[["_itemClass", "", [""]], ["_name", "", [""]], ["_id", -1, [0]]];

        if ((_id == -1) || (_name == "")) EX;

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

    PUBLIC FUNCTION("any", "LoadGrensMenu") {
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


        if (count _playerGrens == 0) exitWith {
            SHOW_HINT LBL_DONT_HAVE_GRENS;
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

