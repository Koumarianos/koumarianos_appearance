--[[
    Koumarianos Appearance - Appearance Module
--]]

Appearance = {}

--[[
    Helper: Convert table with string numeric keys to numeric keys
--]]
local function ToNumberKeyedTable(t, maxIndex)
    if type(t) ~= "table" then
        return {}
    end
    
    local result = {}
    
    for k, v in pairs(t) do
        local numKey = tonumber(k)
        if numKey then
            result[numKey] = v
        else
            result[k] = v
        end
    end
    
    if maxIndex then
        for i = 0, maxIndex do
            if result[i] == nil then
                result[i] = 0
            end
        end
    end
    
    return result
end

--[[
    Normalize appearance data
--]]
function Appearance.Normalize(appearance)
    if not appearance or type(appearance) ~= "table" then
        if Config.Debug then
            print('[Koumarianos Appearance] ERROR: Normalize - appearance is nil or not table')
        end
        return nil
    end
    
    if Config.Debug then
        print('[Koumarianos Appearance] Normalize: START')
    end
    
    appearance.model = tonumber(appearance.model)
    if not appearance.model then
        if Config.Debug then
            print('[Koumarianos Appearance] ERROR: Normalize - model is nil after tonumber')
        end
        return nil
    end
    
    if appearance.faceFeatures then
        local normalized = ToNumberKeyedTable(appearance.faceFeatures, 19)
        for i = 0, 19 do
            normalized[i] = math.max(-1.0, math.min(1.0, tonumber(normalized[i]) or 0.0))
        end
        appearance.faceFeatures = normalized
    else
        appearance.faceFeatures = {}
        for i = 0, 19 do
            appearance.faceFeatures[i] = 0.0
        end
    end
    
    if appearance.overlays then
        local normalized = ToNumberKeyedTable(appearance.overlays, 11)
        for i = 0, 11 do
            if type(normalized[i]) == "table" then
                normalized[i].index = math.floor(tonumber(normalized[i].index) or 0)
                normalized[i].opacity = math.max(0.0, math.min(1.0, tonumber(normalized[i].opacity) or 0.0))
                normalized[i].color = math.floor(tonumber(normalized[i].color) or 0)
            else
                normalized[i] = {index = 0, opacity = 0.0, color = 0}
            end
        end
        appearance.overlays = normalized
    else
        appearance.overlays = {}
        for i = 0, 11 do
            appearance.overlays[i] = {index = 0, opacity = 0.0, color = 0}
        end
    end
    
    if appearance.components then
        local normalized = ToNumberKeyedTable(appearance.components, 11)
        for i = 0, 11 do
            if type(normalized[i]) == "table" then
                normalized[i].drawable = math.floor(tonumber(normalized[i].drawable) or 0)
                normalized[i].texture = math.floor(tonumber(normalized[i].texture) or 0)
            else
                normalized[i] = {drawable = 0, texture = 0}
            end
        end
        appearance.components = normalized
    else
        appearance.components = {}
        for i = 0, 11 do
            appearance.components[i] = {drawable = 0, texture = 0}
        end
    end
    
    if appearance.props then
        local normalized = ToNumberKeyedTable(appearance.props)
        for _, propId in ipairs({0, 1, 2, 6, 7}) do
            if type(normalized[propId]) == "table" then
                normalized[propId].drawable = math.floor(tonumber(normalized[propId].drawable) or -1)
                normalized[propId].texture = math.floor(tonumber(normalized[propId].texture) or 0)
            else
                normalized[propId] = {drawable = -1, texture = 0}
            end
        end
        appearance.props = normalized
    else
        appearance.props = {}
        for _, propId in ipairs({0, 1, 2, 6, 7}) do
            appearance.props[propId] = {drawable = -1, texture = 0}
        end
    end
    
    if appearance.headBlend and type(appearance.headBlend) == "table" then
        appearance.headBlend.shapeFirst = math.floor(tonumber(appearance.headBlend.shapeFirst) or 0)
        appearance.headBlend.shapeSecond = math.floor(tonumber(appearance.headBlend.shapeSecond) or 0)
        appearance.headBlend.skinFirst = math.floor(tonumber(appearance.headBlend.skinFirst) or 0)
        appearance.headBlend.skinSecond = math.floor(tonumber(appearance.headBlend.skinSecond) or 0)
        appearance.headBlend.shapeMix = math.max(0.0, math.min(1.0, tonumber(appearance.headBlend.shapeMix) or 0.5))
        appearance.headBlend.skinMix = math.max(0.0, math.min(1.0, tonumber(appearance.headBlend.skinMix) or 0.5))
    else
        appearance.headBlend = {
            shapeFirst = 0, shapeSecond = 0, skinFirst = 0, skinSecond = 0,
            shapeMix = 0.5, skinMix = 0.5
        }
    end
    
    if appearance.hairColor and type(appearance.hairColor) == "table" then
        appearance.hairColor.primary = math.max(0, math.min(63, math.floor(tonumber(appearance.hairColor.primary) or 0)))
        appearance.hairColor.highlight = math.max(0, math.min(63, math.floor(tonumber(appearance.hairColor.highlight) or 0)))
    else
        appearance.hairColor = {primary = 0, highlight = 0}
    end
    
    appearance.eyeColor = math.max(0, math.min(31, math.floor(tonumber(appearance.eyeColor) or 0)))
    
    if Config.Debug then
        print(('[Koumarianos Appearance] Normalize: ✓ SUCCESS - Model %d'):format(appearance.model))
    end
    
    return appearance
