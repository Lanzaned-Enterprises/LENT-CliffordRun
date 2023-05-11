local QBCore = exports['qb-core']:GetCoreObject()

-- [[ Resource Metadata ]] --
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        RemoveBlip(VehicleBlip)
        RemoveBlip(BuyerBlip)
    end
end)

-- [[ Variables ]] --
local pedSpawned2 = false
local PedCreated2 = {}

local VehicleBlip = nil
local BuyerBlip = nil

-- [[ Functions ]] --
local VehicleItems = {
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

-- [[ Net Events ]] --
RegisterNetEvent('LENT-CliffordRun:Client:StartMainEvent', function()
    if Config.GlobalSettings['UseClifford'] then
        MissionText("~b~Clifford: ~w~Set Config for Clifford to false!", 5000)

        local Clifford = exports['LENT-Clifford']:isLoggedIntoClifford()
        if Clifford then
            if Objectives.HasRunBeenStarted or Objectives.HasRunBeenCompleted then
                MissionText("~b~Clifford Goon: ~w~Hey! This mission won't complete itself!", 5000)
            else
                MissionText("~b~Clifford Goon: ~w~I left a location on your ~g~GPS~w~!", 5000)
                local GetCoords = Config.Coords['StartingCoords']
                local SetCoords = (GetCoords[math.random(#GetCoords)])
                VehicleBlip = AddBlipForCoord(SetCoords.x, SetCoords.y, SetCoords.z)
    
                SetBlipSprite(VehicleBlip, 821)
                SetBlipColour(VehicleBlip, 5)
                SetBlipScale(VehicleBlip, 0.8)
                
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Vehicle Location")
                EndTextCommandSetBlipName(VehicleBlip)
                
                SetBlipRoute(VehicleBlip, true)
                SetBlipRouteColour(VehicleBlip, 5)
                TriggerEvent("LENT-CliffordRun:Client:SpawnVehicle", SetCoords)
                Objectives.HasRunBeenStarted = true
            end
        else
            MissionText("~b~Clifford: ~w~You will need to sign into the system first!", 5000)
        end
    else
        if Objectives.HasRunBeenStarted or Objectives.HasRunBeenCompleted then
            MissionText("~b~Clifford Goon: ~w~Hey! This mission won't complete itself!", 5000)
        else
            MissionText("~b~Clifford Goon: ~w~I left a location on your ~g~GPS~w~!", 5000)
            local GetCoords = Config.Coords['StartingCoords']
            local SetCoords = (GetCoords[math.random(#GetCoords)])
            VehicleBlip = AddBlipForCoord(SetCoords.x, SetCoords.y, SetCoords.z)
    
            SetBlipSprite(VehicleBlip, 821)
            SetBlipColour(VehicleBlip, 5)
            SetBlipScale(VehicleBlip, 0.8)
            
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Vehicle Location")
            EndTextCommandSetBlipName(VehicleBlip)
            
            SetBlipRoute(VehicleBlip, true)
            SetBlipRouteColour(VehicleBlip, 5)
            TriggerEvent("LENT-CliffordRun:Client:SpawnVehicle", SetCoords)
            Objectives.HasRunBeenStarted = true
        end
    end
    
end)

RegisterNetEvent('LENT-CliffordRun:Client:EndCliffordRun', function()
    if Objectives.HasRunBeenStarted then
        if QBCore.Functions.HasItem('weed_brick', 22) then
            TriggerServerEvent('LENT-CliffordRun:Server:EndCliffordRun')
            RemoveBlip(BuyerBlip)
            Objectives.HasRunBeenStarted = false
            Objectives.HasRunBeenCompleted = true
        end
    end
end)

-- [[ Other Net Events ]] --
RegisterNetEvent('LENT-Clifford:Client:SendFinalEmail', function()
    local coords = GetEntityCoords(PlayerPedId())
    local closestVehicle, distance = QBCore.Functions.GetClosestVehicle(coords)
    if distance < 100 then 
        local DrugRunCar = isDrugRunCar(closestVehicle)
        if DrugRunCar then
            NetworkRequestControlOfEntity(closestVehicle)
            QBCore.Functions.DeleteVehicle(closestVehicle)
        else
            print("closest vehicle was not the right car")
        end        
    else
        print("no vehicle was nearby")
    end

    TriggerEvent('LENT-CliffordRun:Client:DeletePeds')

    TriggerServerEvent("qb-phone:server:sendNewMail", {
        sender = Config.EmailSettings['Sender'],
        subject = Config.EmailSettings['Subject'],
        message = Config.EmailSettings['EmailText'],
        button = {}
    })
end)

RegisterNetEvent('LENT-CliffordRun:Client:SpawnVehicle', function(SetCoords)
    local GetVehicleList = Config.VehicleSettings['Vehicles']
    local ChosenVehicle = (GetVehicleList[math.random(#GetVehicleList)])

    if not IsModelInCdimage(ChosenVehicle) then
        return
    end

    RequestModel(ChosenVehicle)

    while not HasModelLoaded(ChosenVehicle) do
        Wait(10)
    end

    local GetAllPlates = Config.VehicleSettings['Plates']
    local SetPlate = (GetAllPlates[math.random(#GetAllPlates)])

    local Vehicle = CreateVehicle(ChosenVehicle, SetCoords.x, SetCoords.y, SetCoords.z, SetCoords.w, true, false)

    SetVehicleNumberPlateText(Vehicle, SetPlate)
    SetCarItemsInfo()
    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(Vehicle))
    TriggerServerEvent("inventory:server:addTrunkItems", QBCore.Functions.GetPlate(Vehicle), VehicleItems)
    SetVehicleDirtLevel(Vehicle, 0.0)
    PerformanceUpgrades(Vehicle)

    exports['cdn-fuel']:SetFuel(Vehicle, 100.0)

    SetModelAsNoLongerNeeded(vehicleCode) -- removes model from game memory as we no longer need it    
end)

RegisterNetEvent('LENT-CliffordRun:Client:SetCoords', function()
    local MyPed = PlayerPedId()
    local MyVehicle = GetVehiclePedIsIn(MyPed, true)

    local GetEndingCoords = Config.Coords['EndingCoords']
    local SetEndingCoords = (GetEndingCoords[math.random(#GetEndingCoords)])

    SetWaypointOff()
    BuyerBlip = AddBlipForCoord(SetEndingCoords.x, SetEndingCoords.y, SetEndingCoords.z)
    
    SetBlipSprite(BuyerBlip, 1)
    SetBlipColour(BuyerBlip, 5)
    SetBlipScale(BuyerBlip, 0.8)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Buyer Location")
    EndTextCommandSetBlipName(BuyerBlip)
    
    SetBlipRoute(BuyerBlip, true)
    SetBlipRouteColour(BuyerBlip, 5)

    local EndingPedsList = {
        ["SetFinalPed"] = {
            ["Ped"] = "mp_m_weed_01",
        },
    }

    for k, v in pairs(EndingPedsList) do        
        for k, v in pairs(EndingPedsList) do
            print(EndingPedsList)
            if not PedCreated2[k] then 
                PedCreated2[k] = {} 
            end
            
            local current = v["Ped"]
            current = type(current) == 'string' and joaat(current) or current
            RequestModel(current)

            while not HasModelLoaded(current) do
                Wait(0)
            end
        
            -- The coords + heading of the Ped
            PedCreated2 = CreatePed(0, current, SetEndingCoords.x, SetEndingCoords.y, SetEndingCoords.z-1, SetEndingCoords.w, false, false)
        
            -- Start the scneario in a basic loop
            TaskStartScenarioInPlace(PedCreated2, "WORLD_HUMAN_CLIPBOARD", true)
        
            -- Let the entity stay in posistion
            FreezeEntityPosition(PedCreated2, true)
            -- Set the ped to be invincible
            SetEntityInvincible(PedCreated2, true)

            -- Block events like bumping
            SetBlockingOfNonTemporaryEvents(PedCreated2, true)
        
            -- Target Stuff.. Read Config
            exports['qb-target']:AddTargetEntity(PedCreated2, {
                options = {
                    {
                        type = "client",
                        event = "LENT-CliffordRun:Client:EndCliffordRun",
                        icon = "fa-solid fa-tablets",
                        label = "Deliver The Goods",
                    },
                },
                distance = 2.0
            })
        
            pedSpawned2 = true
        end
    end
end)

RegisterNetEvent('LENT-CliffordRun:Client:DeletePeds', function()
    print("Debug: Client Delete Peds Event")
    RemoveBlip(VehicleBlip)
    RemoveBlip(BuyerBlip)
    for k, v in pairs(PedCreated2) do
        print("Ped K:" .. k)
        DeletePed(k)
    end
end)

-- [[ Main Thread ]] --
CreateThread(function()
    while true do
        Wait(1)
        if Objectives.HasRunBeenStarted and not Objectives.HasRunBeenCompleted then
            local getStartCoords = Config.Coords['StartingCoords']
            local setStartCoords = (getStartCoords[math.random(#getStartCoords)])
            local getPlayerCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local getVehicleDistance = Vdist(getPlayerCoords.x, getPlayerCoords.y, getPlayerCoords.z, setStartCoords.x, setStartCoords.y, setStartCoords.z)

            if getVehicleDistance <= 20.0 and IsPedGettingIntoAVehicle(GetPlayerPed(-1)) then
                Wait(5000)
                if not Events.VehicleDistanceHasBeenTriggered then
                    if not Events.HasDispatchBeenNotified then
                        RemoveBlip(VehicleBlip)
                        MissionText("~d~Radio: ~w~Keys are in the vehicle for you!", 5000)
                        MissionText("~d~Radio: ~w~The vehicle has " .. Config.GlobalSettings['Tracker']['TrackerAmount'] .. " trackers! Cops are on their way!", 5000)
                        Events.VehicleDistanceHasBeenTriggered = true
                        Events.HasDispatchBeenNotified = true
                    end
                end
            end
        end
    end    
end)

-- [[ Ending Thread ]] --
-- SOON