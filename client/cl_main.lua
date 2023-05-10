local QBCore = exports['qb-core']:GetCoreObject()

-- [[ Variables ]] --
local pedSpawned = false
local PedCreated = {}

-- [[ Net Events ]] --
RegisterNetEvent('LENT-CliffordRun:Client:StartMainEvent', function()
    if Config.GlobalSettings['UseClifford'] then
        MissionText("~b~Clifford: ~w~Set Config for Clifford to false!", 5000)
        break;

        local Clifford = exports['LENT-Clifford']:isLoggedIntoClifford()
        if Clifford then
            if Objectives.HasRunBeenStarted or Objectives.HasRunBeenCompleted then
                MissionText("~b~Clifford Goon: ~w~Hey! This mission won't complete itself!", 5000)
            else
                MissionText("~b~Clifford Goon: ~w~I left a location on your ~g~GPS~w~!", 5000)
                local GetCoords = Config.Coords['StartingCoords']
                local SetCoords = (GetCoords[math.random(#GetCoords)])
                SetWaypointOff()
                SetNewWaypoint(SetCoords)
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
            SetWaypointOff()
            SetNewWaypoint(SetCoords)
            TriggerEvent("LENT-CliffordRun:Client:SpawnVehicle", SetCoords)
            Objectives.HasRunBeenStarted = true
        end
    end
    
end)

RegisterNetEvent('LENT-CliffordRun:Client:EndCliffordRun', function()
    if Objectives.HasRunBeenStarted then
        if QBCore.Functions.HasItem('weed_brick', 22) then
            TriggerServerEvent('LENT-CliffordRun:Server:EndCliffordRun')

            Objectives.HasRunBeenStarted = false
            Objectives.HasRunBeenCompleted = true
        end
    end
end)

-- [[ Other Net Events ]] --
RegisterNetEvent('LENT-Clifford:Client:SendFinalEmail', function()
    local coords = GetEntityCoords(PlayerPedId())
    local closestVehicle, distance = QBCore.Functions.GetClosestVehicle(coords)
    print(closestVehicle, distance)
    if distance < 100 then 
        local DrugRunCar = isDrugRunCar(closestVehicle)
        if DrugRunCar then
            print("Deleting vehicle")
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

    local GetMyPed = PlayerPedId()
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
    SetNewWaypoint(SetEndingCoords)

    local EndingPedsList = {
        ["SetFinalPed"] = {
            ["Ped"] = `mp_m_weed_01`
        }
    }

    for k, v in pairs(EndingPedsList) do
        if PedSpawned then
            return
        end
        
        for k, v in pairs(EndingPedsList) do
            if not PedCreated[k] then 
                PedCreated[k] = {} 
            end
            
            local current = v["Ped"]
            current = type(current) == 'string' and joaat(current) or current
            RequestModel(current)

            while not HasModelLoaded(current) do
                Wait(0)
            end
        
            -- The coords + heading of the Ped
            PedCreated = CreatePed(0, current, SetEndingCoords.x, SetEndingCoords.y, SetEndingCoords.z-1, SetEndingCoords.w, false, false)
        
            -- Start the scneario in a basic loop
            TaskStartScenarioInPlace(PedCreated, "WORLD_HUMAN_CLIPBOARD", true)
        
            -- Let the entity stay in posistion
            FreezeEntityPosition(PedCreated, true)
            -- Set the ped to be invincible
            SetEntityInvincible(PedCreated, true)
        
            -- Give the ped a weapon with 999 ammo
            GiveWeaponToPed(PedCreated, "WEAPON_PISTOL", 999, false, true) -- Give them the specified weapon with ammo
            -- Set the weapon equiped
            SetCurrentPedWeapon(PedCreated, "WEAPON_PISTOL", true)
            -- Let the ped switch weapons
            SetPedCanSwitchWeapon(PedCreated, true) -- Allow them to switch weapon if applicible
        
            -- Block events like bumping
            SetBlockingOfNonTemporaryEvents(PedCreated, true)
        
            -- Target Stuff.. Read Config
            exports['qb-target']:AddTargetEntity(PedCreated, {
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
        
            pedSpawned = true
        end
    end
end)

RegisterNetEvent('LENT-CliffordRun:Client:DeletePeds', function()
    print("Debug: Client Delete Peds Event")
    for k, v in pairs(PedCreated) do
        DeletePed(v)
        DeletePed(k)
        print("Trying to delete: " .. v)
        print("Trying to delete: " .. k)
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