end

--[[
    Validate appearance (calls Normalize + checks permissions)
    Returns normalized appearance if valid, nil otherwise.
--]]
function Appearance.Validate(appearance)
    appearance = Appearance.Normalize(appearance)
    
    if not appearance then
        return nil
    end
    
    if not Config.AllowedModels[appearance.model] then
        if Config.AllowAnyModelSave then
            if Config.Debug then
                print(('[Koumarianos Appearance] WARNING: Model %d not in AllowedModels but AllowAnyModelSave=true'):format(appearance.model))
            end
        else
            if Config.Debug then
                print(('[Koumarianos Appearance] ERROR: Validate - Model %d not allowed and AllowAnyModelSave=false'):format(appearance.model))
            end
            return nil
        end
    end
    
    return appearance
end

--[[
    Get default appearance template for model
--]]
function Appearance.GetDefaultForModel(model)
    local isMale = model == `mp_m_freemode_01`
    
    local appearance = {
        model = model,
        gender = isMale and 'male' or 'female',
        headBlend = {
            shapeFirst = 0, shapeSecond = 0, skinFirst = 0, skinSecond = 0,
            shapeMix = 0.5, skinMix = 0.5
        },
        faceFeatures = {},
        hairColor = {primary = 0, highlight = 0},
        eyeColor = 0,
        overlays = {},
        components = {},
        props = {}
    }
    
    for i = 0, 19 do
        appearance.faceFeatures[i] = 0.0
    end
    
    for i = 0, 11 do
        appearance.overlays[i] = {index = 0, opacity = 0.0, color = 0}
    end
    
    for i = 0, 11 do
        appearance.components[i] = {drawable = 0, texture = 0}
    end
    
    for _, prop in ipairs({0, 1, 2, 6, 7}) do
        appearance.props[prop] = {drawable = -1, texture = 0}
    end
    
    return appearance
end

