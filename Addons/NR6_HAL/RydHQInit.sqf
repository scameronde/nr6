
if not (isServer) exitWith {};

if (isNil ("RydHQ_Wait")) then {RydHQ_Wait = 15};

sleep RydHQ_Wait;

_hi = "HAL 1.25.0 RC1 [NR6 Pack] Initialized";

if ((random 100) < 1) then {_hi = "Good morning, Dave."};

_hi remoteExecCall ["systemChat"];

//if (isNil "RYD_Path") then {RYD_Path = "RYD_HAL\"};

RYD_Path = "\NR6_HAL\";

call compile preprocessfile (RYD_Path + "HAC_fnc.sqf");
call compile preprocessfile (RYD_Path + "HAC_fnc2.sqf");
call compile preprocessfile (RYD_Path + "VarInit.sqf");
call compile preprocessfile (RYD_Path + "TaskMenu.sqf");
call compile preprocessfile (RYD_Path + "TaskInitNR6.sqf");
HAL_fnc_getType = compile preprocessFileLineNumbers "A3\modules_f\marta\data\scripts\fnc_getType.sqf";
HAL_fnc_getSize = compile preprocessFileLineNumbers "A3\modules_f\marta\data\scripts\fnc_getSize.sqf";

if (isNil ("RydHQ_Actions")) then {RydHQ_Actions = true};
if (isNil ("RydHQ_ActionsMenu")) then {RydHQ_ActionsMenu = true};
if (isNil ("RydHQ_TaskActions")) then {RydHQ_TaskActions = false};
if (isNil ("RydHQ_SupportActions")) then {RydHQ_SupportActions = false};
if (isNil ("RydHQ_ActionsAceOnly")) then {RydHQ_ActionsAceOnly = false};

if (isNil "RydxHQ_NoRestPlayers") then {RydxHQ_NoRestPlayers = false};
if (isNil "RydxHQ_NoCargoPlayers") then {RydxHQ_NoCargoPlayers = false};
if (isNil "RYD_WS_ArtyMarks") then {RYD_WS_ArtyMarks = false};
if (isNil "RydxHQ_InfoMarkersID") then {RydxHQ_InfoMarkersID = false};

if (isNil "RydxHQ_ReconCargo") then {RydxHQ_ReconCargo = false};

publicVariable "RYD_MP_Sidechat";
publicVariable "RYD_MP_SideRadio";
publicVariable "RYD_MP_orderGetIn";
publicVariable "RYD_MP_unassignVehicle";
publicVariable "RYD_MP_assignedVehicle";
publicVariable "RYD_MP_assignedVehicle2";

publicVariable "RYD_ReqTransport_Actions";
publicVariable "RYD_ReqLogistics_Actions";
publicVariable "RYD_ReqLogisticsDelete_Actions";

publicVariable "ActionMfnc";
publicVariable "ACEActionMfnc";
publicVariable "ActionMfncR";
publicVariable "ACEActionMfncR";

publicVariable "NR6_Player_Menu";
publicVariable "NR6_Tasking_Menu";
publicVariable "NR6_Supports_Menu";
publicVariable "NR6_Logistics_Menu";

publicVariable "Action1ct";
publicVariable "Action1fnc";
publicVariable "ACEAction1fnc";
publicVariable "Action2ct";
publicVariable "Action2fnc";
publicVariable "ACEAction2fnc";
publicVariable "Action3ct";
publicVariable "Action3fnc";
publicVariable "ACEAction3fnc";
publicVariable "Action1fncR";
publicVariable "ACEAction1fncR";
publicVariable "Action2fncR";
publicVariable "ACEAction2fncR";
publicVariable "Action3fncR";
publicVariable "ACEAction3fncR";

publicVariable "Action4ct";
publicVariable "Action4fnc";
publicVariable "ACEAction4fnc";
publicVariable "Action4fncR";
publicVariable "ACEAction4fncR";

