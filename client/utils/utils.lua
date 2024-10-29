Utils = {}

Utils.getNearestBank = function(banks)
    local pCoords = GetEntityCoords(cache.ped)
    for _, bank in ipairs(banks) do
        if #(bank.data.coords - pCoords) < bank.data.radius then
            return _, bank
        end
    end
    if Config.ATM.enabled then
        for k, v in pairs(Config.ATM.models) do
            e = GetClosestObjectOfType(GetEntityCoords(cache.ped), 1.0, GetHashKey(v), false, false, false)

            if ( e ~= 0 ) then
                return k, {data = {name = "ATM"}}
            end
        end
    end
    return false
end

Utils.getAccount = function(account)
    return lib.callback.await("hajden_banking:getAccount", false, {account = account})
end

Utils.formatMoney = function(num)
    _ = tostring(num):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if _:sub(1,1) == "," then
        _ = _:sub(2)
    end

    return _
end

return Utils