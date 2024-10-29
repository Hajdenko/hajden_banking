repeat Wait(5) until Config.bankLocations ~= nil
if ( not Config.robbery.enabled.idcard ) and ( not Config.robbery.enabled.hack ) then return end

local setupZones = {}
vaultDoor = require('client.utils.vaultDoor')
cashGrab = require('client.utils.cashGrab')

function StartBankCashPhase(bankName)
    local bank
    for _, b in ipairs(Config.bankLocations) do
        if b.name == bankName then
            bank = b
            break
        end
    end
    
    if not bank then return false end
    
    local trolleys = cashGrab.spawnCashTrolleys(bank)
    if trolleys then
        cashGrab.addTrolleyTargets(trolleys)
        return true
    end
    return false
end

IDAccess = function()
end

HackAccess = function()
    local currentBank
    
    for _, bank in ipairs(Config.bankLocations) do
        local distance = #(GetEntityCoords(cache.ped) - bank.coords)
        if distance < 10.0 then
            currentBank = bank
            break
        end
    end
    
    if not currentBank then return end
    
    hack = Config.robbery.hack
    success = Config.DEBUG and true or hack.minigame()
    
    if success then
        cashGrab.cleanupBankEntities()
        CreateThread(vaultDoor.openVaultDoor)
        
        StartBankCashPhase(currentBank.name)

        resetTime = hack.resetTime * 1000
        CreateThread(function()
            lib.notify({
                title = "Robbery",
                description = ("The vault will close after %s seconds"):format(hack.resetTime),
                type = "warning"
            })
            for i = 1,hack.resetTime/10 do 
                formatTime = hack.resetTime - i*10
                if formatTime ~= 0 then
                    lib.notify({
                        title = "Robbery",
                        description = ("The vault will close after %s seconds"):format(formatTime),
                        type = "warning"
                    })
                else
                    lib.notify({
                        title = "Robbery",
                        description = "The vault is closing",
                        type = "error"
                    })
                end
                Wait(10*1000)
            end
        end)

        CreateThread(function()
            Citizen.SetTimeout(hack.resetTime * 1000, function()
                vaultDoor.closeVaultDoor()
                cashGrab.cleanupBankEntities()
            end)
        end)
    else
        hack.alertCops()
    end
end

robberyZoneSetup = function()
    for _, bank in ipairs(Config.bankLocations) do
        zone = bank.robbery
        if ( not zone ) or ( setupZones[_] or setupZones[bank.name] ) then return end

        setupZones[_] = zone
        setupZones[bank.name] = zone

        exports.ox_target:addSphereZone({
            coords = zone.vault.coords,
            name = bank.name..".vault.hack",
            radius = .5,
            debug = Config.DEBUG,
            options = {
                {
                    label = "Access using ID",
                    name = bank.name..".vault.hack.idcard",
                    icon = "fa-regular fa-id-card",
                    items = Config.robbery.neededItems.idcard,
                    onSelect = IDAccess
                },
                {
                    label = "Hack the Terminal",
                    name = bank.name..".vault.hack.terminal",
                    icon = "fa-solid fa-laptop-code",
                    items = Config.robbery.neededItems.hack,
                    onSelect = HackAccess
                }
            }
        })
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    FreezeEntityPosition(cache.ped, false)

    cashGrab.cleanupBankEntities()
    vaultDoor.resourceStop()
end)

robberyZoneSetup()