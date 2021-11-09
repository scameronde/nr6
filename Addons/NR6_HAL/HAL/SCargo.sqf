_SCRname = "SCargo";

private ["_request","_Rdest","_reqdone","_firstlead"];

_unitG = _this select 0;
_HQ = _this select 1;
_posT = _this select 2;
_withdraw = false;
_request = false;
_requestG = false;
if ((count _this) > 3) then {_withdraw = _this select 3};
if ((count _this) > 4) then {_request = _this select 4};
if ((count _this) > 5) then {_requestG = _this select 5};

if ((_withdraw) and not (_HQ getVariable ["RydHQ_AirEvac",false])) exitwith {_unitG setVariable [("CC" + (str _unitG)), true, true]};

_GL = leader _unitG;
_posS = (getPosATL (vehicle _GL));

_NG = count (units _unitG);
_AV = ObjNull;
_ChosenOne = ObjNull;
_Free = true;
_emptyV = true;

if (isNil "RydHQx_CargoDist") then {RydHQx_CargoDist = 100000};


if ( not (_withdraw) and not (_request)) then
	{
	_CP = nearestObjects [_GL, ["Car","Tank","Motorcycle","Air"], (_HQ getVariable ["RydHQ_CargoFind",0])];

		{
		if not (_x getVariable ["Hired",false]) then
			{
			_ESpace = (_x emptyPositions "Cargo") + (_x emptyPositions "Driver") + (_x emptyPositions "Gunner") + (_x emptyPositions "Commander");
			if ((_ESpace >= _NG) and ((count (assignedCargo _x)) == 0) and ((count (crew _x)) == 0) and ((fuel _x) >= 0.2) and (damage _x <= 0.8) and (canMove _x)) exitwith 
				{
				_ChosenOne = _x;
				_unitG setVariable ["CargoChosen",true];
				_x setVariable ["Hired",true]
				}
			}
		}
	foreach _CP;
	};

_actV = ObjNull;
_ELast = 0;
_mpl = 1;
_airCargo = [];
_offRoad = false;
_vHQ = vehicle (leader _HQ);
_vGL = vehicle _GL;