publicVariable "Action5ct";
publicVariable "Action5fnc";
publicVariable "ACEAction5fnc";
publicVariable "Action5fncR";
publicVariable "ACEAction5fncR";

publicVariable "Action6ct";
publicVariable "Action6fnc";
publicVariable "ACEAction6fnc";
publicVariable "Action6fncR";
publicVariable "ACEAction6fncR";

publicVariable "Action7ct";
publicVariable "Action7fnc";
publicVariable "ACEAction7fnc";
publicVariable "Action7fncR";
publicVariable "ACEAction7fncR";

publicVariable "Action8ct";
publicVariable "Action8fnc";
publicVariable "ACEAction8fnc";
publicVariable "Action8fncR";
publicVariable "ACEAction8fncR";

publicVariable "Action9ct";
publicVariable "Action9fnc";
publicVariable "ACEAction9fnc";
publicVariable "Action9fncR";
publicVariable "ACEAction9fncR";

publicVariable "Action10ct";
publicVariable "Action10fnc";
publicVariable "ACEAction10fnc";
publicVariable "Action10fncR";
publicVariable "ACEAction10fncR";

publicVariable "Action11ct";
publicVariable "Action11fnc";
publicVariable "ACEAction11fnc";
publicVariable "Action11fncR";
publicVariable "ACEAction11fncR";

publicVariable "Action12ct";
publicVariable "Action12fnc";
publicVariable "ACEAction12fnc";
publicVariable "Action12fncR";
publicVariable "ACEAction12fncR";

publicVariable "Action13ct";
publicVariable "Action13fnc";
publicVariable "ACEAction13fnc";
publicVariable "Action13fncR";
publicVariable "ACEAction13fncR";

publicVariable "ActionGTct";
publicVariable "ActionArtct";
publicVariable "ActionArt2ct";


if (RydHQ_RHQCheck) then {[] call RYD_RHQCheck};

RydxHQ_AllLeaders = [];
RydxHQ_AllHQ = [];

_clB = [(profilenamespace getvariable ['Map_BLUFOR_R',0]),(profilenamespace getvariable ['Map_BLUFOR_G',1]),(profilenamespace getvariable ['Map_BLUFOR_B',1]),(profilenamespace getvariable ['Map_BLUFOR_A',0.8])];
_clO = [(profilenamespace getvariable ['Map_OPFOR_R',0]),(profilenamespace getvariable ['Map_OPFOR_G',1]),(profilenamespace getvariable ['Map_OPFOR_B',1]),(profilenamespace getvariable ['Map_OPFOR_A',0.8])];
_clI = [(profilenamespace getvariable ['Map_Independent_R',0]),(profilenamespace getvariable ['Map_Independent_G',1]),(profilenamespace getvariable ['Map_Independent_B',1]),(profilenamespace getvariable ['Map_Independent_A',0.8])];
_clU = [(profilenamespace getvariable ['Map_Unknown_R',0]),(profilenamespace getvariable ['Map_Unknown_G',1]),(profilenamespace getvariable ['Map_Unknown_B',1]),(profilenamespace getvariable ['Map_Unknown_A',0.8])];

/*RydHQ_CallSignsA = [RydHQ_CallSignsA] call RYD_RandomOrdB;

	{
	_nouns = [_x] call RYD_RandomOrdB;
	RydHQ_CallSignsN set [_foreachIndex,_nouns]
	}
foreach RydHQ_CallSignsN;*/

if not (isNull leaderHQ) then 
	{
	_gp = group leaderHQ;
	RydxHQ_AllLeaders set [(count RydxHQ_AllLeaders),leaderHQ];
	RydxHQ_AllHQ set [(count RydxHQ_AllHQ),_gp];
	_gp setVariable ["RydHQ_CodeSign","A"];
			
	if not (isNil ("HET_FA")) then 
		{
		_gp setVariable ["RydHQ_Front",HET_FA]
		}
	};
	
