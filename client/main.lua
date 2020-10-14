models = {
	[1] = -2007231801,
	[2] = 1339433404,
	[3] = 1694452750,
	[4] = 1933174915,
	[5] = -462817101,
	[6] = -469694731,
	[7] = -164877493
}

blacklistedVehicles = {
	[11] = TR22,
	[10] = TESLAX,
	[1] = BMX,
	[2] = CRUISER,
	[3] = FIXTER,
	[4] = SCORCHER,
	[5] = TRIBIKE,
	[6] = TRIBIKE2,
	[7] = TRIBIKE3,
	[8] = TR22,
	[9] = TESLAX,
}

local debug_stations          = true
local Vehicles 				  = {}
local pumpLoc 				  = {}
local stationId 			  = nil
local stationNames 			  = {count=0,names={},requests={}}
local stationFuel             = {}
local pumpIsEmpty             = false
local nearPump 				  = false
local IsFueling 			  = false
local IsFuelingWithJerryCan   = false
local InBlacklistedVehicle	  = false
local NearVehicleWithJerryCan = false
local price 				  = 0
local cash 					  = 0

local	ESX = nil

Citizen.CreateThread(function()
	while not ESX do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)


local valid = {}
for _,m in ipairs(models) do
	if type(m) == "string" then
		m = GetHashKey(m)
	end
	valid[m] = true
end

Citizen.CreateThread(function()
	local nanoSecond = 0;
	local count,pumps = 0,{}
	while true do
		if (Config.FrozenPumps) then
			FrozenPumps()
		end
		if (Config.DebugStation) then
			DebugStation()
		end
		core()
		nanoSecond = nanoSecond + 1;
		if (nanoSecond == 10000) then
			nanoSecond = 0;
		end
		Citizen.Wait(1)
	end
end)

function FrozenPumps()
	for obj in objects() do
		if not pumps[obj] and valid[GetEntityModel(obj)] then
			FreezeEntityPosition(obj,true)
			SetEntityInvincible(obj,true)
			pumps[obj] = true
			count = count + 1
		end
	end
	if count >= 100 then
		for obj in pairs(pumps) do
			if not DoesEntityExist(obj) then
				pumps[obj] = nil
				count = count - 1
			end
		end
	end
end

function DebugStation()
	local name = nearPump and getStationName(stationId)
	if name then
		SetTextEntry("STRING")
		SetTextCentre(true)
		SetTextOutline()
		AddTextComponentString(name.." ("..tostring(stationFuel[stationId])..")")
		DrawText(0.5,0.2)
	end
end

RegisterNetEvent("LegacyFuel:SpecifyStation")
AddEventHandler("LegacyFuel:SpecifyStation",function(id,name)
	if not stationNames.names[id] then
		stationNames.count = stationNames.count + 1
		stationNames.names[id] = tostring(name)
		stationNames.requests[id] = nil
	end
end)

RegisterNetEvent("LegacyFuel:SetStationFuel")
AddEventHandler("LegacyFuel:SetStationFuel",function(id,fuel)
	stationFuel[id] = fuel
end)

TriggerServerEvent("LegacyFuel:AskFuel")

function getStationName(id)
	if stationNames.names[id] then
		return stationNames.names[id]
	end
	if not stationNames.requests[id] then
		stationNames.requests[id] = true
		TriggerServerEvent("LegacyFuel:RequestStation",id)
	end
end

