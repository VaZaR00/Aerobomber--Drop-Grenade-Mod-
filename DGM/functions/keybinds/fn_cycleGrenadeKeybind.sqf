#include "defines.hpp"

if !(hasInterface) exitWith {false};

private _drone = call FUNC(getControlledDrone);
if (!IS_DROP_DEVICE(_drone) || {!(alive _drone)}) exitWith {false};

private _grenList = DGM_GVAR(_drone, "droneGrenList", createHashMap);
private _availClasses = keys _grenList;
if (_availClasses isEqualTo []) exitWith {
    SHOW_HINT(DGM_STR_NO_GRENS_LOADED);
    true
};

_availClasses sort true;

private _curSelected = _drone getVariable ["DGM_selectedGrenClass", ""];
private _curIdx = _availClasses find _curSelected;
private _nextIdx = if (_curIdx < 0) then {0} else {(_curIdx + 1) mod (count _availClasses)};
private _nextClass = _availClasses select _nextIdx;

_drone setVariable ["DGM_selectedGrenClass", _nextClass];

private _rawAmt = _grenList getOrDefault [_nextClass, 0];
private _amt = if (_rawAmt isEqualType createHashMap) then {_rawAmt getOrDefault ["Amount", 0]} else {_rawAmt};
private _itemName = ITEM_NAME(_nextClass);
if (_itemName isEqualTo "") then {_itemName = _nextClass};

private _msg = format [DGM_STR_SELECTED_GREN, _itemName, _amt];
SHOW_HINT(_msg);
true
