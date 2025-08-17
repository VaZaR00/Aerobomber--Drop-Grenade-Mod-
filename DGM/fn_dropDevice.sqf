/*
	Name: DGM_fnc_dropDevice

	Example: 
		[this, 1, true, "rhs_VOG25"] call DGM_fnc_dropDevice;
*/

#include "includes\defines.h"

FILE_ONLY_SPAWN

sleep 0.1;

WAIT_THIS_SCRIPT

PR _obj = _this select 0;

if ((isNil "_obj") || {!(_obj isEqualType objNull) || {(_obj isEqualTo objNull)}}) exitWith {};

PR _deviceInstance = NEW(OO_DROP_DEVICE, _this);

_deviceInstance