#include "defines.hpp"

/*
    Function: DGM_fnc_getAllExp

    Description:
        Scans CfgMagazines and CfgAmmo once per Arma 3 session and caches:
        - Base throwable/UGL explosive magazine list
        - CfgAmmo list & lowercase ammo -> magazine lookup HashMap
        - Lowercase magazine -> canonical magazine classname HashMap
        - Precomputed smoke and chemlight/flare exclusion sets
        Restores missionNamespace variables DGM_var_expArr and DGM_var_ammoCfg for backwards compatibility.
*/

private _cache = parsingNamespace getVariable "DGM_expCacheMap";

if (isNil "_cache" || {!(_cache isEqualType createHashMap)}) then {
    private _expArr = [];
    private _ammoCfgEnt = "true" configClasses (configFile >> "CfgAmmo");
    private _magCfgEnt = "true" configClasses (configFile >> "CfgMagazines");

    private _ammoCfg = _ammoCfgEnt apply {configName _x};
    private _canonicalMag = createHashMap;
    private _ammoToMag = createHashMap;
    private _smokeSet = createHashMap;
    private _chemlightSet = createHashMap;

    private _smokeTokens = ["smoke", "m18", "83", "m8h", "dm32", "nsp", "rdg"];

    {
        private _cfg = _x;
        private _magName = configName _cfg;
        private _lwrMag = toLower _magName;
        _canonicalMag set [_lwrMag, _magName];

        private _ammoName = getText (_cfg >> "ammo");
        private _lwrAmmo = toLower _ammoName;
        if (_lwrAmmo != "" && {!(_lwrAmmo in _ammoToMag)}) then {
            _ammoToMag set [_lwrAmmo, _magName];
        };

        // Walk inheritance chain natively (works in XEH_preStart with zero BIS_fnc dependency)
        private _isGrenOrShell = false;
        private _parent = _cfg;
        while {isClass _parent} do {
            private _pName = configName _parent;
            if (_pName == "HandGrenade" || {_pName == "1Rnd_HE_Grenade_shell"}) exitWith {
                _isGrenOrShell = true;
            };
            _parent = inheritsFrom _parent;
        };

        if (_isGrenOrShell) then {
            _expArr pushBack _magName;
        };

        // Precompute chemlight / handflare classification (case-insensitive)
        if (("hemlight" in _lwrMag) || {"handflare" in _lwrMag} || {"hemlight" in _lwrAmmo} || {"flare" in _lwrAmmo && {"flare" in _lwrMag}}) then {
            _chemlightSet set [_lwrMag, true];
        };

        // Precompute smoke classification (case-insensitive across mag name, ammo name, and short display name)
        private _shortNameLwr = toLower (getText (_cfg >> "displayNameShort"));
        private _isSmoke = ("moke" in _shortNameLwr) || {"дым" in _shortNameLwr} || {"дим" in _shortNameLwr};
        if !(_isSmoke) then {
            {
                if ((_x in _lwrMag) || {_x in _lwrAmmo}) exitWith {
                    _isSmoke = true;
                };
            } forEach _smokeTokens;
        };
        if (_isSmoke) then {
            _smokeSet set [_lwrMag, true];
        };
    } forEach _magCfgEnt;

    {
        if !(_x in _expArr) then {
            _expArr pushBack _x;
        };
    } forEach ["MiniGrenade", "1Rnd_HE_Grenade_shell", "HandGrenade"];

    _expArr = _expArr arrayIntersect _expArr;

    _cache = createHashMap;
    _cache set ["expArr", _expArr];
    _cache set ["ammoCfg", _ammoCfg];
    _cache set ["canonicalMag", _canonicalMag];
    _cache set ["ammoToMag", _ammoToMag];
    _cache set ["smokeSet", _smokeSet];
    _cache set ["chemlightSet", _chemlightSet];

    parsingNamespace setVariable ["DGM_expCacheMap", _cache];
};

private _expArr = +(_cache get "expArr");
private _ammoCfg = _cache get "ammoCfg";

missionNamespace setVariable ["DGM_var_expArr", _expArr];
missionNamespace setVariable ["DGM_var_ammoCfg", _ammoCfg];

[_expArr, _ammoCfg]
