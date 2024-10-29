Config = {}
Config.DEBUG = false

Config.textUI = {
    prompts = { -- dont make it the same otherwise the bank one wont work lol
        bank = "[E] - Open Bank",
        atm = "[E] - Open ATM"
    },
    openKeybind = "E"
}

Config.ATM = {
    enabled = true,
    models = {'prop_atm_01', 'prop_atm_02', 'prop_fleeca_atm', 'prop_atm_03'}
}

Config.PIN = {
    enabled = true,
    length = 4, -- be aware by changing this will result in resetting everyones PIN
    chargeWhenForgotten = true, -- you can set this to a integer if you want to charge only after a certain amount of changes
    changeCost = 5000
}

Config.billing = {
    enabled = {
        command = true,
        inBanking = true
    },
    command = {"billing", "bill", "bills"}, -- table or string
    defaultJob = "unemployed",
    allowedJobs = { -- who can send billings?
        { job = "police", grade = 2 } -- the job name & the grade from where the player can send the bills to other players.
    },
    jobBills = { -- who can manage the job bills?
        { job = "police", grade = 2 } -- the job name & the grade from where the player can manage the bills.
    }
}

Config.robbery = {
    enabled = {
        idcard = true, -- players can access the vault trough idcards if found
        hack = true -- players can access the vault trough hacking the terminal
    },
    neededItems = { -- you can set idcard/hack to nil if you dont want to use items
        idcard = "idcard",
        hack = "laptop"
    },
    hack = {
        resetTime = 60, -- seconds
        rewardItem = "money",
        rewardAmount = {100,200}, -- the user will get 100-200$
        alertCops = function()
            print("alertCops")
            -- just return if you dont want to alert the cops, please if you do, add the event and notify yourself
            -- if you want a chance system:
            CHANCE = 70
            if math.random(0, 100) <= CHANCE then
                -- alert the cops
            end return
        end,
        minigame = function()
            -- please always always return if the player got it right. any except false/nil will be recognized as true which means the user will get access.
            return lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}}, {'w','a','s','d'})
        end
    }
}

Config.contextMenu = {
    welcome = false,
    quickActions = {
        deposit = {
            { amount = 10000 },
            { amount = 50000 },
            { amount = 100000 }
        },
        withdraw = {
            { amount = 10000 },
            { amount = 50000 },
            { amount = 100000 }
        }
    }
}