--[[
    Capture current ped appearance
--]]
function Appearance.Capture()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then
        if Config.Debug then
            print('[Koumarianos Appearance] ERROR: Capture - Ped does not exist')
        end
        return nil
    end
    
    local model = GetEntityModel(ped)
    
    if not Config.AllowedModels[model] and not Config.AllowAnyModelSave then
        if Config.Debug then
            print(('[Koumarianos Appearance] ERROR: Capture - Model %d not allowed'):format(model))
        end
        TriggerEvent('esx:showNotification', 'This ped model is not allowed to be saved!')
        return nil
    end
    
    if Config.Debug then
        print(('[Koumarianos Appearance] Capture: START for model %d'):format(model))
    end
    
    local appearance = Appearance.GetDefaultForModel(model)
    
    appearance.model = model
    
    local shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix = GetPedHeadBlendData(ped)
    if shapeFirst then
        appearance.headBlend = {
            shapeFirst = tonumber(shapeFirst) or 0,
            shapeSecond = tonumber(shapeSecond) or 0,
            skinFirst = tonumber(skinFirst) or 0,
            skinSecond = tonumber(skinSecond) or 0,
            shapeMix = tonumber(shapeMix) or 0.5,
            skinMix = tonumber(skinMix) or 0.5
        }
    end
    
    for i = 0, 19 do
        local feature = GetPedFaceFeature(ped, i)
        appearance.faceFeatures[i] = tonumber(feature) or 0.0
    end
    
    appearance.hairColor = {
        primary = GetPedHairColor(ped),
        highlight = GetPedHairHighlightColor(ped)
    }
    
    appearance.eyeColor = GetPedEyeColor(ped)
    
    for i = 0, 11 do
        local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, i)
        if success then
            appearance.overlays[i] = {
                index = tonumber(overlayValue) or 0,
                opacity = tonumber(overlayOpacity) or 0.0,
                color = tonumber(firstColour) or 0
            }
        else
            appearance.overlays[i] = {
                index = 0,
                opacity = 0.0,
                color = 0
            }
        end
    end
    
    for i = 0, 11 do
        appearance.components[i] = {
            drawable = GetPedDrawableVariation(ped, i),
            texture = GetPedTextureVariation(ped, i)
        }
    end
    
    for _, propId in ipairs({0, 1, 2, 6, 7}) do
        local propIndex = GetPedPropIndex(ped, propId)
        if propIndex ~= -1 then
            appearance.props[propId] = {
                drawable = propIndex,
                texture = GetPedPropTextureIndex(ped, propId)
            }
        else
            appearance.props[propId] = {drawable = -1, texture = 0}
        end
    end
    
    if Config.Debug then
        print('[Koumarianos Appearance] Capture: ✓ COMPLETE')
    end
    
    return appearance
end