if not (isNull leaderHQB) then 
	{
	_gp = group leaderHQB;
	RydxHQ_AllLeaders set [(count RydxHQ_AllLeaders),leaderHQB];
	RydxHQ_AllHQ set [(count RydxHQ_AllHQ),_gp];
	_gp setVariable ["RydHQ_CodeSign","B"];
	
	if not (isNil ("HET_FB")) then 
		{
		_gp setVariable ["RydHQ_Front",HET_FB]
		}
	};
	
if not (isNull leaderHQC) then 
	{
	_gp = group leaderHQC;
	RydxHQ_AllLeaders set [(count RydxHQ_AllLeaders),leaderHQC];
	RydxHQ_AllHQ set [(count RydxHQ_AllHQ),_gp];
	_gp setVariable ["RydHQ_CodeSign","C"];
	
	if not (isNil ("HET_FC")) then 
		{
		_gp setVariable ["RydHQ_Front",HET_FC]
		}
	};
	
if not (isNull leaderHQD) then 
	{
	_gp = group leaderHQD;
	RydxHQ_AllLeaders set [(count RydxHQ_AllLeaders),leaderHQD];
	RydxHQ_AllHQ set [(count RydxHQ_AllHQ),_gp];
	_gp setVariable ["RydHQ_CodeSign","D"];
	
	if not (isNil ("HET_FD")) then 
		{
		_gp setVariable ["RydHQ_Front",HET_FD]
		}
	};
	
if not (isNull leaderHQE) then 
	{
	_gp = group leaderHQE;
	RydxHQ_AllLeaders set [(count RydxHQ_AllLeaders),leaderHQE];
	RydxHQ_AllHQ set [(count RydxHQ_AllHQ),_gp];
	_gp setVariable ["RydHQ_CodeSign","E"];
	
	if not (isNil ("HET_FE")) then 
		{
		_gp setVariable ["RydHQ_Front",HET_FE]
		}
	};
	
if not (isNull leaderHQF) then 
	{
	_gp = group leaderHQF;
	RydxHQ_AllLeaders set [(count RydxHQ_AllLeaders),leaderHQF];
	RydxHQ_AllHQ set [(count RydxHQ_AllHQ),_gp];
	_gp setVariable ["RydHQ_CodeSign","F"];
	
	if not (isNil ("HET_FF")) then 
		{
		_gp setVariable ["RydHQ_Front",HET_FF]
		}
	};
	
if not (isNull leaderHQG) then 
	{
	_gp = group leaderHQG;
	RydxHQ_AllLeaders set [(count RydxHQ_AllLeaders),leaderHQG];
	RydxHQ_AllHQ set [(count RydxHQ_AllHQ),_gp];
	_gp setVariable ["RydHQ_CodeSign","G"];
	
	if not (isNil ("HET_FG")) then 
		{
		_gp setVariable ["RydHQ_Front",HET_FG]
		}
	};
	
if not (isNull leaderHQH) then 
	{
	_gp = group leaderHQH;
	RydxHQ_AllLeaders set [(count RydxHQ_AllLeaders),leaderHQH];
	RydxHQ_AllHQ set [(count RydxHQ_AllHQ),_gp];
	_gp setVariable ["RydHQ_CodeSign","H"];
	
	if not (isNil ("HET_FH")) then 
		{
		_gp setVariable ["RydHQ_Front",HET_FH]
		}
	};

[] call compile preprocessfile (RYD_Path + "Front.sqf");

if (RydHQ_TimeM) then 
	{
	[([player] + (switchableUnits - [player]))] call RYD_TimeMachine
	};
	
