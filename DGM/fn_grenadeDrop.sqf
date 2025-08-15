#include "includes\defines.h"

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

PR _deviceInstance = NEW(IOO_DROP_DEVICE, _this);

_deviceInstance