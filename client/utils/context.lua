context = {}

bankHandler = require('client.utils.bankHandler')
Utils = require('client.utils.utils')

context.createQuickActions = function(bank)
    local options = {}

    local function addAction(type, icon, handler)
        if type == "divider" then
            return table.insert(options, {description="",disabled=true})
        end
        for _, i in ipairs(Config.contextMenu.quickActions[type]) do
            table.insert(options, {
                title = ("%s %s"):format(type:sub(1, 1):upper() .. type:sub(2), i.amount),
                description = ("Click to %s %s into your bank"):format(type, i.amount),
                icon = icon,
                onSelect = function()
                    lib.showContext('hajden_banking:quickActions')
                    handler(i.amount)
                end
            })
        end
    end

    addAction("deposit", "building-columns", bankHandler.deposit)
    addAction("divider", nil, nil)
    addAction("withdraw", "hand-holding-dollar", bankHandler.withdraw)

    return options
end

context.createBankOptions = function(bank, data)
    local options = {}
    local playerName = GetPlayerName(cache.playerId)
    local bankMoney = Utils.getAccount('bank')
    local inventoryMoney = Utils.getAccount('money')

    if Config.contextMenu.welcome then
        options[#options + 1] = {
            title = ("Welcome, %s"):format(playerName),
            readOnly = true
        }
    end

    options[#options + 1] = {
        title = "Bank Money",
        description = ("You have %s cash in the bank"):format(Utils.formatMoney(bankMoney)),
        icon = "piggy-bank",
        readOnly = true
    }

    options[#options + 1] = {
        title = "Inventory Money",
        description = ("You have %s cash in your inventory"):format(Utils.formatMoney(inventoryMoney)),
        icon = "money-bill",
        readOnly = true
    }

    -- Divider
    options[#options + 1] = {description = "", disabled = true}

    if data.name ~= "ATM" then
        options[#options + 1] = {
            title = "Quick Actions",
            description = "Click for access to quick actions",
            icon = "forward-fast",
            menu = "hajden_banking:quickActions"
        }
        options[#options + 1] = {
            title = "Deposit",
            description = "Click to deposit money into your bank",
            icon = "building-columns",
            readOnly = inventoryMoney <= 0,  -- Disabled if no inventory money
            onSelect = function()
                local input = lib.inputDialog('Depositing...', {
                    {type = 'number', label = 'Deposit Amount', description = 'How much do you want to deposit to your bank?', icon = 'money-bill', min = 1, max = inventoryMoney}
                })
    
                if input and input[1] then
                    bankHandler.deposit(input[1])
                else
                    lib.notify({
                        title = "Banking",
                        description = "Deposit has been cancelled",
                        type = "error"
                    })
                end
            end
        }
        if inventoryMoney <= 0 then
            lib.notify({
                title = "Banking",
                description = "You will not be able to deposit to your bank since you got no money on yourself",
                type = "warning",
                duration = 15000
            })
        end
    end

    options[#options + 1] = {
        title = "Withdraw",
        description = "Click to withdraw money from your bank",
        icon = "hand-holding-dollar",
        readOnly = bankMoney <= 0,  -- Disabled if no bank money
        onSelect = function()
            local input = lib.inputDialog('Withdrawing...', {
                {type = 'number', label = 'Withdraw Amount', description = 'How much do you want to withdraw from your bank?', icon = 'money-bill', min = 1, max = bankMoney}
            })

            if input and input[1] then
                bankHandler.withdraw(input[1])
            else
                lib.notify({
                    title = "Banking",
                    description = "Withdrawal has been cancelled",
                    type = "error"
                })
            end
        end
    }

    if bankMoney <= 0 then
        lib.notify({
            title = "Banking",
            description = "You will not be able to use Withdraw or Transfer since you got no money in the bank",
            type = "warning",
            duration = 15000
        })
    end

    options[#options + 1] = {
        title = "Transfer",
        description = "Click to send money to someone",
        icon = "money-bill-transfer",
        readOnly = bankMoney <= 0,  -- Disabled if no bank money
        onSelect = function()
            local players = lib.callback.await("hajden_banking:getAllPlayersToDialog", false)
            if #players > 0 then
                local input = lib.inputDialog('Transferring...', {
                    {type = 'select', label = 'Select a Player', description = 'Select the player you want to send the money to', icon = 'user', searchable = true, options = players},
                    {type = 'number', label = 'Transfer Amount', description = 'How much do you want to transfer to the player?', icon = 'money-bill', min = 1, max = bankMoney}
                })

                if input and input[1] and input[2] then
                    bankHandler.transfer(input[2], input[1])
                else
                    lib.notify({
                        title = "Banking",
                        description = "Transfer has been cancelled",
                        type = "error"
                    })
                end
            else
                lib.notify({
                    title = "Banking",
                    description = "No players available",
                    type = "error"
                })
            end
        end
    }

    if Config.billing.enabled.inBanking and data.name ~= "ATM" then
        options[#options + 1] = {description = "", disabled = true}  -- Divider
        options[#options + 1] = {
            title = "Billing",
            description = "Click to access the billing menu",
            icon = "file-invoice-dollar",
            onSelect = function()
                openUI()
            end
        }
    end

    return options
end


-- BILLING --

context.createJobBillsOptions = function(jobBills)
    local jobBillsOptions = {}
    if not jobBills then return {} end
    
    if #jobBills < 1 then
        table.insert(jobBillsOptions, {
            title = "You're fine!",
            description = "There are no bills for your job",
            icon = "check",
            readOnly = true
        })
    else
        for _, bill in ipairs(jobBills) do
            table.insert(jobBillsOptions, {
                title = bill.title,
                description = ("This bill is from: **%s**\nThe reason for this bill is: **%s**\nYou will need to pay: **%s**$\n\n**Click to pay this bill**"):format(bill.from, bill.reason, bill.cost),
                icon = "scroll",
                onSelect = function()
                    -- Handle bill payment logic here
                    lib.showContext("hajden_banking:billing:jobBills")
                end
            })
        end
    end
    
    return jobBillsOptions
end

context.createPlayerBillsOptions = function(playerBills)
    playerBillsOptions = {}
    if not playerBills then return {} end
    if #playerBills < 1 then
        table.insert(playerBillsOptions, {
            title = "You're fine!",
            description = "You have no bills to pay",
            icon = "check",
            readOnly = true
        })
    else
        for _, bill in ipairs(playerBills) do
            table.insert(playerBillsOptions, {
                title = bill.title,
                description = ("This bill is from: %s\nThe reason for this bill is: %s\n\nYou will need to pay: %s$\n**Click to pay this bill**"):format(bill.from, bill.reason, bill.cost),
                icon = "scroll",
                onSelect = function()
                    local confirm = lib.alertDialog({
                        header = 'Confirmation',
                        content = ("Do you really want to pay a bill for %s$"):format(bill.cost),
                        centered = true,
                        cancel = true
                    })

                    if confirm == "confirm" then
                        bankMoney = Utils.getAccount('bank')
                        print(bankMoney, bill.cost)
                        if bankMoney < bill.cost then
                            lib.showContext("hajden_banking:billing:yourBills")
                            return lib.notify({
                                title = "Banking",
                                description = "You don't have enough money to pay for the bill",
                                type = "error",
                                duration = 5000
                            })
                        end

                        lib.callback.await("hajden_banking:sv_billing:payBill", false, bill.id, false)

                        lib.notify({
                            title = "Banking",
                            description = "Your bill has been paid",
                            type = "success",
                            duration = 7500
                        })
                    else
                        lib.notify({
                            title = "Banking",
                            description = "You have canceled the bill payment",
                            type = "error",
                            duration = 5000
                        })
                    end

                    lib.showContext("hajden_banking:billing:yourBills")
                end
            })
        end
    end

    Wait(10)
    return playerBillsOptions
end

context.createBillingOptions = function(playerBills)
    local mainOptions = {}
    local pJob = lib.callback.await("hajden_banking:sv_billing:getJob", false)
    local jobBills = lib.callback.await("hajden_banking:sv_billing:getJobBills", false, pJob.name)
    local paidBills = {}
    local unpaidBills = {}
    for _, bill in ipairs(playerBills) do
        print(json.encode(bill))
        if bill.status == "paid" then
            table.insert(paidBills, bill)
        elseif bill.status == "unpaid" then
            table.insert(unpaidBills, bill)
        end
    end

    mainOptions[#mainOptions + 1] = {
        title = "Paid Bills",
        description = ("You have %s PAID bills"):format(#paidBills),
        icon = "check",
        readOnly = true
    }

    mainOptions[#mainOptions + 1] = {
        title = "Unpaid Bills",
        description = ("You have %s UNPAID bills%s"):format(#unpaidBills, #unpaidBills > 0 and "!" or ""),
        icon = "xmark",
        readOnly = true
    }

    mainOptions[#mainOptions + 1] = {
        description = "",
        disabled = true
    }
    
    mainOptions[#mainOptions + 1] = {
        title = "Your Bills",
        description = "Click here to manage your bills",
        icon = "user",
        iconColor = #playerBills > 0 and "red" or nil,
        menu = "hajden_banking:billing:yourBills"
    }

    if pJob.name ~= Config.billing.defaultJob and pJob.label ~= Config.billing.defaultJob then
        -- Job Bills Menu
        for _, jobConfig in ipairs(Config.billing.jobBills) do
            if (pJob.name == jobConfig.job or pJob.label == jobConfig.job) and pJob.grade >= jobConfig.grade then
                mainOptions[#mainOptions + 1] = {
                    title = "Job Bills",
                    description = "Click here to manage bills of your job",
                    icon = "suitcase",
                    menu = "hajden_banking:billing:jobBills",
                    onSelect = function()
                        lib.registerContext({
                            id = "hajden_banking:billing:jobBills",
                            title = "Job Bills",
                            menu = "hajden_banking:billing:main",
                            options = context.createJobBillsOptions(jobBills)
                        })
                    end
                }
                break
            end
        end

        -- Send Bill Option
        for _, job in ipairs(Config.billing.allowedJobs) do
            if (pJob.name == job.job or pJob.label == job.job) and pJob.grade >= job.grade then
                mainOptions[#mainOptions + 1] = {
                    title = "Send a Bill",
                    description = "Click here to send a bill to a player",
                    icon = "file-pen",
                    onSelect = function()
                        local playerCoords = GetEntityCoords(cache.ped)
                        local nearbyPlayers = lib.getNearbyPlayers(playerCoords, 10.0, true)
                        
                        if #nearbyPlayers == 0 then
                            lib.notify({
                                title = 'No Players Nearby',
                                description = 'There are no players within range to bill',
                                type = 'error'
                            })
                            return
                        end

                        local options = {}
                        for _, player in ipairs(nearbyPlayers) do
                            if player.id ~= PlayerId() then
                                table.insert(options, {
                                    label = GetPlayerName(player.id),
                                    value = tostring(player.id)  -- Convert ID to string for the input dialog
                                })
                            end
                        end

                        if #options == 0 then
                            lib.notify({
                                title = 'No Valid Players',
                                description = 'No valid players to bill nearby',
                                type = 'error'
                            })
                            return
                        end

                        local input = lib.inputDialog('Send Bill', {
                            {
                                type = 'select',
                                label = 'Select a Player',
                                description = 'Select the player you want to bill',
                                icon = 'user',
                                options = options,
                                required = true
                            },
                            {
                                type = 'input',
                                label = 'Title',
                                description = 'Enter the bill title',
                                icon = 'heading',
                                required = true
                            },
                            {
                                type = 'number',
                                label = 'Amount',
                                description = 'Enter the bill amount',
                                icon = 'dollar-sign',
                                required = true,
                                min = 1
                            },
                            {
                                type = 'input',
                                label = 'Reason',
                                description = 'Enter the reason for the bill',
                                icon = 'comment',
                                required = true
                            }
                        })
                        
                        if input then
                            local targetId = input[1]
                            local title = input[2]
                            local amount = input[3]
                            local reason = input[4]
                            
                            lib.callback.await('hajden_banking:sv_billing:sendBill', false, GetPlayerServerId(tonumber(targetId)), title, amount, reason, GetPlayerName(PlayerId()))
                            
                            Wait(500)
                            lib.showContext("hajden_banking:billing:main")
                        end
                    end
                }
                break
            end
        end
    end
    
    return mainOptions
end

return context