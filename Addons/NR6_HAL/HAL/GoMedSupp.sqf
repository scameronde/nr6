_SCRname = "GoMedSupp";

_i = "";

_unit = _this select 0;
_Trg = _this select 1;
_wounded = _this select 2;
_HQ = _this select 3;
_request = false;
if ((count _this) > 4) then {_request = _this select 4};

_MedPoints = _HQ getVariable ["RydHQ_MedPoints",[]];

_MedPoints pushBack _Trg;

_unitG = group _unit;

_unitvar = str (_unitG);
_startpos = _unitG getVariable ("START" + _unitvar);
if (isNil ("_startpos")) then {_unitG setVariable [("START" + _unitvar),(position _unit)]};

_amb = assignedvehicle (leader (_unitG));

_amb disableAI "TARGET";_amb disableAI "AUTOTARGET";

[_unitG] call RYD_WPdel;

(group (assigneddriver _unit)) setVariable [("Deployed" + (str (group (assigneddriver _unit)))),false,true];
_unitvar = str (_unitG);
_unitG setVariable [("Busy" + _unitvar), true];

_posX = ((position _Trg) select 0) + (random 100) - 50;
_posY = ((position _Trg) select 1) + (random 100) - 50;

_isWater = surfaceIsWater [_posX,_posY];

_cnt = 0;

while {((_isWater) and (_cnt <= 20))} do
	{
	_posX = _posX + (random 200) - 100;
	_posY = _posY + (random 200) - 100;
	_isWater = surfaceIsWater [_posX,_posY];
	_cnt = _cnt + 1;
	};
	
[_unitG,[_posX,_posY,0],"HQ_ord_medS",_HQ] call RYD_OrderPause;

_alive = false;

if ((isPlayer (leader _unitG)) and (RydxHQ_GPauseActive)) then {hintC "New orders from HQ!";setAccTime 1};

_UL = leader _unitG;

if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdConf,"OrdConf"] call RYD_AIChatter}};

if (_HQ getVariable ["RydHQ_Debug",false]) then 
	{
	_signum = _HQ getVariable ["RydHQ_CodeSign","X"];
	_i = [[_posX,_posY],_unitG,"markMedSupp","ColorKhaki","ICON","waypoint","MED " + (groupId _unitG) + " "  + _signum," - MEDICAL SUPPORT",[0.5,0.5]] call RYD_Mark
	};

_task = [(leader _unitG),["Provide medical assistance to " + (groupId (group _Trg)), "Heal " + (groupId (group _Trg)), ""],[_posX,_posY],"heal"] call RYD_AddTask;

_counter = 0;
_timer = 0;

if (_request) then {

	[_amb,"Medical"] remoteExecCall ["RYD_ReqLogistics_Actions"];

	_amb setVariable ["HAL_Requested",true,true];
	
};

while {(_counter <= 3)} do
	{
	
	[_unitG] call RYD_WPdel;

	if not (_counter == 0) then 
		{
		_posX = ((position _unit) select 0) + (random 100) -  50;
		_posY = ((position _unit) select 1) + (random 100) -  50;

		_isWater = surfaceIsWater [_posX,_posY];

		_cnt = 0;

		while {((_isWater) and (_cnt <= 20))} do
			{
			_posX = _posX + (random 200) -  100;
			_posY = _posY + (random 200) -  100;
			_isWater = surfaceIsWater [_posX,_posY];
			_cnt = _cnt + 1;
			};

		if not (_task isEqualTo taskNull) then 
			{
			
			[_task,(leader _unitG),["Provide medical attention to nearby troops.", "Provide Medical Support", ""],[_posX,_posY],"ASSIGNED",0,false,true] call BIS_fnc_SetTask;
			}
		};

	_pos = [_posX,_posY];
	if (_counter == 0) then {_pos = _Trg};

	_tp = "MOVE";
	if (_HQ getVariable ["RydHQ_SupportWP",false]) then {_tp = "SUPPORT"};

	_wp = [_unitG,_pos,_tp,"SAFE","BLUE","FULL",["true","(vehicle this) land 'GET IN';deletewaypoint [(group this), 0]"]] call RYD_WPadd;
	if (_counter == 0) then {_wp waypointAttachVehicle _Trg};

	_cause = [_unitG,6,true,0,24,[],true,true,true,true] call RYD_Wait;
	_timer = _cause select 0;
	_alive = _cause select 1;

	if not (_alive) exitwith 
		{
		if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
			{
			deleteMarker ("markMedSupp" + str (_unitG))
			};
			
		_MedPoints = _MedPoints - [_Trg];
		_HQ setVariable ["RydHQ_MedPoints",_MedPoints];
		_unitG setVariable [("Busy" + _unitvar), false];
		_amb setVariable ["HAL_Requested",false,true];
		};
		
	if (_timer > 24) then {_counter = _counter + 1;[_unitG, (currentWaypoint _unitG)] setWaypointPosition [position (vehicle (leader _unitG)), 0];} else {_counter = _counter + 1}; 

	if ((RydxHQ_MagicHeal) and (_timer <= 24)) then { {if (((side _x) getFriend (side _unitG)) >= 0.6) then {_x call ace_medical_treatment_fnc_fullHealLocal; if (isPlayer _x) then {"Medical Treatment Applied" remoteExec ["hint", _x]};}} foreach ((vehicle (leader _unitG)) nearEntities [["Man"], 25]);};
	
//	if ((_request) and ((_amb getVariable ["HAL_Requested",false]) or ((_amb distance _Trg) > 500))) then {_counter = 5};

	if ((_request) and (_amb getVariable ["HAL_Requested",false]) and ((_amb distance _Trg) < 500)) then {_counter = 0};

	if ((_request) and not (_amb getVariable ["HAL_Requested",false])) then {_counter = 5};
	
	_UL = leader _unitG;if not (isPlayer _UL) then {if ((_timer <= 24) and (_counter == 1)) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdFinal,"OrdFinal"] call RYD_AIChatter}}};

	if (((damage _Trg) < 0.1) or ((damage _Trg) >= 0.9) or (isNull (group (_this select 1)))) then {_wounded = _wounded - [_Trg]};
	};