if (isNull _ChosenOne) then
	{
	_emptyV = false;
	
	_cargos = ((_HQ getVariable ["RydHQ_CargoG",[]]) - ((_HQ getVariable ["RydHQ_AOnly",[]]) + (_HQ getVariable ["RydHQ_ROnly",[]]) + (_HQ getVariable ["RydHQ_NoCargo",[]]) + (_HQ getVariable ["RydHQ_SpecForG",[]])));
	_cargos = +_cargos;
	
	_cargos = [_cargos,getPosATL (vehicle _GL),RydHQx_CargoDist] call RYD_DistOrd;
	
	_allCargo = _cargos;
	
		{
		if (_x in (_HQ getVariable ["RydHQ_AirG",[]])) then
			{
			_airCargo pushBack _x
			}
		}
	foreach _cargos;
		
	switch (true) do
		{
		case ((count (_posS nearRoads 100)) < 1) : {_offRoad = true};
		case ((count (_posT nearRoads 100)) < 1) : {_offRoad = true};
		};

	_GCargo = _allCargo - _airCargo;
	_GCargo = +_GCargo;
		
	switch (true) do
		{
		case (_withdraw) : {_cargos = [_airCargo]};
		case (_requestG) : {_cargos = [_GCargo]};
		case (_request) : {_cargos = [_airCargo]};
		case (_offRoad) : {_cargos = [_airCargo,_allCargo]};
		default {_cargos = [_allCargo]};
		};
		
		{
			{
			_ESpace = 0;
			_SizeCargo = 0;
			_prefV = ObjNull;

				{
					if (_SizeCargo < (((assignedvehicle _x) emptyPositions "Cargo") + ((assignedvehicle _x) emptyPositions "Gunner") + ((assignedvehicle _x) emptyPositions "Commander"))) then {
						_SizeCargo = (((assignedvehicle _x) emptyPositions "Cargo") + ((assignedvehicle _x) emptyPositions "Gunner") + ((assignedvehicle _x) emptyPositions "Commander"));
						_prefV = (assignedvehicle _x);
					};
				}
			foreach (units _x);

				{
				_unitvar = str (group _x);
				_busy = false;
				_unable = false;
				_busy = (group _x) getvariable ("Busy" + _unitvar);
				_unable = (group _x) getvariable "Unable";
				if (isNil ("_busy")) then {_busy = false};
				if (isNil ("_unable")) then {_unable = false};
				if (_actV == (assignedvehicle _x)) then 
					{
					_Elast = 0;
					}
				else
					{
					_Elast = _ESpace;
					};

				_ESpace = _ELast + ((assignedvehicle _x) emptyPositions "Cargo") + ((assignedvehicle _x) emptyPositions "Gunner") + ((assignedvehicle _x) emptyPositions "Commander");
				_actV = (assignedvehicle _x);
				if ((group _x) in (_HQ getVariable ["RydHQ_AirG",[]])) then {_mpl = 100} else {_mpl = 1};
				_noenemy = true;
				_halfway = [(((position _actV) select 0) + ((position _GL) select 0))/2,(((position _actV) select 1) + ((position _GL) select 1))/2];
				_hired = (assignedvehicle _x) getVariable "Hired";
				if (isNil ("_hired")) then {_hired = false};
				
				_mpl2 = 500;
				if (_withdraw) then {_mpl2 = 0};
				if (_request) then {_mpl2 = 0; _mpl = 10000};
				
				if (((((_vHQ findNearestEnemy _vGL) distance _vGL) <= (_mpl2*_mpl)) or (((_vHQ findNearestEnemy _halfway) distance _halfway) <= (_mpl2*_mpl))) and ((random 100) > (20*(0.5 + (2*(_HQ getVariable ["RydHQ_Recklessness",0.5])))))) then {_noenemy = false};
				if ((_ESpace >= _NG) and (_prefV == (assignedvehicle _x)) and 
					((count (assignedCargo (assignedvehicle _x))) == 0) and not 
						((_busy) or (_unable) or (_hired)) and not
							((_x in (_HQ getVariable ["RydHQ_NCrewInfG",[]])) and (count (units _x) > 1)) and
								(((vehicle (leader _x)) distance (vehicle _GL)) < (2000*_mpl)) and 
									((fuel (assignedvehicle _x)) >= 0.2) and 
										(damage (assignedvehicle _x) <= 0.8) and 
											(canMove (assignedvehicle _x)) and
												(_noenemy) and
													(not ((group _x) in (_HQ getVariable ["RydHQ_AirG",[]])) or (((count ((_HQ getVariable ["RydHQ_AAthreat",[]]) + (_HQ getVariable ["RydHQ_Airthreat",[]]))) == 0) or (random 100 > (85/(0.5 + (2*(_HQ getVariable ["RydHQ_Recklessness",0.5])))))))) exitwith 
					{
					_ChosenOne = (assignedvehicle _x)
					}
				}
			foreach (units _x);
			if not (isNull _ChosenOne) exitwith {_unitG setVariable ["CargoChosen",true]};
			}
		foreach _x;
		
		if not (isNull _ChosenOne) exitWith {}
		}
	foreach _cargos;
	};

_unitvar = str _unitG;
if (isNull _ChosenOne) exitwith {{[_x] remoteExecCall ["RYD_MP_unassignVehicle",0]} foreach (units _unitG);_unitG setVariable [("CC" + _unitvar), true, true];_unitG setVariable ["CargoChosen",false];};
_GD = (group (assigneddriver _ChosenOne));
_unitvar2 = str _GD;
_Vpos = _GD getvariable ("START" + _unitvar2); 

_lz = objNull;
_alive = true;
_EDpositions = [];

