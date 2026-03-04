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

	sleep 0.1;	

	private _syncedObjs = (synchronizedObjects _logic);

	private _mainObject = missionNamespace getVariable [(LGVAR ["Object", ""]), objNull];

	if !(isNil "_mainObject") then {
		if (_mainObject isEqualType objNull) then {
			if !(_mainObject isEqualTo objNull) then {
				_syncedObjs pushBackUnique _mainObject;
			};
		};
	};
	
	{
		private _obj = _x;

		if (isNil "_obj") then {continue};
		if !(_obj isEqualType objNull) then {continue};
		if (isNull _obj) then {continue};
		if !(local _obj) then {continue};

		[
			_obj,
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
	} forEach _syncedObjs;
};

