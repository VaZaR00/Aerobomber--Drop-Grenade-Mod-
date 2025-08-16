#include "..\includes\defines.h"

/*
    Класс: OO_DROP_MENU

    Description:
        All methods and class handling is local
*/


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
            [_instance]
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

    PUBLIC FUNCTION("array", "addAction") {
        ["addAction"] RLOG;
        params[["_type", "", [""]], ["_name", "", [""]], ["_code", {}, [{}]], ["_arguments", [], [[]]], ["_condition", "", [""]], ["_itemClass", "", [""]]];

        ARGS [_type, _itemClass];
        if (MEMBER("actionsExists", _args)) exitWith {
            MEMBER("modifyAction", _itemClass)
        };

        PR _drone = SELF_VAR("Drone");
        ["addAction ADD", SELF_VAR("Drone"), _type, _name, _itemClass, SELF_VAR("AllActions")] RLOG;

        if (isNil "_drone") EX;

		PR _id = _drone addAction
        [
            _name,
            _code,
            _arguments,
            1.5,
            true,
            false,
            "",
            format[
                "(%1) && {%2}",
                format[
                    if (_type == "MenuAction") then {"!(%1)"} else {"%1"}, 
                    "_target getVariable ['DGM_IsMenuActive', false]"
                ],
                format[
                    if (_type == "DropId") then {"%1"} else {"!(%1)"}, 
                    "(vehicle (remoteControlled player)) isEqualTo _target"
                ],
                "_caller in (_target getVariable ['MENU_ALLOWED_USER_VAR', []])"
            ],
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

        if (MEMBER("actionsExists", ["DetachId" C _this])) then {
            MEMBER("modifyAction", _this)
        } else {
            MEMBER("removeAction", _grenActions getOrDefault ["DetachId" C -1]);
            _grenActions set ["DetachId", -1];
            SELF_VAR("Actions") set [_this, _grenActions];
        };

        if (MEMBER("actionsExists", ["DropId" C _this])) then {
            MEMBER("modifyAction", _this)
        } else {
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
                params ["_drone", "_menuInstance"];
                PR _inventoryDisplay = 602;
                waitUntil { 
                    uiSleep 0.1;
                    !(_drone getVariable ["DGM_IsMenuActive", false]) || 
                    ((_drone distance player) > 3) || 
                    (!(isNull (findDisplay _inventoryDisplay)))
                };
                if (_drone getVariable ["DGM_IsMenuActive", false]) then {  
                    METHOD(_menuInstance, "SetMenuActive", false);
                };
                ["Force close menu"] RLOG
            ENSURE_SPAWN_ONCE_END
        };
    };

    PUBLIC FUNCTION("any", "UpdateMenu") {
        ["UpdateMenu"] RLOG
        MEMBER("SetMenuActive", SELF_VAR("IsMenuActive"));
    };

    PRIVATE FUNCTION("array", "actionsExists") {
        params[["_name", "", [""]], ["_itemClass", "", [""]]];

        if ((_itemClass == "") || (_name == "")) exitWith {false};


        PR _grenActions = SELF_VAR("Actions") get _itemClass;
        if (isNil "_grenActions") exitWith {false};
        ["actionsExists", _name, _itemClass, !((_grenActions getOrDefault [_name, -1]) == -1)] RLOG;
        if ((_grenActions getOrDefault [_name, -1]) == -1) exitWith {false};

        true
    };

    PRIVATE FUNCTION("string", "modifyAction") {
        private _itemClass = _this;
        private _itemName = ITEM_NAME(_this);

        private _drone = SELF_VAR("Drone");
	    private _deviceInst = _drone GV ["DGM_deviceInstance", {}];
        private _amount = METHOD(_deviceInst, "getGrenAmount", _itemClass);
        private _actionsHash = SELF_VAR("Actions") get _itemClass;

        ["modifyAction", _this, _amount, !((isNil "_actionsHash") || (isNil "_amount") || {_amount <= 0})] RLOG

        if ((isNil "_actionsHash") || (isNil "_amount") || {_amount <= 0}) exitWith {
            MEMBER("removeGrenActions", _itemClass);
            false
        };

        PR _itemAmount = _amount;

        _drone setUserActionText [_actionsHash getOrDefault ["DetachId", -1], TXT_DETACH];
        _drone setUserActionText [_actionsHash getOrDefault ["DropId", -1], TXT_DROP];
        ["SET modifyAction", _actionsHash getOrDefault ["DetachId", -1], _actionsHash getOrDefault ["DropId", -1], TXT_DETACH, TXT_DROP] RLOG

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
                PR _actions = SELF_VAR("Actions");
                PR _grenHash = _actions getOrDefault [_itemClass, createHashMap];
                _grenHash set [_name, _id];
                _actions set [_itemClass, _grenHash];
                MEMBER("Actions", _actions);
            };
        };

        SELF_VAR("AllActions") pushBack _id;
    };

    PRIVATE FUNCTION("any", "LoadGrensMenu") {
	    PR _drone = SELF_VAR("Drone");
	    PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
	    PR _actions = SELF_VAR("Actions");
	    PR _currentMenuGrenades = keys _actions;
        PR _playerGrens = (itemsWithMagazines player) arrayIntersect INSTANCE_VAR(_deviceInst, "AllowedGrenList");

        if (isNil "_playerGrens") exitWith {};

        ["LoadGrensMenu", _playerGrens] RLOG

        if (count _playerGrens == 0) exitWith {
            hint LBL_DONT_HAVE_GRENS;
        };

        {
            MEMBER("addActionAttach", _x);
        } forEach _playerGrens;

        (_currentMenuGrenades select {!(_x in _playerGrens)}) apply {
            PR _grenActions = MEMBER("getGrenActions", _x); 
            MEMBER("removeAction", _grenActions getOrDefault ["AttachId" C -1]);
        };
        _playerGrens
    };

ENDCLASS;