function getPumpStation(pump)
	local pumps = {}
	
	local function getPumps(root)
		local x1,y1,z1 = table.unpack(GetEntityCoords(root))
		pumps[root] = {x1,y1,z1}
		for obj in objects() do
			if not pumps[obj] and valid[GetEntityModel(obj)] then
				local x2,y2,z2 = table.unpack(GetEntityCoords(obj))
				local dx,dy,dz = x2-x1,y2-y1,z2-z1
				if math.sqrt(dx*dx+dy*dy+dz*dz) < 30 then
					getPumps(obj)
				end
			end
		end
	end
	
	getPumps(pump)
	
	local n,x,y,z = 0,0,0,0
	for obj,pos in pairs(pumps) do
		n = n + 1
		x = x + pos[1]
		y = y + pos[2]
		z = z + pos[3]
	end
	
	local id = string.format("%.1f,%.1f,%.1f",x/n,y/n,z/n)
	return id
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function DrawAdvancedText(x,y ,w,h,sc, text, r,g,b,a,font,jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
	N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
	DrawText(x - 0.1+w, y - 0.02+h)
end

function loadAnimDict(dict)
	while(not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(1)
	end
end

function FuelVehicle()
	local ped 	  = GetPlayerPed(-1)
	local coords  = GetEntityCoords(ped)
	local vehicle = GetPlayersLastVehicle()

	FreezeEntityPosition(ped, true)
	FreezeEntityPosition(vehicle, false)
	SetVehicleEngineOn(vehicle, false, false, false)
	loadAnimDict("timetable@gardener@filling_can")
	TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 1.0, 2, -1, 49, 0, 0, 0, 0)
end

function core()

	if not InBlacklistedVehicle then
		if Timer then
			DisplayHud()
		end

		if nearPump and IsCloseToLastVehicle then
			local vehicle  = GetPlayersLastVehicle()
			local fuel 	   = round(GetVehicleFuelLevel(vehicle), 1)
			
			if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
				DrawText3Ds(pumpLoc['x'], pumpLoc['y'], pumpLoc['z'], Config.Translate[Config.Lang]['exit_vehicle_for_refuel'])
			elseif IsFueling then
				local position = GetEntityCoords(vehicle)

				DrawText3Ds(pumpLoc['x'], pumpLoc['y'], pumpLoc['z'], string.format(Config.Translate[Config.Lang]['exit_vehicle_for_refuel'], price))
				DrawText3Ds(position.x, position.y, position.z + 0.5, fuel .. "%")
				
				DisableControlAction(0, 0, true) -- Changing view (V)
				DisableControlAction(0, 22, true) -- Jumping (SPACE)
				DisableControlAction(0, 23, true) -- Entering vehicle (F)
				DisableControlAction(0, 24, true) -- Punching/Attacking
				DisableControlAction(0, 29, true) -- Pointing (B)
				DisableControlAction(0, 30, true) -- Moving sideways (A/D)
				DisableControlAction(0, 31, true) -- Moving back & forth (W/S)
				DisableControlAction(0, 37, false) -- Weapon wheel
				DisableControlAction(0, 44, true) -- Taking Cover (Q)
				DisableControlAction(0, 56, true) -- F9
				DisableControlAction(0, 82, true) -- Mask menu (,)
				DisableControlAction(0, 140, true) -- Hitting your vehicle (R)
				DisableControlAction(0, 166, true) -- F5
				DisableControlAction(0, 167, true) -- F6
				DisableControlAction(0, 168, true) -- F7
				DisableControlAction(0, 170, true) -- F3
				DisableControlAction(0, 288, true) -- F1
				DisableControlAction(0, 289, true) -- F2
				DisableControlAction(1, 323, true) -- Handsup (X)

				if pumpIsEmpty or IsControlJustReleased(0, 47) then
					if pumpIsEmpty then
						pumpIsEmpty = false
						exports.pNotify:SendNotification({text = "Cette station est vide!",type = "error",timeout = 10000,layout = "centerRight",queue = "left"})
					end
					loadAnimDict("reaction@male_stand@small_intro@forward")
					TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)

					TriggerServerEvent('Rex:PayFuel', price)
					Citizen.Wait(2500)
					ClearPedTasksImmediately(GetPlayerPed(-1))
					FreezeEntityPosition(GetPlayerPed(-1), false)
					FreezeEntityPosition(vehicle, false)

					price = 0
					IsFueling = false
				end
			elseif fuel > 95.0 then
				DrawText3Ds(pumpLoc['x'], pumpLoc['y'], pumpLoc['z'], Config.Translate[Config.Lang]['full_fuel'])
			elseif cash <= 0 then
				DrawText3Ds(pumpLoc['x'], pumpLoc['y'], pumpLoc['z'], Config.Translate[Config.Lang]['not_enough_fuel'])
			else
				DrawText3Ds(pumpLoc['x'], pumpLoc['y'], pumpLoc['z'], Config.Translate[Config.Lang]['can_fuel'])
				
				if IsControlJustReleased(0, 46) then
					if stationFuel[stationId] == 0 then
						exports.pNotify:SendNotification({text = Config.Translate[Config.Lang]['empty_station'], type = "error",timeout = 10000,layout = "centerRight",queue = "left"})
					else
						local vehicle = GetPlayersLastVehicle()
						local plate   = GetVehicleNumberPlateText(vehicle)

						ClearPedTasksImmediately(GetPlayerPed(-1))

						if GetSelectedPedWeapon(GetPlayerPed(-1)) ~= -1569615261 then
							SetCurrentPedWeapon(GetPlayerPed(-1), -1569615261, true)
							Citizen.Wait(1000)
						end

						IsFueling = true

						FuelVehicle()
					end
				end
			end
		elseif NearVehicleWithJerryCan and not nearPump and Config.EnableJerryCans then
			local vehicle  = GetPlayersLastVehicle()
			local coords   = GetEntityCoords(vehicle)
			local fuel 	   = round(GetVehicleFuelLevel(vehicle), 1)
			local jerrycan = GetAmmoInPedWeapon(GetPlayerPed(-1), 883325847)
			
			if IsFuelingWithJerryCan then
				DrawText3Ds(coords.x, coords.y, coords.z + 0.5, string.format(Config.Translate[Config.Lang]['refuel_with_jerycan'], fuel, jerrycan))

				DisableControlAction(0, 0, true) -- Changing view (V)
				DisableControlAction(0, 22, true) -- Jumping (SPACE)
				DisableControlAction(0, 23, true) -- Entering vehicle (F)
				DisableControlAction(0, 24, true) -- Punching/Attacking
				DisableControlAction(0, 29, true) -- Pointing (B)
				DisableControlAction(0, 30, true) -- Moving sideways (A/D)
				DisableControlAction(0, 31, true) -- Moving back & forth (W/S)
				DisableControlAction(0, 37, false) -- Weapon wheel
				DisableControlAction(0, 44, true) -- Taking Cover (Q)
				DisableControlAction(0, 56, true) -- F9
				DisableControlAction(0, 82, true) -- Mask menu (,)
				DisableControlAction(0, 140, true) -- Hitting your vehicle (R)
				DisableControlAction(0, 166, true) -- F5
				DisableControlAction(0, 167, true) -- F6
				DisableControlAction(0, 168, true) -- F7
				DisableControlAction(0, 170, true) -- F3
				DisableControlAction(0, 288, true) -- F1
				DisableControlAction(0, 289, true) -- F2
				DisableControlAction(1, 323, true) -- Handsup (X)

				if IsControlJustReleased(0, 46) then
					loadAnimDict("reaction@male_stand@small_intro@forward")
					TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)

					Citizen.Wait(2500)
					ClearPedTasksImmediately(GetPlayerPed(-1))
					FreezeEntityPosition(GetPlayerPed(-1), false)
					FreezeEntityPosition(vehicle, false)

					IsFuelingWithJerryCan = false
				end
			else
				DrawText3Ds(coords.x, coords.y, coords.z + 0.5, Config.Translate[Config.Lang]['can_refuel_with_jerycan'])

				if IsControlJustReleased(0, 46) then
					local vehicle = GetPlayersLastVehicle()
					local plate   = GetVehicleNumberPlateText(vehicle)

					ClearPedTasksImmediately(GetPlayerPed(-1))

					IsFuelingWithJerryCan = true

					FuelVehicle()
				end
			end
		end
	end