if (_request) then {[_amb] remoteExecCall ["RYD_ReqLogisticsDelete_Actions"]};
_amb setVariable ["HAL_Requested",false,true];

if not (_alive) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
		{
		deleteMarker ("markMedSupp" + str (_unitG))
		};
		
	_MedPoints = _MedPoints - [_Trg];
	_HQ setVariable ["RydHQ_MedPoints",_MedPoints];
	_unitG setVariable [("Busy" + _unitvar), false];
	};
	
[_unitG, (currentWaypoint _unitG)] setWaypointPosition [position (vehicle (leader _unitG)), 0];

_tp = "MOVE";
if (_HQ getVariable ["RydHQ_SupportWP",false]) then {_tp = "SUPPORT"};

_pos = [_posX,_posY];

if (_HQ getVariable ["RydHQ_SupportRTB",false]) then {_pos = _startpos; if not (isNull (_HQ getVariable ["RydHQ_SupportDecoy",objNull])) then {if ((random 100) <= (_HQ getVariable ["RydHQ_SDChance",100])) then {_pos = (getpos (_HQ getVariable ["RydHQ_SupportDecoy",objNull]))}}; _MedPoints = _MedPoints - [_Trg]; if not (_task isEqualTo taskNull) then {[_task,(leader _unitG),["Return to base.", "Return To Base", ""],_pos,"ASSIGNED",0,false,true] call BIS_fnc_SetTask;}};


_wp = [_unitG,_pos,_tp,"SAFE","BLUE","FULL",["true","{(vehicle _x) land 'LAND'} foreach (units (group this));deletewaypoint [(group this), 0]"]] call RYD_WPadd;

_timer = 0;
_alive = true;

if not (_HQ getVariable ["RydHQ_SupportRTB",false]) then {
	_cause = [_unitG,6,true,0,24,[],true,true,true,true] call RYD_Wait;
	_timer = _cause select 0;
	_alive = _cause select 1;
};

if not (_alive) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
		{
		deleteMarker ("markMedSupp" + str (_unitG))
		};
		
	_MedPoints = _MedPoints - [_Trg];
	_HQ setVariable ["RydHQ_MedPoints",_MedPoints];
	_unitG setVariable [("Busy" + _unitvar), false];
	};
	
if (_timer > 24) then {[_unitG, (currentWaypoint _unitG)] setWaypointPosition [position (vehicle _UL), 0]}; 

_MedPoints = _MedPoints - [_Trg];
_HQ setVariable ["RydHQ_MedPoints",_MedPoints];
if not (_HQ getVariable ["RydHQ_SupportRTB",false]) then {if not (_task isEqualTo taskNull) then {[_task,"SUCCEEDED",true] call BIS_fnc_taskSetState}};

_amb enableAI "TARGET";_amb enableAI "AUTOTARGET";
_unitG setVariable [("Busy" + _unitvar), false];

if (((damage _Trg) < 0.1) or ((damage _Trg) >= 0.9) or (isNull (group (_this select 1)))) then {_wounded = _wounded - [_Trg]};
if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markMedSupp" + str (_unitG))};
_lastOne = true;

	{
	if (((group _x) == (group _Trg)) and not (_x == _Trg)) exitwith {_lastOne = false};
	}
foreach _wounded;

if (_lastOne) then 
	{
	_mSupp = _HQ getVariable ["RydHQ_SupportedG",[]];
	_mSupp = _mSupp - [(group _Trg)];
	_HQ setVariable ["RydHQ_SupportedG",_mSupp]
	};

_UL = leader _unitG;if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdEnd,"OrdEnd"] call RYD_AIChatter}};