#include "generic.h"
#include "oop.h"

// #define MP_RLOG ;
// #define RLOG ;

#define PREFX DGM

#define UNQ_TEMP_VAR(v1, v2) (format["%1_%2", STR(PREFX), UNQ_HASHVAL(v1, v2)])

#define CURR_SLOTS "SlotsOccupied"
#define VAR_CURR_SLOTS QPREF(SlotsOccupied)
#define MAX_SLOTS "MaxSlotNum"
#define VAR_MAX_SLOTS QPREF(MaxSlotNum)

#define D_GET_VAR(var, def) (_drone getVariable [var, def])
#define D_SET_VAR(var, val) _drone setVariable [var, val, true]
#define DGVAR _drone getVariable
#define DSVAR _drone setVariable
#define CLR_DUPS(arr) arr = arr arrayIntersect arr;

#define ITEM_NAME(item) (getText (configFile >> "CfgMagazines" >> item >> "displayName"))
#define ITEM_DATA(item)\
    PR _itemConfig = configFile >> "CfgMagazines" >> item; \
    PR _itemName = getText (_itemConfig >> "displayName"); \
    PR _itemModel = getText (_itemConfig >> "model"); \
    PR _itemAmmo = getText (_itemConfig >> "ammo"); 

    
// localization
#define SHOW_HINT hint

#define LOC  

#define LBL_ATTACH_GREN (LOC "Attach %1: %2")
#define LBL_DETACH_GREN (LOC "Detach %1: %2")
#define LBL_DROP_GREN (LOC "Drop %1: %2")
#define LBL_DONT_HAVE_GRENS (LOC "You don't have grenades")
#define LBL_GRENS_MENU (LOC "Attach grenades menu: %1 slots")
#define LBL_CLOSE_MENU (LOC "Close menu")
#define LBL_MENU (LOC "Drop device menu")
#define LBL_DROPED_GREN (LOC "%1 Dropped")
#define LBL_SLOTS_NOT_ENOUGH (LOC "Slots number can't be less than 1!")
#define LBL_CANT_ADD_MORE_GREN (LOC "Can't add more grenades")

#define TXT_ATTACH format[TXT_CLR(LBL_ATTACH_GREN, GREEN), _itemName, _itemAmount]
#define TXT_DETACH format[TXT_CLR(LBL_DETACH_GREN, RED), _itemName, _itemAmount]
#define TXT_DROP format[TXT_CLR(LBL_DROP_GREN, RED), _itemName, _itemAmount]
#define TXT_DROPED format[LBL_DROPED_GREN, _itemName]
#define TXT_MENU format[TXT_CLR(LBL_MENU, BLUE)]
#define TXT_CLOSE_MENU format[TXT_CLR(LBL_CLOSE_MENU, RED_b)]

#define RED "#ff0000"
#define RED_b "#b01313"
#define GREEN "#00ff00"
#define BLUE "#0390fc"

#define TXT_CLR(txt, clr) "<t color='" + clr + "'>" + txt + "</t>"