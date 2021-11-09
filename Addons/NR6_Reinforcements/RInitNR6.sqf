
if (isNil ("RydHQ_Included")) then {RydHQ_Included = []};
if (isNil ("RydHQB_Included")) then {RydHQB_Included = []};
if (isNil ("RydHQC_Included")) then {RydHQC_Included = []};
if (isNil ("RydHQD_Included")) then {RydHQD_Included = []};
if (isNil ("RydHQE_Included")) then {RydHQE_Included = []};
if (isNil ("RydHQF_Included")) then {RydHQF_Included = []};
if (isNil ("RydHQG_Included")) then {RydHQG_Included = []};
if (isNil ("RydHQH_Included")) then {RydHQH_Included = []};

SpawnRGroup = {

    private ["_grp","_vharr","_class","_crewGear","_unit","_SelGroup","_grpi","_selectedPos","_SpawnPos","_SpawnRadius","_side","_Pool","_Leaders","_RejoinPoint","_sentence","_ExtraArgs"];

	_SpawnPos = _this select 0;
	_SpawnRadius = _this select 1;
	_side = _this select 2;
	_Pool = _this select 3;
	_Leaders = _this select 4;
    _RejoinPoint = _this select 5;
    _ExtraArgs = _this select 6;
    _SelGroup =  selectRandom _Pool;
    _selectedPos = selectRandom _SpawnPos;

    _grp = grpNull;

    if ((typeName _SelGroup) isEqualTo "ARRAY") then {

        if not ((typeName (_SelGroup select 0)) isEqualTo "ARRAY") then {

            {_SelGroup set [_foreachindex,[_x,[],[],[]]]} foreach _SelGroup;

        };

        _grp = createGroup _side;
        _selectedPos = ([_selectedPos,0,_SpawnRadius,10] call BIS_fnc_findSafePos);
        {
            _class = _x select 0;
            if (_class isKindOf "Man") then {
               _unit = _grp createUnit [_class, ([_selectedPos,0,30,1] call BIS_fnc_findSafePos), [], 0, "NONE"];
               if not ((_x select 1) isEqualTo []) then {_unit setUnitLoadout (_x select 1)};

            } else {
                _crewGear = _x select 1;
                _vharr = [([_selectedPos,0,75,10] call BIS_fnc_findSafePos),0,_class,_grp] call BIS_fnc_spawnVehicle;
                if not ((_x select 3) isEqualTo []) then {{_vharr setPylonLoadOut [(_forEachIndex + 1),_x]} foreach (_x select 3)};
                {((_vharr select 1) select _foreachindex) setUnitLoadout _x} foreach _crewGear;
            };
        } foreach _SelGroup;

    } else {

        _grp = [([_selectedPos,0,_SpawnRadius,10] call BIS_fnc_findSafePos),_side,_SelGroup] call BIS_fnc_spawnGroup;

    }; 
        
    _grp deleteGroupWhenEmpty true;

    if not (isNil "_ExtraArgs") then {(leader _grp) call compile _ExtraArgs};
    
    if !(isNil "_RejoinPoint") then {_grp addWaypoint [_RejoinPoint,100]};

    {
        if (_side==(side _x)) then 
            {
            if (isNull _x) then {} else 
                {
                _sentence = (format ["%2 deployed at grid: %1",mapGridPosition _selectedPos,groupId _grp]);
            //    [_x,_sentence] remoteExecCall ["RYD_MP_Sidechat"];
                if (_x==LeaderHQ) then {RydHQ_Included pushBack _grp; (group LeaderHQ) setvariable ["RydHQ_Included",RydHQ_Included];};
                if (_x==LeaderHQB) then {RydHQB_Included pushBack _grp; (group LeaderHQB) setvariable ["RydHQ_Included",RydHQB_Included];};
                if (_x==LeaderHQC) then {RydHQC_Included pushBack _grp; (group LeaderHQC) setvariable ["RydHQ_Included",RydHQC_Included];};
                if (_x==LeaderHQD) then {RydHQD_Included pushBack _grp; (group LeaderHQD) setvariable ["RydHQ_Included",RydHQD_Included];};
                if (_x==LeaderHQE) then {RydHQE_Included pushBack _grp; (group LeaderHQE) setvariable ["RydHQ_Included",RydHQE_Included];};
                if (_x==LeaderHQF) then {RydHQF_Included pushBack _grp; (group LeaderHQF) setvariable ["RydHQ_Included",RydHQF_Included];};
                if (_x==LeaderHQG) then {RydHQG_Included pushBack _grp; (group LeaderHQG) setvariable ["RydHQ_Included",RydHQG_Included];};
                if (_x==LeaderHQH) then {RydHQH_Included pushBack _grp; (group LeaderHQH) setvariable ["RydHQ_Included",RydHQH_Included];};
                }; 
            };

    } forEach _Leaders;

};