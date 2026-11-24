#include "includes\defines.hpp"

class CfgPatches {
    class PREFX {
        name = "Drone Grenade Mod";
        author = "Vazar";
        requiredAddons[] = {
            "cba_common",
            "A3_Functions_F"
        };
        units[] = {};
        weapons[] = {};
        skipWhenMissingDependencies = 1;
    };
};

// #include "includes\cfgFunctions.hpp"
#include "includes\cfgRemoteExec.hpp"
#include "includes\configIncludes.hpp"
#include "includes\ExtendedEventHandlers.hpp"
