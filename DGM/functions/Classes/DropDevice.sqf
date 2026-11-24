/*
    Class: DropDevice

    Description:
        Server-authoritative backend controller attached directly onto a drone object.
        Manages grenade slots, allowed item lists, decorative 3D grenade attachment,
        drop charge state, ordnance spawning, and automatic teardown on death/disassembly.
*/

PUBLIC GLOBAL SINGLETON_CLASS(DropDevice)

    SET_SELF_VAR("_drone");
    SET_VARS_PREFIX("");

    // Synced state on _drone (hot-path readable via DGM_GVAR(_drone, "<field>", def))
    PUBLIC  GLOBAL FIELD ["_isDropDevice", false];
    PUBLIC  GLOBAL FIELD ["_maxSlotNum", 1];
    PUBLIC  GLOBAL FIELD ["_slotsOccupied", 0];
    PUBLIC  GLOBAL FIELD ["_droneGrenList", createHashMap];
    PUBLIC  GLOBAL FIELD ["_allowedGrenList", []];
    PUBLIC  GLOBAL FIELD ["_canSetCharge", false];
    PUBLIC  GLOBAL FIELD ["_dropCharge", 1];
    PRIVATE GLOBAL FIELD ["_spawnTempGren", true];
    PRIVATE GLOBAL FIELD ["_tempAttachedGren", objNull];
    PRIVATE GLOBAL FIELD ["_tempAttachedGrenClass", ""];
    PRIVATE GLOBAL FIELD ["_zOffset", -0.45];
    PRIVATE GLOBAL FIELD ["_tempAttachGrenOffset", -0.2];

    // Server / local internal state (never broadcast over network)
    PRIVATE LOCAL FIELD ["_tempDropGren", objNull];
    PRIVATE LOCAL FIELD ["_addedItems", []];
    PRIVATE LOCAL FIELD ["_removedItems", []];
    PRIVATE LOCAL FIELD ["_customList", []];
    PRIVATE LOCAL FIELD ["_allowOnlyListed", false];
    PRIVATE LOCAL FIELD ["_removeChemlights", true];
    PRIVATE LOCAL FIELD ["_removeSmokes", true];
    PRIVATE LOCAL FIELD ["_killedEhId", -1];
    PRIVATE LOCAL FIELD ["_deletedEhId", -1];
    PRIVATE LOCAL FIELD ["_menuJipId", ""];

    // ========================================================================
    // Lifecycle
    // ========================================================================

    PRIVATE SERVER METHOD("Init") {
        if (!isServer || {!IS_OBJ(_drone)}) exitWith {false};
        if (_isDropDevice) exitWith {true};

        params [
            ["_slotNumArg", _drone getVariable ["Amount_of_slots_t", 1]],
            ["_spawnWithGrenArg", _drone getVariable ["spawn_with_gren", "HandGrenade"]],
            ["_addedItemsArg", _drone getVariable ["list_of_grens", ""]],
            ["_removedItemsArg", _drone getVariable ["removedItems", ""]],
            ["_allowSetChargeArg", _drone getVariable ["allowSetCharge", false]],
            ["_spawnTempGrenArg", _drone getVariable ["spawn_temp_gren", true]],
            ["_allowOnlyListedArg", _drone getVariable ["allow_only_list", false]],
            ["_removeChemlightsArg", _drone getVariable ["remove_chemlights", true]],
            ["_removeSmokesArg", _drone getVariable ["remove_smokes", true]]
        ];

        SAVE_VARS
        GLOBAL_SETTER
        SAVE_VAR_LOCAL(_tempDropGren);
        SAVE_VAR_LOCAL(_addedItems);
        SAVE_VAR_LOCAL(_removedItems);
        SAVE_VAR_LOCAL(_customList);
        SAVE_VAR_LOCAL(_allowOnlyListed);
        SAVE_VAR_LOCAL(_removeChemlights);
        SAVE_VAR_LOCAL(_removeSmokes);
        SAVE_VAR_LOCAL(_killedEhId);
        SAVE_VAR_LOCAL(_deletedEhId);
        SAVE_VAR_LOCAL(_menuJipId);

        _maxSlotNum = (_slotNumArg max 1);
        _slotsOccupied = 0;
        _droneGrenList = createHashMap;
        _canSetCharge = _allowSetChargeArg isEqualTo true || {_allowSetChargeArg isEqualTo 1};
        _dropCharge = 1;
        _spawnTempGren = _spawnTempGrenArg isEqualTo true || {_spawnTempGrenArg isEqualTo 1};
        _allowOnlyListed = _allowOnlyListedArg isEqualTo true || {_allowOnlyListedArg isEqualTo 1};
        _removeChemlights = _removeChemlightsArg isEqualTo true || {_removeChemlightsArg isEqualTo 1};
        _removeSmokes = _removeSmokesArg isEqualTo true || {_removeSmokesArg isEqualTo 1};

        private _rawCustom = if (_spawnWithGrenArg isEqualType []) then {_spawnWithGrenArg} else {_spawnWithGrenArg splitString SPLIT_CHARACTERS};
        private _rawAdded = if (_addedItemsArg isEqualType []) then {_addedItemsArg} else {_addedItemsArg splitString SPLIT_CHARACTERS};
        private _rawRemoved = if (_removedItemsArg isEqualType []) then {_removedItemsArg} else {_removedItemsArg splitString SPLIT_CHARACTERS};

        _customList = (_rawCustom apply {[_x] call FUNC(resolveItemMagazine)}) select {_x != ""};
        _addedItems = (_rawAdded apply {[_x] call FUNC(resolveItemMagazine)}) select {_x != ""};
        _removedItems = (_rawRemoved apply {[_x] call FUNC(resolveItemMagazine)}) select {_x != ""};

        private _initialGren = _customList param [0, ""];

        ["defineAttachParams", []] CALL_SELF;
        ["defineAllowedGrens", [_customList, _addedItems, _removedItems, _allowOnlyListed, _removeChemlights, _removeSmokes]] CALL_SELF;

        // Pre-populate initial grenades synchronously before publishing menu JIP event
        if (_initialGren != "" && {isClass (configFile >> "CfgMagazines" >> _initialGren)}) then {
            _droneGrenList set [_initialGren, _maxSlotNum];
            _slotsOccupied = _maxSlotNum;
            if (_spawnTempGren) then {
                ["spawnAttachedGren", [_initialGren]] CALL_SELF;
            };
        };

        // Cleanup EHs on server: handles destruction AND UAV backpack disassembly / Zeus deletion
        _killedEhId = _drone addEventHandler ["Killed", {
            params ["_unit"];
            [_unit] call FUNC(removeDropDevice);
        }];

        _deletedEhId = _drone addEventHandler ["Deleted", {
            params ["_entity"];
            private _tempGren = DGM_GVAR(_entity, "tempAttachedGren", objNull);
            if (!isNull _tempGren) then {
                deleteVehicle _tempGren;
            };
        }];

        _isDropDevice = true;
        SET_SELFVARG(_isDropDevice);
        SET_SELFVARG(_droneGrenList);
        SET_SELFVARG(_slotsOccupied);
        SET_SELFVARG(_maxSlotNum);
        SET_SELFVARG(_allowedGrenList);
        SET_SELFVARG(_canSetCharge);
        SET_SELFVARG(_dropCharge);

        // Single drone-bound JIP event so all current & JIP clients initialize DropMenu cleanly
        _menuJipId = ["DGM_initDropMenu", [_drone], _drone] call CBA_fnc_globalEventJIP;

        true
    };

    PUBLIC SERVER METHOD("Deinit") {
        if (!isServer) exitWith {false};

        if (IS_OBJ(_drone)) then {
            if (_killedEhId >= 0) then {
                _drone removeEventHandler ["Killed", _killedEhId];
                _killedEhId = -1;
            };
            if (_deletedEhId >= 0) then {
                _drone removeEventHandler ["Deleted", _deletedEhId];
                _deletedEhId = -1;
            };
        };

        ["deleteAttachedGren", []] CALL_SELF;

        if (_menuJipId != "" && {!isNil "CBA_fnc_removeGlobalEventJIP"}) then {
            [_menuJipId] call CBA_fnc_removeGlobalEventJIP;
            _menuJipId = "";
        };

        _isDropDevice = false;
        SET_SELFVARG(_isDropDevice);

        ["DGM_removeDropMenu", [_drone]] call CBA_fnc_globalEvent;
        true
    };

    // ========================================================================
    // Configuration & Allowed Grenades
    // ========================================================================

    PRIVATE SERVER METHOD("defineAttachParams") {
        private _drType = toLower (typeOf _drone);
        private _offsets = switch (true) do {
            case ("uav_01" in _drType): {[-0.12, -0.3]};
            case ("mavik" in _drType): {[-0.075, -0.3]};
            case ("uav_vampire" in _drType): {[-0.69, -0.8]};
            default {[-0.2, -0.45]};
        };

        _tempAttachGrenOffset = _offsets select 0;
        _zOffset = _offsets select 1;
        SET_SELFVARG(_tempAttachGrenOffset);
        SET_SELFVARG(_zOffset);
    };

    PUBLIC SERVER METHOD("defineAllowedGrens") {
        params [
            ["_pCustomList", _customList],
            ["_pAddedItems", _addedItems],
            ["_pRemovedItems", _removedItems],
            ["_pAllowOnlyListed", _allowOnlyListed],
            ["_pRemoveChemlights", _removeChemlights],
            ["_pRemoveSmokes", _removeSmokes]
        ];

        private _cache = parsingNamespace getVariable "DGM_expCacheMap";
        if (isNil "_cache" || {!(_cache isEqualType createHashMap)}) then {
            call FUNC(getAllExp);
            _cache = parsingNamespace getVariable "DGM_expCacheMap";
        };
        if (isNil "_cache") exitWith {[]};

        private _grenList = [];

        if (_pAllowOnlyListed) then {
            _grenList append _pCustomList;
            _grenList append _pAddedItems;
        } else {
            private _baseExp = +(_cache get "expArr");
            private _chemlightSet = _cache get "chemlightSet";
            private _smokeSet = _cache get "smokeSet";

            _grenList = _baseExp select {
                private _lwr = toLower _x;
                (!_pRemoveChemlights || {!(_lwr in _chemlightSet)}) &&
                {!_pRemoveSmokes || {!(_lwr in _smokeSet)}}
            };

            // Explicit custom & added items override generic smoke/chemlight filters
            _grenList append _pCustomList;
            _grenList append _pAddedItems;
        };

        // Explicit blacklist always wins
        if (_pRemovedItems isNotEqualTo []) then {
            private _remLwrMap = createHashMapFromArray (_pRemovedItems apply {[toLower _x, true]});
            _grenList = _grenList select {!((toLower _x) in _remLwrMap)};
        };

        // Case-insensitive deduplication preserving canonical config case
        private _seen = createHashMap;
        private _uniqueList = [];
        {
            private _canon = [_x] call FUNC(resolveItemMagazine);
            private _lwr = toLower _canon;
            if (_lwr != "" && {!(_lwr in _seen)}) then {
                _seen set [_lwr, true];
                _uniqueList pushBack _canon;
            };
        } forEach _grenList;

        _allowedGrenList = _uniqueList;
        SET_SELFVARG(_allowedGrenList);

        _allowedGrenList
    };

    // ========================================================================
    // Server-Authoritative Grenade Inventory Mutations
    // ========================================================================

    PUBLIC SERVER METHOD("addGrenade") {
        if (!isServer) exitWith {0};
        params [["_grenClass", ""], ["_amount", 1]];
        if (_grenClass isEqualTo "" || {_amount <= 0}) exitWith {0};

        private _canonClass = [_grenClass] call FUNC(resolveItemMagazine);
        private _freeSlots = (_maxSlotNum - _slotsOccupied) max 0;
        if (_freeSlots <= 0) exitWith {0};

        private _toAdd = _amount min _freeSlots;
        private _curAmt = _droneGrenList getOrDefault [_canonClass, 0];
        if (_curAmt isEqualType createHashMap) then {
            _curAmt = _curAmt getOrDefault ["Amount", 0];
        };

        _droneGrenList set [_canonClass, _curAmt + _toAdd];
        _slotsOccupied = _slotsOccupied + _toAdd;

        SET_SELFVARG(_droneGrenList);
        SET_SELFVARG(_slotsOccupied);

        if (_spawnTempGren && {isNull _tempAttachedGren}) then {
            ["spawnAttachedGren", [_canonClass]] CALL_SELF;
        };

        ["DGM_syncMenuState", [_drone, _droneGrenList, _slotsOccupied]] call CBA_fnc_globalEvent;
        _toAdd
    };

    PUBLIC SERVER METHOD("removeGrenade") {
        if (!isServer) exitWith {0};
        params [["_grenClass", ""], ["_amount", 1]];
        if (_grenClass isEqualTo "" || {_amount <= 0}) exitWith {0};

        // Match exact key in _droneGrenList case-insensitively
        private _matchedKey = _grenClass;
        if !(_matchedKey in _droneGrenList) then {
            private _targetLwr = toLower _grenClass;
            {
                if ((toLower _x) isEqualTo _targetLwr) exitWith {_matchedKey = _x};
            } forEach _droneGrenList;
        };

        private _curAmt = _droneGrenList getOrDefault [_matchedKey, 0];
        if (_curAmt isEqualType createHashMap) then {
            _curAmt = _curAmt getOrDefault ["Amount", 0];
        };
        if (_curAmt <= 0) exitWith {0};

        private _toRemove = _amount min _curAmt;
        private _newAmt = _curAmt - _toRemove;

        if (_newAmt <= 0) then {
            _droneGrenList deleteAt _matchedKey;
        } else {
            _droneGrenList set [_matchedKey, _newAmt];
        };

        _slotsOccupied = (_slotsOccupied - _toRemove) max 0;
        if (count _droneGrenList == 0) then {
            _slotsOccupied = 0;
        };

        SET_SELFVARG(_droneGrenList);
        SET_SELFVARG(_slotsOccupied);

        // Update decorative 3D grenade: delete if empty or if displayed grenade ran out, then show next if any remain
        if (_slotsOccupied <= 0) then {
            ["deleteAttachedGren", []] CALL_SELF;
        } else {
            if (_newAmt <= 0 && {(toLower _matchedKey) isEqualTo (toLower _tempAttachedGrenClass)}) then {
                ["deleteAttachedGren", []] CALL_SELF;
                if (_spawnTempGren && {count _droneGrenList > 0}) then {
                    private _nextClass = (keys _droneGrenList) select 0;
                    ["spawnAttachedGren", [_nextClass]] CALL_SELF;
                };
            };
        };

        ["DGM_syncMenuState", [_drone, _droneGrenList, _slotsOccupied]] call CBA_fnc_globalEvent;
        _toRemove
    };

    // ========================================================================
    // Decorative Attached 3D Grenade (Server-managed global SimpleObject)
    // ========================================================================

    PUBLIC SERVER METHOD("spawnAttachedGren") {
        if (!isServer || {!IS_OBJ(_drone)}) exitWith {objNull};
        params [["_item", ""]];
        if (_item isEqualTo "" || {!isNull _tempAttachedGren}) exitWith {_tempAttachedGren};

        ITEM_DATA(_item);
        if (_itemModel isEqualTo "") exitWith {objNull};

        private _droneType = toLower (typeOf _drone);
        private _attachZ = _tempAttachGrenOffset;

        if ("mavik" in _droneType && {[_item] call FUNC(isMavicSpecOffsetItem)}) then {
            _attachZ = -0.04;
        };

        if (_droneType isEqualTo "mmm_uav_vampire") then {
            if (local _drone) then {
                _drone setPylonLoadout [1, "", true];
                _drone setPylonLoadout [1, "MMM_Pylon_Vampire_120mm_1x", true];
                _drone setAmmoOnPylon [1, 0];
            } else {
                ["DGM_setupVampirePylon", [_drone], _drone] call CBA_fnc_targetEvent;
            };
        };

        // Normalize model path (createSimpleObject expects path without leading backslash)
        if ((_itemModel select [0, 1]) isEqualTo "\") then {
            _itemModel = _itemModel select [1];
        };

        private _gren = createSimpleObject [_itemModel, [0, 0, 0]];
        _gren attachTo [_drone, [0, 0, _attachZ]];

        _tempAttachedGren = _gren;
        _tempAttachedGrenClass = _item;
        SET_SELFVARG(_tempAttachedGren);
        SET_SELFVARG(_tempAttachedGrenClass);

        _gren
    };

    PUBLIC SERVER METHOD("deleteAttachedGren") {
        if (!isNull _tempAttachedGren) then {
            deleteVehicle _tempAttachedGren;
        };
        _tempAttachedGren = objNull;
        _tempAttachedGrenClass = "";
        if (IS_OBJ(_drone)) then {
            SET_SELFVARG(_tempAttachedGren);
            SET_SELFVARG(_tempAttachedGrenClass);
        };
    };

    // ========================================================================
    // Physical Ordnance Drop (runs on machine where _drone is local)
    // ========================================================================

    PUBLIC LOCAL GE METHOD("drop") {
        params [["_item", ""], ["_num", 1], ["_instigator", objNull]];
        if (!IS_OBJ(_drone) || {_item isEqualTo ""} || {_num <= 0}) exitWith {objNull};

        ITEM_DATA(_item);
        if (_itemAmmo isEqualTo "" && {isClass (configFile >> "CfgAmmo" >> _item)}) then {
            _itemAmmo = _item;
            _itemName = getText (configFile >> "CfgAmmo" >> _item >> "displayName");
        };
        if (_itemAmmo isEqualTo "") exitWith {objNull};

        if ("mavik" in (toLower (typeOf _drone))) then {
            [missionNamespace, "DB_mavic_showMessage", _drone] call BIS_fnc_callScriptedEventHandler;
        };

        private _droneVelocity = velocity _drone;
        private _vectorDirUp = [];
        private _velocity = [];
        private _velocityModelSpace = [];
        private _gren = objNull;

        if (
            (missionNamespace getVariable ["DGM_shoot_rockets", DGM_DEF_SHOOT_ROCKETS]) &&
            {[_item] call FUNC(isRocketItem)}
        ) then {
            _vectorDirUp = [vectorDir _drone, [0.1, 0.1, 1]];
            if ("og7" in (toLower _item)) then {
                _velocityModelSpace = [0, 70, 0];
            } else {
                _velocity = [0, 0, 0];
            };
        } else {
            _vectorDirUp = [];
            _velocity = +_droneVelocity;
        };

        private _randPos = [0, 0];
        private _originVelocity = +_velocity;
        private _itemLower = toLower _item;

        FOR_I(_num) {
            if (!IS_OBJ(_drone)) exitWith {};

            private _worldPos = _drone modelToWorldVisualWorld [_randPos select 0, _randPos select 1, _zOffset];
            private _aglPos = ASLToAGL _worldPos;
            _gren = createVehicle [_itemAmmo, _aglPos, [], 0, "CAN_COLLIDE"];
            _gren setPosWorld _worldPos;

            if (isServer) then {
                _gren setShotParents [_drone, _instigator];
            } else {
                ["DGM_setShotParents", [_gren, _drone, _instigator]] call CBA_fnc_serverEvent;
            };

            if (_vectorDirUp isEqualTo []) then {
                private _angle = if (_itemLower isEqualTo "tbd_mortar_82mm_shell_ammo_he") then {90} else {-90};
                [_gren, _angle, 0] call BIS_fnc_setPitchBank;
            } else {
                _gren setVectorDirAndUp _vectorDirUp;
            };

            if (_velocityModelSpace isNotEqualTo []) then {
                _gren setVelocityModelSpace _velocityModelSpace;
            } else {
                _gren setVelocity _velocity;
            };

            if ((_num > 1) && {_i < (_num - 1)}) then {
                private _randVel = missionNamespace getVariable ["DGM_randomVelocity", DGM_DEF_RANDOM_VELOCITY];
                private _randOffset = missionNamespace getVariable ["DGM_randomOffset", DGM_DEF_RANDOM_OFFSET];
                private _dropDelay = missionNamespace getVariable ["DGM_randomDropDelay", DGM_DEF_RANDOM_DROP_DELAY];

                _randPos = [random [-_randOffset, 0, _randOffset], random [-_randOffset, 0, _randOffset]];
                _velocity = _originVelocity vectorAdd [random [-_randVel, 0, _randVel], random [-_randVel, 0, _randVel], 0];

                if (_dropDelay > 0) then {
                    sleep (random [_dropDelay - (_dropDelay / 3), _dropDelay, _dropDelay + (_dropDelay / 3)]);
                };
            };
        };

        _tempDropGren = _gren;
        SET_SELFVAR(_tempDropGren);

        // Notify instigator player with drop hint (locally if instigator is here, or via targeted owner event)
        if (IS_OBJ(_instigator)) then {
            if (hasInterface && {_instigator isEqualTo PLAYER_}) then {
                SHOW_DROP_HINT(TXT_DROPPED(_itemName));
            } else {
                if (isPlayer _instigator) then {
                    ["DGM_showHint", [TXT_DROPPED(_itemName), true], _instigator] call CBA_fnc_targetEvent;
                };
            };
        };

        _gren
    };

    // ========================================================================
    // Queries & Configuration Setters
    // ========================================================================

    PUBLIC LOCAL METHOD("getGrenadeData") {
        params [["_grenClass", ""]];
        private _amt = ["getGrenAmount", [_grenClass]] CALL_SELF;
        createHashMapFromArray [["Name", _grenClass], ["Amount", _amt]]
    };

    PUBLIC LOCAL METHOD("getGrenAmount") {
        params [["_grenClass", ""]];
        if (_grenClass isEqualTo "") exitWith {0};

        private _val = _droneGrenList get _grenClass;
        if (isNil "_val") then {
            private _lwr = toLower _grenClass;
            {
                if ((toLower _x) isEqualTo _lwr) exitWith {_val = _y};
            } forEach _droneGrenList;
        };
        if (isNil "_val") exitWith {0};
        if (_val isEqualType createHashMap) exitWith {_val getOrDefault ["Amount", 0]};
        _val
    };

    PUBLIC LOCAL METHOD("grenadeAvailable") {
        params [["_grenClass", ""]];
        if (_grenClass isEqualTo "") exitWith {false};
        (["getGrenAmount", [_grenClass]] CALL_SELF) > 0
    };

    PUBLIC SERVER METHOD("setSlotsNumber") {
        params [["_newSlots", 1]];
        if (_newSlots <= 0) exitWith {
            SHOW_HINT(DGM_STR_SLOTS_NOT_ENOUGH);
            false
        };
        if (!isServer) exitWith {false};

        _maxSlotNum = _newSlots;
        SET_SELFVARG(_maxSlotNum);

        if (_dropCharge > _maxSlotNum) then {
            _dropCharge = _maxSlotNum;
            SET_SELFVARG(_dropCharge);
            ["DGM_syncChargeState", [_drone, _dropCharge, _canSetCharge]] call CBA_fnc_globalEvent;
        };
        true
    };

    PUBLIC SERVER METHOD("setCharge") {
        params [["_newCharge", 1]];
        if (_newCharge <= 0) exitWith {
            SHOW_HINT(DGM_STR_ABOVE_ZERO);
            false
        };
        if (!isServer) exitWith {false};

        _dropCharge = (_newCharge max 1) min (_maxSlotNum max 1);
        SET_SELFVARG(_dropCharge);

        ["DGM_syncChargeState", [_drone, _dropCharge, _canSetCharge]] call CBA_fnc_globalEvent;
        true
    };

    PUBLIC SERVER METHOD("changeCharge") {
        if (!isServer) exitWith {1};

        private _maxAllowed = _maxSlotNum max 1;
        private _nextCharge = if ((_dropCharge >= _maxAllowed) || {_dropCharge < 1}) then {
            1
        } else {
            _dropCharge + 1
        };

        ["setCharge", [_nextCharge]] CALL_SELF;
        _dropCharge
    };

    PUBLIC SERVER METHOD("allowSetCharge") {
        params [["_allow", true]];
        if (!isServer) exitWith {false};

        _canSetCharge = _allow;
        SET_SELFVARG(_canSetCharge);

        ["DGM_syncChargeState", [_drone, _dropCharge, _canSetCharge]] call CBA_fnc_globalEvent;
        true
    };

CLASS_END
