bankHandler = {}

Utils = require('client.utils.utils')

local cooldowns = {
    deposit = 0,
    withdraw = 0
}

local cooldownDuration = 0.5

local isOutOfCooldown = function(last)
    return ( ( lib.callback.await("hajden_banking:getTime", false) - last ) >= cooldownDuration )
end

bankHandler.deposit = function(amount)
    if not Utils.getNearestBank(_G.created_banks) then if Config.DEBUG then print("[WARNING] Player %s is possibly cheating. Flag: Depositing to player while not in a bank area") return end end
    if not lib.getOpenContextMenu() then if Config.DEBUG then print("[WARNING] Player %s is possibly cheating. Flag: Depositing while not in menu") return end end

    local currentTime = lib.callback.await("hajden_banking:getTime", false)

    if not isOutOfCooldown(cooldowns.deposit) then
        return lib.notify({
            title = "Banking",
            description = "Deposit is on cooldown!",
            type = "error"
        })
    end

    cooldowns.deposit = currentTime
    local account = {
        bank = Utils.getAccount('bank'),
        money = Utils.getAccount('money')
    }

    print(account.money - amount)
    if (account.money - amount) < 0 then
        return lib.notify({
            title = "Banking",
            description = "Not Enough Money!",
            type = "error"
        })
    else
        lib.callback.await("hajden_banking:deposit", false, {account = account, amount = amount})
    end
end

bankHandler.withdraw = function(amount)
    if not Utils.getNearestBank(_G.created_banks) then if Config.DEBUG then print("[WARNING] Player %s is possibly cheating. Flag: Withdrawing to player while not in a bank area") return end end
    if not lib.getOpenContextMenu() then if Config.DEBUG then print("[WARNING] Player %s is possibly cheating. Flag: Withdrawing while not in menu") return end end

    local currentTime = lib.callback.await("hajden_banking:getTime", false)

    if not isOutOfCooldown(cooldowns.withdraw) then
        return lib.notify({
            title = "Banking",
            description = "Withdrawal is on cooldown!",
            type = "error"
        })
    end

    cooldowns.withdraw = currentTime
    local account = {
        bank = Utils.getAccount('bank'),
        money = Utils.getAccount('money')
    }

    if (account.bank - amount) < 0 then
        return lib.notify({
            title = "Banking",
            description = "Not Enough Money in Bank!",
            type = "error"
        })
    else
        lib.callback.await("hajden_banking:withdraw", false, {account = account, amount = amount})
    end
end

bankHandler.transfer = function(amount, sendTo)
    if not Utils.getNearestBank(_G.created_banks) then if Config.DEBUG then print("[WARNING] Player %s is possibly cheating. Flag: Transfering to player while not in a bank area") return end end
    if not lib.getOpenContextMenu() then if Config.DEBUG then print("[WARNING] Player %s is possibly cheating. Flag: Transfering while not in menu") return end end

    local account = {
        bank = Utils.getAccount('bank'),
        money = Utils.getAccount('money')
    }
    lib.callback.await("hajden_banking:transfer", false, {account = account, amount = amount, sendTo = sendTo})
end

return bankHandler