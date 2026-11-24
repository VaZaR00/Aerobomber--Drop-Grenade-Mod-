/*
    Class: DropMenu

    Description:
        Purely client-local UI action menu controller attached to a drone object.
        Zero network variables or remote writes — synchronizes exclusively from DropDevice state.
*/

PRIVATE LOCAL SINGLETON_CLASS(DropMenu)

    SET_SELF_VAR("_drone");
    SET_VARS_PREFIX("_menu");

    PRIVATE LOCAL FIELD ["_isMenuActive", false];
    PRIVATE LOCAL FIELD ["_menuActionId", -1];
    PRIVATE LOCAL FIELD ["_closeActionId", -1];
    PRIVATE LOCAL FIELD ["_setChargeActionId", -1];
    PRIVATE LOCAL FIELD ["_attachActions", createHashMap];
    PRIVATE LOCAL FIELD ["_detachActions", createHashMap];
    PRIVATE LOCAL FIELD ["_dropActions", createHashMap];
    PRIVATE LOCAL FIELD ["_allActions", []];
    PRIVATE LOCAL FIELD ["_watchHandle", scriptNull];

    // ========================================================================
    // Lifecycle
    // ========================================================================

    PRIVATE LOCAL METHOD("Init") {
        if (!hasInterface || {!IS_OBJ(_drone)}) exitWith {false};

        // Prevent duplicate action creation if Init is called on an already-initialized menu
        if (_menuActionId >= 0) exitWith {
            ["syncFromDevice", []] CALL_SELF;
            true
        };

        SAVE_VARS
        LOCAL_SETTER

        _isMenuActive = false;
        _attachActions = createHashMap;
        _detachActions = createHashMap;
        _dropActions = createHashMap;
        _allActions = [];

        private _radius = 10;

        // 1. Open Menu Action
        _menuActionId = _drone addAction [
            TXT_MENU,
            {
                params ["_target"];
                ["setMenuActive", [true, true]] CALL_OBJCLASS("DropMenu", _target);
            },
            [],
            DGM_PRIORITY_MENU,
            true,
            false,
            "",
            "[_target] call DGM_fnc_menuActionCondition",
            _radius
        ];
        _allActions pushBack _menuActionId;

        // 2. Close Menu Action
        _closeActionId = _drone addAction [
            TXT_CLOSE_MENU,
            {
                params ["_target"];
                ["setMenuActive", [false, false]] CALL_OBJCLASS("DropMenu", _target);
            },
            [],
            DGM_PRIORITY_CLOSE,
            true,
            false,
            "",
            "[_target] call DGM_fnc_menuCloseActionCondition",
            _radius
        ];
        _allActions pushBack _closeActionId;

        // 3. Set Charge Action (visibility controlled dynamically via DGM_canSetCharge in condition)
        private _curCharge = DGM_GVAR(_drone, "dropCharge", 1);
        _setChargeActionId = _drone addAction [
            TXT_SET_CHARGE(_curCharge),
            {
                params ["_target"];
                ["DGM_requestChangeCharge", [_target]] call CBA_fnc_serverEvent;
            },
            [],
            DGM_PRIORITY_CHARGE,
            true,
            false,
            "",
            "[_target] call DGM_fnc_setChargeActionCondition",
            _radius
        ];
        _allActions pushBack _setChargeActionId;

        // Populate Drop/Detach actions for any grenades already attached on the drone (initial spawn or JIP)
        ["syncFromDevice", []] CALL_SELF;

        true
    };

    PUBLIC LOCAL METHOD("Deinit") {
        if (!isNull _watchHandle && {!scriptDone _watchHandle}) then {
            terminate _watchHandle;
        };
        _watchHandle = scriptNull;

        if (IS_OBJ(_drone)) then {
            {
                if (_x >= 0) then {
                    _drone removeAction _x;
                };
            } forEach _allActions;
        };

        _allActions = [];
        _attachActions = createHashMap;
        _detachActions = createHashMap;
        _dropActions = createHashMap;
        _menuActionId = -1;
        _closeActionId = -1;
        _setChargeActionId = -1;
        _isMenuActive = false;

        SAVE_VARS
        LOCAL_SETTER
        true
    };

    // ========================================================================
    // Menu Open / Close & Auto-Close Watcher
    // ========================================================================

    PUBLIC LOCAL METHOD("setMenuActive") {
        params [["_active", false], ["_showEmptyHint", false]];
        if (!hasInterface || {!IS_OBJ(_drone)}) exitWith {false};

        if (_active) then {
            private _playerGrens = ["refreshAttachActions", []] CALL_SELF;
            private _slotsOccupied = DGM_GVAR(_drone, "slotsOccupied", 0);
            private _canSetCharge = DGM_GVAR(_drone, "canSetCharge", false);

            // Only block & warn when player has 0 compatible grenades AND drone itself has nothing to detach/configure
            if ((count _playerGrens == 0) && {_slotsOccupied <= 0} && {!_canSetCharge}) exitWith {
                if (_showEmptyHint) then {
                    SHOW_HINT(DGM_STR_DONT_HAVE_GRENS);
                };
                _isMenuActive = false;
                SET_SELFVAR(_isMenuActive);
                false
            };

            _isMenuActive = true;
            SET_SELFVAR(_isMenuActive);

            if (isNull _watchHandle || {scriptDone _watchHandle}) then {
                _watchHandle = ["watchMenuConditions", []] SPAWN_SELF;
                SET_SELFVAR(_watchHandle);
            };
        } else {
            _isMenuActive = false;
            SET_SELFVAR(_isMenuActive);
            ["clearAttachActions", []] CALL_SELF;
        };

        _isMenuActive
    };

    PRIVATE LOCAL METHOD("watchMenuConditions") {
        private _invDisplayIdd = 602;
        waitUntil {
            uiSleep 0.1;
            !IS_OBJ(_drone) ||
            {!(alive _drone)} ||
            {!(MENU_GVAR(_drone, "isMenuActive", false))} ||
            {(_drone distance PLAYER_) > (GET_ACTION_RADIUS + 0.5)} ||
            {!isNull (findDisplay _invDisplayIdd)} ||
            {call FUNC(isControllingAnyDrone)}
        };

        if (IS_OBJ(_drone) && {MENU_GVAR(_drone, "isMenuActive", false)}) then {
            ["setMenuActive", [false, false]] CALL_SELF;
        };
    };

    // ========================================================================
    // Synchronization from DropDevice State
    // ========================================================================

    PUBLIC LOCAL METHOD("syncFromDevice") {
        if (!hasInterface || {!IS_OBJ(_drone)}) exitWith {};

        private _droneGrenList = DGM_GVAR(_drone, "droneGrenList", createHashMap);
        private _radius = 10;

        // 1. Add or update Drop & Detach actions for all grenades currently on the drone
        {
            private _grenClass = _x;
            private _amt = if (_y isEqualType createHashMap) then {_y getOrDefault ["Amount", 0]} else {_y};

            if (_amt > 0) then {
                private _itemName = ITEM_NAME(_grenClass);
                if (_itemName isEqualTo "") then {_itemName = _grenClass};

                // Drop action
                private _dropLbl = TXT_DROP(_itemName, _amt);
                private _dropId = _dropActions getOrDefault [_grenClass, -1];
                if (_dropId >= 0) then {
                    _drone setUserActionText [_dropId, _dropLbl];
                } else {
                    _dropId = _drone addAction [
                        _dropLbl,
                        {
                            params ["_target", "", "", "_arguments"];
                            _arguments params ["_grenClass"];
                            private _charge = DGM_GVAR(_target, "dropCharge", 1);
                            ["DGM_requestDropGren", [_target, _grenClass, _charge, PLAYER_]] call CBA_fnc_serverEvent;
                        },
                        [_grenClass],
                        DGM_PRIORITY_DROP,
                        true,
                        false,
                        "",
                        "[_target] call DGM_fnc_dropActionCondition",
                        _radius
                    ];
                    _dropActions set [_grenClass, _dropId];
                    _allActions pushBack _dropId;
                };

                // Detach action
                private _detachLbl = TXT_DETACH(_itemName, _amt);
                private _detachId = _detachActions getOrDefault [_grenClass, -1];
                if (_detachId >= 0) then {
                    _drone setUserActionText [_detachId, _detachLbl];
                } else {
                    _detachId = _drone addAction [
                        _detachLbl,
                        {
                            params ["_target", "", "", "_arguments"];
                            _arguments params ["_grenClass"];
                            ["DGM_requestDetachGren", [_target, _grenClass, 1, PLAYER_]] call CBA_fnc_serverEvent;
                        },
                        [_grenClass],
                        DGM_PRIORITY_DETACH,
                        true,
                        false,
                        "",
                        "[_target] call DGM_fnc_detachActionCondition",
                        _radius
                    ];
                    _detachActions set [_grenClass, _detachId];
                    _allActions pushBack _detachId;
                };
            };
        } forEach _droneGrenList;

        // 2. Remove stale Drop actions for grenades that reached 0
        {
            private _grenClass = _x;
            private _rawAmt = _droneGrenList getOrDefault [_grenClass, 0];
            private _amt = if (_rawAmt isEqualType createHashMap) then {_rawAmt getOrDefault ["Amount", 0]} else {_rawAmt};
            if (_amt <= 0) then {
                private _actId = _dropActions getOrDefault [_grenClass, -1];
                if (_actId >= 0) then {
                    _drone removeAction _actId;
                    _allActions = _allActions - [_actId];
                };
                _dropActions deleteAt _grenClass;
            };
        } forEach (+(keys _dropActions));

        // 3. Remove stale Detach actions for grenades that reached 0
        {
            private _grenClass = _x;
            private _rawAmt = _droneGrenList getOrDefault [_grenClass, 0];
            private _amt = if (_rawAmt isEqualType createHashMap) then {_rawAmt getOrDefault ["Amount", 0]} else {_rawAmt};
            if (_amt <= 0) then {
                private _actId = _detachActions getOrDefault [_grenClass, -1];
                if (_actId >= 0) then {
                    _drone removeAction _actId;
                    _allActions = _allActions - [_actId];
                };
                _detachActions deleteAt _grenClass;
            };
        } forEach (+(keys _detachActions));

        // 4. Keep selected keybind grenade valid
        private _selectedGren = _drone getVariable ["DGM_selectedGrenClass", ""];
        if (_selectedGren == "" || {!(_selectedGren in _droneGrenList)}) then {
            private _availKeys = keys _droneGrenList;
            _drone setVariable ["DGM_selectedGrenClass", _availKeys param [0, ""]];
        };

        // 5. Update Charge label
        ["updateChargeLabel", []] CALL_SELF;

        // 6. If menu is currently open on this client, refresh Attach actions from player inventory
        if (_isMenuActive) then {
            ["refreshAttachActions", []] CALL_SELF;
        };

        SET_SELFVAR(_dropActions);
        SET_SELFVAR(_detachActions);
        SET_SELFVAR(_allActions);
    };

    PUBLIC LOCAL METHOD("updateChargeLabel") {
        if (!hasInterface || {!IS_OBJ(_drone)}) exitWith {};
        if (_setChargeActionId >= 0) then {
            private _curCharge = DGM_GVAR(_drone, "dropCharge", 1);
            _drone setUserActionText [_setChargeActionId, TXT_SET_CHARGE(_curCharge)];
        };
    };

    // ========================================================================
    // Player Inventory Attach Actions
    // ========================================================================

    PUBLIC LOCAL METHOD("refreshAttachActions") {
        if (!hasInterface || {!IS_OBJ(_drone)}) exitWith {createHashMap};

        private _plr = PLAYER_;
        if !(IS_OBJ(_plr)) exitWith {createHashMap};

        private _allowedList = DGM_GVAR(_drone, "allowedGrenList", []);
        private _allowedMap = createHashMapFromArray (_allowedList apply {[toLower _x, _x]});

        // Count compatible magazines strictly inside uniform/vest/backpack containers (not loaded in weapon UGLs)
        private _playerMags = itemsWithMagazines _plr;
        private _playerGrens = createHashMap;
        {
            private _lwr = toLower _x;
            if (_lwr in _allowedMap) then {
                private _canon = _allowedMap get _lwr;
                _playerGrens set [_canon, (_playerGrens getOrDefault [_canon, 0]) + 1];
            };
        } forEach _playerMags;

        private _radius = 10;

        // Add or update Attach actions for items currently in player's inventory
        {
            private _grenClass = _x;
            private _playerCount = _y;
            private _itemName = ITEM_NAME(_grenClass);
            if (_itemName isEqualTo "") then {_itemName = _grenClass};

            private _attachLbl = TXT_ATTACH(_itemName, _playerCount);
            private _attachId = _attachActions getOrDefault [_grenClass, -1];

            if (_attachId >= 0) then {
                _drone setUserActionText [_attachId, _attachLbl];
            } else {
                _attachId = _drone addAction [
                    _attachLbl,
                    {
                        params ["_target", "", "", "_arguments"];
                        _arguments params ["_grenClass"];
                        private _plr = PLAYER_;
                        if !(IS_OBJ(_plr)) exitWith {};

                        // Verify item is in container inventory (prevents UGL loaded-round duplication)
                        private _hasInContainers = ({(toLower _x) isEqualTo (toLower _grenClass)} count (itemsWithMagazines _plr)) > 0;
                        if !(_hasInContainers) exitWith {
                            SHOW_HINT(DGM_STR_DONT_HAVE_THIS_GREN);
                            ["refreshAttachActions", []] CALL_OBJCLASS("DropMenu", _target);
                        };

                        if ((DGM_GVAR(_target, "slotsOccupied", 0)) >= (DGM_GVAR(_target, "maxSlotNum", 1))) exitWith {
                            SHOW_HINT(DGM_STR_CANT_ADD_MORE_GREN);
                        };

                        // Remove immediately on client to prevent click-spam; server refunds if slot was taken concurrently
                        _plr removeItem _grenClass;
                        ["refreshAttachActions", []] CALL_OBJCLASS("DropMenu", _target);
                        ["DGM_requestAttachGren", [_target, _grenClass, 1, _plr]] call CBA_fnc_serverEvent;
                    },
                    [_grenClass],
                    DGM_PRIORITY_ATTACH,
                    true,
                    false,
                    "",
                    "[_target] call DGM_fnc_attachActionCondition",
                    _radius
                ];
                _attachActions set [_grenClass, _attachId];
                _allActions pushBack _attachId;
            };
        } forEach _playerGrens;

        // Remove Attach actions for any grenades the player no longer has in inventory
        {
            private _grenClass = _x;
            if !(_grenClass in _playerGrens) then {
                private _actId = _attachActions getOrDefault [_grenClass, -1];
                if (_actId >= 0) then {
                    _drone removeAction _actId;
                    _allActions = _allActions - [_actId];
                };
                _attachActions deleteAt _grenClass;
            };
        } forEach (+(keys _attachActions));

        SET_SELFVAR(_attachActions);
        SET_SELFVAR(_allActions);

        _playerGrens
    };

    PRIVATE LOCAL METHOD("clearAttachActions") {
        if (IS_OBJ(_drone)) then {
            {
                if (_y >= 0) then {
                    _drone removeAction _y;
                    _allActions = _allActions - [_y];
                };
            } forEach _attachActions;
        };
        _attachActions = createHashMap;
        SET_SELFVAR(_attachActions);
        SET_SELFVAR(_allActions);
    };

CLASS_END
