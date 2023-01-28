local folderName = "scppalarms_folder" --Folder name in the addon
local name = "SCP Alarms" --Addon name

--Load server file
if SERVER then
    MsgC("["..name.."] Succesfully load serverside !\n")

    --Base config file load in server
    AddCSLuaFile(folderName.."/config.lua")
    include(folderName.."/config.lua")
    AddCSLuaFile(folderName.."/fonts.lua")

    --Language file load in server
    local files = file.Find(folderName.."/language/*.lua", "LUA")
    for _, file in ipairs(files) do
        AddCSLuaFile(folderName.."/language/"..file)
        include(folderName.."/language/"..file)
    end

    --Server file load in server
    local files = file.Find(folderName.."/server/*.lua", "LUA")
    for _, file in ipairs(files) do
        include(folderName.."/server/"..file)
    end

    --Shared file load in server
    local files = file.Find(folderName.."/shared/*.lua", "LUA")
    for _, file in ipairs(files) do
        AddCSLuaFile(folderName.."/shared/"..file)
        include(folderName.."/shared/"..file)
    end

    --Client file load in server
    local files = file.Find(folderName.."/client/*.lua", "LUA")
    for _, file in ipairs(files) do
        AddCSLuaFile(folderName.."/client/"..file)
    end
end

--Load client file
if CLIENT then
    MsgC("["..name.."] Succesfully load clientside !\n")

    --Base config file load in client
    include(folderName.."/config.lua")
    include(folderName.."/fonts.lua")

    --Language file load in client
    local files = file.Find(folderName.."/language/*.lua", "LUA")
    for _, file in ipairs(files) do
        include(folderName.."/language/"..file)
    end

    --Shared file load in client
    local files = file.Find(folderName.."/shared/*.lua", "LUA")
    for _, file in ipairs(files) do
        include(folderName.."/shared/"..file)
    end

    --Client file load in client
    local files = file.Find(folderName.."/client/*.lua", "LUA")
    for _, file in ipairs(files) do
        include(folderName.."/client/"..file)
    end
end
