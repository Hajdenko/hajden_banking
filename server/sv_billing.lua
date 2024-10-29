ESX = exports["es_extended"]:getSharedObject()
billing = Config.billing

if billing.enabled.command then
    lib.addCommand(billing.command, {
        help = 'Opens the billing UI',
    }, function(source)
        lib.callback.await("hajden_banking:cl_billing:openUI", source)
    end)
end
lib.callback.register("hajden_banking:sv_billing:openUI", function(source)
    lib.callback.await("hajden_banking:cl_billing:openUI", source)
end)

lib.callback.register("hajden_banking:sv_billing:getJob", function(source)
    player = ESX.GetPlayerFromId(source)
    return player.getJob()
end)

lib.callback.register("hajden_banking:sv_billing:getPlayerBills", function(source, identifier)
    if not identifier then identifier = ESX.GetPlayerFromId(source).getIdentifier() end
    
    local bills = MySQL.query.await("SELECT id, title, cost, reason, `from`, status FROM hajden_banking_playerBills WHERE identifier = ?", { identifier })
    if bills then
        local formattedBills = {}
        for _, bill in ipairs(bills) do
            table.insert(formattedBills, {
                id = bill.id,
                title = bill.title,
                cost = bill.cost,
                reason = bill.reason,
                from = bill.from,
                status = tostring(bill.status)
            })
        end
        return formattedBills
    else
        return {}
    end
end)

lib.callback.register("hajden_banking:sv_billing:getJobBills", function(source, jobName)
    if not jobName then jobName = ESX.GetPlayerFromId(source).getJob().name end
    
    local bills = MySQL.query.await("SELECT id, title, cost, reason, `from`, status FROM hajden_banking_jobBills WHERE jobName = ?", { jobName })
    if bills then
        local formattedBills = {}
        for _, bill in ipairs(bills) do
            table.insert(formattedBills, {
                id = bill.id,
                title = bill.title,
                cost = bill.cost,
                reason = bill.reason,
                from = bill.from,
                status = tostring(bill.status)
            })
        end
        return formattedBills
    else
        return {}
    end
end)

addPlayerBill = function(source, identifier, title, cost, reason, from)
    if not identifier then identifier = ESX.GetPlayerFromId(source).getIdentifier() end
    
    local query = [[
        INSERT INTO hajden_banking_playerBills (identifier, title, cost, reason, `from`, status)
        VALUES (?, ?, ?, ?, ?, 'unpaid')
    ]]
    local parameters = {identifier, title, cost, reason, from}
    
    local insertedId = MySQL.insert.await(query, parameters)
    return insertedId
end
lib.callback.register("hajden_banking:sv_billing:addPlayerBill", addPlayerBill)

lib.callback.register("hajden_banking:sv_billing:addJobBill", function(source, jobName, title, cost, reason, from)
    if not jobName then jobName = ESX.GetPlayerFromId(source).getJob().name end
    
    local query = [[
        INSERT INTO hajden_banking_jobBills (jobName, title, cost, reason, `from`, status)
        VALUES (?, ?, ?, ?, ?, 'unpaid')
    ]]
    local parameters = {jobName, title, cost, reason, from}
    
    local insertedId = MySQL.insert.await(query, parameters)
    return insertedId
end)



lib.callback.register("hajden_banking:sv_billing:setBillStatus", function(id, status, isJobBill)
    local tableName = isJobBill and "hajden_banking_jobBills" or "hajden_banking_playerBills"
    local query = "UPDATE "..tableName.." SET status = ? WHERE id = ?"
    
    MySQL.execute(query, {status, id})
end)

lib.callback.register("hajden_banking:sv_billing:getBillStatus", function(id, isJobBill, callback)
    local tableName = isJobBill and "hajden_banking_jobBills" or "hajden_banking_playerBills"
    local query = "SELECT status FROM "..tableName.." WHERE id = ?"
    
    MySQL.query(query, {id}, function(result)
        if result[1] then
            callback(result[1].status)
        else
            callback(nil)
        end
    end)
end)

lib.callback.register("hajden_banking:sv_billing:sendBill", function(source, targetId, title, amount, reason, from)
    local source = source
    local player = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(targetId)

    if not target then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'Target player not found',
            type = 'error'
        })
        return
    end

    if not player then
        return
    end
    
    local insertedId = addPlayerBill(false, target.identifier, title, amount, reason, from)
    if insertedId then
        TriggerClientEvent('ox_lib:notify', targetId, {
            title = 'New Bill',
            description = ('You received a bill for $%s from %s'):format(amount, from),
            type = 'inform'
        })
        
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Bill Sent',
            description = ('Successfully sent bill to %s'):format(GetPlayerName(targetId)),
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'Failed to create bill',
            type = 'error'
        })
    end
end)

lib.callback.register("hajden_banking:sv_billing:payBill", function(source, billId, isJobBill)
    local player = ESX.GetPlayerFromId(source)
    if not player then
        return false, "Invalid player"
    end

    local tableName = isJobBill and "hajden_banking_jobBills" or "hajden_banking_playerBills"
    local bill = MySQL.query.await("SELECT * FROM "..tableName.." WHERE id = ?", { billId })[1]
    
    if not bill then
        return false, "Bill not found"
    end

    if bill.status ~= 'unpaid' then
        return false, "Bill is already paid"
    end

    if not isJobBill then
        local playerIdentifier = player.getIdentifier()
        if bill.identifier ~= playerIdentifier then
            print(string.format("[SECURITY WARNING] Player %s (%s) attempted to pay bill %s belonging to %s", 
                GetPlayerName(source), playerIdentifier, billId, bill.identifier))
            return false, "Unauthorized payment attempt"
        end
    else
        local playerJob = player.getJob()
        if bill.jobName ~= playerJob.name then
            print(string.format("[SECURITY WARNING] Player %s attempted to pay job bill for %s while being %s", 
                GetPlayerName(source), bill.jobName, playerJob.name))
            return false, "Unauthorized job bill payment attempt"
        end
    end

    local playerMoney = player.getMoney()
    local playerBank = player.getAccount('bank').money
    local totalMoney = playerMoney + playerBank
    
    if totalMoney < bill.cost then
        return false, "Insufficient funds"
    end

    local remainingCost = bill.cost
    
    if playerBank >= remainingCost then
        player.removeAccountMoney('bank', remainingCost)
        remainingCost = 0
    else
        if playerBank > 0 then
            player.removeAccountMoney('bank', playerBank)
            remainingCost = remainingCost - playerBank
        end
        player.removeMoney(remainingCost)
    end

    MySQL.update.await("UPDATE "..tableName.." SET status = ? WHERE id = ?", { 'paid', billId })

    if bill.from then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..bill.from, function(account)
            if account then
                account.addMoney(bill.cost)
            end
        end)
    end

    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Bill Paid',
        description = string.format('You paid $%s for %s', bill.cost, bill.title),
        type = 'success'
    })

    if isJobBill and bill.from then
        local xPlayers = ESX.GetPlayers()
        for _, xPlayer in ipairs(xPlayers) do
            local xTarget = ESX.GetPlayerFromId(xPlayer)
            if xTarget.job.name == bill.from then
                TriggerClientEvent('ox_lib:notify', xPlayer, {
                    title = 'Bill Paid',
                    description = string.format('%s paid $%s for %s', GetPlayerName(source), bill.cost, bill.title),
                    type = 'inform'
                })
            end
        end
    end

    return true, "Payment successful"
end)