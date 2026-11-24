#include "includes\defines.hpp"

class CfgPatches {
    class PREFX {
        name = "DGM Modules";
        author = "Vazar";
        requiredAddons[] = {
            "cba_common",
            "A3_Functions_F",
#ifdef FINAL
            "DGM"
#endif
        };
        units[] = {
            "DGM_Device"
        };
        weapons[] = {};
        skipWhenMissingDependencies = 1;
    };
};

#ifdef FINAL
#include "includes\CfgFunctions.hpp"
#include "includes\ExtendedEventHandlers.hpp"
#endif

#include "includes\CfgRemoteExec.hpp"
#include "includes\configIncludes.hpp"
