#include "generic.h"
#include "oop.h"

#define PREFX DGM
#define PREF_FNC PREFX##_fnc_
#define FUNC(fnc) PREF_FNC##fnc
#define QFUNC(f) (MGVAR [STR(PREF_FNC) + f, {}])

#define D_GET_VAR(var, def) (_drone getVariable [var, def])
#define D_SET_VAR(var, val) _drone setVariable [var, val, true]
#define CLR_DUPS(arr) arr = arr arrayIntersect arr;

#define ITEM_NAME(item) (configFile >> "CfgMagazines" >> item >> "displayName")
#define ITEM_DATA(item)\
    PR _itemConfig = configFile >> "CfgMagazines" >> item; \
    PR _itemName = getText (_itemConfig >> "displayName"); \
    PR _itemModel = getText (_itemConfig >> "model"); \
    PR _itemAmmo = getText (_itemConfig >> "ammo"); 

    
// localization
#define LBL_ATTACH_GREN "Attach %1: %2"
#define LBL_DETACH_GREN "Detach %1: %2"
#define LBL_DROP_GREN "Drop %1: %2"
#define LBL_DONT_HAVE_GRENS "You don't have grenades"
#define LBL_GRENS_MENU "Attach grenades menu: %1 slots"
#define LBL_CLOSE_MENU "Close menu"
#define LBL_DROPED_GREN "%1 Dropped"

#define TXT_ATTACH format[TXT_CLR(LBL_ATTACH_GREN, GREEN), _itemName, _itemAmount]
#define TXT_DETACH format[TXT_CLR(LBL_DETACH_GREN, RED), _itemName, _itemAmount]
#define TXT_DROP format[TXT_CLR(LBL_DROP_GREN, RED), _itemName, _itemAmount]
#define TXT_DROPED format[LBL_DROPED_GREN, _itemName]

#define RED "#ff0000"
#define RED_b "#b01313"
#define GREEN "#00ff00"
#define BLUE "#0390fc"

#define TXT_CLR(txt, clr) "<t color='" + clr + "'>" + txt + "</t>"