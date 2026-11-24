#include "defines.hpp"

if !(hasInterface) exitWith {false};

private _drone = call FUNC(getControlledDrone);
if (!IS_DROP_DEVICE(_drone) || {!(alive _drone)}) exitWith {false};

private _grenList = DGM_GVAR(_drone, "droneGrenList", createHashMap);
if (count _grenList == 0) exitWith {
    SHOW_HINT(DGM_STR_NO_GRENS_LOADED);
    true
};

private _selectedClass = _drone getVariable ["DGM_selectedGrenClass", ""];
if (_selectedClass isEqualTo "" || {!(_selectedClass in _grenList)}) then {
    _selectedClass = (keys _grenList) param [0, ""];
    _drone setVariable ["DGM_selectedGrenClass", _selectedClass];
};
if (_selectedClass isEqualTo "") exitWith {false};

private _charge = DGM_GVAR(_drone, "dropCharge", 1);
["DGM_requestDropGren", [_drone, _selectedClass, _charge, PLAYER_]] call CBA_fnc_serverEvent;

true
