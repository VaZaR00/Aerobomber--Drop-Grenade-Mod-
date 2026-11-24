// -- Settings defaults --
#define DGM_DEF_SHOOT_ROCKETS true
#define DGM_DEF_RANDOM_VELOCITY 0.15
#define DGM_DEF_RANDOM_OFFSET 0.05
#define DGM_DEF_RANDOM_DROP_DELAY 0.05
#define DGM_DEF_ACTION_RADIUS 3
#define DGM_DEF_SHOW_DROP_HINT true

// -- Action priorities --
#define DGM_PRIORITY_MENU 5
#define DGM_PRIORITY_CLOSE 5
#define DGM_PRIORITY_CHARGE 4.2
#define DGM_PRIORITY_DETACH 4
#define DGM_PRIORITY_DROP 3
#define DGM_PRIORITY_ATTACH 2

// -- Hot-path direct object variable readers (matches OOP field names on _drone) --
#define DGM_GVAR(obj, var, def) ((obj) getVariable ["DGM_" + (var) I def])
#define DGM_SVAR(obj, var, val) ((obj) setVariable ["DGM_" + (var) I val])
#define DGM_SVARG(obj, var, val, pub) ((obj) setVariable ["DGM_" + (var) I val I pub])

#define MENU_GVAR(obj, var, def) ((obj) getVariable ["DGM_menu_" + (var) I def])
#define MENU_SVAR(obj, var, val) ((obj) setVariable ["DGM_menu_" + (var) I val])

#define IS_DROP_DEVICE(obj) (IS_OBJ(obj) && {DGM_GVAR(obj, "isDropDevice", false)})
#define GET_ACTION_RADIUS (missionNamespace getVariable ["DGM_actionRadius", DGM_DEF_ACTION_RADIUS])

// -- Magazine config helpers --
#define ITEM_NAME(item) (getText (configFile >> "CfgMagazines" >> (item) >> "displayName"))
#define ITEM_DATA(item) \
    private _itemConfig = configFile >> "CfgMagazines" >> (item); \
    private _itemName = getText (_itemConfig >> "displayName"); \
    private _itemModel = getText (_itemConfig >> "model"); \
    private _itemAmmo = getText (_itemConfig >> "ammo");

// -- Colored text formatting --
#define CLR_RED "#ff0000"
#define CLR_RED_DARK "#b01313"
#define CLR_GREEN "#00ff00"
#define CLR_BLUE "#0390fc"
#define CLR_CYAN "#03b0c1"

#define TXT_CLR(txt, clr) ("<t color='" + (clr) + "'>" + (txt) + "</t>")

#define TXT_ATTACH(name, amt) format [TXT_CLR(DGM_STR_ATTACH_GREN, CLR_GREEN), name, amt]
#define TXT_DETACH(name, amt) format [TXT_CLR(DGM_STR_DETACH_GREN, CLR_RED), name, amt]
#define TXT_DROP(name, amt) format [TXT_CLR(DGM_STR_DROP_GREN, CLR_RED), name, amt]
#define TXT_DROPPED(name) format [DGM_STR_DROPPED_GREN, name]
#define TXT_MENU TXT_CLR(DGM_STR_MENU, CLR_BLUE)
#define TXT_CLOSE_MENU TXT_CLR(DGM_STR_CLOSE_MENU, CLR_RED_DARK)
#define TXT_SET_CHARGE(chg) format [TXT_CLR(DGM_STR_SET_CHARGE, CLR_CYAN), chg]

#define SHOW_HINT(txt) if (hasInterface) then {hint (txt)}
#define SHOW_DROP_HINT(txt) if (hasInterface && {missionNamespace getVariable ["DGM_showDropHint", DGM_DEF_SHOW_DROP_HINT]}) then {hint (txt)}

_ADDON_PREFX = SPREFX;
