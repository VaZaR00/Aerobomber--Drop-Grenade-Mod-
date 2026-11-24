#include "defines.hpp"

#ifndef ADDON
call FUNC(XEH_prep);
#else
if ((fileExists "OOP_DEV") && {fileExists "scripts\DGM\functions\XEH_prep.sqf"}) then {
    call compileScript ["scripts\DGM\functions\XEH_prep.sqf"];
} else {
    if (fileExists FUNC_PATH(XEH_prep.sqf)) then {
        call compileScript [FUNC_PATH(XEH_prep.sqf)];
    } else {
        call FUNC(XEH_prep);
    };
};
#endif

call FUNC(getAllExp);
