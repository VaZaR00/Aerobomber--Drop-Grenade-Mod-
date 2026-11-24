#include "\a3\ui_f\hpp\definedikcodes.inc"
#include "defines.hpp"

#define DGM_CATEGORY DGM_STR_SETTINGS_CATEGORY

// ============================================================================
// CBA Settings
// ============================================================================

[
    "DGM_shoot_rockets",
    "CHECKBOX",
    [DGM_STR_SHOOT_ROCKETS, DGM_STR_DESC_SHOOT_ROCKETS],
    DGM_CATEGORY,
    DGM_DEF_SHOOT_ROCKETS,
    1
] call CBA_fnc_addSetting;

[
    "DGM_randomVelocity",
    "SLIDER",
    [DGM_STR_RANDOM_VELOCITY, DGM_STR_DESC_RANDOM_VELOCITY],
    DGM_CATEGORY,
    [0, 2, DGM_DEF_RANDOM_VELOCITY, 2],
    1
] call CBA_fnc_addSetting;

[
    "DGM_randomOffset",
    "SLIDER",
    [DGM_STR_RANDOM_OFFSET, DGM_STR_DESC_RANDOM_OFFSET],
    DGM_CATEGORY,
    [0, 1, DGM_DEF_RANDOM_OFFSET, 2],
    1
] call CBA_fnc_addSetting;

[
    "DGM_randomDropDelay",
    "SLIDER",
    [DGM_STR_RANDOM_DROP_DELAY, DGM_STR_DESC_RANDOM_DROP_DELAY],
    DGM_CATEGORY,
    [0, 1, DGM_DEF_RANDOM_DROP_DELAY, 2],
    1
] call CBA_fnc_addSetting;

[
    "DGM_actionRadius",
    "SLIDER",
    [DGM_STR_ACTION_RADIUS, DGM_STR_DESC_ACTION_RADIUS],
    DGM_CATEGORY,
    [1.5, 10, DGM_DEF_ACTION_RADIUS, 1],
    1
] call CBA_fnc_addSetting;

[
    "DGM_showDropHint",
    "CHECKBOX",
    [DGM_STR_SHOW_DROP_HINT, DGM_STR_DESC_SHOW_DROP_HINT],
    DGM_CATEGORY,
    DGM_DEF_SHOW_DROP_HINT,
    0
] call CBA_fnc_addSetting;


// ============================================================================
// CBA Keybinds
// ============================================================================

[
    DGM_CATEGORY,
    "DGM_dropGrenadeKey",
    [DGM_STR_KEY_DROP_GRENADE, DGM_STR_DESC_KEY_DROP_GRENADE],
    {call FUNC(dropGrenadeKeybind)},
    "",
    [DIK_G, [false, false, true]]
] call CBA_fnc_addKeybind;

[
    DGM_CATEGORY,
    "DGM_cycleChargeKey",
    [DGM_STR_KEY_CYCLE_CHARGE, DGM_STR_DESC_KEY_CYCLE_CHARGE],
    {call FUNC(cycleChargeKeybind)},
    "",
    [DIK_C, [false, false, true]]
] call CBA_fnc_addKeybind;

[
    DGM_CATEGORY,
    "DGM_cycleGrenadeKey",
    [DGM_STR_KEY_CYCLE_GRENADE, DGM_STR_DESC_KEY_CYCLE_GRENADE],
    {call FUNC(cycleGrenadeKeybind)},
    "",
    [DIK_B, [false, false, true]]
] call CBA_fnc_addKeybind;

[
    DGM_CATEGORY,
    "DGM_toggleMenuKey",
    [DGM_STR_KEY_TOGGLE_MENU, DGM_STR_DESC_KEY_TOGGLE_MENU],
    {call FUNC(toggleMenuKeybind)},
    "",
    [0, [false, false, false]]
] call CBA_fnc_addKeybind;
