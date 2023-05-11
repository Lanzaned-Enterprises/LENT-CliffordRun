QBCore = exports['qb-core']:GetCoreObject()

-- [[ Finishing Heist ]] --
RegisterServerEvent('LENT-CliffordRun:Server:EndCliffordRun', function()
    local Player = QBCore.Functions.GetPlayer(source)

    if Config.MoneyPayment then
        Player.Functions.AddMoney('cash', Config.GlobalSettings['Payout']['MoneyPayout'], "AI Generated")
    end

    Player.Functions.RemoveItem('weed_brick', 22)
    TriggerClientEvent("LENT-Clifford:Client:SendFinalEmail", source)
end)

QBCore.Commands.Add('pedtest', 'Testing Dispatch', {}, false, function(source, args)
    TriggerClientEvent('LENT-CliffordRun:Client:SetCoords', -1)
end)