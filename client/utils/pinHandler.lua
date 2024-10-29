pinHandler = {}

pinHandler.getPin = function(identifier, cb)
    cb(lib.callback.await("hajden_banking:database:getPin", false, identifier))
end

pinHandler.setPin = function(identifier, newPincode, cb)
    cb(lib.callback.await("hajden_banking:database:setPin", false, identifier, newPincode))
end

pinHandler.getPinChanges = function(identifer, cb)
    cb(lib.callback.await("hajden_banking:databse:getPinChanges", false, identifier))
end

return pinHandler