#include "defines.hpp"

if (!hasInterface) exitWith {};

if (!isNil "zen_custom_modules_fnc_register") then {
    call DGM_fnc_registerZenModules;
} else {
    ["CBA_loadingScreenDone", {
        if (!isNil "zen_custom_modules_fnc_register") then {
            call DGM_fnc_registerZenModules;
        };
    }] call CBA_fnc_addEventHandler;
};
