/*
	Name: DGM_fnc_dropDevice
*/

#include "includes\defines.h"

FILE_ONLY_SPAWN

params[
	"_drone",
	["_slotNum", D_GET_VAR("Amount_of_slots_t", 1)],
	["_spawnWithGren", D_GET_VAR("spawn_with_gren", true)],
	["_addedItems", D_GET_VAR("list_of_grens", "")],
	["_allowOnlyListed", D_GET_VAR("allow_only_list", false)],
	["_removeListed", D_GET_VAR("remove_list_grens", false)],
	["_removeChemlights", D_GET_VAR("remove_chemlights", true)],
	["_removeSmokes", D_GET_VAR("remove_smokes", true)]
];

WAIT_THIS_SCRIPT

PR _obj = _this select 0;

sleep 0.1; // wait for mission fully initialized

// Ensure the function is only executed where the object is local on mission init
if !(local _obj) exitWith {
	// if mission time is less than 1 second, we assume its init and all clients are executing it including server
	if (time > 1) then {
		_this remoteExec ["DGM_fnc_dropDevice", OBJ_OWNER(_obj)];
	}; 
};

PR _deviceInstance = NEW(IOO_DROP_DEVICE, _this);

_deviceInstance