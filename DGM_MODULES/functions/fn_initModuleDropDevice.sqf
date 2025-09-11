#include "defines.h"

#define LGVAR _logic GV 
#define BOOL(var, def) ((LGVAR [var, def]) isEqualTo 1)

private _logic = [_this,0,objNull,[objNull]] call BIS_fnc_param;
private _units = [_this,1,[],[[]]] call BIS_fnc_param;
private _activated = [_this,2,true,[true]] call BIS_fnc_param;

if !(_activated) exitWith {};
if (is3DEN) exitWith {};

[_logic] spawn {
	params["_logic"];

	private _syncedObj = (synchronizedObjects _logic)#0;

	if (isNil "_syncedObj") then {
		_syncedObj = objNull;
	};

	sleep 0.1;

	private _object = call compile (LGVAR ["Object", ""]);

	if ((isNil "_object") || {!(_object isEqualType objNull)}) then {
		_object = _syncedObj;
	};

	if ((isNil "_object") || {(_object isEqualTo objNull)}) exitWith {};

	if !(local _object) exitWith {};

	[
		_object,
		LGVAR ["slotNum", 1],
		LGVAR ["spawnWithGren", "HandGrenade"],
		LGVAR ["addedItems", ""],
		LGVAR ["removedItems", ""],
		BOOL("allowSetCharge", 0),
		BOOL("spawnTempGren", 1),
		BOOL("allowOnlyListed", 0),
		BOOL("removeChemlights", 1),
		BOOL("removeSmokes", 1)
	] call DGM_fnc_dropDevice;
};