end

RegisterNetEvent('LegacyFuel:refuelVehicle')
AddEventHandler('LegacyFuel:refuelVehicle', function(vehicle, plate, fuel)
	SetVehicleFuelLevel(vehicle, fuel)

	for i = 1, #Vehicles do
		if Vehicles[i].plate == plate then
			TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, round(GetVehicleFuelLevel(vehicle), 1))
			table.remove(Vehicles, i)
			table.insert(Vehicles, {plate = plate, fuel = fuel})
			break
		end
	end
end)

RegisterNetEvent('LegacyFuel:refuelPlayerVehicle')
AddEventHandler('LegacyFuel:refuelPlayerVehicle', function()
	local vehicle  = GetPlayersLastVehicle()
	local plate    = GetVehicleNumberPlateText(vehicle)
	TriggerEvent("LegacyFuel:refuelVehicle", vehicle, plate, 100.0)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)

		if IsFueling then
			local vehicle  = GetPlayersLastVehicle()
			local plate    = GetVehicleNumberPlateText(vehicle)
			local fuel 	   = GetVehicleFuelLevel(vehicle)
			local integer  = math.random(6, 10)
			local fuelthis = integer / 10
			
			if not stationFuel[stationId] then
				fuelthis = 0
			elseif fuelthis < stationFuel[stationId] then
				stationFuel[stationId] = stationFuel[stationId] - fuelthis
			else
				fuelthis = stationFuel[stationId]
				stationFuel[stationId] = 0
			end
			if fuelthis == 0 then
				pumpIsEmpty = true
			else
				TriggerServerEvent("LegacyFuel:TakeFuel",stationId,fuelthis)
			end
			
			local newfuel  = fuel + fuelthis

			price = price + fuelthis * 4.0 * 0.5

			if cash >= price then
				TriggerServerEvent('LegacyFuel:CheckServerFuelTable', plate)
				Citizen.Wait(150)
				
				if newfuel < 100 then
					SetVehicleFuelLevel(vehicle, newfuel)

					for i = 1, #Vehicles do
						if Vehicles[i].plate == plate then
							TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, round(GetVehicleFuelLevel(vehicle), 1))

							table.remove(Vehicles, i)
							table.insert(Vehicles, {plate = plate, fuel = newfuel})

							break
						end
					end
				else
					SetVehicleFuelLevel(vehicle, 100.0)
					loadAnimDict("reaction@male_stand@small_intro@forward")
					TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)

					TriggerServerEvent('LegacyFuel:PayFuel', price)
					Citizen.Wait(2500)
					ClearPedTasksImmediately(GetPlayerPed(-1))
					FreezeEntityPosition(GetPlayerPed(-1), false)
					FreezeEntityPosition(vehicle, false)

					price = 0
					IsFueling = false

					for i = 1, #Vehicles do
						if Vehicles[i].plate == plate then
							TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, round(GetVehicleFuelLevel(vehicle), 1))

							table.remove(Vehicles, i)
							table.insert(Vehicles, {plate = plate, fuel = newfuel})

							break
						end
					end
				end
			else
				SetVehicleFuelLevel(vehicle, newfuel)
				loadAnimDict("reaction@male_stand@small_intro@forward")
				TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)

				TriggerServerEvent('LegacyFuel:PayFuel', price)
				Citizen.Wait(2500)
				ClearPedTasksImmediately(GetPlayerPed(-1))
				FreezeEntityPosition(GetPlayerPed(-1), false)
				FreezeEntityPosition(vehicle, false)

				price = 0
				IsFueling = false

				for i = 1, #Vehicles do
					if Vehicles[i].plate == plate then
						TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, round(GetVehicleFuelLevel(vehicle), 1))

						table.remove(Vehicles, i)
						table.insert(Vehicles, {plate = plate, fuel = newfuel})

						break
					end
				end
			end
		elseif IsFuelingWithJerryCan then
			local vehicle   = GetPlayersLastVehicle()
			local plate     = GetVehicleNumberPlateText(vehicle)
			local fuel 	    = GetVehicleFuelLevel(vehicle)
			local integer   = math.random(6, 10)
			local fuelthis  = integer / 10
			local newfuel   = fuel + fuelthis
			local jerryfuel = fuelthis * 100
			local jerrycurr = GetAmmoInPedWeapon(GetPlayerPed(-1), 883325847)
			local jerrynew  = jerrycurr - jerryfuel

			if jerrycurr >= jerryfuel then
				TriggerServerEvent('LegacyFuel:CheckServerFuelTable', plate)
				Citizen.Wait(150)
				SetPedAmmo(GetPlayerPed(-1), 883325847, round(jerrynew, 0))

				if newfuel < 100 then
					SetVehicleFuelLevel(vehicle, newfuel)

					for i = 1, #Vehicles do
						if Vehicles[i].plate == plate then
							TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, round(GetVehicleFuelLevel(vehicle), 1))

							table.remove(Vehicles, i)
							table.insert(Vehicles, {plate = plate, fuel = newfuel})

							break
						end
					end
				else
					SetVehicleFuelLevel(vehicle, 100.0)
					loadAnimDict("reaction@male_stand@small_intro@forward")
					TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)

					Citizen.Wait(2500)
					ClearPedTasksImmediately(GetPlayerPed(-1))
					FreezeEntityPosition(GetPlayerPed(-1), false)
					FreezeEntityPosition(vehicle, false)

					IsFuelingWithJerryCan = false

					for i = 1, #Vehicles do
						if Vehicles[i].plate == plate then
							TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, round(GetVehicleFuelLevel(vehicle), 1))

							table.remove(Vehicles, i)
							table.insert(Vehicles, {plate = plate, fuel = newfuel})

							break
						end
					end
				end
			else
				loadAnimDict("reaction@male_stand@small_intro@forward")
				TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)

				Citizen.Wait(2500)
				ClearPedTasksImmediately(GetPlayerPed(-1))
				FreezeEntityPosition(GetPlayerPed(-1), false)
				FreezeEntityPosition(vehicle, false)

				IsFuelingWithJerryCan = false

				for i = 1, #Vehicles do
					if Vehicles[i].plate == plate then
						TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, round(GetVehicleFuelLevel(vehicle), 1))

						table.remove(Vehicles, i)
						table.insert(Vehicles, {plate = plate, fuel = newfuel})

						break
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(250)

		if IsPedInAnyVehicle(GetPlayerPed(-1)) then
			Citizen.Wait(2500)

			Timer = true
		else
			Timer = false
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1500)

		nearPump 			 	= false
		IsCloseToLastVehicle 	= false
		found 				 	= false
		NearVehicleWithJerryCan = false

		local myCoords = GetEntityCoords(GetPlayerPed(-1))
		
		for i = 1, #models do
			local closestPump = GetClosestObjectOfType(myCoords.x, myCoords.y, myCoords.z, 1.5, models[i], false, false)
			
			if closestPump ~= nil and closestPump ~= 0 then
				local coords    = GetEntityCoords(closestPump)
				local vehicle   = GetPlayersLastVehicle()
				nearPump = true
				pumpLoc  = {['x'] = coords.x, ['y'] = coords.y, ['z'] = coords.z + 1.2}
				stationId = getPumpStation(closestPump)

				if vehicle ~= nil then
					local vehcoords = GetEntityCoords(vehicle)
					local mycoords  = GetEntityCoords(GetPlayerPed(-1))
					local distance  = GetDistanceBetweenCoords(vehcoords.x, vehcoords.y, vehcoords.z, mycoords.x, mycoords.y, mycoords.z)

					if distance < 3 then
						IsCloseToLastVehicle = true
					end
				end
				break
			end
		end

		if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
			local vehicle = GetPlayersLastVehicle()
			local plate   = GetVehicleNumberPlateText(vehicle)
			local fuel 	  = GetVehicleFuelLevel(vehicle)
			local found   = false

			TriggerServerEvent('LegacyFuel:CheckServerFuelTable', plate)

			Citizen.Wait(500)

			for i = 1, #Vehicles do
				if Vehicles[i].plate == plate then
					found = true
					fuel  = round(Vehicles[i].fuel, 1)

					break
				end
			end

			if not found then
				integer = math.random(200, 800)
				fuel 	= integer / 10

				table.insert(Vehicles, {plate = plate, fuel = fuel})

				TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, fuel)
			end

			SetVehicleFuelLevel(vehicle, fuel)
		end

		local currentVeh = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(GetPlayerPed(-1))))

		for i = 1, #blacklistedVehicles do
			if blacklistedVehicles[i] == currentVeh then
				InBlacklistedVehicle = true
				found 				 = true
				
				break
			end
		end

		if not found then
			InBlacklistedVehicle = false
		end

		if nearPump then
			TriggerServerEvent('LegacyFuel:CheckCashOnHand')
		end

		local CurrentWeapon = GetSelectedPedWeapon(GetPlayerPed(-1))
						
		if CurrentWeapon == 883325847 then
			local MyCoords 		= GetEntityCoords(GetPlayerPed(-1))
			local Vehicle  		= GetClosestVehicle(MyCoords.x, MyCoords.y, MyCoords.z, 3.0, false, 23) == GetPlayersLastVehicle() and GetPlayersLastVehicle() or 0

			if Vehicle ~= 0 then
				NearVehicleWithJerryCan = true
			end
		end
	end
