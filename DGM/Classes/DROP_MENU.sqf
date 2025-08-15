#include "..\includes\defines.h"

/*
    Класс: OO_DROP_MENU
*/

CLASS("OO_DROP_MENU") // IOO_DROP_MENU

    PUBLIC VARIABLE("object", "Drone");              // дрон
    PUBLIC VARIABLE("hashmap", "Actions"); // grenclass : [attach, detach, drop]
    PUBLIC VARIABLE("scalar", "MainAction"); // Menu action
    PUBLIC VARIABLE("scalar", "CloseAction"); // Close Menu action
    PRIVATE VARIABLE("array", "AllActions");

    // Конструктор
    PUBLIC FUNCTION("array", "constructor") {
        params [
            "_drone"
        ];

        MEMBER("Drone", _drone);

        MEMBER("Actions", createHashMap);

		_drone setVariable ["DGM_menuInstance", _instance];
    };

    // Деконструктор
    PUBLIC FUNCTION("array", "deconstructor") {
		{
            MEMBER("removeAction", _x)
        } forEach SELF_VAR("AllActions");

		_drone setVariable ["DGM_menuInstance", nil];
    };

    PUBLIC FUNCTION("string", "addActionAttach") {
        // Attach Action
        private _drone = SELF_VAR("Drone");
		_drone addAction
        [
            format["Attach", _this],
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                _arguments params ["_grenClass"];
                ["DGM_attachGrenEvent", [_target, _grenClass, _caller]] call CBA_fnc_globalEvent;
            },
            [_this],
            1.5,
            true,
            false,
            "",
            "true",
            2
        ];
        MEMBER("addActionId", [_id C "AttachId"]);
        _id
    };

    PUBLIC FUNCTION("string", "addActionDetach") {
        // Detach Action
        private _drone = SELF_VAR("Drone");
		_drone addAction
        [
            format["Detach", _this],
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                _arguments params ["_grenClass"];
                ["DGM_detachGrenEvent", [_target, _grenClass, _caller]] call CBA_fnc_globalEvent;
            },
            [_this],
            1.5,
            true,
            false,
            "",
            "true",
            2
        ];
        MEMBER("addActionId", [_id C "DetachId"]);
        _id
    };

    PUBLIC FUNCTION("string", "addActionDrop") {
        // Drop Action
        private _drone = SELF_VAR("Drone");
		PR _id = _drone addAction
        [
            format["Drop", _this],
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                _arguments params ["_grenClass"];
                ["DGM_dropGrenEvent", [_target, _grenClass, _caller]] call CBA_fnc_globalEvent;
            },
            [_this],
            1.5,
            true,
            false,
            "",
            "true",
            2
        ];
        MEMBER("addActionId", [_id C "DropId"]);
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

    PRIVATE FUNCTION("array", "addActionId") {
        params[["_id", -1, [0]], ["_name", "", [""]]];

        if ((_id == -1) || (_name == "")) EX;

        switch (_name) do {
            case "MainAction": {
                MEMBER("MainAction", _id);
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

ENDCLASS;