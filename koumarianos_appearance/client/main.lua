--[[
    Koumarianos Appearance - Main Client Module
--]]

ESX = exports['es_extended']:getSharedObject()

local menuOpen = false
local menuType = nil
local isForced = false
local currentCamera = nil
local cameraRotation = 0.0
local cameraMode = 'body'
local playerSpawned = false
local mainMenuOpen = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    if Config.Debug then
        print('[Koumarianos Main] esx:playerLoaded received')
    end
    Storage.Init()
    Wait(1000)
end)

CreateThread(function()
    Wait(1000)
    if ESX.IsPlayerLoaded() then
        if Config.Debug then
            print('[Koumarianos Main] Player already loaded on resource start')
        end
        Storage.Init()
    end
end)

AddEventHandler('playerSpawned', function()
    if not playerSpawned then
        playerSpawned = true
    end
end)

CreateThread(function()
    while true do
        Wait(Config.ModelCheckInterval)
        
        if not menuOpen then
            local ped = PlayerPedId()
            local model = GetEntityModel(ped)
            
            if not Config.AllowedModels[model] then
                local defaultApp = Storage.GetDefault()
                if defaultApp then
                    defaultApp = Appearance.Normalize(defaultApp)
                    if defaultApp then
                        Appearance.Apply(defaultApp)
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 244) then
            if not menuOpen and not mainMenuOpen then
                OpenMainMenu()
            end
        end
    end
end)

function OpenMainMenu()
    mainMenuOpen = true
    
    SendNUIMessage({
        action = 'openMainMenu',
        hasDefault = Storage.HasDefault()
    })
    
    SetNuiFocus(true, true)
end

function CloseMainMenu()
    mainMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({action = 'closeMainMenu'})
end

--[[
    Sanitize appearance for NUI
--]]
function SanitizeAppearanceForNUI(appearance)
    if not appearance or type(appearance) ~= "table" then
        return nil
    end
    
    local sanitized = {
        model = tostring(appearance.model or 0),
        gender = appearance.gender or 'male',
        headBlend = appearance.headBlend or {},
        faceFeatures = appearance.faceFeatures or {},
        hairColor = appearance.hairColor or {primary = 0, highlight = 0},
        eyeColor = appearance.eyeColor or 0,
        overlays = appearance.overlays or {},
        components = appearance.components or {},
        props = appearance.props or {}
    }
    
    return sanitized
end

function OpenClothingMenu()
    if menuOpen then return end
    
    menuOpen = true
    menuType = 'clothing'
    isForced = false
    
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    
    local appearance = Appearance.Capture()
    if not appearance then
        TriggerEvent('esx:showNotification', 'Failed to capture appearance')
        menuOpen = false
        return
    end
    
    local sanitized = SanitizeAppearanceForNUI(appearance)
    if not sanitized then
        TriggerEvent('esx:showNotification', 'Failed to prepare appearance data')
        menuOpen = false
        return
    end
    
    local outfits = Storage.GetAllOutfits()
    
    SendNUIMessage({
        action = 'open',
        type = 'clothing',
        forced = false,
        appearance = sanitized,
        config = {
            components = Config.Components,
            props = Config.Props,
            overlays = Config.Overlays,
            faceFeatures = Config.FaceFeatures,
            parents = Config.Parents,
            hairColors = Config.HairColors,
            eyeColors = Config.EyeColors
        },
        outfits = outfits,
        hasDefault = Storage.HasDefault()
    })
    
    CreateCamera()
end

