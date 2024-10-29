fx_version('cerulean')
games({ 'gta5' })
lua54('yes')

author('hajdenkoo')
description('Advanced Banking, Billing and Bank Robbery Script')
version('1.0.0')

shared_script({
    '@ox_lib/init.lua',
    'shared/*.lua'
});

server_scripts({
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
});

client_scripts({
    -- 'client/*.lua',
    'client/**/*.lua'
});