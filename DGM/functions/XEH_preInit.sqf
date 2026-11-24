#include "defines.hpp"

#ifndef ADDON
call FUNC(XEH_preStart);
#else
if ((fileExists "OOP_DEV") && {fileExists "scripts\DGM\functions\XEH_prep.sqf"}) then {
    call compileScript ["scripts\DGM\functions\XEH_prep.sqf"];
    call FUNC(getAllExp);
} else {
    if (fileExists FUNC_PATH(XEH_prep.sqf)) then {
        call compileScript [FUNC_PATH(XEH_prep.sqf)];
    } else {
        call FUNC(XEH_preStart);
    };
};
#endif

call FUNC(initSettings);

if (is3DEN) exitWith {};

call FUNC(restoreAllCachedClasses);
call FUNC(initCBAEvents);
call FUNC(init);
