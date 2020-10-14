Config = {}

Config.EnableBlips				= true
Config.EnableHUD				= true
Config.EnableJerryCans			= true
Config.EnableBuyableJerryCans	= true -- Coming soon, currently useless
Config.VehicleFailure			= 10 -- At what fuel-percentage should the engine stop functioning properly? (Defualt: 10)
Config.FrozenPumps				= false
Config.DebugStation				= false
Config.Lang						= 'fr'

Config.Classes = {
	[0] = 1.0, -- Compacts
	[1] = 1.0, -- Sedans
	[2] = 1.0, -- SUVs
	[3] = 1.0, -- Coupes
	[4] = 1.0, -- Muscle
	[5] = 1.0, -- Sports Classics
	[6] = 1.0, -- Sports
	[7] = 1.0, -- Super
	[8] = 1.0, -- Motorcycles
	[9] = 1.0, -- Off-road
	[10] = 1.0, -- Industrial
	[11] = 1.0, -- Utility
	[12] = 1.0, -- Vans
	[13] = 0.0, -- Cycles
	[14] = 1.0, -- Boats
	[15] = 1.0, -- Helicopters
	[16] = 1.0, -- Planes
	[17] = 1.0, -- Service
	[18] = 1.0, -- Emergency
	[19] = 1.0, -- Military
	[20] = 1.0, -- Commercial
	[21] = 1.0, -- Trains
}

-- The left part is at percentage RPM, and the right is how much fuel (divided by 10) you want to remove from the tank every second
Config.FuelUsage = {
	[1.0] = 1.4,
	[0.9] = 1.2,
	[0.8] = 1.0,
	[0.7] = 0.9,
	[0.6] = 0.8,
	[0.5] = 0.7,
	[0.4] = 0.5,
	[0.3] = 0.4,
	[0.2] = 0.2,
	[0.1] = 0.1,
	[0.0] = 0.0,
}

Config.FuelConfiguration = {}
Config.FuelConfiguration['1.0'] = {}
Config.FuelConfiguration['1.0']['consume'] = 0.97
Config.FuelConfiguration['1.0']['wait'] = 1000

Config.FuelConfiguration['0.9'] = {}
Config.FuelConfiguration['0.9']['consume'] = 1.1
Config.FuelConfiguration['0.9']['wait'] = 1500

Config.FuelConfiguration['0.8'] = {}
Config.FuelConfiguration['0.8']['consume'] = 1.2
Config.FuelConfiguration['0.8']['wait'] = 2000

Config.FuelConfiguration['0.7'] = {}
Config.FuelConfiguration['0.7']['consume'] = 1.3
Config.FuelConfiguration['0.7']['wait'] = 3000

Config.FuelConfiguration['0.6'] = {}
Config.FuelConfiguration['0.6']['consume'] = 1.4
Config.FuelConfiguration['0.6']['wait'] = 4000

Config.FuelConfiguration['0.5'] = {}
Config.FuelConfiguration['0.5']['consume'] = 1.5
Config.FuelConfiguration['0.5']['wait'] = 5000

Config.FuelConfiguration['0.4'] = {}
Config.FuelConfiguration['0.4']['consume'] = 1.5
Config.FuelConfiguration['0.4']['wait'] = 6000

Config.FuelConfiguration['0.3'] = {}
Config.FuelConfiguration['0.3']['consume'] = 1.5
Config.FuelConfiguration['0.3']['wait'] = 7000

Config.FuelConfiguration['0.2'] = {}
Config.FuelConfiguration['0.2']['consume'] = 1.5
Config.FuelConfiguration['0.2']['wait'] = 8000

Config.FuelConfiguration['0.1'] = {}
Config.FuelConfiguration['0.1']['consume'] = 1.5
Config.FuelConfiguration['0.1']['wait'] = 15000

Config.gas_stations = {
	{ ['x'] = 49.4187,   ['y'] = 2778.793,  ['z'] = 58.043},
		{ ['x'] = 263.894,   ['y'] = 2606.463,  ['z'] = 44.983},
		{ ['x'] = 1039.958,  ['y'] = 2671.134,  ['z'] = 39.550},
		{ ['x'] = 1207.260,  ['y'] = 2660.175,  ['z'] = 37.899},
		{ ['x'] = 2539.685,  ['y'] = 2594.192,  ['z'] = 37.944},
		{ ['x'] = 2679.858,  ['y'] = 3263.946,  ['z'] = 55.240},
		{ ['x'] = 2005.055,  ['y'] = 3773.887,  ['z'] = 32.403},
		{ ['x'] = 1687.156,  ['y'] = 4929.392,  ['z'] = 42.078},
		{ ['x'] = 1701.314,  ['y'] = 6416.028,  ['z'] = 32.763},
		{ ['x'] = 179.857,   ['y'] = 6602.839,  ['z'] = 31.868},
		{ ['x'] = -94.4619,  ['y'] = 6419.594,  ['z'] = 31.489},
		{ ['x'] = -2554.996, ['y'] = 2334.40,  ['z'] = 33.078},
		{ ['x'] = -1800.375, ['y'] = 803.661,  ['z'] = 138.651},
		{ ['x'] = -1437.622, ['y'] = -276.747,  ['z'] = 46.207},
		{ ['x'] = -2096.243, ['y'] = -320.286,  ['z'] = 13.168},
		{ ['x'] = -724.619, ['y'] = -935.1631,  ['z'] = 19.213},
		{ ['x'] = -526.019, ['y'] = -1211.003,  ['z'] = 18.184},
		{ ['x'] = -70.2148, ['y'] = -1761.792,  ['z'] = 29.534},
		{ ['x'] = 265.648,  ['y'] = -1261.309,  ['z'] = 29.292},
		{ ['x'] = 819.653,  ['y'] = -1028.846,  ['z'] = 26.403},
		{ ['x'] = 1208.951, ['y'] =  -1402.567, ['z'] = 35.224},
		{ ['x'] = 1181.381, ['y'] =  -330.847,  ['z'] = 69.316},
		{ ['x'] = 620.843,  ['y'] =  269.100,  ['z'] = 103.089},
		{ ['x'] = 2581.321, ['y'] = 362.039, ['z'] = 108.468}
}


Config.Translate = {};
Config.Translate['fr'] = {};
Config.Translate['fr']['exit_vehicle_for_refuel'] = '~R~Sortez~W~ pour faire le plein';	
Config.Translate['fr']['refuel_current_price'] = '~g~G ~w~Pour annuler le plein. Prix:~r~%d $ ~w~+  tax';	
Config.Translate['fr']['full_fuel'] = 'Votre reservoir est deja plein!';
Config.Translate['fr']['not_enough_fuel'] = "Vous n\'avez actuellement pas d'argent pour acheter du carburant";
Config.Translate['fr']['can_fuel'] = "Press ~g~E ~w~Pour faire le plein.";
Config.Translate['fr']['empty_station'] = "Cette station est vide!";
Config.Translate['fr']['refuel_with_jerycan'] = "Press ~g~E ~w~ pour annuler le ravitaillement du vehicule. Reservoir: %d% - Jerry Can: %d";
Config.Translate['fr']['can_refuel_with_jerycan'] = "~g~E ~w~pour faire le plein du vehicule avec votre bidon d'essence";