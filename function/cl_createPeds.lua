-- [[ Variables ]] --
local pedSpawned = false
local PedCreated = {}

-- [[ Create Peds ]] --
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeletePeds()
    end
end)

-- [[ Function ]] --
function DeletePeds()
    if pedSpawned then
        for _, v in pairs(PedCreated) do
            DeletePed(v)
        end
    end
end

-- [[ Ped Config ]] --
local peds = {
    ["CliffordDrugRunStart"] = {
        ["coords"] = vector4(-1069.85, -63.02, -90.2, 178.09), -- The start Coordinatos of the first mission
        
        ["ped"] = "mp_m_avongoon",
        ["scenario"] = "WORLD_HUMAN_COP_IDLES", ["block_events"] = true, ["invincible"] = true, ["freeze"] = true,

        ["target"] = true,
        ["type"] = "client", ["event"] = "LENT-CliffordRun:Client:StartMainEvent", 
        ["icon"] = "fa-solid fa-car", ["text"] = "Start Clifford Run",
    },
}

-- [[ Spawning Thread ]] --
CreateThread(function()
    for k, v in pairs(peds) do
        if pedSpawned then 
            return 
        end
    
        for k, v in pairs(peds) do
            if not PedCreated[k] then 
                PedCreated[k] = {} 
            end
    
            local current = v["ped"]
            current = type(current) == 'string' and joaat(current) or current
            RequestModel(current)
    
            while not HasModelLoaded(current) do
                Wait(0)
            end
    
            -- The coords + heading of the Ped
            PedCreated[k] = CreatePed(0, current, v["coords"].x, v["coords"].y, v["coords"].z-1, v["coords"].w, false, false)
            
            -- Start the scneario in a basic loop
            TaskStartScenarioInPlace(PedCreated[k], v["scenario"], true)
            
            if v["freeze"] then
                -- Let the entity stay in posistion
                FreezeEntityPosition(PedCreated[k], true)
            end
    
            if v["invincible"] then
                -- Set the ped to be invincible
                SetEntityInvincible(PedCreated[k], true)
            end
    
            -- Block events like bumping
            if v["block_events"] then
                SetBlockingOfNonTemporaryEvents(PedCreated[k], true)
            end
    
            -- Target Stuff.. Read Config
            if v["target"] then
                exports['qb-target']:AddTargetEntity(PedCreated[k], {
                    options = {
                        {
                            type = v["type"],
                            event = v["event"],
                            icon = v["icon"],
                            label = v["text"],
                        },
                    },
                    distance = 2.0
                })
            end
        end
    
        pedSpawned = true
    end
end)

-- [[ Last Resort ]] --
CreateThread(function()
    while true do
        Wait(5000)
        if pedSpawned then
            for _, v in pairs(PedCreated) do
                if IsEntityDead(v) then 
                    DeletePed(v)
                end
            end
        end
    end
end)