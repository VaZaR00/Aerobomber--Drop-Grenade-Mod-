
#define STR(s) #s
#define PR private
#define GV getVariable
#define SV setVariable
#define MN missionNamespace
#define MGVAR MN GV
#define MSVAR MN SV
#define LOG hint str 
#define RLOG call {_txt = format["%3 :: %2 : %1", _this, if (isServer) then {"SERVER"} else {clientOwner}, __FILE_SHORT__]; hint _txt; diag_log _txt};
#define MP_RLOG call {(format["%3 :: ID %1 : %2", if (isServer) then {"SERVER"} else {clientOwner}, _this, __FILE_SHORT__]) remoteExec ["diag_log", 0]; (format["ID %1 : %2", clientOwner, _this]) remoteExec ["hint", 0];};
#define NLOG ;
#define IFLOG call {if (MGVAR ["TEMP_DO_LOG", false]) then {hint str _this; diag_log str _this}};
#define DOLOG MSVAR ["TEMP_DO_LOG", true];
#define NOLOG MSVAR ["TEMP_DO_LOG", false];
#define CRTHSH createHashMap

#define GET_PLAYER_DRONE (vehicle (remoteControlled player))

// #define LOC  
#define LOC localize
#define DOUBLE(v1, v2) v1##v2
#define TRIPLE(v1, v2, v3) v1##v2##v3
#define SKIP continue
#define ONUL objNull
#define EW exitWith
#define EX EW {};
#define C , 
#define EQTYPE isEqualType
#define EQTO isEqualTo
#define ISNIL(v) isNil STR(v)
#define MAP(v) v = v apply 
#define IF_(c, t) if (c) then {t}
#define IF_ELSE(c, t, t1) if (c) then {t} else {t1}
#define IF_EX(c) if (c) exitWith {}
#define IF_EXW(c, t) if (c) exitWith {t}
#define IF_ELSE_EX(c, t, t1) if (c) exitWith {t} else {t1}
#define IF_NIL_EX(v) if (ISNIL(v)) EX;
#define IF_NIL(v, d) IF_ELSE(ISNIL(v), d, v)
#define NIL_(v) IF_NIL(v, nil)
#define SET_IF_NIL(v, d) IF_ELSE(ISNIL(v), v = d, v)
#define getDef getOrDefault
#define IS_HASH(h) (h isEqualType createHashMap)
#define IS_OBJ(o) (o isEqualType objNull)
#define IS_OBJNULL(o) (o isEqualTo objNull)
#define IS_OBJNULL_DEF(o) IF_ELSE(IS_OBJ(o), o, objNull)
#define IS_ARR(o) (o isEqualType [])
#define IS_STR(s) (s isEqualType "")
#define IS_BOOL(s) (s isEqualType true)
#define IS_CODE(s) (s isEqualType {})
#define IS_INT(s) (s isEqualType 0)
#define IS_REB(r) (r call REB_fnc_isReb)
#define IS_LOCAL(o) ((IS_OBJ(o) && {local o}) || isServer)
#define STR_EMPTY(s) (s isEqualTo "")
#define ARR_EMPTY(a) (count a == 0)
// #define REB_itemRebsClasses (keys REB_all_classes)
#define ARGS PR _args = 

#define ABSOLUTE_RANDOM_NUM (round (((random 2) * 100000) + (systemTimeUTC select -1)))

#define CLEAR_SYMBOLS(s) ((s) call {PR _s = toArray _this; PR _n = count _s; PR _r = []; PR _f = true; for "_i" from 0 to (_n - 1) do {PR _c = _s select _i; if (((_c >= 48) && (_c <= 57)) || ((_c >= 65) && (_c <= 90)) || ((_c >= 97) && (_c <= 122))) then {if (_f && (_c >= 48) && (_c <= 57)) then {} else {_r pushBack _c}; _f = false;}}; toString _r})
#define HASHVAL_(v) CLEAR_SYMBOLS(hashValue v)
#define UNQ_HASHVAL(v1, v2) (HASHVAL_(v1) + HASHVAL_(v2))
#define OBJ_HASHVAL(o) UNQ_HASHVAL(o, typeOf o)