function OpenCharacterCreator(forced)
    if menuOpen then return end
    
    menuOpen = true
    menuType = 'creator'
    isForced = forced or false
    
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    
    local appearance = Appearance.Capture()
    if not appearance then
        TriggerEvent('esx:showNotification', 'Failed to capture appearance')
        menuOpen = false
        return
    end
    
    local sanitized = SanitizeAppearanceForNUI(appearance)
    if not sanitized then
        TriggerEvent('esx:showNotification', 'Failed to prepare appearance data')
        menuOpen = false
        return
    end
    
    local outfits = Storage.GetAllOutfits()
    
    SendNUIMessage({
        action = 'open',
        type = 'creator',
        forced = isForced,
        appearance = sanitized,
        config = {
            components = Config.Components,
            props = Config.Props,
            overlays = Config.Overlays,
            faceFeatures = Config.FaceFeatures,
            parents = Config.Parents,
            hairColors = Config.HairColors,
            eyeColors = Config.EyeColors
        },
        outfits = outfits,
        hasDefault = Storage.HasDefault()
    })
    
    CreateCamera()
end

function CloseMenu()
    if not menuOpen then return end
    
    if isForced then
        TriggerEvent('esx:showNotification', 'You must complete character creation first!')
        return
    end
    
    menuOpen = false
    menuType = nil
    isForced = false
    
    SetNuiFocus(false, false)
    SendNUIMessage({action = 'close'})
    
    DestroyCamera()
end

function CreateCamera()
    if currentCamera then
        DestroyCamera()
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    currentCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(currentCamera, true)
    RenderScriptCams(true, false, 0, true, true)
    
    cameraMode = 'body'
    cameraRotation = 0.0
    
    UpdateCamera()
end

