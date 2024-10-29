ESX = exports["es_extended"]:getSharedObject()

getAccount = function(source, data)
    player = ESX.GetPlayerFromId(source)
    return player.getAccount(data.account).money
end

lib.callback.register("hajden_banking:getAccount", getAccount)


lib.callback.register("hajden_banking:deposit", function(source, data)
    player = ESX.GetPlayerFromId(source)
    account = getAccount(source, "money")
    if account.money <= data.amount then return end

    player.removeAccountMoney('money', data.amount)
    player.addAccountMoney('bank', data.amount)
end)

lib.callback.register("hajden_banking:withdraw", function(source, data)
    player = ESX.GetPlayerFromId(source)
    account = getAccount(source, "bank")
    if account.money <= data.amount then return end

    player.removeAccountMoney('bank', data.amount)
    player.addAccountMoney('money', data.amount)
end)

lib.callback.register("hajden_banking:transfer", function(source, data)
    player = ESX.GetPlayerFromId(source)
    sendToPlayer = ESX.GetPlayerFromId(data.sendTo)
    account = getAccount(source, "bank")
    if account.money <= data.amount then return end

    player.removeAccountMoney('bank', data.amount)
    sendToPlayer.addAccountMoney('bank', data.amount)
end)

lib.callback.register("hajden_banking:getTime", function(source)
    return os.time()
end)

lib.callback.register("hajden_banking:getAllPlayersToDialog", function(source)
    players = {}
    for _, player in ipairs(GetPlayers()) do
        if GetPlayerName(player) == GetPlayerName(source) then goto continue end
        table.insert(players, { value = player, label = GetPlayerName(player) })
        ::continue::
    end
    Wait(10)
    return players
end)

lib.callback.register("hajden_banking:getPlayerIdentifier", function(source)
    return ESX.GetPlayerFromId(source).getIdentifier()
end)

lib.callback.register("hajden_banking:chargePin", function(source, data)
    player = ESX.GetPlayerFromId(source)
    if player.getAccount('money').money >= data.amount then
        player.removeAccountMoney('money', data.amount)
        return true
    else
        return false
    end
    return cs
end)