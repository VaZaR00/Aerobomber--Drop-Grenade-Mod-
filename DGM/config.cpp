#include "includes\main.h"

class CfgPatches {
	class PREFX {
		name = "Aerobomber";
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

#include "CfgFunctions.hpp"
#include "CfgRemoteExec.hpp"