end)

function round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function GetSeatPedIsIn(ped)
	local vehicle = GetVehiclePedIsIn(ped, false)

	for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
		if GetPedInVehicleSeat(vehicle, i) == ped then
			return i
		end
	end

	return -2
end

function DisplayHud()
	if IsPedInAnyVehicle(GetPlayerPed(-1), false) and GetSeatPedIsIn(GetPlayerPed(-1)) == -1 and Config.EnableHUD then
		local vehicle = GetPlayersLastVehicle()
		local fuel    = math.ceil(round(GetVehicleFuelLevel(vehicle), 1))
		local kmh 	  =	round(GetEntitySpeed(vehicle) * 3.6, 0)
		local mph 	  = round(GetEntitySpeed(vehicle) * 2.236936, 0)

		if fuel == 0 then
			fuel = "0"
		end
		if kmh == 0 then
			kmh = "0"
		end
		if mph == 0 then
			mph = "0"
		end

		x = 0.01135
		y = 0.002

		DrawAdvancedText(0.2195 - x, 0.77 - y, 0.005, 0.0028, 0.6, fuel, 255, 255, 255, 255, 6, 1)

		DrawAdvancedText(0.130 - x, 0.77 - y, 0.005, 0.0028, 0.6, mph, 255, 255, 255, 255, 6, 1)
		DrawAdvancedText(0.174 - x, 0.77 - y, 0.005, 0.0028, 0.6, kmh, 255, 255, 255, 255, 6, 1)

		DrawAdvancedText(0.148 - x, 0.7765 - y, 0.005, 0.0028, 0.4, "mp/h              km/h              Fuel", 255, 255, 255, 255, 6, 1)
	end
