RegisterNetEvent("hajden_banking:sv_robbery:syncDoor")
AddEventHandler("hajden_banking:sv_robbery:syncDoor", function(syncData)
    TriggerClientEvent("hajden_banking:cl_robbery:syncDoor", -1, syncData)
end)

lib.callback.register("hajden_banking:sv_robbery:RELEASE_CASH_DESTROY", function(source, data, _ff)
    print(not data, not data.p, not data.tt, _ff ~= nil, #(vec3(data.p.x,data.p.y,data.p.z-1) - GetEntityCoords(data.tt)) > 2)
    if not data then return end
    if not data.p then return end
    if not data.tt then return end
    if _ff then return end
    if not ( #(vec3(data.p.x,data.p.y,data.p.z-1) - GetEntityCoords(data.tt)) > 2 ) then return end
    exports.ox_inventory:AddItem(source, Config.robbery.hack.rewardItem, math.random(Config.robbery.hack.rewardAmount[1],Config.robbery.hack.rewardAmount[2]))
end)