if not (_emptyV) then
	{
	if (isNil ("_Vpos")) then {_GD setVariable [("START" + _unitvar2),(position _ChosenOne)]};
	
	if (_offRoad) then
		{		
		if not (_GD in _airCargo) then
			{
				{
				_cR = objNull;
				_pos0 = _x;

				for "_i" from 100 to 600 step 100 do
					{
					_nR = _pos0 nearRoads _i;
					
					if ((count _nR) > 0) exitWith
						{
						_cR = [_pos0,_nR] call RYD_FindClosest;
						
						_pos0 = getPosATL _cR;
						_pos = +_pos0;
						_ct = 0;
						
						while {(isOnRoad _pos)} do
							{
							_pos = [_pos0,30 + _ct] call RYD_RandomAround;
							_ct = _ct + 1;
							if (_ct > 50) exitWith {}
							};
						
						_EDpositions pushBack _pos;
						}
					}
					
				}
			foreach [_posS,_posT];
			if ((count _EDpositions) < 2) exitWith {_alive = false};
			_GD setVariable ["RydHQ_EDPos",_EDpositions];
			};
		};
		
	if not (_alive) exitWith {{[_x] remoteExecCall ["RYD_MP_unassignVehicle",0]} foreach (units _unitG);_unitG setVariable [("CC" + _unitvar), true, true];_unitG setVariable ["CargoChosen",false]};
			
	_GD setVariable [("Busy" + (str _GD)), true];
	_GD setVariable [("CargoM" + (str _GD)), true];
//	if (_request) then {_GD setvariable ["HAL_ReqTraOn",false,true]};

	[_GD] call RYD_WPdel;
	
	_UL = leader _GD;
	
	_Lpos = [((position _GL) select 0) + (random 100) - 50,((position _GL) select 1) + (random 100) - 50,0];
	
	if (((count _EDpositions) > 1) and not (_request)) then 
		{
		_Lpos = _EDpositions select 0;

		_wp = [_unitG,([_Lpos,30] call RYD_RandomAround)] call RYD_WPadd;
		};
		
	if ((_GD in _airCargo) and {not (isOnRoad _Lpos)})  then
		{
		_fe = (count (_Lpos isflatempty [20,0,1,10,0,false,objNull])) > 0;
		_ct = 0;
		_dst = 30;
		
		while {not (_fe)} do
			{
			if (_dst > 100) exitWith {};
			_dst =_dst + 10;
			_Lpos = [_Lpos,_dst/2,_dst] call RYD_RandomAroundMM;
			_fe = (count (_Lpos isflatempty [20 - (_dst/20),0,1 + (_dst/80),10,0,false,objNull])) > 0;
			}
		};
	
	[_GD,_Lpos,"HQ_ord_cargo",_HQ] call RYD_OrderPause;

	if ((isPlayer _UL) and (RydxHQ_GPauseActive)) then {hintC "New orders from HQ!";setAccTime 1};

	if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdConf,"OrdConf"] call RYD_AIChatter}};

	_ChosenOne disableAI "TARGET";_ChosenOne disableAI "AUTOTARGET";
		
	if not (_withdraw) then {
		_task = [(leader _GD),["Pick up "+ (groupId _unitG) + " for transport to a designated position.", "Pick Up " + (groupId _unitG) , ""],_Lpos,"run"] call RYD_AddTask;
		} else {
		_task = [(leader _GD),["Pick up " + (groupId _unitG) + " for MEDEVAC.", "MEDEVAC " + (groupId _unitG), ""],_Lpos,"heal"] call RYD_AddTask;
		};

	_taskTxt = "Wait and get into vehicle.";
	if (_withdraw) then 
		{
		_pos1 = getPosATL _vGL;
		_pos2 = _posT;
		
		_halfway = [((_pos1 select 0) + (_pos2 select 0))/2,((_pos1 select 1) + (_pos2 select 1))/2];
		
		_dstHalf = _pos1 distance _halfway;
		
		_angle = [_pos1,_pos2,5] call RYD_AngTowards;
		_posLZ = [_pos1,_angle,100] call RYD_PosTowards2D;
		
		_nE = (_vHQ findNearestEnemy _posLZ);
		_dstE = 1000;
		if not (isNull _nE) then {_dstE = _nE distance _posLZ};
		
		_dst = 200;
		
		while {_dstE < 400} do
			{
			_posLZ = [_pos1,_angle,_dst] call RYD_PosTowards2D;
			_dst = _dst + 100;
			
			_nE = (_vHQ findNearestEnemy _posLZ);
			_dstE = 1000;
			if not (isNull _nE) then {_dstE = _nE distance _posLZ};
			
			if (_dst > _dstHalf) exitWith {_posLZ = _halfway}
			};
		
		_lz = [_posLZ] call RYD_LZ;
		_ChosenOne setVariable ["TempLZ",_lz];
		if not (isNull _lz) then {_Lpos = getPosATL _lz} else {_Lpos = _posLZ};
		
		_taskTxt = "Reach LZ, wait for evacuation.";

		_wp = [_unitG,([_Lpos,30] call RYD_RandomAround)] call RYD_WPadd;
		};
		
	if not (_request) then {
		
		_task2 = [(leader _unitG),[_taskTxt, "Wait For Lift", ""],_Lpos,"getin"] call RYD_AddTask;

		_wp = [_GD,_Lpos,"MOVE","STEALTH","YELLOW","FULL",["true","{(vehicle _x) land 'GET IN'} foreach (units (group this));deletewaypoint [(group this), 0];"],true,0,[0,0,0],"COLUMN"] call RYD_WPadd;

	} else {

		_wp = [_GD,_Lpos,"MOVE","STEALTH","YELLOW","FULL",["true","{(vehicle _x) land 'LAND'} foreach (units (group this));deletewaypoint [(group this), 0];"],true,0,[0,0,0],"COLUMN"] call RYD_WPadd;

	};
	
	if (_ChosenOne isKindOf "Air") then 
		{
		if ((_HQ getVariable ["RydHQ_LZ",false]) and not (_withdraw)) then 
			{
			_lz = [_Lpos] call RYD_LZ;
			_ChosenOne setVariable ["TempLZ",_lz];
			}
		};

	_alive = true;
	_timer = -5;
	waituntil 
		{
		_DAV = assigneddriver _ChosenOne;
		_GD = group _DAV;
		if (isNull _GD) then {_alive = false};
		if (_alive) then {if not (alive  (leader _GD)) then {_alive = false}};
		if (_alive) then {if ((speed _ChosenOne) < 0.5) then {_timer = _timer + 5}};
		if (_GD getVariable ["Break",false]) then {_endThis = true;_alive = false; _GD setVariable ["Break",false]; _GD setVariable ["Busy" + (str _GD),false];};
		sleep 6;

		((((count (waypoints _GD)) < 1)) or (_timer > 120) or (_request) or not (_alive));
		};

	if ((_timer > 120) and ((_ChosenOne distance (vehicle (leader _unitG))) > 500)) then {_alive = false};
	if not (_alive) exitwith {[_unitG,_ChosenOne] remoteExecCall ["leaveVehicle"];{[_x] remoteExecCall ["RYD_MP_unassignVehicle",0]} foreach (units _unitG);_unitG setVariable [("CC" + _unitvar), true, true];_unitG setVariable ["CargoChosen",false];_GD setVariable [("CargoM" + (str _GD)), false];_GD setVariable [("Busy" + (str _unitG)),false];};


	if (((_ChosenOne emptyPositions "Cargo") > 0) and not (_request)) then 
		{
			{
			_x assignAsCargo _ChosenOne
			}
		foreach (units _unitG)
		};

	_ct = 0;
	_alive = true;
	waituntil 
		{
		sleep 1;
		
		if (isNull _unitG) then {_alive = false;};

		if ((speed (leader _unitG)) < 0.5) then {_ct = _ct + 1};
		
		_assigned = true;

		if (_alive) then
			{
				{
				if (isNull (assignedVehicle _x)) exitWith {_assigned = false}
				}
			foreach (units _unitG);
			};

		((_assigned) or not (_alive) or (_request) or (_ct > 300))
		};

	if (_ct > 300) then {_alive = false;[_unitG,_ChosenOne] remoteExecCall ["leaveVehicle"];{[_x] remoteExecCall ["RYD_MP_unassignVehicle",0]} foreach (units _unitG);_unitG setVariable [("CC" + _unitvar), true, true];_unitG setVariable ["CargoChosen",false]};
	};

