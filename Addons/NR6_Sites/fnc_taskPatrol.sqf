/* ----------------------------------------------------------------------------
Function: CBA_fnc_taskPatrol

Description:
    A function for a group to randomly patrol a parsed radius and location.

Parameters:
    - Group (Group or Object)

Optional:
    - Position (XYZ, Object, Location or Group)
    - Radius (Scalar)
	- Marker (Marker)
    - Waypoint Count (Scalar)
    - Waypoint Type (String)
    - Behaviour (String)
    - Combat Mode (String)
    - Speed Mode (String)
    - Formation (String)
    - Code To Execute at Each Waypoint (String)
    - TimeOut at each Waypoint (Array [Min, Med, Max])

Example:
    (begin example)
    [this, getMarkerPos "objective1", 50] call CBA_fnc_taskPatrol
    [this, this, 300, 7, "MOVE", "AWARE", "YELLOW", "FULL", "STAG COLUMN", "this call CBA_fnc_searchNearby", [3, 6, 9]] call CBA_fnc_taskPatrol;
    (end)

Returns:
    Nil

Author:
    Rommel

---------------------------------------------------------------------------- */

params [
    ["_group", grpNull, [grpNull, objNull]],
    ["_position", [], [[], objNull, grpNull, locationNull], [2, 3]],
    ["_radius", 100, [0]],
	["_marker", "", [""]],
    ["_count", 3, [0]]
];

_group = _group call CBA_fnc_getGroup;
if !(local _group) exitWith {}; // Don't create waypoints on each machine

_position = [_position, _group] select (_position isEqualTo []);
_position = _position call CBA_fnc_getPos;

if not (_marker == "") then 
{
    // recalculate _position and _radius
    private _markerPos = markerPos _marker;
    private _markerSize = markerSize _marker;
    private _markerShape = markerShape _marker;
    private _markerRadius;
    switch (_markerShape) do
    {
        case "RECTANGLE": {
            private _a = _markerSize select 0;
            private _b = _markerSize select 1;
            _markerRadius = sqrt ((_a*_a) + (_b*_b));
            _position = _markerPos;
            _radius = _markerRadius;
        };
        case "ELLIPSE": {
            private _a = _markerSize select 0;
            private _b = _markerSize select 1;
            _markerRadius = _a max _b;
            _position = _markerPos;
            _radius = _markerRadius;
        };
        default {
            // do not use that marker
            _marker = "";
        };
    };
};

// Clear existing waypoints first
[_group] call CBA_fnc_clearWaypoints;
{
    _x enableAI "PATH";
} forEach units _group;

// Can pass parameters straight through to addWaypoint
_this =+ _this;
_this set [2,-1];
if (count _this > 4) then {
    _this deleteAt 4;
};

// Using angles create better patrol patterns
// Also fixes weird editor bug where all WP are on same position
private _step = 360 / _count;
private _offset = random _step;
for "_i" from 1 to _count do {
    // Gaussian distribution avoids all waypoints ending up in the center
    private _rad = _radius * random [0.1, 0.75, 1];

    // Alternate sides of circle & modulate offset
    private _theta = (_i % 2) * 180 + sin (deg (_step * _i)) * _offset + _step * _i;

    _this set [1, _position getPos [_rad, _theta]];
    _this call NR6_fnc_CBA_AddWaypoint;
};

// Close the patrol loop
_this set [1, _position];
_this set [2, _radius];
_this set [3, _marker];
_this set [4, "CYCLE"];
_this call NR6_fnc_CBA_AddWaypoint;
