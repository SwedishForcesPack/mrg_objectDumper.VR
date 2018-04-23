/*
	Name: Object Dumper
	Author: MisterGoodson ( http://forums.bistudio.com/member.php?141895 )
	Version: 1.0

	Description:
		Spawns all units/vehicles/weapons/objects associated with a given list of mods.
		Purpose is to help identify errors generated by mods (by reviewing RPT logs),
		without having to manually place down all objects in the editor one by one.
		This script was originally created for 3 Commando Brigade to help identify the
		'bugginess' of a mod before it's approved for use in our missions.

		Could also be used as a playground to explore all mod assets ;)

	Usage:
		Execute script via execVM.

	Parameters:
		0: Array - Mod folder names to spawn. Provide empty array to scan all (incl. vanilla)
		1: Integer - Scope of objects to search for (private = 0, protected = 1, public = 2)
					 2 = Editor units (recommended)
					 0/1 = Base classes, wrecks, etc.

Example:
	[["CUP", "UK3CB", "RHS"], 2] execVM "mrg_objectDumper.sqf";
*/

if (!isServer) exitWith {};
diag_log "==================================================";
diag_log "Object Dumper: Started.";

_mods = _this select 0;
_scope = _this select 1;
_crew = _this select 2;

_trimStart = 27; // Trims up to "bin\config.bin/CfgVehicles/"
_spawnPos = getMarkerPos "spawn";

_conditionString = "";
_configUnits = [];
_configVehicles = [];
_unitClassnames = [];
_vehicleClassnames = [];
_unitsSpawned = 0;
_vehiclesSpawned = 0;

// Get all units
if (count _mods < 1) then { // Get all vanilla units if no mod prefixes given
	_conditionString = format["((configName _x) isKindOf 'Man') && (getNumber (_x >> 'scope') == %1)", _scope];
	_configUnits = _conditionString configClasses (configFile >> "CfgVehicles");
} else {
	_conditionString = format["((configName _x) isKindOf 'Man') && (getNumber (_x >> 'scope') == %1)", _scope];
	_units = (_conditionString configClasses (configFile >> "CfgVehicles"));
	{
		if ((toLower (configSourceMod _x)) in _mods) then {
			_configUnits pushBack _x;
		};
	} forEach _units;
};
{
	_unitClassnames pushBack ([format["%1 ", _x], _trimStart, -1] call bis_fnc_trimString); // Get classname only
} forEach _configUnits;

// Get all objects
if (count _mods < 1) then { // Get all vanilla objects if no mod prefixes given
	_conditionString = format["(!((configName _x) isKindOf 'Man')) && (getNumber (_x >> 'scope') == %1)", _scope];
	_configVehicles = _conditionString configClasses (configFile >> "CfgVehicles");
} else {
	_conditionString = format["(!((configName _x) isKindOf 'Man')) && (getNumber (_x >> 'scope') == %1)", _scope];
	_vehicles = (_conditionString configClasses (configFile >> "CfgVehicles"));
	{
		if ((toLower (configSourceMod _x)) in _mods) then {
			_configVehicles pushBack _x;
		};
	} forEach _vehicles;
};
{
	_vehicleClassnames pushBack ([format["%1 ", _x], _trimStart, -1] call bis_fnc_trimString); // Get classname only
} forEach _configVehicles;


waitUntil {!isNull player && player == player};

_rowLength = 20;
_spacing = 3;
_cursorX = (_spawnPos select 0) - _spacing;
_cursorY = _spawnPos select 1;

// Spawn units
diag_log "==================================================";
diag_log "Object Dumper: Spawning units...";
diag_log "==================================================";
_grp = createGroup CIVILIAN;
{
	// Move spawn pos 'cursor'
	_cursorX = _cursorX + _spacing;
	if (_forEachIndex % _rowLength == 0) then { // Start new row when rowLength reached
		_cursorX = (_spawnPos select 0) - _spacing ; // Reset x pos
		_cursorY = _cursorY - _spacing; // Drop Y pos
	};

	if (_forEachIndex % 10 == 0) then { // Create new group for every 10 units
		_grp = createGroup CIVILIAN;
	};

	diag_log format["Spawning unit: %1", _x];
	systemChat format["Spawning unit: %1", _x];
	_unit = _grp createUnit [_x, [_cursorX, _cursorY], [], 0, "NONE"];
	_unit setBehaviour "CARELESS";
	_unit switchMove "";
	_unit disableAI "ANIM";
	_unit disableAI "MOVE";
	_unit disableAI "TARGET";
	_unit disableAI "AUTOTARGET";
	_unit disableAI "FSM";
	[_unit] joinSilent _grp;
	curator addCuratorEditableObjects [[_unit], false];

	if (!isNull _unit) then {
		_unitsSpawned = _unitsSpawned + 1;
	};

	_mkr = createMarker [str(_unit), getPosATL _unit];
	_mkr setMarkerShape "ICON";
	_mkr setMarkerType "mil_dot";
	_mkr setMarkerText _x;

	sleep 0.01;
} forEach _unitClassnames;


// Spawn objects
diag_log "==================================================";
diag_log "Object Dumper: Spawning objects...";
diag_log "==================================================";
_spacing = 20;
_cursorX = (_spawnPos select 0) - _spacing;
_cursorY = _cursorY - _spacing; // Carry on from previous position

{
	// Move spawn pos 'cursor'
	_cursorX = _cursorX + _spacing;
	if (_forEachIndex % _rowLength == 0) then { // Start new row when rowLength reached
		_cursorX = (_spawnPos select 0) - _spacing ; // Reset x pos
		_cursorY = _cursorY - _spacing; // Drop Y pos
	};

	diag_log format["Spawning object: %1", _x];
	systemChat format["Spawning object: %1", _x];
	_veh = createVehicle [_x, [_cursorX, _cursorY], [], 0, "NONE"];
	curator addCuratorEditableObjects [[_veh], false];

	if (!isNull _veh) then {
		if (_crew > 0) then {
			createVehicleCrew _veh;
		};
		
		_vehiclesSpawned = _vehiclesSpawned + 1;
	};

	_mkr = createMarker [str(_veh), getPosATL _veh];
	_mkr setMarkerShape "ICON";
	_mkr setMarkerType "mil_dot";
	_mkr setMarkerText _x;

	sleep 0.01;
} forEach _vehicleClassnames;


systemChat "==================================================";
systemChat format["Done. Units spawned: %1 | Objects spawned: %2", _unitsSpawned, _vehiclesSpawned];
systemChat "==================================================";

diag_log "==================================================";
diag_log "Object Dumper: Finished.";
diag_log "==================================================";