// if not (_task isEqualTo taskNull) then {[_task,"SUCCEEDED",true] call BIS_fnc_taskSetState};

if not (_alive) exitWith {_unitG setVariable [("CC" + _unitvar), true, true]; _GD setVariable ["Busy" + (str _GD),false];};


if not (_request) then {
	_asCargo = units _unitG;

	if ((_emptyV) or (isNull (assignedDriver _ChosenOne))) then {_GL assignAsDriver _ChosenOne;_asCargo = _asCargo - [_GL]};
	if (((_ChosenOne emptyPositions "Gunner") > 0) and (count (units _unitG) > 1)) then {((units _unitG) select 1) assignAsGunner _ChosenOne;_asCargo = _asCargo - [(units _unitG) select 1]};

	if (_emptyV) then
	{
		{
		_x assignAsCargo _ChosenOne
		}
	foreach _asCargo
	};
};

_GD = (group (assigneddriver _ChosenOne));

if not (_request) then {_unitG setVariable [("CC" + _unitvar), true, true];};

_unitvar = str _GD;

_busy = false;

_firstlead = objNull;

if not (_GD == _unitG) then 
	{
	_timer = -5;
	_alive = true;

	if (_request) then {

		_firstlead = (leader _unitG);

		[_ChosenOne,leader _unitG,_GD] remoteExecCall ["RYD_ReqTransport_Actions",(leader _unitG)];
	};

	waituntil 
		{
		sleep 5;
		_GD = (group (assigneddriver _ChosenOne));
		_reqdone = false;
		if (isNull _GD) then {_alive = false};
		if (_alive) then {if not (alive  (leader _GD)) then {_alive = false}};
		if (_GD getVariable ["Break",false]) then {_endThis = true;_alive = false; _GD setVariable ["Break",false]; _GD setVariable ["Busy" + (str _GD),false];};
		
		if (_alive) then
			{
			_busy = _GD getvariable ("CargoM" + _unitvar);
			if not (_request) then {if ((abs (speed _ChosenOne)) < 0.5) then {_timer = _timer + 5}};
			};
		
		if (_request) then {

			if not ((leader _unitG) isEqualTo _firstlead) then {

				[_ChosenOne,leader _unitG,_GD] remoteExecCall ["RYD_ReqTransport_Actions",(leader _unitG)];

				{[_firstlead,_x] remoteExecCall ["removeAction",_firstlead]} foreach (_firstlead getVariable ["HAL_ReqTraActs",[]]);
				{[_ChosenOne,_x] remoteExecCall ["removeAction",_firstlead]} foreach (_firstlead getVariable ["HAL_ReqTraVActs",[]]);

				_firstlead setVariable ["HAL_ReqTraActs",[],true];

				_firstlead = (leader _unitG);
				

			};
			
			_Rdest = _unitG getvariable ["HALReqDest",nil];

			if not (isNil "_Rdest") then {

				_wp = [_GD,_Rdest,"MOVE",behaviour (leader _GD),combatMode _GD,"NORMAL",["true","(vehicle this) land 'LAND';deletewaypoint [(group this), 0];"],true,0,[0,0,0],"COLUMN"] call RYD_WPadd;

				[_ChosenOne,"Destination received, we're headed there now."] remoteExecCall ["vehicleChat"];

//				[(leader _unitG),""] remoteExecCall ["onMapSingleClick",(leader _unitG)];

				_unitG setvariable ["HALReqDest",nil];

			};

			if (_GD getvariable ['HALReqDone',false]) then {_reqdone = true;};
			if not (isPlayer (leader _unitG)) then {_reqdone = true; _timer = 601;};

		};
			
		(not (_busy) or (_timer > 600) or (_reqdone) or not (_alive));
		};

	if (_request) then {
		
		_unitvar = str _unitG;
		_unitG setVariable [("CC" + _unitvar), true, true]; {[_x] remoteExecCall ["RYD_MP_unassignVehicle",0]} foreach (units _unitG);
		
		_GD setVariable [("CargoM" + (str _GD)), false];

//		_GD setvariable ["HAL_ReqTraOn",true,true];
		
		[(leader _unitG),""] remoteExecCall ["onMapSingleClick",(leader _unitG)];

		_GD setvariable ["HALReqDone",false];

		_unitG setvariable ["HALReqDest",nil];

		{[_firstlead,_x] remoteExecCall ["removeAction",_firstlead]} foreach (_firstlead getVariable ["HAL_ReqTraActs",[]]);
		{[_ChosenOne,_x] remoteExecCall ["removeAction",_firstlead]} foreach (_firstlead getVariable ["HAL_ReqTraVActs",[]]);

		_firstlead setVariable ["HAL_ReqTraActs",[],true];
		_firstlead setVariable ["HAL_ReqTraVActs",[],true];

		{
			[_x] remoteExecCall ["RYD_MP_unassignVehicle",0]; 
		} foreach (units _unitG);

	};

	_unitvar = str _GD;
		
	if not (_alive) exitWith {_unitG setVariable ["CargoChosen",false];_GD setVariable [("CargoM" + (str _GD)), false];_unitG setVariable [("Busy" + (str _unitG)),false];};

	_unitG setVariable ["CargoChosen",false];

	if (_timer > 600) then 
		{
		[_GD, (currentWaypoint _GD)] setWaypointPosition [position _ChosenOne, 0];
		if (_ChosenOne isKindOf "Air") then 
			{
			if (_HQ getVariable ["RydHQ_LZ",false]) then 
				{
				_lz = [position _ChosenOne] call RYD_LZ
				}
			};

		_ChosenOne land 'GET OUT';

		if not ((_GD == _unitG) or (isNull ((group (assigneddriver _ChosenOne))))) then 
			{
			_unitvar = str _GD;
			_GD setVariable [("CargoM" + _unitvar), false];

			{
				[_x] remoteExecCall ["RYD_MP_unassignVehicle",0]; 
				if not (_request) then {[[_x],false] remoteExecCall ["orderGetIn",0]};
			} foreach (units _unitG);

			[_unitG] call RYD_WPdel;
			}
		else
			{
			{[[_x],false] remoteExecCall ["orderGetIn",0];} foreach (units _unitG);
			};

		_cause = [_unitG,1,false,0,240,[],false,true,false] call RYD_Wait;
		if (_HQ getVariable ["RydHQ_LZ",false]) then {deleteVehicle _lz};
		_timer = _cause select 0;
		_ChosenOne land 'NONE';
		};

//	(units _unitG) doFollow (leader _unitG);

	_Landpos = [];
	_Vpos = _GD getvariable ("START" + _unitvar);

	_ChosenOne land 'NONE';

	if not (isNil ("_Vpos")) then {_LandPos = _GD getvariable ("START" + _unitvar)} else {_LandPos = [((position (vehicle (leader _HQ))) select 0) + (random 200) - 100,((position (vehicle (leader _HQ))) select 1) + (random 200) - 100]};
	sleep 5;
	if not (_GD in (_HQ getVariable ["RydHQ_AirG",[]])) then {sleep 15};

	_task = [(leader _GD),["Return to departure base.", "Return To Base", ""],_LandPos,"land"] call RYD_AddTask;

	_GD = (group (assigneddriver _ChosenOne));

	_beh = "AWARE";
	if (_unitG in (_HQ getVariable ["RydHQ_RAirG",[]])) then {_beh = "SAFE"};
	_wp = [_GD,_LandPos,"MOVE",_beh,"YELLOW","FULL",["true","if not ((group this) getVariable ['AirNoLand',false]) then {{(vehicle _x) land 'LAND'} foreach (units (group this))}; deletewaypoint [(group this), 0]"],true,0,[0,0,0],"COLUMN"] call RYD_WPadd;

	/*
	_GD Move _LandPos;

	_timer = -5;
	_alive = true;
	waituntil 
		{
		_cnt = 1;
		_GD = (group (assigneddriver _ChosenOne));
		if (isNull _GD) then {_alive = false};
		if (_alive) then {if not (alive  (leader _GD)) then {_alive = false}};
		if (_alive) then
			{
			_cnt = (count (waypoints _GD));
			if (abs (speed _ChosenOne) < 0.5) then {_timer = _timer + 5};
			sleep 5;
			};
			
		(((_cnt < 1) and (((getpos _ChosenOne) select 2) < 1)) or (_timer > 120) or not (_alive))
		};
		
	if not (_alive) exitWith {};
	*/

	//if (_timer > 120) then {deleteWaypoint [_GD, 1]};	
	//if not (_task isEqualTo taskNull) then {[_task,"SUCCEEDED",true] call BIS_fnc_taskSetState};

	_GD setVariable [("Busy" + _unitvar), false];
	_ChosenOne enableAI "TARGET";_ChosenOne enableAI "AUTOTARGET";
	_UL = leader _unitG;if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdEnd,"OrdEnd"] call RYD_AIChatter}};
	
	//_ChosenOne land 'NONE';
	
	};
	
// this spawn {while {alive _this} do {sleep 2;if (((count (waypoints (group _this))) < 1) and  (((getpos vehicle _this) select 2) < 1)) then {{_x disableAI 'MOVE'} foreach (units (group _this))};if (((count (waypoints (group _this))) > 0) or ((group _this) getvariable ['HAL_ReqTraOn',true])) exitwith {{_x enableAI 'MOVE'} foreach (units (group _this))};}};