
if (isNil ("RydHQ_Included")) then {RydHQ_Included = []};
if (isNil ("RydHQB_Included")) then {RydHQB_Included = []};
if (isNil ("RydHQC_Included")) then {RydHQC_Included = []};
if (isNil ("RydHQD_Included")) then {RydHQD_Included = []};
if (isNil ("RydHQE_Included")) then {RydHQE_Included = []};
if (isNil ("RydHQF_Included")) then {RydHQF_Included = []};
if (isNil ("RydHQG_Included")) then {RydHQG_Included = []};
if (isNil ("RydHQH_Included")) then {RydHQH_Included = []};

SpawnARGroupA = {

    private ["_grp","_selectedPos","_flight","_birds","_GoodPads","_side","_Pool","_Leaders","_VC","_selectedDir","_relpos","_sel","_pylons","_bridssettings","_settings"];

	_GoodPads = _this select 0;
	_side = _this select 1;
	_Pool = _this select 2;
	_Leaders = _this select 3;
    _flight = _this select 4;

    if not ((typeName (_Pool select 0)) isEqualTo "ARRAY") then {

         {_Pool set [_foreachindex,[_x,[],[],[]]]} foreach _Pool;

    };

    _birds = [];
    _bridssettings = [];
    _relpos = [];

    for "_i" from 1 to _flight do {

    _sel = (selectRandom _Pool);
    _bird = _sel select 0;
    _crewgear = _sel select 1;
    _crewClasses = _sel select 2;
    _pylons =  _sel select 3;

    _bridssettings pushBack [_crewgear,_crewClasses,_pylons];
    _birds pushBack _bird;
    _relpos pushBack [_i*50,0,0];

    };

    _selectedPad = selectRandom _GoodPads;

    _selectedPos = [(getpos _selectedPad) select 0, (getpos _selectedPad) select 1, (((getpos _selectedPad) select 2) + (random [500,700,1500]))];
    _selectedDir = (getdir _selectedPad);



    _grp = [_selectedPos,_side,_birds,_relpos] call BIS_fnc_spawnGroup; 
    _grp setBehaviour "SAFE";
    _grp setCombatMode "GREEN";

    _VC = [];

    {
        _VC pushBackUnique (vehicle _x);
    } foreach (units _grp);

    {
        _bird = _x;
        _settings = _bridssettings select _forEachIndex;
        {_bird setPylonLoadOut [(_forEachIndex + 1),_x]} foreach (_settings select 2);
        {((crew _bird) select _forEachIndex) setUnitLoadout _x} foreach (_settings select 0);
    } foreach _VC;
/*
    if (_VC isKindof "Plane") then {
        _VC FlyInHeight (random [100,1000,3500]);
    };
        


    } else {

        _grp = createGroup _side;

        _VC = (selectRandom _Pool) createVehicle _selectedPos;
        _VC setdir _selectedDir;
        createVehicleCrew _VC;
        units (group _VC) joinSilent _grp;
        _grp addVehicle _VC;

        if (_VC isKindof "Plane") then {
            _VC FlyInHeight (random [100,1000,3500]);
        };

        _grp setBehaviour "CARELESS";

    };
*/
    {  
        if (_side==(side _x)) then 
            {
            if (isNull _x) then {} else 
                {
            //    _x sideChat (format ["Air asset %2 deployed at grid: %1",mapGridPosition _selectedPos,groupId _grp]);
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

    _grp;

};