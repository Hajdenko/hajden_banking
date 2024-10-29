database = {}

database.getPin = function(identifier)
    local result = MySQL.query.await("SELECT pincode FROM users WHERE identifier = ?", {identifier})
    if result and #result > 0 then
        return result[1].pincode
    else
        return nil
    end
end

database.setPin = function(identifier, newPincode)
    database.addPinChange(identifier)
    local affectedRows = MySQL.update.await("UPDATE users SET pincode = ? WHERE identifier = ?", {newPincode, identifier})
    return affectedRows > 0
end

database.addPinChange = function(identifier)
    MySQL.update.await([[
        UPDATE users 
        SET pinchanges = IFNULL(pinchanges, 0) + 1 
        WHERE identifier = ?
    ]], {identifier})
end

database.getPinChanges = function(identifier)
    local result = MySQL.query.await("SELECT pinchanges FROM users WHERE identifier = ?", {identifier})
    if result and #result > 0 then
        return result[1].pinchanges
    else
        return nil
    end
end

lib.callback.register("hajden_banking:database:getPin", function(source, identifier)
    return database.getPin(identifier)
end)

lib.callback.register("hajden_banking:database:setPin", function(source, identifier, newPincode)
    return database.setPin(identifier, newPincode)
end)

lib.callback.register("hajden_banking:database:getPinChanges", function(source, identifier)
    return database.getPinChanges(identifier)
end)

return database