--[[
    Koumarianos Appearance - Storage Module
--]]

Storage = {}
Storage.prefix = "koumarianos_appearance"
Storage.identifier = nil
Storage.ready = false
Storage.initAttempted = false

--[[
    Initialize storage system (idempotent)
--]]
function Storage.Init()
    if Storage.ready and Storage.identifier and Storage.identifier ~= "" then
        if Config.Debug then
            print(('[Koumarianos Storage] Init: Already initialized with identifier: %s'):format(Storage.identifier))
        end
        return
    end
    
    if Storage.initAttempted then
        if Config.Debug then
            print('[Koumarianos Storage] Init: Already attempting initialization, skipping duplicate call')
        end
        return
    end
    
    Storage.initAttempted = true
    
    CreateThread(function()
        if Config.Debug then
            print('[Koumarianos Storage] Initializing...')
        end
        
        local attempts = 0
        while not ESX or not ESX.IsPlayerLoaded() do
            Wait(500)
            attempts = attempts + 1
            if attempts > 20 then
                print('[Koumarianos Storage] ERROR: ESX not loaded after 10 seconds')
                Storage.initAttempted = false
                return
            end
        end
        
        if Config.Debug then
            print('[Koumarianos Storage] ESX loaded, requesting identifier from server...')
        end
        
        local identifierReceived = false
        
        RegisterNetEvent('apex_appearance:receiveIdentifier')
        AddEventHandler('apex_appearance:receiveIdentifier', function(identifier)
            if identifierReceived then
                if Config.Debug then
                    print('[Koumarianos Storage] WARNING: Received duplicate identifier, ignoring')
                end
                return
            end
            
            identifierReceived = true
            
            if identifier and identifier ~= "" and string.match(identifier, ':') then
                Storage.identifier = identifier
                Storage.ready = true
                print(('[Koumarianos Storage] ✓ Identifier received: %s'):format(identifier))
                print('[Koumarianos Storage] ✓ Storage is READY')
            else
                print(('[Koumarianos Storage] ERROR: Received invalid identifier: %s'):format(tostring(identifier)))
                Storage.ready = false
                Storage.identifier = nil
            end
        end)
        
        TriggerServerEvent('apex_appearance:requestIdentifier')
        
        local timeout = 0
        while not Storage.ready and timeout < 50 do
            Wait(100)
            timeout = timeout + 1
        end
        
        if not Storage.ready then
            print('[Koumarianos Storage] ERROR: Identifier timeout after 5 seconds')
            print('[Koumarianos Storage] ERROR: Cannot save/load without valid identifier!')
            Storage.initAttempted = false
        else
            if Config.Debug then
                print(('[Koumarianos Storage] ✓ Initialization complete with identifier: %s'):format(Storage.identifier))
            end
        end
    end)
end

function Storage.WaitReady()
    local timeout = 0
    while not Storage.ready and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
    
    if not Storage.ready then
        print('[Koumarianos Storage] ERROR: WaitReady timeout - Storage not ready')
        print('[Koumarianos Storage] ERROR: Identifier is: ' .. tostring(Storage.identifier))
    end
    
    return Storage.ready
end

--[[
    Build KVP key from identifier + key type + optional subkey
    Format: koumarianos_appearance:license:xxxxx:keyType(:subKey)
--]]
function Storage.GetKey(keyType, subKey)
    if not Storage.identifier or Storage.identifier == "" then
        print('[Koumarianos Storage] ERROR: GetKey called but identifier is nil or empty')
        return nil
    end
    
    local base = string.format("%s:%s", Storage.prefix, Storage.identifier)
    local key
    if subKey then
        key = string.format("%s:%s:%s", base, keyType, subKey)
    else
        key = string.format("%s:%s", base, keyType)
    end
    
    return key
end

