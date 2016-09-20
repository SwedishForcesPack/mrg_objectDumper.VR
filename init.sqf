enableSaving [false, false];

if (isServer) then {
	// Prefixes used by each mod (e.g. "CUP", "UK3CB", "RHS", etc.)
	// Leave empty to spawn all (incl. vanilla)
	_modPrefixes = ["sfp"];

	// Scope search (private = 0, protected = 1, public = 2)
	// 2 = Editor units (recommended)
	// 0/1 = Base classes, wrecks, etc.
	_scope = 2;


	// Exec
	[_modPrefixes, _scope] execVM "mrg_objectDumper.sqf";
};
