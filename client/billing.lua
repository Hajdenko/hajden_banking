context = require('client.utils.context')
Utils = require('client.utils.utils')

local playerBills = lib.callback.await("hajden_banking:sv_billing:getPlayerBills", false)

local function registerBillingMenus()
    local playerBills = lib.callback.await("hajden_banking:sv_billing:getPlayerBills", false)
    local pJob = lib.callback.await("hajden_banking:sv_billing:getJob", false)
    local jobBills = lib.callback.await("hajden_banking:sv_billing:getJobBills", false, pJob.name)

    lib.registerContext({
        id = "hajden_banking:billing:main",
        title = "Billing",
        options = context.createBillingOptions(playerBills)
    })

    lib.registerContext({
        id = "hajden_banking:billing:yourBills",
        title = "Your Bills",
        menu = "hajden_banking:billing:main",
        options = context.createPlayerBillsOptions(playerBills)
    })

    if pJob.name ~= Config.billing.defaultJob then
        lib.registerContext({
            id = "hajden_banking:billing:jobBills",
            title = "Job Bills",
            menu = "hajden_banking:billing:main",
            options = context.createJobBillsOptions(jobBills)
        })
    end
end

openUI = function()
    registerBillingMenus()
    lib.showContext("hajden_banking:billing:main")
end
lib.callback.register("hajden_banking:cl_billing:openUI", openUI)