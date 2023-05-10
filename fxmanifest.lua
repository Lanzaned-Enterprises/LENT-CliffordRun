--[[ Metadata ]]--
fx_version 'cerulean'
games { 'gta5' }

-- [[ Author ]] --
author 'Izumi S. <https://discordapp.com/users/871877975346405388>'
description 'Lananed Development | Clifford Jobs'
discord 'https://discord.lanzaned.com'
github 'https://github.com/Lanzaned-Enterprises/'
docs 'https://docs.lanzaned.com/'

-- [[ Version ]] --
version '1.0.0'

-- [[ Dependencies ]] --
dependencies {
    'PolyZone',
}

-- [[ Files ]] --
shared_scripts { 
    'shared/*.lua',
}
server_scripts { 
    'server/*.lua',
}
client_scripts { 
    -- Polyzone
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    -- Client Events
    'client/*.lua',
    -- Special Events
    'function/cl_*.lua'
}

-- [[ Tebex ]] --
lua54 'yes'

escrow_ignore {
    'shared/*.lua'
}