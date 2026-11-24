#include "defines.hpp"

if (isNil "DGM_fnc_parseModuleAttributesForZen" && {fileExists FUNC_PATH(fn_parseModuleAttributesForZen.sqf)}) then {
    DGM_fnc_parseModuleAttributesForZen = compileScript [FUNC_PATH(fn_parseModuleAttributesForZen.sqf)];
};
if !(isNil "DGM_fnc_parseModuleAttributesForZen") then {
    call DGM_fnc_parseModuleAttributesForZen;
};
