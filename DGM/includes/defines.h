#include "generic.h"
#include "oop.h"

#define PREFX DGM 
#define FUNC(fnc) PREFX##_fnc_##fnc


#define D_GET_VAR(var, def) (_drone getVariable [var, def])
#define D_SET_VAR(var, val) _drone setVariable [var, val, true]
#define CLR_DUPS(arr) arr = arr arrayIntersect arr;