end

RegisterNetEvent('LegacyFuel:ReturnFuelFromServerTable')
AddEventHandler('LegacyFuel:ReturnFuelFromServerTable', function(vehInfo)
	local fuel   = round(vehInfo.fuel, 1)

	for i = 1, #Vehicles do
		if Vehicles[i].plate == vehInfo.plate then
			table.remove(Vehicles, i)

			break
		end
	end

	table.insert(Vehicles, {plate = vehInfo.plate, fuel = fuel})
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)

		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
		local engine  = Citizen.InvokeNative(0xAE31E7DF9B5B132E, vehicle)

		if vehicle and engine then
			local plate    	   = GetVehicleNumberPlateText(vehicle)
			local rpm 	   	   = GetVehicleCurrentRpm(vehicle)
			local fuel     	   = GetVehicleFuelLevel(vehicle)
			local rpmfuelusage = 0

			local rmp_value = '0.1'

			if rpm > 0.9 then
				rmp_value = '1.0'
			elseif rpm > 0.8 then
				rmp_value = '0.9'
			elseif rpm > 0.7 then
				rmp_value = '0.8'
            elseif rpm > 0.6 then
				rmp_value = '0.7'
            elseif rpm > 0.5 then
				rmp_value = '0.6'
            elseif rpm > 0.4 then
				rmp_value = '0.5'
            elseif rpm > 0.3 then
				rmp_value = '0.4'
            elseif rpm > 0.2 then
				rmp_value = '0.3'
            elseif rpm > 0.1 then
				rmp_value = '0.2'
            else 
				rmp_value = '0.1'
			end
			
			rpmfuelusage = fuel - rpm / Config.FuelConfiguration[rmp_value]['consume']
			Citizen.Wait(Config.FuelConfiguration[rmp_value]['wait'])

			for i = 1, #Vehicles do
				if Vehicles[i].plate == plate then
					SetVehicleFuelLevel(vehicle, rpmfuelusage)

					local updatedfuel = round(GetVehicleFuelLevel(vehicle), 1)

					if updatedfuel ~= 0 then
						TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, updatedfuel)

						table.remove(Vehicles, i)
						table.insert(Vehicles, {plate = plate, fuel = rpmfuelusage})
					end

					break
				end
			end

			if rpmfuelusage < Config.VehicleFailure then
				SetVehicleUndriveable(vehicle, true)
			elseif rpmfuelusage == 0 then
				SetVehicleEngineOn(vehicle, false, false, false)
			else
				SetVehicleUndriveable(vehicle, false)
			end
		end
	end
end)

RegisterNetEvent('LegacyFuel:RecieveCashOnHand')
AddEventHandler('LegacyFuel:RecieveCashOnHand', function(cb)
	cash = cb
end)

Citizen.CreateThread(function()
	if Config.EnableBlips then
		for k, v in ipairs(Config.gas_stations) do
			local blip = AddBlipForCoord(v.x, v.y, v.z)

			SetBlipSprite(blip, 361)
			SetBlipScale(blip, 0.6)
			SetBlipColour(blip, 6)
			SetBlipDisplay(blip, 4)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Station Essences")
			EndTextCommandSetBlipName(blip)
		end
	end
end)
