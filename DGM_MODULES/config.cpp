#include "includes\defines.h"
#include "includes\main.h"

class CfgPatches {
	class ADDON_NAME {
		name = "DGM Modules";
		author = "Vazar";
		requiredAddons[] = {
			"A3_Functions_F",
			"cba_common"
		};
		units[] = {};
		weapons[] = {};
        skipWhenMissingDependencies = 1;
	};
};

#include "includes\CfgFunctions.hpp"
#include "includes\CfgRemoteExec.hpp"
#include "includes\CfgModules.hpp"