function UpdateCamera()
    if not currentCamera then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    local camPos = Config.Camera.positions[cameraMode]
    if not camPos then camPos = Config.Camera.positions.body end
    
    local angleRad = math.rad(heading + cameraRotation)
    local offsetX = camPos.offset.x * math.cos(angleRad) - camPos.offset.y * math.sin(angleRad)
    local offsetY = camPos.offset.x * math.sin(angleRad) + camPos.offset.y * math.cos(angleRad)
    
    local camCoords = coords + vector3(offsetX, offsetY, camPos.offset.z)
    local pointCoords = coords + vector3(0.0, 0.0, camPos.pointOffset.z)
    
    SetCamCoord(currentCamera, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtCoord(currentCamera, pointCoords.x, pointCoords.y, pointCoords.z)
    SetCamFov(currentCamera, Config.Camera.fov)
end

function DestroyCamera()
    if currentCamera then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(currentCamera, false)
        currentCamera = nil
    end
end

function RotateCamera(direction)
    cameraRotation = cameraRotation + (direction * 5.0)
    if cameraRotation >= 360.0 then cameraRotation = 0.0 end
    if cameraRotation < 0.0 then cameraRotation = 359.0 end
    UpdateCamera()
end

function SetCameraMode(mode)
    cameraMode = mode
    UpdateCamera()
end

RegisterNUICallback('selectCreator', function(data, cb)
    CloseMainMenu()
    Wait(100)
    OpenCharacterCreator(false)
    cb('ok')
end)

RegisterNUICallback('selectClothing', function(data, cb)
    CloseMainMenu()
    Wait(100)
    OpenClothingMenu()
    cb('ok')
end)

RegisterNUICallback('closeMainMenu', function(data, cb)
    CloseMainMenu()
    cb('ok')
end)

RegisterNUICallback('updateAppearance', function(data, cb)
    if not data or not data.appearance then
        cb('ok')
        return
    end
    
    Appearance.Apply(data.appearance)
    cb('ok')
end)

RegisterNUICallback('updateComponent', function(data, cb)
    if not data or not data.componentId then
        cb({maxDrawable = 0, maxTexture = 0})
        return
    end
    
    local ped = PlayerPedId()
    local componentId = math.floor(tonumber(data.componentId) or 0)
    local drawable = math.floor(tonumber(data.drawable) or 0)
    local texture = math.floor(tonumber(data.texture) or 0)
    
    componentId = math.max(0, math.min(11, componentId))
    
    local maxDrawable = GetNumberOfPedDrawableVariations(ped, componentId) - 1
    if maxDrawable < 0 then maxDrawable = 0 end
    
    drawable = math.max(0, math.min(maxDrawable, drawable))
    
    local maxTexture = GetNumberOfPedTextureVariations(ped, componentId, drawable) - 1
    if maxTexture < 0 then maxTexture = 0 end
    
    texture = math.max(0, math.min(maxTexture, texture))
    
    SetPedComponentVariation(ped, componentId, drawable, texture, 0)
    
    cb({
        maxDrawable = math.floor(maxDrawable),
        maxTexture = math.floor(maxTexture)
    })
end)

RegisterNUICallback('updateProp', function(data, cb)
    if not data or not data.propId then
        cb({maxDrawable = -1, maxTexture = 0})
        return
    end
    
    local ped = PlayerPedId()
    local propId = math.floor(tonumber(data.propId) or 0)
    local drawable = math.floor(tonumber(data.drawable) or -1)
    local texture = math.floor(tonumber(data.texture) or 0)
    
    propId = math.max(0, math.min(7, propId))
    
    if drawable == -1 then
        ClearPedProp(ped, propId)
        cb({maxDrawable = -1, maxTexture = 0})
        return
    end
    
    local maxDrawable = GetNumberOfPedPropDrawableVariations(ped, propId) - 1
    if maxDrawable < 0 then
        ClearPedProp(ped, propId)
        cb({maxDrawable = -1, maxTexture = 0})
        return
    end
    
    drawable = math.max(0, math.min(maxDrawable, drawable))
    
    local maxTexture = GetNumberOfPedPropTextureVariations(ped, propId, drawable) - 1
    if maxTexture < 0 then maxTexture = 0 end
    
    texture = math.max(0, math.min(maxTexture, texture))
    
    SetPedPropIndex(ped, propId, drawable, texture, true)
    
    cb({
        maxDrawable = math.floor(maxDrawable),
        maxTexture = math.floor(maxTexture)
    })
end)

RegisterNUICallback('getComponentRange', function(data, cb)
    if not data or not data.componentId then
        cb({maxDrawable = 0, maxTexture = 0})
        return
    end
    
    local ped = PlayerPedId()
    local componentId = math.floor(tonumber(data.componentId) or 0)
    local drawable = math.floor(tonumber(data.drawable) or 0)
    
    componentId = math.max(0, math.min(11, componentId))
    
    local maxDrawable = GetNumberOfPedDrawableVariations(ped, componentId) - 1
    if maxDrawable < 0 then maxDrawable = 0 end
    
    drawable = math.max(0, math.min(maxDrawable, drawable))
    
    local maxTexture = GetNumberOfPedTextureVariations(ped, componentId, drawable) - 1
    if maxTexture < 0 then maxTexture = 0 end
    
    cb({
        maxDrawable = math.floor(maxDrawable),
        maxTexture = math.floor(maxTexture)
    })
end)

RegisterNUICallback('getPropRange', function(data, cb)
    if not data or not data.propId then
        cb({maxDrawable = -1, maxTexture = 0})
        return
    end
    
    local ped = PlayerPedId()
    local propId = math.floor(tonumber(data.propId) or 0)
    local drawable = math.floor(tonumber(data.drawable) or 0)
    
    propId = math.max(0, math.min(7, propId))
    
    local maxDrawable = GetNumberOfPedPropDrawableVariations(ped, propId) - 1
    if maxDrawable < 0 then
        cb({maxDrawable = -1, maxTexture = 0})
        return
    end
    
    drawable = math.max(0, math.min(maxDrawable, drawable))
    
    local maxTexture = GetNumberOfPedPropTextureVariations(ped, propId, drawable) - 1
    if maxTexture < 0 then maxTexture = 0 end
    
    cb({
        maxDrawable = math.floor(maxDrawable),
        maxTexture = math.floor(maxTexture)
    })
end)

RegisterNUICallback('changeGender', function(data, cb)
    if not data or not data.gender then
        cb({appearance = nil})
        return
    end
    
    local newModel = data.gender == 'male' and `mp_m_freemode_01` or `mp_f_freemode_01`
    local defaultApp = Appearance.GetDefaultForModel(newModel)
    Appearance.Apply(defaultApp)
    
    local sanitized = SanitizeAppearanceForNUI(defaultApp)
    cb({appearance = sanitized})
end)

--[[
    Save callback
--]]
RegisterNUICallback('save', function(data, cb)
    if Config.Debug then
        print('[Koumarianos Main] ═══════════ SAVE START ═══════════')
    end
    
    local appearance = Appearance.Capture()
    
    if not appearance then
        print('[Koumarianos Main] ERROR: save - Capture failed')
        TriggerEvent('esx:showNotification', 'Failed to capture appearance!')
        cb({success = false, hasDefault = Storage.HasDefault()})
        return
    end
    
    appearance = Appearance.Normalize(appearance)
    
    if not appearance then
        print('[Koumarianos Main] ERROR: save - Normalize failed')
        TriggerEvent('esx:showNotification', 'Failed to normalize appearance!')
        cb({success = false, hasDefault = Storage.HasDefault()})
        return
    end
    
    local success = Storage.SaveDefault(appearance)
    
    if success then
        if Config.Debug then
            local verify = Storage.GetDefault()
            if verify then
                verify = Appearance.Normalize(verify)
                print(('[Koumarianos Main] ✓ VERIFY: Model %d saved'):format(verify.model))
                print(('[Koumarianos Main] ✓ VERIFY: Components[0] = drawable:%d texture:%d'):format(
                    verify.components[0].drawable, verify.components[0].texture))
                print(('[Koumarianos Main] ✓ VERIFY: Props[0] = drawable:%d texture:%d'):format(
                    verify.props[0].drawable, verify.props[0].texture))
            else
                print('[Koumarianos Main] ✗ VERIFY FAILED: Could not read back')
            end
        end
        
        TriggerEvent('esx:showNotification', 'Appearance saved successfully!')
        
        if isForced and Config.RequireDefaultOnFirstJoin then
            isForced = false
            SendNUIMessage({action = 'updateForced', forced = false})
        end
        
        cb({success = true, hasDefault = true})
    else
        print('[Koumarianos Main] ERROR: save - Storage.SaveDefault failed')
        TriggerEvent('esx:showNotification', 'Failed to save appearance!')
        cb({success = false, hasDefault = Storage.HasDefault()})
    end
    
    if Config.Debug then
        print('[Koumarianos Main] ═══════════ SAVE END ═══════════')
    end
end)

RegisterNUICallback('setDefault', function(data, cb)
    local appearance = Appearance.Capture()
    if not appearance then
        TriggerEvent('esx:showNotification', 'Failed to capture appearance!')
        cb({hasDefault = false})
        return
    end
    
    appearance = Appearance.Normalize(appearance)
    
    if not appearance then
        TriggerEvent('esx:showNotification', 'Failed to normalize appearance!')
        cb({hasDefault = false})
        return
    end
    
    local success = Storage.SaveDefault(appearance)
    if success then
        TriggerEvent('esx:showNotification', 'Default appearance set!')
        
        if isForced then
            isForced = false
            SendNUIMessage({action = 'updateForced', forced = false})
        end
        
        cb({hasDefault = true})
    else
        TriggerEvent('esx:showNotification', 'Failed to save default!')
        cb({hasDefault = false})
    end
end)

--[[
    Load default callback
--]]
RegisterNUICallback('loadDefault', function(data, cb)
    if Config.Debug then
        print('[Koumarianos Main] ═══════════ LOAD DEFAULT START ═══════════')
    end
    
    local defaultApp = Storage.GetDefault()
    if not defaultApp then
        TriggerEvent('esx:showNotification', 'No default appearance saved!')
        cb({appearance = nil})
        return
    end
    
    defaultApp = Appearance.Normalize(defaultApp)
    
    if not defaultApp then
        print('[Koumarianos Main] ERROR: loadDefault - Normalize failed')
        TriggerEvent('esx:showNotification', 'Saved appearance data is corrupted!')
        cb({appearance = nil})
        return
    end
    
    if Config.Debug then
        print(('[Koumarianos Main] LOAD: Model %d'):format(defaultApp.model))
        print(('[Koumarianos Main] LOAD: Components[0] = drawable:%d texture:%d'):format(
            defaultApp.components[0].drawable, defaultApp.components[0].texture))
        print(('[Koumarianos Main] LOAD: Props[0] = drawable:%d texture:%d'):format(
            defaultApp.props[0].drawable, defaultApp.props[0].texture))
    end
    
    local success = Appearance.Apply(defaultApp)
    if success then
        TriggerEvent('esx:showNotification', 'Default appearance loaded!')
        local sanitized = SanitizeAppearanceForNUI(defaultApp)
        cb({appearance = sanitized})
    else
        TriggerEvent('esx:showNotification', 'Failed to apply default!')
        cb({appearance = nil})
    end
    
    if Config.Debug then
        print('[Koumarianos Main] ═══════════ LOAD DEFAULT END ═══════════')
    end
end)

--[[
    Save outfit callback
--]]
RegisterNUICallback('saveOutfit', function(data, cb)
    if not data or not data.name or data.name == "" then
        cb({success = false, message = 'Invalid outfit name!'})
        return
    end
    
    local name = tostring(data.name)
    
    if Config.Debug then
        print(('[Koumarianos Main] ═══════════ SAVE OUTFIT "%s" START ═══════════'):format(name))
    end
    
    local appearance = Appearance.Capture()
    
    if not appearance then
        print('[Koumarianos Main] ERROR: saveOutfit - Capture failed')
        cb({success = false, message = 'Failed to capture appearance!'})
        return
    end
    
    appearance = Appearance.Normalize(appearance)
    
    if not appearance then
        print('[Koumarianos Main] ERROR: saveOutfit - Normalize failed')
        cb({success = false, message = 'Failed to normalize appearance!'})
        return
    end
    
    local success = Storage.SaveOutfit(name, appearance)
    
    if success then
        if Config.Debug then
            local verify = Storage.GetOutfit(name)
            if verify then
                verify = Appearance.Normalize(verify)
                print(('[Koumarianos Main] ✓ VERIFY: Outfit "%s" model %d saved'):format(name, verify.model))
                print(('[Koumarianos Main] ✓ VERIFY: Components[0] = drawable:%d texture:%d'):format(
                    verify.components[0].drawable, verify.components[0].texture))
            else
                print(('[Koumarianos Main] ✗ VERIFY FAILED: Could not read outfit "%s"'):format(name))
            end
        end
        
        TriggerEvent('esx:showNotification', 'Outfit "' .. name .. '" saved!')
        cb({success = true, outfits = Storage.GetAllOutfits()})
    else
        print('[Koumarianos Main] ERROR: saveOutfit - Storage.SaveOutfit failed')
        TriggerEvent('esx:showNotification', 'Failed to save outfit!')
        cb({success = false, message = 'Failed to save outfit!'})
    end
    
    if Config.Debug then
        print(('[Koumarianos Main] ═══════════ SAVE OUTFIT "%s" END ═══════════'):format(name))
    end
end)

--[[
    Load outfit callback
--]]
RegisterNUICallback('loadOutfit', function(data, cb)
    if not data or not data.name or data.name == "" then
        TriggerEvent('esx:showNotification', 'Invalid outfit name!')
        cb({success = false})
        return
    end
    
    local name = tostring(data.name)
    
    if Config.Debug then
        print(('[Koumarianos Main] ═══════════ LOAD OUTFIT "%s" START ═══════════'):format(name))
    end
    
    local outfit = Storage.GetOutfit(name)
    
    if not outfit then
        TriggerEvent('esx:showNotification', 'Outfit not found!')
        cb({success = false})
        return
    end
    
    outfit = Appearance.Normalize(outfit)
    
    if not outfit then
        print(('[Koumarianos Main] ERROR: loadOutfit - Normalize failed for "%s"'):format(name))
        TriggerEvent('esx:showNotification', 'Outfit data is corrupted!')
        cb({success = false})
        return
    end
    
    if Config.Debug then
        print(('[Koumarianos Main] LOAD: Outfit "%s" model %d'):format(name, outfit.model))
        print(('[Koumarianos Main] LOAD: Components[0] = drawable:%d texture:%d'):format(
            outfit.components[0].drawable, outfit.components[0].texture))
    end
    
    local success = Appearance.Apply(outfit)
    
    if success then
        TriggerEvent('esx:showNotification', 'Outfit "' .. name .. '" loaded!')
        local sanitized = SanitizeAppearanceForNUI(outfit)
        cb({success = true, appearance = sanitized})
    else
        TriggerEvent('esx:showNotification', 'Failed to load outfit!')
        cb({success = false})
    end
    
    if Config.Debug then
        print(('[Koumarianos Main] ═══════════ LOAD OUTFIT "%s" END ═══════════'):format(name))
    end
end)

RegisterNUICallback('deleteOutfit', function(data, cb)
    if not data or not data.name or data.name == "" then
        cb({success = false, outfits = Storage.GetAllOutfits()})
        return
    end
    
    local name = tostring(data.name)
    local success = Storage.DeleteOutfit(name)
    
    if success then
        TriggerEvent('esx:showNotification', 'Outfit "' .. name .. '" deleted!')
        cb({success = true, outfits = Storage.GetAllOutfits()})
    else
        cb({success = false, outfits = Storage.GetAllOutfits()})
    end
end)

RegisterNUICallback('rotateCamera', function(data, cb)
    if not data or not data.direction then
        cb('ok')
        return
    end
    
    local direction = tonumber(data.direction) or 0
    RotateCamera(direction)
    cb('ok')
end)

RegisterNUICallback('setCameraMode', function(data, cb)
    if not data or not data.mode then
        cb('ok')
        return
    end
    
    SetCameraMode(tostring(data.mode))
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('escape', function(data, cb)
    if not isForced then
        CloseMenu()
    else
        TriggerEvent('esx:showNotification', 'You must complete character creation first!')
    end
    cb('ok')
end)

if Config.ClothingCommand then
    RegisterCommand(Config.ClothingCommand, function()
        if not menuOpen then
            OpenClothingMenu()
        end
    end, false)
end

if Config.CreatorCommand then
    RegisterCommand(Config.CreatorCommand, function()
        if not menuOpen then
            OpenCharacterCreator(false)
        end
    end, false)
end

exports('OpenClothingMenu', OpenClothingMenu)
exports('OpenCharacterCreator', OpenCharacterCreator)

exports('SetDefaultFromCurrent', function()
    local appearance = Appearance.Capture()
    if appearance then
        appearance = Appearance.Normalize(appearance)
        if appearance then
            return Storage.SaveDefault(appearance)
        end
    end
    return false
end)

exports('ApplyDefaultIfExists', function()
    if Storage.HasDefault() then
        local defaultApp = Storage.GetDefault()
        if defaultApp then
            defaultApp = Appearance.Normalize(defaultApp)
            if defaultApp then
                return Appearance.Apply(defaultApp)
            end
        end
    end
    return false
end)

exports('GetCurrentAppearance', function()
    local appearance = Appearance.Capture()
    if appearance then
        return Appearance.Normalize(appearance)
    end
    return nil
end)

exports('ApplyAppearance', function(appearance)
    if appearance then
        appearance = Appearance.Normalize(appearance)
        if appearance then
            return Appearance.Apply(appearance)
        end
    end
    return false
end)

exports('HasDefault', function()
    return Storage.HasDefault()
end)