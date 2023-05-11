--[[ Version Checker ]] --
local version = 201

-- [[ Settings ]] --
-- [[ Discord Settings ]] --
local DISCORD_WEBHOOK = ""
local DISCORD_NAME = "LENT - Clifford Jobs"
local DISCORD_IMAGE = "https://cdn.discordapp.com/attachments/1026175982509506650/1026176123928842270/Lanzaned.png"

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        checkResourceVersion()
    end
end)

function checkResourceVersion()
    PerformHttpRequest("https://raw.githubusercontent.com/Lanzaned-Enterprises/LENT-CliffordRun/main/version.txt", function(err, text, headers)
        if (version > text) then -- Using Dev Branch
            print(" ")
            print("---------- LANZANED CLIFFORD RUN ----------")
            print("Clifford is using a development branch! Please update to stable ASAP!")
            print("Your Version: " .. version .. " Current Stable Version: " .. text)
            print("https://github.com/Lanzaned-Enterprises/LENT-CliffordRun")
            print("-------------------------------------------")
            print(" ")
            checkUpdateEmbed(5242880, "Clifford Update Checker", "Clifford is using a development branch! Please update to stable ASAP!\nYour Version: " .. version .. " Current Stable Version: " .. text .. "\nhttps://github.com/Lanzaned-Enterprises/LENT-CliffordRun", "Script created by: https://discord.lanzaned.com")
        elseif (text > version) then -- Not updated
            print(" ")
            print("---------- LANZANED CLIFFORD RUN ----------")
            print("Clifford is not up to date! Please update!")
            print("Curent Version: " .. version .. " Latest Version: " .. text)
            print("https://github.com/Lanzaned-Enterprises/LENT-CliffordRun")
            print("-------------------------------------------")
            print(" ")
            checkUpdateEmbed(5242880, "Clifford Update Checker", "Clifford is not up to date! Please update!\nCurent Version: " .. version .. " Latest Version: " .. text .. "\nhttps://github.com/Lanzaned-Enterprises/LENT-CliffordRun", "Script created by: https://discord.lanzaned.com")
        else -- resource is fine
            print(" ")
            print("---------- LANZANED CLIFFORD RUN ----------")
            print("Clifford is up to date and ready to go!")
            print("Running on Version: " .. version)
            print("https://github.com/Lanzaned-Enterprises/LENT-CliffordRun")
            print("-------------------------------------------")
            print(" ")
            checkUpdateEmbed(20480, "Clifford Update Checker", "Clifford is up to date and ready to go!\nRunning on Version: " .. version .. "\nhttps://github.com/Lanzaned-Enterprises/LENT-CliffordRun", "Script created by: https://discord.lanzaned.com")
        end 
    end, "GET", "", {})
end