--[[
    Apply appearance to ped
--]]
function Appearance.Apply(appearance, ped)
    if not appearance then
        if Config.Debug then
            print('[Koumarianos Appearance] ERROR: Apply - appearance is nil')
        end
        return false
    end
    
    ped = ped or PlayerPedId()
    
    if not ped or not DoesEntityExist(ped) then
        if Config.Debug then
            print('[Koumarianos Appearance] ERROR: Apply - ped does not exist')
        end
        return false
    end
    
    appearance = Appearance.Validate(appearance)
    if not appearance then
        if Config.Debug then
            print('[Koumarianos Appearance] ERROR: Apply - validation failed')
        end
        TriggerEvent('esx:showNotification', 'Cannot apply this appearance (invalid data)')
        return false
    end
    
    local currentModel = GetEntityModel(ped)
    local targetModel = appearance.model
    
    if Config.Debug then
        print(('[Koumarianos Appearance] Apply: Current model %d -> Target model %d'):format(currentModel, targetModel))
    end
    
    if currentModel ~= targetModel then
        if not Config.AllowedModels[targetModel] and not Config.AllowAnyModelSave then
            if Config.Debug then
                print(('[Koumarianos Appearance] ERROR: Apply - Model %d not allowed'):format(targetModel))
            end
            TriggerEvent('esx:showNotification', 'This ped model is not allowed!')
            return false
        end
        
        if Config.Debug then
            print(('[Koumarianos Appearance] Apply: Changing model to %d'):format(targetModel))
        end
        
        RequestModel(targetModel)
        local timeout = 0
        while not HasModelLoaded(targetModel) and timeout < 100 do
            Wait(50)
            timeout = timeout + 1
        end
        
        if not HasModelLoaded(targetModel) then
            print(('[Koumarianos Appearance] ERROR: Failed to load model %d'):format(targetModel))
            TriggerEvent('esx:showNotification', 'Failed to load ped model')
            return false
        end
        
        SetPlayerModel(PlayerId(), targetModel)
        SetModelAsNoLongerNeeded(targetModel)
        Wait(100)
        ped = PlayerPedId()
        SetPedDefaultComponentVariation(ped)
    end
    
    if appearance.headBlend then
        SetPedHeadBlendData(
            ped,
            appearance.headBlend.shapeFirst or 0,
            appearance.headBlend.shapeSecond or 0,
            0,
            appearance.headBlend.skinFirst or 0,
            appearance.headBlend.skinSecond or 0,
            0,
            appearance.headBlend.shapeMix or 0.5,
            appearance.headBlend.skinMix or 0.5,
            0.0,
            false
        )
    end
    
    Wait(50)
    
    if appearance.faceFeatures then
        for i = 0, 19 do
            SetPedFaceFeature(ped, i, appearance.faceFeatures[i] or 0.0)
        end
    end
    
    if appearance.hairColor then
        SetPedHairColor(ped, appearance.hairColor.primary or 0, appearance.hairColor.highlight or 0)
    end
    
    SetPedEyeColor(ped, appearance.eyeColor or 0)
    
    if appearance.overlays then
        local isMale = targetModel == `mp_m_freemode_01`
        
        for i = 0, 11 do
            local data = appearance.overlays[i]
            if data then
                local overlayConfig = nil
                for _, ov in ipairs(Config.Overlays) do
                    if ov.id == i then
                        overlayConfig = ov
                        break
                    end
                end
                
                if overlayConfig and overlayConfig.maleOnly and not isMale then
                    SetPedHeadOverlay(ped, i, 0, 0.0)
                else
                    SetPedHeadOverlay(ped, i, data.index or 0, data.opacity or 0.0)
                    
                    if overlayConfig and overlayConfig.colorType > 0 and data.index and data.index > 0 then
                        SetPedHeadOverlayColor(ped, i, overlayConfig.colorType, data.color or 0, data.color or 0)
                    end
                end
            end
        end
    end
    
    if appearance.components then
        for i = 0, 11 do
            local data = appearance.components[i]
            if data then
                local drawable = data.drawable or 0
                local texture = data.texture or 0
                
                local maxDrawable = GetNumberOfPedDrawableVariations(ped, i) - 1
                drawable = math.max(0, math.min(maxDrawable, drawable))
                
                local maxTexture = GetNumberOfPedTextureVariations(ped, i, drawable) - 1
                texture = math.max(0, math.min(maxTexture, texture))
                
                SetPedComponentVariation(ped, i, drawable, texture, 0)
            end
        end
    end
    
    if appearance.props then
        for _, propId in ipairs({0, 1, 2, 6, 7}) do
            local data = appearance.props[propId]
            if data then
                if data.drawable == -1 then
                    ClearPedProp(ped, propId)
                else
                    local drawable = data.drawable or 0
                    local texture = data.texture or 0
                    
                    local maxDrawable = GetNumberOfPedPropDrawableVariations(ped, propId) - 1
                    
                    if maxDrawable >= 0 then
                        drawable = math.max(0, math.min(maxDrawable, drawable))
                        
                        local maxTexture = GetNumberOfPedPropTextureVariations(ped, propId, drawable) - 1
                        texture = math.max(0, math.min(maxTexture, texture))
                        
                        SetPedPropIndex(ped, propId, drawable, texture, true)
                    end
                end
            end
        end
    end
    
    if Config.Debug then
        print('[Koumarianos Appearance] Apply: ✓ COMPLETE')
    end
    
    return true
end

function Appearance.Reset()
    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    local defaultApp = Appearance.GetDefaultForModel(model)
    Appearance.Apply(defaultApp)
end