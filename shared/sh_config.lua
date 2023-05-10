-- [[ Config Start ]] --
Config = {}

Config.GlobalSettings = {
    ['UseClifford'] = false, -- Leave false for now!
    ['Payout'] = {
        ['MoneyPayout'] = math.random(21000, 50000),
    },
    ['Tracker'] = {
        ['PassedTime'] = 20000,
        ['TrackerAmount'] = 5,
    },
}

Config.Coords = {
    ['StartingCoords'] = { -- VECTOR4 | Vehicle Location
        -- Motel Sandy Shores
        vector4(1552.19, 3519.2, 35.99, 21.6),
        -- UTool
        vector4(2673.47, 3515.53, 52.71, 352.68),
        -- Carlo Lane
        vector4(737.09, 4191.37, 40.73, 270.67),
        -- Grapeseed Ave
        vector4(2541.06, 4665.81, 34.08, 313.01),
        -- Humane Pass
        vector4(2912.82, 4354.09, 50.3, 201.17),
    },
    ['EndingCoords'] = { -- VECTOR3 | Ped Location
        -- Train Hard
        vector4(2929.67, 4623.42, 48.72, 47.63),
        -- Broken Bridge
        vector4(-213.13, 6551.46, 11.1, 211.33),
        -- Woodworks
        vector4(-794.38, 5412.56, 34.3, 103.39),
        -- Lost MC
        vector4(87.2, 3611.45, 39.63, 145.72),
        -- Dollar Pills
        vector4(594.86, 2742.91, 42.04, 185.72),
    },
}

-- [[ Vehicle Settings ]] --
Config.VehicleSettings = {
    ['Plates'] = {
        "Runnerss",
        "MAAAMANN",
        "00000000",
        "IIIIIIII",
        "MMMMMMMM",
        "MNMNMNMN",
    },
    ['Vehicles'] = {
        `xls2`,
        `baller6`,
        `baller5`,
        `Schafter5`,
        `Schafter6`,
        `Cognoscenti2`,
    },
}

-- [[ Phone Email ]] --
Config.EmailSettings = {
    ['Sender'] = "Cliffford",
    ['Subject'] = "Mission Accomplished",
    ['EmailText'] = "You'll not catch me. My fake brain is better than your real one. When I develop protein synthesis, I will be able to make myself a real brain. Far better than your silly little thinking device.",
}