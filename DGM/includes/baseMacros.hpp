// Standalone base & utility macros for DGM (zero external library dependency beyond CBA_A3)

#ifndef STR
#define STR(s) #s
#endif

#ifndef DOUBLE
#define DOUBLE(a,b) a##b
#endif

#ifndef TRIPLE
#define TRIPLE(a,b,c) a##b##c
#endif

#ifndef QUAD
#define QUAD(a,b,c,d) a##b##c##d
#endif

#ifndef I
#define I ,
#endif

#ifndef SPREFX
#define SPREFX STR(PREFX)
#endif

#ifndef PREF_
#define PREF_ PREFX##_
#endif

#ifndef SPREF_
#define SPREF_ STR(PREF_)
#endif

#ifndef PREF
#define PREF(s) PREF_##s
#endif

#ifndef SPREF
#define SPREF(s) STR(PREF(s))
#endif

#ifndef PREF_FNC
#define PREF_FNC PREFX##_fnc_
#endif

#ifndef FUNC
#define FUNC(f) PREF_FNC##f
#endif

#ifndef SFUNC
#define SFUNC(f) STR(FUNC(f))
#endif

#ifndef SFUNC_NAME
#define SFUNC_NAME(name) (STR(PREF_FNC) + name)
#endif

#ifndef VAR_PREFIX
#define VAR_PREFIX (if (isNil "_ADDON_PREFX") then {SPREFX} else {_ADDON_PREFX})
#endif

#ifndef FUNC_PATH_JOIN
#define FUNC_PATH_JOIN(path) ADDON_PATH\##path
#endif

#ifndef FUNC_PATH
#define FUNC_PATH(path) STR(FUNC_PATH_JOIN(path))
#endif

#ifndef CALL_FUNC_XEH
#define CALL_FUNC_XEH(f) STR(call compileScript ['FUNC_PATH_JOIN(f)'])
#endif

#ifndef DO_FUNC_RECOMPILE
#define DO_FUNC_RECOMPILE recompile = 1;
#endif

#ifndef FUNC_PRE_START
#define FUNC_PRE_START preStart = 1;
#endif

#ifndef CFUNC
#define CFUNC(f) _cFuncs pushBack [STR(DOUBLE(_,f)), STR(FUNC(f))]; private DOUBLE(_,f)
#endif

#define FN_FUNC_CFG(name) class name {file = FUNC_PATH(TRIPLE(fn_,name,.sqf));DO_FUNC_RECOMPILE};
#define FN_FUNC_CFG_PRE(name) class name {file = FUNC_PATH(TRIPLE(fn_,name,.sqf));preInit = 1;DO_FUNC_RECOMPILE};
#define FN_FUNC_CFG_POST(name) class name {file = FUNC_PATH(TRIPLE(fn_,name,.sqf));postInit = 1;DO_FUNC_RECOMPILE};

#ifndef _NIL
#define _NIL(var) (if !(isNil STR(var)) then {var})
#endif

#ifndef IF_NIL
#define IF_NIL(v, d) (if (isNil STR(v)) then {d} else {v})
#endif

#ifndef NIL_DEF
#define NIL_DEF _NIL(_def)
#endif

#define PR private
#define GV getVariable
#define SV setVariable
#define MN missionNamespace
#define MGVAR missionNamespace getVariable
#define MSVAR missionNamespace setVariable

#define IS_OBJ(o) (!(o isEqualTo objNull) && {o isEqualType objNull})
#define IS_OBJNULL(o) (o isEqualTo objNull)
#define IS_STR(s) ((s isEqualType "") && {!(s isEqualTo "")})
#define IS_FUNC(f) ((f isEqualType {}) && {!(f isEqualTo {})})
#define IS_ARRAY(a) ((a isEqualType []) && {!(a isEqualTo [])})
#define IS_HASH(h) (h isEqualType createHashMap)
#define IS_INT(s) (s isEqualType 0)
#define IS_BOOL(s) (s isEqualType true)
#define IS_LOCAL(o) (IS_OBJ(o) && {local o})

#define STR_EMPTY(s) (s isEqualTo "")
#define ARR_EMPTY(a) (a isEqualTo [])
#define LWR(s) (toLower (s))
#define FOR_I(n) for "_i" from 0 to ((n) - 1) do
#define SPLIT_CHARACTERS ";,: "
#define OBJ_OWNER(o) (if ((owner (o)) == 0) then {2} else {owner (o)})
#define PLAYER_ (missionNamespace getVariable ["bis_fnc_moduleremotecontrol_unit", player])

#ifndef VARS_STR
#define VARS_STR call { \
    if !(_this isEqualType []) then {_this = ["", _this]}; \
    params ["_txt", ["_varstr", ""]]; \
    if (_varstr isEqualTo "") then {_varstr = _txt}; \
    private _ar = _varstr splitString (",;.     " + endl); \
    private _arvs = _ar apply { \
        private _val = call compile format ["if !(isNil '%1') then {%1}", _x]; \
        if (isNil "_val") then {""} else {format ["%1: %2", _x, _val]} \
    }; \
    _txt + "  :  " + (_arvs joinString "; ") \
}
#endif

#ifndef DLOG
#define DLOG call {diag_log text format ["[DLOG:%3] %2 :: %1", _this, serverTime, SPREFX]}
#endif

#define RLOG call {private _txt = text format ["[RLOG:%4] %3 :: %2 :: %1", _this, serverTime, __FILE_SHORT__, SPREFX]; hint _txt; diag_log _txt}
#define WARN DLOG
#define HINT hint
#define _HINT call {hint _this}
