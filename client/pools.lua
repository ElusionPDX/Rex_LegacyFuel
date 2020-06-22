local find = function(init,next,stop)
	local h,s,v
	local gc = setmetatable({},{__gc=function()
		if h then
			stop(h)
			h = nil
		end
	end})
	return function()
		if h then
			s,v = next(h)
			if not s then
				stop(h)
				h = nil
				return
			end
		else
			h,v = init()
			if h == -1 then
				collectgarbage()
				h,v = init()
				if h == -1 then
					h = nil
					return
				end
			end
		end
		return v
	end
end
findp = function(...)
	local iter = find(...)
	return function()
		local s,v = pcall(iter)
		if s then
			return v
		end
	end
end
peds = function()
	return findp(FindFirstPed,FindNextPed,EndFindPed)
end
vehicles = function()
	return findp(FindFirstVehicle,FindNextVehicle,EndFindVehicle)
end
objects = function()
	return findp(FindFirstObject,FindNextObject,EndFindObject)
end
pickups = function()
	return findp(FindFirstPickup,FindNextPickup,EndFindPickup)
end
entities = function()
	local i,funcs = 1,{peds(),vehicles(),objects(),pickups()}
	return function()
		while funcs[i] do
			local v = funcs[i]()
			if v ~= nil then
				return v,i
			end
			i = i + 1
		end
	end
end
