#include "includes\defines.h"

PR _expArr = [];
PR _ammoCfg = [];

PR _ammoCfgEnt = "true" configClasses (configFile >> "CfgAmmo");
PR _magCfgEnt = "true" configClasses (configFile >> "CfgMagazines");
{
	PR _elcfg = _x;
	PR _el = configName _elcfg;
	PR _elPar = [configFile >> "CfgMagazines" >> _el, true] call BIS_fnc_returnParents;
	if (count _elPar > 3) then {
		PR _el3 = _elPar select -3;
		if ((_el3 == "1Rnd_HE_Grenade_shell") || (_el3 == "HandGrenade")) then {
			PR _toArr = _elPar select 0;
			_expArr pushBack _toArr;
		};
	};
}forEach _magCfgEnt;

_ammoCfg = _ammoCfgEnt apply {configName _x};

_expArr append ["MiniGrenade", "1Rnd_HE_Grenade_shell", "HandGrenade"];	

MSVAR ["DGM_var_expArr", _expArr];
MSVAR ["DGM_var_ammoCfg", _ammoCfg];