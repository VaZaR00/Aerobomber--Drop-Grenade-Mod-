#include "defines.hpp"

if (is3DEN) exitWith {};

["DGM_initModuleDropDevice", {
    _this call DGM_fnc_initModuleDropDevice
}] call CBA_fnc_addEventHandler;
