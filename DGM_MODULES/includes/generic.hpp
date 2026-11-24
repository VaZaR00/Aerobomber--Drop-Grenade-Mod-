#ifndef STR
#define STR(s) #s
#endif
#ifndef DOUBLE
#define DOUBLE(a,b) a##b
#endif
#ifndef TRIPLE
#define TRIPLE(a,b,c) a##b##c
#endif
#ifndef I
#define I ,
#endif

#define SPREFX STR(PREFX)

#ifndef DO_FUNC_RECOMPILE
#define DO_FUNC_RECOMPILE recompile = 1;
#endif

#ifndef FUNC_PRE_START
#define FUNC_PRE_START preStart = 1;
#endif

#define FUNC_PATH_JOIN(path) ADDON_PATH\##path
#define FUNC_PATH(path) STR(FUNC_PATH_JOIN(path))
#define CALL_FUNC_XEH(f) STR(call compileScript ['FUNC_PATH_JOIN(f)'])

#define PREF_ PREFX##_
#define SPREF_ STR(PREF_)
#define PREF_FNC PREFX##_fnc_
#define FUNC(f) PREF_FNC##f
#define SFUNC(f) STR(FUNC(f))

#define FN_FUNC_CFG(name) class name {file = FUNC_PATH(TRIPLE(fn_,name,.sqf));DO_FUNC_RECOMPILE};
#define FN_FUNC_CFG_PRE(name) class name {file = FUNC_PATH(TRIPLE(fn_,name,.sqf));preInit = 1;DO_FUNC_RECOMPILE};
#define FN_FUNC_CFG_POST(name) class name {file = FUNC_PATH(TRIPLE(fn_,name,.sqf));postInit = 1;DO_FUNC_RECOMPILE};

#define PR private
#define GV getVariable
#define SV setVariable
#define MN missionNamespace
#define MGVAR missionNamespace getVariable
#define MSVAR missionNamespace setVariable

#define IS_OBJ(o) (!(o isEqualTo objNull) && {o isEqualType objNull})
#define IS_STR(s) ((s isEqualType "") && {!(s isEqualTo "")})
#define SPLIT_CHARACTERS ";,: "

#define DLOG call {diag_log text format ["[DLOG:%3] %2 :: %1", _this, serverTime, SPREFX]}
#define WARN DLOG
