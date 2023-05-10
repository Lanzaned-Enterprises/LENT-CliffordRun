QBCore = exports['qb-core']:GetCoreObject()

-- [[ Start of Objectives ]] --
Objectives = {
    HasRunBeenStarted = false,
    HasRunBeenCompleted = false,
}

----------------------------------------------

-- [[ Start of Events ]] --
Events = {
    HasDispatchBeenNotified = false,
    VehicleDistanceHasBeenTriggered = false,
    
    ThreadHasBeenTriggered = false,

    VehicleBlipsHavePassed = false
}

-----------------------------------------------