// for handling scripts
#define THIS_FUNC_NAME ((__FILE_SHORT__ splitString "_") select -1)
#define SCR_HNDLR(s) DOUBLE(s,_scriptHandler)
#define SCR_HNDLR_UNQ(s) (format["%1_%2_%3", s, "scriptHandler", HASHVAL_(_this)])
#define SCR_HNDLR_VAR(s) (MGVAR [STR(SCR_HNDLR(s)), scriptNull])
#define SCR_HNDLR_VAR_UNQ(s) (MGVAR [SCR_HNDLR_UNQ(s), scriptNull])
#define SPAWN_F_ONCE(f) call (if (scriptDone SCR_HNDLR_VAR(f)) then {{SCR_HNDLR(f) = _this spawn f;}} else {{}});

#define ENSURE_SPAWN_ONCE_UNQ  \
    if !(scriptDone SCR_HNDLR_VAR_UNQ(THIS_FUNC_NAME)) EW {};  \
    MSVAR [SCR_HNDLR_UNQ(THIS_FUNC_NAME), _thisScript]; \

#define ENSURE_SPAWN_ONCE_UNQ_GLOBAL  \
    if !(scriptDone SCR_HNDLR_VAR_UNQ(THIS_FUNC_NAME)) EW {};  \
    MSVAR [SCR_HNDLR_UNQ(THIS_FUNC_NAME), _thisScript, true]; \

#define ENSURE_SPAWN_ONCE_START PR _codeForSpawnOnce = {
#define ENSURE_SPAWN_ONCE_END }; \
    PR _spawnOnceArgs = [_this, _codeForSpawnOnce]; \
    PR _codeHash = HASHVAL_(_spawnOnceArgs); \
    _spawnOnceArgs call ( \
        if (scriptDone (MGVAR [_codeHash, scriptNull])) then { \
            {PR _hndl = (_this select 0) spawn (_this select 1); MSVAR [_codeHash, _hndl]} \
        } else {{}} \
    ); \

#define SPAWN_NWAIT(c) PR _thndl = [] spawn c; waitUntil {scriptDone _thndl}; _thndl = nil;
#define SPAWNF_NWAIT(a, f) PR _thndl = a spawn f; waitUntil {scriptDone _thndl}; _thndl = nil;
#define WAIT_THIS_SCRIPT \
    waitUntil { scriptDone (missionNamespace getVariable ["REB_TEMP_HNDL_" + THIS_FUNC_NAME, scriptNull]) }; \
	missionNamespace setVariable ["REB_TEMP_HNDL_" + THIS_FUNC_NAME, _thisScript]; \

#define WAITVAR(v) waitUntil { !ISNIL(v) };
#define WAITSVAR(v) waitUntil { !isNil v };
#define WAITVAR_OR_EX_T(v, t) _thisScript spawn {sleep t; terminate _this}; WAITVAR(v)
#define WAITVAR_OR_EX(v) WAITVAR_OR_EX_T(v, 0.5)
#define ONLY_SPAWN(fnc) \
if (!canSuspend) EW { \
    _this spawn fnc; \
}; \

#define FILE_ONLY_SPAWN ONLY_SPAWN(QFUNC(THIS_FUNC_NAME))

// for server execuiton
#define EXEC_ON_SERVER_START PR _codeForServer = {
#define EXEC_ON_SERVER_END }; if (isServer) then {_this call _codeForServer} else {[[_this], _codeForServer] remoteExec ["REB_fnc_remoteCall", 2]};
#define EXEC_ON_SERVER_END_RESULT }; \
PR _serverExecResult = if (isServer) then { \
	_this call _codeForServer \
} else { \
    private _tempVarName = format ["REB_TEMP_remoteExec_result_%1", ABSOLUTE_RANDOM_NUM]; \
    [[_this, clientOwner, _tempVarName], _codeForServer] remoteExec ["REB_fnc_remoteCall", 2]; \
    WAITSVAR(_tempVarName); \
    MGVAR _tempVarName; \
}; \
_serverExecResult; \

#define EXEC_ON_SERVER_END_RESULT_VAR(var) EXEC_ON_SERVER_END_RESULT; var = _serverExecResult;

#define GET_SERVER_VAL \
    EXEC_ON_SERVER_START \

#define GSRES(var) \
    EXEC_ON_SERVER_END_RESULT_VAR(var) \

#define OBJ_OWNER(o) IF_ELSE(owner o == 0, 2, owner o)

// FOR OOP

#define BOOL(i) (IF_ELSE(IS_INT(i), i == 1, nil))
#define BOOL_TO_INT(b) (if (b) then {1} else {0})
#define SET_BOOL(b) (if (IS_BOOL(b)) then {b} else {0})
#define IS_OOP(s) (IS_CODE(s) && {IS_STR(METHOD(s, "classname", nil))})

