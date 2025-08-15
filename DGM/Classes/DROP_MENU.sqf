#include "..\includes\defines.h"

/*
    Класс: OO_DROP_MENU

    Description:
        All methods and class handling is local
*/

#define MENU_ACTIVE_VAR "DGM_IsMenuActive"


CLASS("OO_DROP_MENU") // IOO_DROP_MENU

    PUBLIC VARIABLE("object", "Drone");              // дрон
    PUBLIC VARIABLE("hashmap", "Actions"); // (hashmap) grenclass : (hashmap) [attach: id, detach: id, drop: id]
    PUBLIC VARIABLE("scalar", "MenuAction"); // Menu action
    PUBLIC VARIABLE("scalar", "CloseAction"); // Close Menu action
    PRIVATE VARIABLE("array", "AllActions");
    PRIVATE VARIABLE("bool", "IsMenuActive");


    PUBLIC FUNCTION("array", "constructor") {
        params [
            "_drone"
        ];

        MEMBER("Drone", _drone);
        MEMBER("Actions", createHashMap);

        MEMBER("addActionMenu", nil);
        MEMBER("addActionClose", nil);

		_drone setVariable ["DGM_menuInstance", _instance];
    };

    PUBLIC FUNCTION("array", "deconstructor") {
		{
            MEMBER("removeAction", _x)
        } forEach SELF_VAR("AllActions");

		_drone setVariable ["DGM_menuInstance", nil];
    };

    PUBLIC FUNCTION("any", "addActionMenu") {
        // Menu Action
        PR _arg = [
            "MenuAction",
            format["Menu"],
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                _arguments params ["_grenClass", "_menuInstance"];
                METHOD(_menuInstance, "SetMenuActive", true);
            },
            [_instance]
        ];
        MEMBER("addAction", _arg);
    };

    PUBLIC FUNCTION("any", "addActionClose") {
        // Close Menu Action
        PR _arg = [
            "CloseAction",
            format["Close Menu"],
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                _arguments params ["_grenClass", "_menuInstance"];
                METHOD(_menuInstance, "SetMenuActive", false);
            },
            [_instance]
        ];
        MEMBER("addAction", _arg);
    };

    // for add action funcs argument is grenade class
    
    // Attach Action
    // AttachId
    PUBLIC FUNCTION("string", "addActionAttach") {
        PR _itemAmount = 1;
        PR _itemName = ITEM_NAME(_this);
        PR _arg = [
            "AttachId",
            TXT_ATTACH,
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                _arguments params ["_grenClass"];
                ["DGM_attachGrenEvent", [_target, _grenClass, _caller]] call CBA_fnc_globalEvent;
            },
            [_this],
            _this
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
                ["DGM_dropGrenEvent", [_target, _grenClass, _caller]] call CBA_fnc_globalEvent;
            },
            [_this],
            _this
        ];
        MEMBER("addAction", _arg);
    };

    PUBLIC FUNCTION("scalar", "addAction") {
        params[["_type", "", [""]], ["_name", "", [""]], ["_code", {}, [{}]], ["_args", [], [[]]], ["_class", "", [""]]];

        ARGS [_type, _class];
        if (MEMBER("actionsExists", _args)) exitWith {
            MEMBER("modifyAction", _args)
        };

        PR _drone = SELF_VAR("Drone");
		PR _id = _drone addAction
        [
            _name,
            _code,
            _args,
            1.5,
            true,
            false,
            "",
            format[
                "(%1)", 
                if (_type != "MenuAction") then {
                    "_target getVariable [MENU_ACTIVE_VAR, false]"
                } else {
                    "!(_target getVariable [MENU_ACTIVE_VAR, false])"
                },
                "_caller in (_target getVariable [MENU_ALLOWED_USER_VAR, []])"
            ],
            2
        ];
        MEMBER("addActionId", [_id C _type]);
        _id
    };

    PUBLIC FUNCTION("scalar", "removeAction") {
		PR _drone = SELF_VAR("Drone");

        _drone removeAction _this;
    };

    PUBLIC FUNCTION("string", "removeGrenActions") {
		PR _drone = SELF_VAR("Drone");
        PR _grenActions = MEMBER("getGrenActions", _this);   

        MEMBER("removeAction", _grenActions get "DetachId");
        METHOD("removeAction", _grenActions get "DropId");
    };

    PUBLIC FUNCTION("string", "getGrenActions") {
        SELF_VAR("Actions") getOrDefault [_this, createHashMap];
    };

    PRIVATE FUNCTION("array", "actionsExists") {
        params[["_name", "", [""]], ["_class", "", [""]]];

        if ((_class == "") || (_name == "")) exitWith {false};

        if (isNil {SELF_VAR("Actions") get _class}) exitWith {false};

        true
    };

    PRIVATE FUNCTION("string", "modifyAction") {
        private _class = _this;
        private _itemName = ITEM_NAME(_this);

        private _drone = SELF_VAR("Drone");
	    private _deviceInst = _drone GV ["DGM_deviceInstance", {}];
        private _amount = METHOD(_deviceInst, "getGrenAmount", _class);
        private _actionsHash = SELF_VAR("Actions") get _class;

        // if (_amount <= 0) exitWith {false};

        PR _itemAmount = _amount;
        PR _itemName = ITEM_NAME(_class);

        _drone setUserActionText [_actionsHash get "DetachId", TXT_DETACH];
        _drone setUserActionText [_actionsHash get "DropId", TXT_DROP];

        true
    };

    PRIVATE FUNCTION("array", "addActionId") {
        params[["_id", -1, [0]], ["_name", "", [""]]];

        if ((_id == -1) || (_name == "")) EX;

        switch (_name) do {
            case "MenuAction": {
                MEMBER("MenuAction", _id);
            };
            case "CloseAction": {
                MEMBER("CloseAction", _id);
            };
            default {
                PR _actions = SELF_VAR("Actions");
                PR _grenHash = _actions getOrDefault [_name, createHashMap];
                _grenHash set ["_name", _id];
            };
        };

        SELF_VAR("AllActions") pushBack _id;
    };

    PRIVATE FUNCTION("bool", "SetMenuActive") {
        MEMBER("IsMenuActive", _this);
        SELF_VAR("Drone") setVariable [MENU_ACTIVE_VAR, _this];
        if (_this) then {
            MEMBER("LoadGrensMenu", nil);
        };
    };

    PRIVATE FUNCTION("any", "LoadGrensMenu") {
	    PR _drone = SELF_VAR("Drone");
	    PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
        PR _playerGrens = (itemsWithMagazines player) arrayIntersect INSTANCE_VAR(_deviceInst, "AllowedGrenList");

        if (count _playerGrens == 0) exitWith {
            hint LOC LBL_DONT_HAVE_GRENS;
        };

        {
            MEMBER("addActionAttach", _x);
        } forEach _playerGrens;
    };

ENDCLASS;