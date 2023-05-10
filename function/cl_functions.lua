-- [[ AI Dialog ]] --
function MissionText(text, time)
    BeginTextCommandPrint("STRING")
    AddTextComponentString(text)
    EndTextCommandPrint(time, false)
end

-- [[ Vehicle Performance Mods ]] --
local performanceModIndices = { 11, 12, 13, 15, 16 }
function PerformanceUpgrades(vehicle)
    local max
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        SetVehicleModKit(vehicle, 0)
        for _, modType in ipairs(performanceModIndices) do
            max = GetNumVehicleMods(vehicle, tonumber(modType)) - 1
            SetVehicleMod(vehicle, modType, max)
        end
        ToggleVehicleMod(vehicle, 18, true) -- Turbo
	    SetVehicleFixed(vehicle)
    end
end

-- [[ Check if Vehicle = Config ]] --
function isDrugRunCar(vehicle)
    for k, v in pairs(Config.VehicleSettings['Vehicles']) do
        if GetEntityModel(vehicle) == joaat(v) then
            return true
        end
    end
    return false
end

-- [[ Set The Vehicle Items ]] --
VehicleItems = {
    [1] = {
        name = "weed_brick",
        amount = 22,
        info = {},
        type = "item",
        slot = 1,
    },
}

function SetCarItemsInfo()
	local items = {}
	for k, item in pairs(VehicleItems) do
		local itemInfo = QBCore.Shared.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = item.info,
			label = itemInfo["label"],
			description = itemInfo["description"] and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = item.slot,
		}
	end
	
	VehicleItems = items
end

function newCounter()
    local i = 0
    return function()
       i = i + 1
       return i
    end
end

c1 = newCounter()

-- [[ Tracker Blips ]] --
CreateThread(function()
	while true do
		Wait(0)
		if Events.VehicleDistanceHasBeenTriggered and not Events.VehicleBlipsHavePassed then
			if tonumber(c1()) > Config.GlobalSettings['Tracker']['TrackerAmount'] then
				TriggerEvent("LENT-CliffordRun:Client:SetCoords")

				Events.VehicleBlipsHavePassed = true
			else
				Wait(Config.GlobalSettings['Tracker']['PassedTime'])
				local ped = PlayerPedId()
				local vehicle = GetVehiclePedIsIn(ped, true)

				c1()

				TriggerEvent('LENT-Clifford:Client:SendAlert', vehicle)
			end
		end
	end
end)

RegisterNetEvent('LENT-Clifford:Client:SendAlert', function(vehicle)
	exports['ps-dispatch']:CliffordRunReport(vehicle)
end)