if (RydBB_Active) then 
	{
	call compile preprocessfile (RYD_Path + "Boss_fnc.sqf");
	RydBBa_InitDone = false;
	RydBBb_InitDone = false;

		{
		if ((count (_x select 0)) > 0) then 
			{
			if ((_x select 1) == "A") then {RydBBa_Init = false};
			_BBHQs = _x select 0;
			_BBHQGrps = [];

				{
				_BBHQGrps set [(count _BBHQGrps),(group _x)]
				}
			foreach _BBHQs;

				{
				_x setVariable ["BBProgress",0]
				}
			foreach _BBHQGrps;
			[[_x,_BBHQGrps],Boss] call RYD_Spawn
			};

		sleep 1;
		}
	foreach [[RydBBa_HQs,"A"],[RydBBb_HQs,"B"]];
	};

if (((RydHQ_Debug) or (RydHQB_Debug) or (RydHQC_Debug) or (RydHQD_Debug) or (RydHQE_Debug) or (RydHQF_Debug) or (RydHQG_Debug) or (RydHQH_Debug)) and (RydHQ_DbgMon)) then {[[],RYD_DbgMon] call RYD_Spawn};

if not (isNull leaderHQ) then {publicVariable "leaderHQ";[[(group leaderHQ)],A_HQSitRep] call RYD_Spawn;[[(group leaderHQ)],HAL_FBFTLOOP] call RYD_Spawn; [[(group leaderHQ)],HAL_SecTasks] call RYD_Spawn; sleep 5};
if not (isNull leaderHQB) then {publicVariable "leaderHQB";[[(group leaderHQB)],B_HQSitRep] call RYD_Spawn;[[(group leaderHQB)],HAL_FBFTLOOP] call RYD_Spawn; [[(group leaderHQB)],HAL_SecTasks] call RYD_Spawn; sleep 5};
if not (isNull leaderHQC) then {publicVariable "leaderHQC";[[(group leaderHQC)],C_HQSitRep] call RYD_Spawn;[[(group leaderHQC)],HAL_FBFTLOOP] call RYD_Spawn; [[(group leaderHQC)],HAL_SecTasks] call RYD_Spawn; sleep 5};
if not (isNull leaderHQD) then {publicVariable "leaderHQD";[[(group leaderHQD)],D_HQSitRep] call RYD_Spawn;[[(group leaderHQD)],HAL_FBFTLOOP] call RYD_Spawn; [[(group leaderHQD)],HAL_SecTasks] call RYD_Spawn; sleep 5};
if not (isNull leaderHQE) then {publicVariable "leaderHQE";[[(group leaderHQE)],E_HQSitRep] call RYD_Spawn;[[(group leaderHQE)],HAL_FBFTLOOP] call RYD_Spawn; [[(group leaderHQE)],HAL_SecTasks] call RYD_Spawn; sleep 5};
if not (isNull leaderHQF) then {publicVariable "leaderHQF";[[(group leaderHQF)],F_HQSitRep] call RYD_Spawn;[[(group leaderHQF)],HAL_FBFTLOOP] call RYD_Spawn; [[(group leaderHQF)],HAL_SecTasks] call RYD_Spawn; sleep 5};
if not (isNull leaderHQG) then {publicVariable "leaderHQG";[[(group leaderHQG)],G_HQSitRep] call RYD_Spawn;[[(group leaderHQG)],HAL_FBFTLOOP] call RYD_Spawn; [[(group leaderHQG)],HAL_SecTasks] call RYD_Spawn; sleep 5};
if not (isNull leaderHQH) then {publicVariable "leaderHQH";[[(group leaderHQH)],H_HQSitRep] call RYD_Spawn;[[(group leaderHQH)],HAL_FBFTLOOP] call RYD_Spawn; [[(group leaderHQH)],HAL_SecTasks] call RYD_Spawn; sleep 5};

if ((count RydHQ_GroupMarks) > 0) then
	{	
	[RydHQ_GroupMarks,RYD_GroupMarkerLoop] call RYD_Spawn
	};

if (RydHQ_Actions) then {
nul = [] execVM  (RYD_Path + "SquadTaskingNR6.sqf");
};