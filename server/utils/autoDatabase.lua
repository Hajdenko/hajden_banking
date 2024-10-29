CreateThread(function()
    MySQL.ready(function()
        repeat Wait(5) until Config ~= nil
        if Config.PIN.enabled then 
            MySQL.query("SHOW COLUMNS FROM users LIKE 'pincode'", {}, function(result)
                if #result == 0 then
                    MySQL.execute("ALTER TABLE users ADD COLUMN pincode VARCHAR("..Config.PIN.length..")", {})
                else
                    MySQL.query("SHOW COLUMNS FROM users WHERE Field = 'pincode'", {}, function(columnInfo)
                        local currentLength = tonumber(string.match(columnInfo[1].Type, "%d+"))
                        if currentLength ~= Config.PIN.length then
                            MySQL.execute("UPDATE users SET pincode = NULL", {}, function()
                                MySQL.execute("ALTER TABLE users MODIFY COLUMN pincode VARCHAR("..Config.PIN.length..")", {})
                            end)
                        end
                    end)
                end
            end)
    
            MySQL.query("SHOW COLUMNS FROM users LIKE 'pinchanges'", {}, function(result)
                if #result == 0 then
                    MySQL.execute("ALTER TABLE users ADD COLUMN pinchanges VARCHAR(255)", {})
                end
            end)
        end

        if ( Config.billing.enabled.command ) or ( Config.billing.enabled.inBanking ) then
            MySQL.query("SHOW TABLES LIKE 'hajden_banking_playerBills'", {}, function(result)
                if #result == 0 then
                    MySQL.execute([[
                        CREATE TABLE hajden_banking_playerBills (
                            id INT AUTO_INCREMENT PRIMARY KEY,
                            identifier VARCHAR(255),
                            title VARCHAR(255),
                            cost INT,
                            reason VARCHAR(255),
                            `from` VARCHAR(255),
                            status ENUM('paid', 'unpaid') DEFAULT 'unpaid'
                        )
                    ]], {})
                else
                    MySQL.query("SHOW COLUMNS FROM hajden_banking_playerBills LIKE 'status'", {}, function(statusColumn)
                        if #statusColumn == 0 then
                            MySQL.execute("ALTER TABLE hajden_banking_playerBills ADD COLUMN status ENUM('paid', 'unpaid') DEFAULT 'unpaid'", {})
                        end
                    end)
                end
            end)
    
            MySQL.query("SHOW TABLES LIKE 'hajden_banking_jobBills'", {}, function(result)
                if #result == 0 then
                    MySQL.execute([[
                        CREATE TABLE hajden_banking_jobBills (
                            id INT AUTO_INCREMENT PRIMARY KEY,
                            jobName VARCHAR(255),
                            title VARCHAR(255),
                            cost INT,
                            reason VARCHAR(255),
                            `from` VARCHAR(255),
                            status ENUM('paid', 'unpaid') DEFAULT 'unpaid'
                        )
                    ]], {})
                else
                    MySQL.query("SHOW COLUMNS FROM hajden_banking_jobBills LIKE 'status'", {}, function(statusColumn)
                        if #statusColumn == 0 then
                            MySQL.execute("ALTER TABLE hajden_banking_jobBills ADD COLUMN status ENUM('paid', 'unpaid') DEFAULT 'unpaid'", {})
                        end
                    end)
                end
            end)
        end
    end)
end)