local loadedfile = false
local resource = GetCurrentResourceName()
local path = GetResourcePath(resource)
local file = path.."/stations.txt"
local players = {}
local stations = {}

print(path)

--set the random names it will give a staton when found
local names = {

}
names.n = #names

RegisterCommand("refuel", function(source, args, rawCommand)
	if (source > 0) then
		TriggerClientEvent("LegacyFuel:refuelPlayerVehicle", source)
	else
        print("This command was executed by the server console, RCON client, or a resource.")
    end
end)

math.randomseed(os.time())

local saveStations = function()
	local f,m = io.open(file,"w")
	if not f then
		print("FAILED TO SAVE GAS STATIONS: "..tostring(m).."!")
		return
	end
	for id,info in pairs(stations) do
		f:write(id)
		f:write(" ")
		f:write(string.format("%.3f",info.fuel))
		f:write(" ")
		f:write(info.name)
		f:write("\n")
	end
	f:close()
end
local loadStations = function()
	local count,f,m = 0,io.open(file,"r")
	if not f then
		print("FAILED TO LOAD GAS STATIONS: "..tostring(m).."!")
		return
	end
	for line in f:lines() do
		count = count + 1
		local comment = string.find(line,"%s*#")
		if comment then
			line = string.sub(line,1,comment-1)
		end
		if string.find(line,"%S") then
			local a,b,id,fuel,name = string.find(line,"%s*(%S+)%s*(%S+)%s*([^\r\n]+)")
			if id and name and tonumber(fuel) then
				print("LOADED GAS STATION: "..name.." ["..fuel.."] ("..id..").")
				stations[id] = {name=name,fuel=tonumber(fuel)*1.0}
			else
				print("FAILED TO LOAD GAS STATIONS: INVALID LINE #"..count.."!")
				f:close()
				return
			end
		end
	end
	f:close()
	loadedfile = true
end

RegisterServerEvent("LegacyFuel:RequestStation")
AddEventHandler("LegacyFuel:RequestStation",function(id)
	if type(id) ~= "string" then
		return
	end
	
	local station = stations[id]
	if not station then
		station = {fuel=2000.0}
		stations[id] = station
		if names.n == 0 then
			station.name = "Disponible: "
			print(tostring(GetPlayerName(source)).." discovered a new fuel station, but there are no names left! ("..id..")")
		else
			station.name = table.remove(names,math.random(1,names.n))
			names.n = names.n - 1
			print(tostring(GetPlayerName(source)).." discovered a new fuel station: "..station.name..". ("..id..")")
		end
		if loadedfile then
			saveStations()
		end
		for p in pairs(players) do
			TriggerClientEvent("LegacyFuel:SetStationFuel",p,id,station.fuel)
		end
	end
	TriggerClientEvent("LegacyFuel:SpecifyStation",source,id,station.name)
end)
AddEventHandler("onResourceStart",function(name)
	if name == resource then
		loadStations()
	end
end)
AddEventHandler("LegacyFuel:GetStations",function(callback)
	for id,info in pairs(stations) do
		local a,b,x,y,z = string.find(id,"(%S+),(%S+),(%S+)")
		x,y,z = tonumber(x),tonumber(y),tonumber(z)
		if x and y and z then
			callback(id,info.fuel,info.name,x,y,z)
		end
	end
end)

RegisterServerEvent("LegacyFuel:TakeFuel")
AddEventHandler("LegacyFuel:TakeFuel",function(id,fuel)
	local info = stations[id]
	if info and type(fuel) == "number" and fuel > 0 then
		info.fuel = info.fuel - fuel
		if info.fuel < 0 then
			info.fuel = 0.0
		end
		if loadedfile then
			saveStations()
		end
		for p in pairs(players) do
			TriggerClientEvent("LegacyFuel:SetStationFuel",p,id,info.fuel)
		end
	end
end)
RegisterServerEvent("LegacyFuel:GiveFuel")
AddEventHandler("LegacyFuel:GiveFuel",function(id,fuel)
	local info = stations[id]
	if info and fuel > 0 then
		info.fuel = info.fuel + fuel
		if loadedfile then
			saveStations()
		end
		for p in pairs(players) do
			TriggerClientEvent("LegacyFuel:SetStationFuel",p,id,info.fuel)
		end
	end
end)

RegisterServerEvent("LegacyFuel:AskFuel")
AddEventHandler("LegacyFuel:AskFuel",function()
	players[source] = true
	for id,info in pairs(stations) do
		TriggerClientEvent("LegacyFuel:SetStationFuel",source,id,info.fuel)
	end
end)
-----------------------------------------------------
AddEventHandler("playerDropped",function()
	players[source] = nil
end)

RegisterServerEvent('LegacyFuel:PayFuel')
AddEventHandler('LegacyFuel:PayFuel', function(price)
	TriggerEvent("f:getPlayer",source,function(xPlayer)
		local amount  = round(price, 0)
		xPlayer.removeMoney(amount)
	end)
end)

local Vehicles = {
	{ plate = '87OJP476', fuel = 50}
}

RegisterServerEvent('LegacyFuel:UpdateServerFuelTable')
AddEventHandler('LegacyFuel:UpdateServerFuelTable', function(plate, fuel)
	local found = false

	for i = 1, #Vehicles do
		if Vehicles[i].plate == plate then 
			found = true
			
			if fuel ~= Vehicles[i].fuel then
				table.remove(Vehicles, i)
				table.insert(Vehicles, {plate = plate, fuel = fuel})
			end
			break 
		end
	end

	if not found then
		table.insert(Vehicles, {plate = plate, fuel = fuel})
	end
end)

RegisterServerEvent('LegacyFuel:CheckServerFuelTable')
AddEventHandler('LegacyFuel:CheckServerFuelTable', function(plate)
	for i = 1, #Vehicles do
		if Vehicles[i].plate == plate then
			local vehInfo = {plate = Vehicles[i].plate, fuel = Vehicles[i].fuel}

			TriggerClientEvent('LegacyFuel:ReturnFuelFromServerTable', source, vehInfo)

			break
		end
	end
end)
local	ESX = nil

	Citizen.CreateThread(function()
		while not ESX do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(100)
		end
	end)


	RegisterServerEvent('Rex:PayFuel')
	AddEventHandler('Rex:PayFuel', function(price)
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		local xPlayer = ESX.GetPlayerFromId(source)
		local amount = ESX.Math.Round(price)
print("why no take money")
		if price > 0 then
			xPlayer.removeMoney(amount)
		end
	end)


RegisterServerEvent('LegacyFuel:CheckCashOnHand')
AddEventHandler('LegacyFuel:CheckCashOnHand', function()
		local xPlayer = ESX.GetPlayerFromId(source)
		TriggerClientEvent('LegacyFuel:RecieveCashOnHand', source, xPlayer.getMoney())
	end)


function round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end
