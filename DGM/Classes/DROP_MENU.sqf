#include "..\includes\defines.h"

/*
    Класс: OO_DROP_MENU
*/

CLASS("OO_DROP_MENU") // IOO_DROP_MENU

    PUBLIC VARIABLE("object", "Drone");              // дрон
    PUBLIC VARIABLE("hashmap", "Actions");
    PRIVATE VARIABLE("hashmap", "AllActions");

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
		SELF_VAR("Drone") addAction
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
    };

    PUBLIC FUNCTION("string", "addActionDetach") {
		SELF_VAR("Drone") addAction
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
    };

    PUBLIC FUNCTION("string", "addActionDrop") {
		PR _id = SELF_VAR("Drone") addAction
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
        MEMBER("DeleteAttachedGren", nil);
        _id
    };

    PUBLIC FUNCTION("scalar", "removeAction") {
		PR _drone = SELF_VAR("Drone");

        _drone removeAction _this;
    };

    PUBLIC FUNCTION("string", "removeActions") {
		PR _drone = SELF_VAR("Drone");
	    PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];
        PR _grenInfo = METHOD(_deviceInst, "getGrenadeData", _this);   

        MEMBER("removeAction", _grenInfo get "DetachId");
        METHOD("removeAction", _grenInfo get "DropId");
    };

    PRIVATE FUNCTION()

ENDCLASS;