private["_position","_tent","_location","_isOk","_backpack","_tentType","_trg","_key"];
//check if can pitch here
call gear_ui_init;
_playerPos = 	getPosATL player;
_item = _this;
_hastentitem = _this in magazines player;
_location = player modeltoworld [0,2.5,0];
_location set [2,0];
_building = nearestObject [(vehicle player), "HouseBase"];
_isOk = [(vehicle player),_building] call fnc_isInsideBuilding;
//_isOk = true;

//diag_log ("Pitch Tent: " + str(_isok) );

_config = configFile >> "CfgMagazines" >> _item;
_text = getText (_config >> "displayName");

if (!_hastentitem) exitWith {cutText [format[(localize "str_player_31"),_text,"pitch"] , "PLAIN DOWN"]};

//blocked
if (["concrete",dayz_surfaceType] call fnc_inString) then { _isOk = true; diag_log ("surface concrete"); };
//Block Tents in pounds
_objectsPond = 		nearestObjects [_playerPos, [], 10];
	{
		_isPond = ["pond",str(_x),false] call fnc_inString;
		if (_isPond) then {
			_pondPos = (_x worldToModel _playerPos) select 2;
			if (_pondPos < 0) then {
				_isOk = true;
			};
		};
	} forEach _objectsPond;

//diag_log ("Pitch Tent: " + str(_isok) );

if (!_isOk) then {
	//remove tentbag
	player removeMagazine _item;
	_dir = round(direction player);	
	
	//wait a bit
	player playActionNow "Medic";
	sleep 1;
	[player,"tentunpack",0,false] call dayz_zombieSpeak;
	
	_id = [player,50,true,(getPosATL player)] spawn player_alertZombies;
	
	sleep 5;
	//place tent (local)
	_tent = createVehicle ["VaultStorageLocked", _location, [], 0, "CAN_COLLIDE"];
	_tent setdir _dir;
	_tent setpos _location;
	player reveal _tent;
	_location = getPosATL _tent;

	_tent setVariable ["characterID",dayz_characterID,true];

	//player setVariable ["tentUpdate",["Land_A_tent",_dir,_location,[dayz_tentWeapons,dayz_tentMagazines,dayz_tentBackpacks]],true];

	dayzPublishObj = [dayz_characterID,_tent,[_dir,_location],"VaultStorageLocked"];
	publicVariable "dayzPublishObj";
	if (isServer) then {
		dayzPublishObj call server_publishObj;
	};
	
	cutText ["You have setup your vault", "PLAIN DOWN"];
} else {
	cutText ["You cannot place a Vault here. The area must be flat, and free of other objects", "PLAIN DOWN"];
};

