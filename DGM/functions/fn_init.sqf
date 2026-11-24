#include "defines.hpp"

// Ensure magazine/ammo cache is populated in missionNamespace
call FUNC(getAllExp);

// Compile OOP classes on all machines
call FUNC(compileClasses);

DGM_inited = true;
