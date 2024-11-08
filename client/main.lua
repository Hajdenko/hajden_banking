repeat Wait(5) until Config ~= nil

-- TODO: LOGGING

local Utils = require('client.utils.utils')
local context = require('client.utils.context')
local bankHandler = require('client.utils.bankHandler')
local pinHandler = require('client.utils.pinHandler')
local createdBanks = {}

local keybinds = {
    bank = lib.addKeybind({
        name = 'openBank',
        description = 'Opens the bank UI',
        defaultKey = Config.textUI.openKeybind,
        onPressed = function()
            openBank()
        end
    }),
    atm = lib.addKeybind({
        name = 'openAtm',
        description = 'Opens the bank UI',
        defaultKey = Config.textUI.openKeybind,
        onPressed = function()
            openBank()
        end
    })
}
keybinds.bank:disable(true)
keybinds.atm:disable(true)

createQuickActions = function(bank)
    lib.registerContext({
        id = "hajden_banking:quickActions",
        title = "Quick Actions",
        menu = "none",
        onBack = function()
            openBank(true)
        end,
        options = context.createQuickActions(bank)
    })
end

CreateThread(function()
    if Config.ATM.enabled then
        while true do Wait(1000)
            for k, v in pairs(Config.ATM.models) do
                e = GetClosestObjectOfType(GetEntityCoords(cache.ped), 1.0, GetHashKey(v), false, false, false)

                if ( e ~= 0 ) then
                    lib.showTextUI(Config.textUI.prompts.atm)
                    keybinds.atm:disable(false)
                    break
                else
                    local isOpen, text = lib.isTextUIOpen()
                    if isOpen and text == Config.textUI.prompts.atm then
                        lib.hideTextUI()
                        keybinds.atm:disable(true)
                    end
                end
            end
        end
    end
end)

setupBanks = function()
    for _, bank in ipairs(Config.bankLocations) do
        createdBanks[_] = {}
        createdBanks[_].data = bank
        createdBanks[_].zone = lib.zones.sphere({
            coords = bank.coords,
            radius = bank.radius,
            debug = Config.DEBUG,
            onEnter = function()
                lib.showTextUI(Config.textUI.prompts.bank)
                keybinds.bank:disable(false)
            end,
            onExit = function()
                lib.hideTextUI()
                keybinds.bank:disable(true)
            end
        })
    end
    CreateThread(function()
        Wait(100)
        _G.created_banks = createdBanks
    end)
end

---@param bank table The nearest bank for createdBanks
createBankOptions = function(bank, data)
    createQuickActions(bank)
    return context.createBankOptions(bank, data)
end

getPINRequirements = function()
    _ = {
        min = 1,
        max = "9"
    }
    for i = 1,tonumber(Config.PIN.length)-1 do
        _ = {
            min = _.min*10,
            max = _.max.."9"
        }
    end
    _.max = tonumber(_.max)
    return _
end

_a = 0
openBank = function(disablePIN)
    local isOpen, text = lib.isTextUIOpen()
    if not isOpen or _a > 0 then return end
    if ( ( disabledPIN or text == Config.textUI.prompts.atm ) and Config.PIN.enabled ) then
        canceled = false

        identifier = lib.callback.await("hajden_banking:getPlayerIdentifier", false)
        requirements = getPINRequirements()

        pinHandler.getPin(identifier, function(pincode)
            if pincode then
                local input = lib.inputDialog('Enter Your PIN', {
                    {type = 'number', label = 'Your PIN', description = 'Enter your PIN below', icon = 'fingerprint', min = requirements.min, max = requirements.max},
                    {type = 'number', label = "Reset PIN", description = 'Reset your PIN below for '..Config.PIN.changeCost..'$\n Write your new PIN in here only in case you forgot your PIN', icon = 'fingerprint', min = requirements.min, max = requirements.max}
                })
                
                if input and input[2] then
                    if not tonumber(Config.PIN.chargeWhenForgotten) then
                        result = Config.PIN.chargeWhenForgotten and lib.callback.await("hajden_banking:chargePin", false, Config.PIN.changeCost) or true
                    else
                        pinHandler.getPinChanges(identifier, function(pinchanges)
                            if pinchanges >= tonumber(Config.PIN.chargeWhenForgotten) then
                                result = lib.callback.await("hajden_banking:chargePin", false, Config.PIN.changeCost)
                            else
                                result = true
                            end
                        end)
                    end
                    if result then
                        pinHandler.setPin(identifier, input[2], function(success)
                            if success then
                                return lib.notify({
                                    title = "Banking",
                                    description = ("Your PIN has been set to %s"):format(input[2]),
                                    type = "success"
                                })
                            else
                                canceled = true
                                return lib.notify({
                                    title = "Banking",
                                    description = "For some reason, your PIN wasn't accepted",
                                    type = "error"
                                })
                            end
                        end)
                    else
                        canceled = true
                        return lib.notify({
                            title = "Banking",
                            description = "You don't have enough money",
                            type = "error"
                        })
                    end
                end

                if input and input[1] then
                    if not ( tonumber(input[1]) == tonumber(pincode) ) then
                        lib.notify({
                            title = "Banking",
                            description = "The PIN you've entered doesn't match your PIN",
                            type = "error"
                        })
                        canceled = true
                    end
                else
                    canceled = true
                end
            else
                local input = lib.inputDialog('Set Your PIN', {
                    {type = 'number', label = 'Set your own PIN', description = 'Please, enter the PIN you want to login with into the bank', icon = 'fingerprint', min = requirements.min, max = requirements.max}
                })

                if input and input[1] then
                    if ( input[1] > 1000 ) and ( input[1] < 9999 ) then
                        pinHandler.setPin(identifier, input[1], function(success)
                            if success then
                                lib.notify({
                                    title = "Banking",
                                    description = ("Your PIN has been set to %s"):format(input[1]),
                                    type = "success"
                                })
                            else
                                lib.notify({
                                    title = "Banking",
                                    description = "For some reason, your PIN wasn't accepted",
                                    type = "error"
                                })
                                canceled = true
                            end
                        end)
                    else
                        canceled = true
                    end
                else
                    canceled = true
                end
            end
        end)

        if canceled then return end
    end

    _G.created_banks = createdBanks
    ID, nearestBank = Utils.getNearestBank(createdBanks)
    if ID and nearestBank then
        _a += 1
        lib.registerContext({
            id = ("hajden_banking:main%s"):format(ID),
            title = ("Banking (%s)"):format(nearestBank.data.name),
            options = createBankOptions(bank, nearestBank.data)
        })
        lib.showContext(("hajden_banking:main%s"):format(ID))
    end

    lib.notify({
        title = "Banking",
        description = "Login Successful",
        type = "success"
    })
    _a = 0
end

setupBanks()