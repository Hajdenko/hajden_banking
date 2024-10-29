vaultDoor = {}
local initialDoorRotation = nil

local function getNearestVaultDoor()
    local playerPos = GetEntityCoords(PlayerPedId())
    local vaultDoorModel = GetHashKey("v_ilev_gb_vauldr")
    local nearestDoor = nil
    local nearestDist = math.huge

    for _, obj in ipairs(GetGamePool("CObject")) do
        if GetEntityModel(obj) == vaultDoorModel then
            local objPos = GetEntityCoords(obj)
            local dist = #(playerPos - objPos)
            if dist < nearestDist then
                nearestDist = dist
                nearestDoor = obj
            end
        end
    end

    return nearestDoor
end

local function rotateVaultDoor(door, targetRotation)
    local currentRotation = GetEntityHeading(door)
    local step = (targetRotation > currentRotation) and 0.1 or -0.1

    if not instant then
        while math.abs(targetRotation - currentRotation) > 0.1 do
            SetEntityHeading(door, currentRotation)
            currentRotation = currentRotation + step
            Citizen.Wait(10)
        end
    end
end

vaultDoor.openVaultDoor = function()
    local door = getNearestVaultDoor()
    if door then
        local currentRotation = GetEntityHeading(door)
        local targetRotation = currentRotation + 90
        initialDoorRotation = currentRotation
        
        local syncData = {
            doorEntity = door,
            rotation = targetRotation,
            action = "open"
        }
        TriggerServerEvent("hajden_banking:sv_robbery:syncDoor", syncData)
        
        rotateVaultDoor(door, targetRotation)
    end
end

vaultDoor.closeVaultDoor = function()
    local door = getNearestVaultDoor()
    if door then
        local currentRotation = GetEntityHeading(door)
        local targetRotation = currentRotation - 90
        
        local syncData = {
            doorEntity = door,
            rotation = targetRotation,
            action = "close"
        }
        TriggerServerEvent("hajden_banking:sv_robbery:syncDoor", syncData)
        
        rotateVaultDoor(door, targetRotation)
    end
end

RegisterNetEvent("hajden_banking:cl_robbery:syncDoor")
AddEventHandler("hajden_banking:cl_robbery:syncDoor", function(syncData)
    local door = getNearestVaultDoor()
    if door then
        rotateVaultDoor(door, syncData.rotation)
    end
end)

vaultDoor.resourceStop = function()
    local door = getNearestVaultDoor()
    if door and initialDoorRotation then
        SetEntityHeading(door, initialDoorRotation)
    end
end

return vaultDoor