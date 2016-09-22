enableSaving [false, false];

if (isServer) then {
	// Prefixes used by each mod (e.g. "CUP", "UK3CB", "RHS", etc.)
	// Leave empty to spawn all (incl. vanilla)
	_modPrefixes = ["sfp"];

	// Scope search (private = 0, protected = 1, public = 2)
	// 2 = Editor units (recommended)
	// 0/1 = Base classes, wrecks, etc.
	_scope = 2;

	// Spawn vehicles with crew
	// 0 = Empty vehicles with no crew
	// 1 = Vehicles with crew
	_crew = 0;

	// Exec
	[_modPrefixes, _scope, _crew] execVM "mrg_objectDumper.sqf";
};