--[[
    Write JSON data to KVP
    Returns true if verified successfully written
--]]
function Storage.Set(keyType, data, subKey)
    if not Storage.WaitReady() then
        print('[Koumarianos Storage] ERROR: Set called but storage not ready')
        return false
    end
    
    local key = Storage.GetKey(keyType, subKey)
    if not key then
        print('[Koumarianos Storage] ERROR: Set got nil key')
        return false
    end
    
    local success, jsonData = pcall(json.encode, data)
    if not success then
        print(('[Koumarianos Storage] ERROR: JSON encode failed: %s'):format(jsonData))
        return false
    end
    
    if Config.Debug then
        print(('[Koumarianos Storage] SET | Key: %s'):format(key))
        print(('[Koumarianos Storage] SET | Size: %d bytes'):format(#jsonData))
    end
    
    SetResourceKvp(key, jsonData)
    
    local verify = GetResourceKvpString(key)
    if verify and verify ~= "" then
        if Config.Debug then
            print(('[Koumarianos Storage] SET ✓ SUCCESS'):format())
        end
        return true
    else
        print(('[Koumarianos Storage] SET ✗ FAILED | Key: %s'):format(key))
        return false
    end
end

--[[
    Read JSON data from KVP
    Returns decoded table or nil
--]]
function Storage.Get(keyType, subKey)
    if not Storage.WaitReady() then
        print('[Koumarianos Storage] ERROR: Get called but storage not ready')
        return nil
    end
    
    local key = Storage.GetKey(keyType, subKey)
    if not key then
        print('[Koumarianos Storage] ERROR: Get got nil key')
        return nil
    end
    
    if Config.Debug then
        print(('[Koumarianos Storage] GET | Key: %s'):format(key))
    end
    
    local data = GetResourceKvpString(key)
    
    if not data or data == "" then
        if Config.Debug then
            print(('[Koumarianos Storage] GET ✗ NO DATA'):format())
        end
        return nil
    end
    
    local success, decoded = pcall(json.decode, data)
    if success then
        if Config.Debug then
            print(('[Koumarianos Storage] GET ✓ SUCCESS | Size: %d bytes'):format(#data))
        end
        return decoded
    else
        print(('[Koumarianos Storage] GET ✗ DECODE FAILED | Error: %s'):format(decoded))
        return nil
    end
end

function Storage.SetInt(keyType, value, subKey)
    if not Storage.WaitReady() then
        return false
    end
    
    local key = Storage.GetKey(keyType, subKey)
    if not key then
        return false
    end
    
    SetResourceKvpInt(key, tonumber(value) or 0)
    return true
end

function Storage.GetInt(keyType, subKey)
    if not Storage.WaitReady() then
        return 0
    end
    
    local key = Storage.GetKey(keyType, subKey)
    if not key then
        return 0
    end
    
    return GetResourceKvpInt(key)
end

function Storage.Delete(keyType, subKey)
    if not Storage.WaitReady() then
        return false
    end
    
    local key = Storage.GetKey(keyType, subKey)
    if not key then
        return false
    end
    
    DeleteResourceKvp(key)
    return true
end

function Storage.HasDefault()
    local hasDefault = Storage.GetInt("hasDefault")
    return hasDefault == 1
end

function Storage.SaveDefault(appearance)
    if not appearance then
        print('[Koumarianos Storage] ERROR: SaveDefault called with nil appearance')
        return false
    end
    
    local success = Storage.Set("default", appearance)
    if success then
        Storage.SetInt("hasDefault", 1)
        return true
    end
    return false
end

function Storage.GetDefault()
    if not Storage.HasDefault() then
        return nil
    end
    
    return Storage.Get("default")
end

function Storage.SaveOutfit(name, appearance)
    if not name or name == "" or not appearance then
        return false
    end
    
    local success = Storage.Set("outfit", appearance, name)
    if success then
        Storage.AddOutfitToList(name)
        return true
    end
    return false
end

function Storage.GetOutfit(name)
    if not name or name == "" then
        return nil
    end
    
    return Storage.Get("outfit", name)
end

function Storage.DeleteOutfit(name)
    if not name or name == "" then
        return false
    end
    
    Storage.Delete("outfit", name)
    Storage.RemoveOutfitFromList(name)
    return true
end

function Storage.GetAllOutfits()
    local list = Storage.Get("outfit_list")
    if not list or type(list) ~= "table" then
        return {}
    end
    return list
end

function Storage.AddOutfitToList(name)
    if not name or name == "" then
        return false
    end
    
    local list = Storage.GetAllOutfits()
    
    for _, v in ipairs(list) do
        if v == name then
            return true
        end
    end
    
    table.insert(list, name)
    return Storage.Set("outfit_list", list)
end

function Storage.RemoveOutfitFromList(name)
    if not name or name == "" then
        return false
    end
    
    local list = Storage.GetAllOutfits()
    local newList = {}
    
    for _, v in ipairs(list) do
        if v ~= name then
            table.insert(newList, v)
        end
    end
    
    return Storage.Set("outfit_list", newList)
end

function Storage.ClearAll()
    Storage.Delete("default")
    Storage.SetInt("hasDefault", 0)
    
    local outfits = Storage.GetAllOutfits()
    for _, name in ipairs(outfits) do
        Storage.DeleteOutfit(name)
    end
    
    Storage.Set("outfit_list", {})
    return true
end