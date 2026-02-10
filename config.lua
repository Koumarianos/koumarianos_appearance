Config = {}

Config.OpenMenuKey = 'M'
Config.ClothingCommand = nil
Config.CreatorCommand = nil
Config.RequireDefaultOnFirstJoin = false
Config.AllowAnyModelSave = false
Config.Debug = true

Config.AllowedModels = {
    [`mp_m_freemode_01`] = true,
    [`mp_f_freemode_01`] = true
}

Config.ModelCheckInterval = 2000

Config.Camera = {
    fov = 50.0,
    positions = {
        face = { offset = vec3(0.0, 0.6, 0.65), pointOffset = vec3(0.0, 0.0, 0.65) },
        body = { offset = vec3(0.0, 1.5, 0.2), pointOffset = vec3(0.0, 0.0, 0.2) },
        legs = { offset = vec3(0.0, 1.5, -0.5), pointOffset = vec3(0.0, 0.0, -0.5) },
        feet = { offset = vec3(0.0, 1.2, -0.9), pointOffset = vec3(0.0, 0.0, -0.9) }
    }
}

Config.Parents = {
    mothers = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45},
    fathers = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45}
}

Config.FaceFeatures = {
    {id = 0, name = 'Nose Width', category = 'Nose'},
    {id = 1, name = 'Nose Peak Height', category = 'Nose'},
    {id = 2, name = 'Nose Peak Length', category = 'Nose'},
    {id = 3, name = 'Nose Bone Height', category = 'Nose'},
    {id = 4, name = 'Nose Peak Lowering', category = 'Nose'},
    {id = 5, name = 'Nose Bone Twist', category = 'Nose'},
    {id = 6, name = 'Eyebrow Height', category = 'Brows'},
    {id = 7, name = 'Eyebrow Depth', category = 'Brows'},
    {id = 8, name = 'Cheekbone Height', category = 'Cheeks'},
    {id = 9, name = 'Cheekbone Width', category = 'Cheeks'},
    {id = 10, name = 'Cheek Width', category = 'Cheeks'},
    {id = 11, name = 'Eye Opening', category = 'Eyes'},
    {id = 12, name = 'Lip Thickness', category = 'Lips'},
    {id = 13, name = 'Jaw Bone Width', category = 'Jaw'},
    {id = 14, name = 'Jaw Bone Length', category = 'Jaw'},
    {id = 15, name = 'Chin Height', category = 'Chin'},
    {id = 16, name = 'Chin Length', category = 'Chin'},
    {id = 17, name = 'Chin Width', category = 'Chin'},
    {id = 18, name = 'Chin Hole Size', category = 'Chin'},
    {id = 19, name = 'Neck Thickness', category = 'Neck'}
}

Config.Overlays = {
    {id = 0, name = 'Blemishes', colorType = 0, maxIndex = 23},
    {id = 1, name = 'Facial Hair', colorType = 1, maxIndex = 28, maleOnly = true},
    {id = 2, name = 'Eyebrows', colorType = 1, maxIndex = 33},
    {id = 3, name = 'Ageing', colorType = 0, maxIndex = 14},
    {id = 4, name = 'Makeup', colorType = 2, maxIndex = 74},
    {id = 5, name = 'Blush', colorType = 2, maxIndex = 6},
    {id = 6, name = 'Complexion', colorType = 0, maxIndex = 11},
    {id = 7, name = 'Sun Damage', colorType = 0, maxIndex = 10},
    {id = 8, name = 'Lipstick', colorType = 2, maxIndex = 9},
    {id = 9, name = 'Moles/Freckles', colorType = 0, maxIndex = 17},
    {id = 10, name = 'Chest Hair', colorType = 1, maxIndex = 16, maleOnly = true},
    {id = 11, name = 'Body Blemishes', colorType = 0, maxIndex = 11}
}

Config.HairColors = {
    primary = {min = 0, max = 63},
    highlight = {min = 0, max = 63}
}

Config.EyeColors = {min = 0, max = 31}

Config.Components = {
    {id = 0, name = 'Face'},
    {id = 1, name = 'Mask'},
    {id = 2, name = 'Hair'},
    {id = 3, name = 'Torso'},
    {id = 4, name = 'Legs'},
    {id = 5, name = 'Bag'},
    {id = 6, name = 'Shoes'},
    {id = 7, name = 'Accessory'},
    {id = 8, name = 'Undershirt'},
    {id = 9, name = 'Body Armor'},
    {id = 10, name = 'Decals'},
    {id = 11, name = 'Tops'}
}

Config.Props = {
    {id = 0, name = 'Hats'},
    {id = 1, name = 'Glasses'},
    {id = 2, name = 'Ears'},
    {id = 6, name = 'Watches'},
    {id = 7, name = 'Bracelets'}
}