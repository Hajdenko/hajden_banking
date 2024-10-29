cashGrab = {}
local Entities = {}

cashGrab.startAnim = function(trolley)
    NetworkRequestControlOfEntity(trolley.obj)
    while not NetworkHasControlOfEntity(trolley.obj) do Wait(100) end
    pPos = GetEntityCoords(cache.ped)
    FreezeEntityPosition(cache.ped, true)
    local cash_model = GetHashKey("hei_prop_heist_cash_pile")
    local bag_model = GetHashKey("hei_p_m_bag_var22_arm_s")
    local empty_trolley_model = trolley.cfg.empty
    local anim_dict = "anim@heists@ornate_bank@grab_cash"
    RequestModel(cash_model)
    RequestModel(bag_model)
    RequestModel(empty_trolley_model)
    RequestAnimDict(anim_dict)

    while not HasAnimDictLoaded(anim_dict)
        or not HasModelLoaded(cash_model)
        or not HasModelLoaded(cash_model)
        or not HasModelLoaded(empty_trolley_model) do Wait(1)
    end

    local self_bag = {
        drawable = GetPedDrawableVariation(cache.ped, 5),
        texture = GetPedTextureVariation(cache.ped, 5)
    }

    local anim_pos, anim_rot = GetEntityCoords(trolley.obj), GetEntityRotation(trolley.obj)

    local trolleyFwd = GetEntityForwardVector(trolley.obj)
    local trolley90 = vec(trolleyFwd.y, trolleyFwd.x*-1)
    
    local camPos = vec(anim_pos.x + trolleyFwd.x*1.5 + trolley90.x*1.5, anim_pos.y + trolleyFwd.y*1.5 + trolley90.y*1.5, anim_pos.z+1)
    local camHeading = GetHeadingFromVector_2d(anim_pos.x - camPos.x, anim_pos.y - camPos.y)

    local grab_cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camPos, -20.0, 0.0, camHeading,  60.0, false, 0)
    SetCamActive(grab_cam, true)
    RenderScriptCams(true, true, 1000, true, true)

    local net_scene = NetworkCreateSynchronisedScene(anim_pos, anim_rot, 2, false, false, 1065353216, 0, 1.3)
    local net_scene_2 = NetworkCreateSynchronisedScene(anim_pos, anim_rot, 2, false, false, 1065353216, 0, 1.3)
    local net_scene_3 = NetworkCreateSynchronisedScene(anim_pos, anim_rot, 2, false, false, 1065353216, 0, 1.3)

    local bag = CreateObject(bag_model, pPos, 1, 1, 0)
    Entities[#Entities+1] = bag
    local data = {}

    NetworkAddPedToSynchronisedScene(cache.ped, net_scene, anim_dict, "intro", 1.0, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, net_scene, anim_dict, "bag_intro", 4.0, -8.0, 1)

    NetworkAddPedToSynchronisedScene(cache.ped, net_scene_2, anim_dict, "grab", 1.0, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, net_scene_2, anim_dict, "bag_grab", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(trolley.obj, net_scene_2, anim_dict, "cart_cash_dissapear", 4.0, -8.0, 1)
    tt = trolley.obj

    NetworkAddPedToSynchronisedScene(cache.ped, net_scene_3, anim_dict, "exit", 1.0, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, net_scene_3, anim_dict, "bag_exit", 4.0, -8.0, 1)

    SetPedComponentVariation(cache.ped, 5, 0, 0)
    
    local function handleCancellation()
        NetworkStopSynchronisedScene(net_scene)
        NetworkStopSynchronisedScene(net_scene_2)
        NetworkStopSynchronisedScene(net_scene_3)
        
        ClearPedTasks(cache.ped)

        SetCamActive(grab_cam, false)
        RenderScriptCams(false, true, 1000, true, true)
        
        DeleteObject(bag)
        if DoesEntityExist(cash_prop) then
            DeleteObject(cash_prop)
        end

        SetPedComponentVariation(cache.ped, 5, self_bag.drawable, self_bag.texture, 0)
        FreezeEntityPosition(cache.ped, false)

        _G.cancelLooting = false
        
        in_net_scene_2 = false

        return false
    end

    NetworkStartSynchronisedScene(net_scene)
    Wait((GetAnimDuration(anim_dict, "intro") * 1000) / 1.3 - 100)

    if _G.cancelLooting then
        return handleCancellation()
    end

    in_net_scene_2 = true
    NetworkStartSynchronisedScene(net_scene_2)
    
    local cash_prop = CreateObject(cash_model, pPos, true, true)
    FreezeEntityPosition(cash_prop, true)
    SetEntityInvincible(cash_prop, true)
    SetEntityNoCollisionEntity(cash_prop, cache.ped)
    SetEntityVisible(cash_prop, false)
    AttachEntityToEntity(cash_prop, cache.ped, GetPedBoneIndex(cache.ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    Entities[#Entities+1] = cash_prop
    data.tt = tt

    CreateThread(function()
        while in_net_scene_2 do
            Wait(100)
            if not DoesEntityExist(trolley.obj) then
                _G.cancelLooting = true
                handleCancellation()
                break
            end
        end
    end)

    CreateThread(function()
        data.p = pPos
        while in_net_scene_2 do 
            Wait(1)
            if _G.cancelLooting then
                handleCancellation()
                break
            end

            if HasAnimEventFired(cache.ped, GetHashKey("CASH_APPEAR")) then 
                SetEntityVisible(cash_prop, true) 
            end
            if HasAnimEventFired(cache.ped, GetHashKey("RELEASE_CASH_DESTROY")) then
                SetEntityVisible(cash_prop, false)
                lib.callback.await("hajden_banking:sv_robbery:RELEASE_CASH_DESTROY", false, data, _us)
            end
        end
    end)

    Wait((GetAnimDuration(anim_dict, "grab") * 1000) / 1.3)

    if _G.cancelLooting then
        return handleCancellation()
    end

    if not _G.cancelLooting then
        DeleteObject(trolley.obj)
        local empty_trolley = CreateObject(empty_trolley_model, anim_pos, true, true)
        Entities[#Entities+1] = empty_trolley
        PlaceObjectOnGroundProperly(empty_trolley)
        FreezeEntityPosition(empty_trolley, true)
        SetEntityRotation(empty_trolley, anim_rot)
    end

    DeleteObject(cash_prop)
    in_net_scene_2 = false

    NetworkStartSynchronisedScene(net_scene_3)
    Wait((GetAnimDuration(anim_dict, "exit") * 1000) / 1.3 - 100)

    SetCamActive(grab_cam, false)
    RenderScriptCams(false, true, 1000, true, true)
    DeleteObject(bag)
    SetPedComponentVariation(cache.ped, 5, self_bag.drawable, self_bag.texture, 0)
    FreezeEntityPosition(cache.ped, false)

    _G.cancelLooting = false

    return true
end

cashGrab.spawnCashTrolleys = function(bank)
    if not bank or not bank.robbery or not bank.robbery.cashLocations then return end
    
    local trolleys = {}
    for _, location in ipairs(bank.robbery.cashLocations) do
        local model = location.model
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
        
        local trolleyObj = CreateObject(model,location.coords,true,false,false)
        
        SetEntityCoords(trolleyObj,location.coords.x,location.coords.y,location.coords.z+0.5,false, false, false, false)
        SetEntityRotation(trolleyObj,0.0,0.0,location.rotation,2,true)
        
        FreezeEntityPosition(trolleyObj, true)
        SetEntityAsMissionEntity(trolleyObj, true, true)
        
        local trolley = {
            obj = trolleyObj,
            cfg = location
        }

        table.insert(trolleys, trolley)
        table.insert(Entities, trolley)
    end
    return trolleys
end

cashGrab.cleanupBankEntities = function()
    for _, entity in ipairs(Entities) do
        _e = type(entity) == "table" and entity.obj or entity
        if DoesEntityExist(_e) then
            DeleteEntity(_e)
        end
    end
    Entities = {}
end

cashGrab.addTrolleyTargets = function(trolleys)
    for _, trolley in ipairs(trolleys) do
        exports.ox_target:addLocalEntity(trolley.obj, {
            {
                name = 'grab_cash_' .. _,
                icon = 'fa-solid fa-money-bill',
                label = 'Grab Cash',
                onSelect = function()
                    local success = cashGrab.startAnim(trolley)
                    if success then
                        TriggerServerEvent('hajden_banking:sv_robbery:cashGrabbed')
                    end
                end
            }
        })
    end
end

return cashGrab