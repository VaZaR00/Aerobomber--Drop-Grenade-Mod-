/*
	Name: DGM_fnc_setSlotsNumber
*/

#include "includes\defines.h"

params["_drone", "_num"];

PR _deviceInst = _drone GV ["DGM_deviceInstance", {}];

METHOD(_deviceInst, "setSlotsNumber", _num);