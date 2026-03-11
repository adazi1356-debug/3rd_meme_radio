
local RES_NAME = GetCurrentResourceName()

local settings = {
    defaultPlaySound = Config.DefaultPlaySound,
    deathSound = Config.DefaultDeathSound,
    rangeLevel = Config.DefaultRangeLevel,
    volumeLevel = Config.DefaultVolumeLevel,
    favorites = {},
    favoriteSlots = {},
    favoriteVolumes = {}
}

local uiOpen = false
local handsUp = false
local lastPlayAt = 0
local wasDead = false
local currentPlaySound = Config.DefaultPlaySound
local selectedSlot = 0
local activeSounds = {}
local pendingRequests = {}
local soundCatalog = {}
local deletedCatalog = {}
local deletedMap = {}
local isAdmin = false
local previewSoundId = 'preview_local'
local showRangePreview = false

local function debugLog(...)
    if Config.Debug then
        print(('^6[%s/client]^7'):format(RES_NAME), ...)
    end
end

local function showNotification(msg)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

local function showHelp(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, false, 1)
end

local function drawHintBox(msg)
    -- font 0 to avoid mojibake in this hint text
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.38)
    SetTextColour(244, 246, 251, 235)
    SetTextDropShadow()
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    SetTextWrap(0.0, 0.35)
    SetTextJustification(1)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayText(0.024, 0.47)
end

local function sendUi(action, payload)
    payload = payload or {}
    payload.action = action
    SendNUIMessage(payload)
end

local function cloneMap(input)
    local out = {}
    if type(input) ~= 'table' then return out end
    for k, v in pairs(input) do
        out[k] = v and true or false
    end
    return out
end

local function cloneSlots(input)
    local out = {}
    if type(input) ~= 'table' then return out end
    for i = 1, 9 do
        local key = tostring(i)
        local value = input[key] or input[i]
        if type(value) == 'string' and Config.IsValidSound(value) and not deletedMap[value] then
            out[key] = value
        end
    end
    return out
end

local function cloneFavoriteVolumes(input)
    local out = {}
    if type(input) ~= 'table' then return out end
    for file, value in pairs(input) do
        file = Config.NormalizeSoundName(file)
        if Config.IsValidSound(file) and not deletedMap[file] then
            out[file] = Config.GetVolumeLevel(value)
        end
    end
    return out
end

local function sanitizeSettings()
    settings.defaultPlaySound = Config.NormalizeSoundName(settings.defaultPlaySound)
    if not Config.IsValidSound(settings.defaultPlaySound) or deletedMap[settings.defaultPlaySound] then
        settings.defaultPlaySound = Config.DefaultPlaySound
    end

    settings.deathSound = Config.NormalizeSoundName(settings.deathSound)
    if settings.deathSound ~= '' and (not Config.IsValidSound(settings.deathSound) or deletedMap[settings.deathSound]) then
        settings.deathSound = ''
    end

    settings.rangeLevel = Config.GetRangeLevel(settings.rangeLevel)
    settings.volumeLevel = Config.GetVolumeLevel(settings.volumeLevel)
    settings.favorites = cloneMap(settings.favorites)
    settings.favoriteSlots = cloneSlots(settings.favoriteSlots)
    settings.favoriteVolumes = cloneFavoriteVolumes(settings.favoriteVolumes)

    if type(settings.favoriteSlotVolumes) == 'table' then
        for i = 0, 9 do
            local key = tostring(i)
            local file = settings.favoriteSlots[key]
            if file and settings.favorites[file] and not settings.favoriteVolumes[file] then
                settings.favoriteVolumes[file] = Config.GetVolumeLevel(settings.favoriteSlotVolumes[key] or settings.favoriteSlotVolumes[i] or settings.volumeLevel)
            end
        end
    end

    for file in pairs(settings.favorites) do
        if deletedMap[file] or not Config.IsValidSound(file) then
            settings.favorites[file] = nil
        end
    end

    for i = 0, 9 do
        local key = tostring(i)
        local file = settings.favoriteSlots[key]
        if file and (deletedMap[file] or not Config.IsValidSound(file)) then
            settings.favoriteSlots[key] = nil
        end
    end

    for file in pairs(settings.favoriteVolumes) do
        if not settings.favorites[file] or deletedMap[file] or not Config.IsValidSound(file) then
            settings.favoriteVolumes[file] = nil
        end
    end

    for file in pairs(settings.favorites) do
        if not settings.favoriteVolumes[file] then
            settings.favoriteVolumes[file] = settings.volumeLevel
        end
    end

    settings.favoriteSlots['0'] = nil

    if selectedSlot ~= 0 and settings.favoriteSlots[tostring(selectedSlot)] == nil then
        selectedSlot = 0
    end

    if selectedSlot == 0 then
        currentPlaySound = settings.defaultPlaySound
    else
        currentPlaySound = settings.favoriteSlots[tostring(selectedSlot)] or settings.defaultPlaySound
    end

    currentPlaySound = Config.NormalizeSoundName(currentPlaySound)
    if deletedMap[currentPlaySound] or not Config.IsValidSound(currentPlaySound) then
        currentPlaySound = settings.defaultPlaySound
        if selectedSlot ~= 0 then
            local selectedFile = settings.favoriteSlots[tostring(selectedSlot)]
            if selectedFile and Config.IsValidSound(selectedFile) and not deletedMap[selectedFile] then
                currentPlaySound = selectedFile
            else
                selectedSlot = 0
            end
        end
    end
end

local function getVoiceRange()
    local pmaDistance = LocalPlayer and LocalPlayer.state and LocalPlayer.state.proximity and LocalPlayer.state.proximity.distance
    if pmaDistance and pmaDistance > 0 then
        return pmaDistance
    end

    local mumbleDistance = MumbleGetTalkerProximity()
    if mumbleDistance and mumbleDistance > 0 then
        return mumbleDistance
    end

    return Config.FallbackVoiceRange
end

local function getMaxDistance(rangeLevel)
    local rangeCfg = Config.GetRangeConfig(rangeLevel or settings.rangeLevel)
    if rangeCfg.mode == 'absolute' then
        return math.max(rangeCfg.value, Config.MinDistance + 0.01)
    end
    return math.max((getVoiceRange() * rangeCfg.value), Config.MinDistance + 0.01)
end

local function localPlayerCoords()
    return GetEntityCoords(PlayerPedId())
end

local function getSelectedVolumeLevel()
    if currentPlaySound and settings.favoriteVolumes[currentPlaySound] then
        return settings.favoriteVolumes[currentPlaySound]
    end
    return settings.volumeLevel
end

local function getSettingsSnapshot()
    sanitizeSettings()
    return {
        defaultPlaySound = settings.defaultPlaySound,
        deathSound = settings.deathSound,
        rangeLevel = settings.rangeLevel,
        volumeLevel = settings.volumeLevel,
        favorites = cloneMap(settings.favorites),
        favoriteSlots = cloneSlots(settings.favoriteSlots),
        favoriteVolumes = cloneFavoriteVolumes(settings.favoriteVolumes)
    }
end

local function buildVisibleCatalog()
    return Config.GetSoundCatalog(deletedMap)
end

local function buildDeletedCatalog()
    return Config.GetDeletedCatalog(deletedMap)
end

local function buildHotbarPayload()
    local slots = {}
    for i = 1, 9 do
        local key = tostring(i)
        local file = settings.favoriteSlots[key]
        slots[#slots + 1] = {
            slot = i,
            file = file or '',
            label = file and Config.GetSoundLabel(file) or '未設定',
            isSelected = selectedSlot == i
        }
    end

    return {
        visible = handsUp and (not uiOpen),
        slots = slots,
        currentLabel = Config.GetSoundLabel(currentPlaySound),
        defaultLabel = Config.GetSoundLabel(settings.defaultPlaySound),
        selectedSlot = selectedSlot,
        version = Config.Version
    }
end

local function updateHud()
    sendUi('setHotbar', buildHotbarPayload())
end

local function setUiState(open)
    uiOpen = open
    SetNuiFocus(open, open)
    SetNuiFocusKeepInput(false)
    if not open then
        showRangePreview = false
    end

    sendUi(open and 'open' or 'close', {
        settings = getSettingsSnapshot(),
        soundCatalog = buildVisibleCatalog(),
        deletedCatalog = buildDeletedCatalog(),
        hotbar = buildHotbarPayload(),
        isAdmin = isAdmin,
        rangeLevels = Config.RangeLevels,
        volumeLevels = Config.VolumeLevels,
        version = Config.Version
    })
    updateHud()
end

local function hydrateUi()
    sendUi('hydrate', {
        settings = getSettingsSnapshot(),
        soundCatalog = buildVisibleCatalog(),
        deletedCatalog = buildDeletedCatalog(),
        hotbar = buildHotbarPayload(),
        isAdmin = isAdmin,
        rangeLevels = Config.RangeLevels,
        volumeLevels = Config.VolumeLevels,
        version = Config.Version
    })
end

local function resolvePromise(token, data)
    local p = pendingRequests[token]
    if not p then return end
    pendingRequests[token] = nil
    p:resolve(data)
end

RegisterNetEvent('3rd_meme_radio:client:reply', function(token, data)
    resolvePromise(token, data)
end)

local function callServer(eventName, payload)
    local p = promise.new()
    local token = ('%s_%s_%s'):format(GetGameTimer(), math.random(1000, 9999), eventName)
    pendingRequests[token] = p
    TriggerServerEvent(eventName, token, payload or {})
    return Citizen.Await(p)
end

local function stopSound(id)
    activeSounds[id] = nil
    sendUi('stopSound', { id = id })
end

local function stopEmitterSounds(sourceServerId)
    for id, data in pairs(activeSounds) do
        if data.sourceServerId == sourceServerId then
            stopSound(id)
        end
    end
end

local function computeVolume(dist, maxDistance, baseVolume)
    if dist >= maxDistance then
        return 0.0
    end

    if dist <= Config.MinDistance then
        return baseVolume
    end

    local t = 1.0 - ((dist - Config.MinDistance) / (maxDistance - Config.MinDistance))
    if t < 0.0 then t = 0.0 end
    if t > 1.0 then t = 1.0 end
    return baseVolume * (t * t)
end

local function resolveEmitterCoords(sound)
    local ply = GetPlayerFromServerId(sound.sourceServerId or -1)
    if ply ~= -1 then
        local ped = GetPlayerPed(ply)
        if ped > 0 then
            local coords = GetEntityCoords(ped)
            sound.lastCoords = { x = coords.x, y = coords.y, z = coords.z }
            return coords
        end
    end

    if sound.lastCoords then
        return vec3(sound.lastCoords.x, sound.lastCoords.y, sound.lastCoords.z)
    end

    return vec3(sound.coords.x, sound.coords.y, sound.coords.z)
end

local function startPreview(file, volumeLevel)
    if not Config.IsValidSound(file) then return end
    local previewVolume = Config.PreviewVolume
    if volumeLevel ~= nil then
        previewVolume = Config.GetBaseVolume(volumeLevel)
    elseif settings.favorites[file] and settings.favoriteVolumes[file] then
        previewVolume = Config.GetBaseVolume(settings.favoriteVolumes[file])
    end
    sendUi('playPreview', { id = previewSoundId, file = file, volume = previewVolume })
end

local function stopPreview()
    sendUi('stopSound', { id = previewSoundId })
end

local function canPlayNow()
    return GetGameTimer() - lastPlayAt >= Config.PlayCooldownMs
end

local function loadAnim()
    if HasAnimDictLoaded(Config.HandsUpAnimDict) then return true end
    RequestAnimDict(Config.HandsUpAnimDict)
    local timeout = GetGameTimer() + 4000
    while not HasAnimDictLoaded(Config.HandsUpAnimDict) and GetGameTimer() < timeout do
        Wait(0)
    end
    return HasAnimDictLoaded(Config.HandsUpAnimDict)
end

local function setHandsUpState(state)
    local ped = PlayerPedId()
    if state then
        if loadAnim() then
            TaskPlayAnim(ped, Config.HandsUpAnimDict, Config.HandsUpAnimName, 2.0, 2.0, -1, Config.HandsUpAnimFlags, 0.0, false, false, false)
        end
        handsUp = true
    else
        StopAnimTask(ped, Config.HandsUpAnimDict, Config.HandsUpAnimName, 1.0)
        ClearPedSecondaryTask(ped)
        handsUp = false
        if uiOpen then
            setUiState(false)
        else
            updateHud()
        end
    end
    updateHud()
end

local function saveNow(showSaved)
    TriggerServerEvent('3rd_meme_radio:server:saveSettings', getSettingsSnapshot())
    if showSaved then
        showNotification('保存しました')
    end
end

local function applySelection(slot, file)
    if slot ~= nil then
        selectedSlot = tonumber(slot) or 0
        if selectedSlot == 0 then
            currentPlaySound = settings.defaultPlaySound
        else
            currentPlaySound = file or settings.favoriteSlots[tostring(selectedSlot)] or settings.defaultPlaySound
        end
    else
        selectedSlot = 0
        currentPlaySound = settings.defaultPlaySound
    end
    updateHud()
end

local function requestAccess()
    local res = callServer('3rd_meme_radio:server:requestAccess', {})
    if type(res) ~= 'table' then
        return false, '使用できません'
    end
    return res.allowed, res.reason
end

local function playCurrentSound()
    if not canPlayNow() then return end
    if not Config.IsValidSound(currentPlaySound) or deletedMap[currentPlaySound] then return end

    lastPlayAt = GetGameTimer()
    local payload = {
        file = currentPlaySound,
        coords = localPlayerCoords(),
        maxDistance = getMaxDistance(settings.rangeLevel),
        volume = Config.GetBaseVolume(getSelectedVolumeLevel())
    }
    TriggerServerEvent('3rd_meme_radio:server:playSound', payload)
end

local function toggleHandsUp()
    if handsUp then
        setHandsUpState(false)
        return
    end

    local allowed, reason = requestAccess()
    if not allowed then
        showNotification(reason or '使用条件を満たしていません')
        return
    end

    setHandsUpState(true)
    playCurrentSound()
end

RegisterNetEvent('3rd_meme_radio:client:init', function(payload)
    deletedMap = payload.deletedMap or {}
    isAdmin = payload.isAdmin or false
    settings = payload.settings or settings
    settings.favoriteVolumes = settings.favoriteVolumes or {}
    sanitizeSettings()
    soundCatalog = buildVisibleCatalog()
    deletedCatalog = buildDeletedCatalog()
    currentPlaySound = settings.defaultPlaySound
    selectedSlot = 0
    updateHud()
    if uiOpen then
        hydrateUi()
    end
end)

RegisterNetEvent('3rd_meme_radio:client:playSound', function(data)
    if type(data) ~= 'table' then return end
    if not data.file or deletedMap[data.file] then return end

    stopEmitterSounds(data.sourceServerId)
    local id = data.id or ('snd_' .. GetGameTimer())
    activeSounds[id] = {
        sourceServerId = data.sourceServerId,
        file = data.file,
        maxDistance = tonumber(data.maxDistance) or getMaxDistance(settings.rangeLevel),
        baseVolume = tonumber(data.volume) or Config.GetBaseVolume(Config.DefaultVolumeLevel),
        coords = data.coords or { x = 0.0, y = 0.0, z = 0.0 }
    }

    local coords = resolveEmitterCoords(activeSounds[id])
    local volume = computeVolume(#(localPlayerCoords() - coords), activeSounds[id].maxDistance, activeSounds[id].baseVolume)
    sendUi('play3d', { id = id, file = data.file, volume = volume })
end)

RegisterNetEvent('3rd_meme_radio:client:syncDeleted', function(newDeletedMap)
    deletedMap = newDeletedMap or {}
    sanitizeSettings()
    saveNow(false)
    hydrateUi()
    updateHud()
end)

RegisterNetEvent('3rd_meme_radio:client:notify', function(msg)
    showNotification(msg)
end)

RegisterNetEvent('3rd_meme_radio:client:purchaseResult', function(ok, msg)
    showNotification(msg or (ok and '購入しました' or '購入できませんでした'))
end)

RegisterNUICallback('closeUi', function(_, cb)
    stopPreview()
    setUiState(false)
    cb('ok')
end)

RegisterNUICallback('saveSettings', function(data, cb)
    if type(data) == 'table' then
        settings = data
        sanitizeSettings()
        if selectedSlot == 0 then
            currentPlaySound = settings.defaultPlaySound
        end
        saveNow(true)
        hydrateUi()
        updateHud()
    end
    cb('ok')
end)

RegisterNUICallback('previewSound', function(data, cb)
    if data and data.file then
        startPreview(Config.NormalizeSoundName(data.file), data.level)
    end
    cb('ok')
end)

RegisterNUICallback('stopPreview', function(_, cb)
    stopPreview()
    cb('ok')
end)

RegisterNUICallback('selectDefaultSound', function(data, cb)
    local file = Config.NormalizeSoundName(data.file)
    if Config.IsValidSound(file) and not deletedMap[file] then
        -- MP3一覧の「選択」はスロット1だけを更新する。
        -- スロット0(デフォルト音)はここでは変更しない。
        settings.favorites[file] = true
        if not settings.favoriteVolumes[file] then
            settings.favoriteVolumes[file] = settings.volumeLevel
        end
        settings.favoriteSlots['1'] = file
        applySelection(1, file)
        saveNow(false)
        hydrateUi()
        updateHud()
    end
    cb('ok')
end)

RegisterNUICallback('selectDeathSound', function(data, cb)
    local file = data and data.file and Config.NormalizeSoundName(data.file) or ''
    if file == '' or (Config.IsValidSound(file) and not deletedMap[file]) then
        settings.deathSound = file
        saveNow(false)
        hydrateUi()
    end
    cb('ok')
end)

RegisterNUICallback('toggleFavorite', function(data, cb)
    local file = Config.NormalizeSoundName(data.file)
    if Config.IsValidSound(file) and not deletedMap[file] then
        settings.favorites[file] = not settings.favorites[file] or nil
        if settings.favorites[file] and not settings.favoriteVolumes[file] then
            settings.favoriteVolumes[file] = settings.volumeLevel
        end
        for i = 0, 9 do
            local key = tostring(i)
            if settings.favoriteSlots[key] == file and not settings.favorites[file] then
                settings.favoriteSlots[key] = nil
            end
        end
        if not settings.favorites[file] then
            settings.favoriteVolumes[file] = nil
        end
        saveNow(false)
        hydrateUi()
        updateHud()
    end
    cb('ok')
end)

RegisterNUICallback('assignSlot', function(data, cb)
    local slot = tonumber(data.slot) or 1
    local file = Config.NormalizeSoundName(data.file)
    if slot >= 1 and slot <= 9 and settings.favorites[file] and Config.IsValidSound(file) and not deletedMap[file] then
        settings.favoriteSlots[tostring(slot)] = file
        if not settings.favoriteVolumes[file] then
            settings.favoriteVolumes[file] = settings.volumeLevel
        end
        saveNow(false)
        hydrateUi()
        updateHud()
    end
    cb('ok')
end)

RegisterNUICallback('clearSlot', function(data, cb)
    local slot = tonumber(data.slot) or 1
    if slot >= 1 and slot <= 9 then
        settings.favoriteSlots[tostring(slot)] = nil
        if selectedSlot == slot then
            selectedSlot = 0
            currentPlaySound = settings.defaultPlaySound
        end
        saveNow(false)
        hydrateUi()
        updateHud()
    end
    cb('ok')
end)

RegisterNUICallback('setFavoriteVolume', function(data, cb)
    local file = data and data.file and Config.NormalizeSoundName(data.file) or ''
    local level = Config.GetVolumeLevel(data and data.level)
    if file ~= '' and settings.favorites[file] and Config.IsValidSound(file) and not deletedMap[file] then
        settings.favoriteVolumes[file] = level
        saveNow(false)
        hydrateUi()
        updateHud()
    end
    cb('ok')
end)

RegisterNUICallback('setRangeLevel', function(data, cb)
    settings.rangeLevel = Config.GetRangeLevel(data.level)
    hydrateUi()
    cb('ok')
end)

RegisterNUICallback('setVolumeLevel', function(data, cb)
    settings.volumeLevel = Config.GetVolumeLevel(data.level)
    if selectedSlot == 0 then
        currentPlaySound = settings.defaultPlaySound
    end
    hydrateUi()
    updateHud()
    cb('ok')
end)

RegisterNUICallback('setRangePreview', function(data, cb)
    showRangePreview = data and data.enabled or false
    cb('ok')
end)

RegisterNUICallback('deleteSound', function(data, cb)
    if data and data.file then
        TriggerServerEvent('3rd_meme_radio:server:deleteSound', Config.NormalizeSoundName(data.file))
    end
    cb('ok')
end)

RegisterNUICallback('restoreSound', function(data, cb)
    if data and data.file then
        TriggerServerEvent('3rd_meme_radio:server:restoreSound', Config.NormalizeSoundName(data.file))
    end
    cb('ok')
end)

RegisterNUICallback('requestInit', function(_, cb)
    TriggerServerEvent('3rd_meme_radio:server:init')
    cb('ok')
end)

CreateThread(function()
    Wait(1200)
    TriggerServerEvent('3rd_meme_radio:server:init')
end)

RegisterCommand('+meme_radio_toggle', function()
    toggleHandsUp()
end, false)
RegisterCommand('-meme_radio_toggle', function() end, false)
RegisterKeyMapping('+meme_radio_toggle', '3rd Meme Radio: 手を上げて再生 / 下げる', 'keyboard', 'X')

RegisterCommand('+meme_radio_ui', function()
    if not handsUp then return end
    stopPreview()
    setUiState(not uiOpen)
end, false)
RegisterCommand('-meme_radio_ui', function() end, false)
RegisterKeyMapping('+meme_radio_ui', '3rd Meme Radio: 設定UI', 'keyboard', 'R')

CreateThread(function()
    while true do
        Wait(Config.VolumeTickMs)
        local ped = PlayerPedId()

        if handsUp then
            if not IsEntityPlayingAnim(ped, Config.HandsUpAnimDict, Config.HandsUpAnimName, 3) and not IsPedRagdoll(ped) and not IsPedInAnyVehicle(ped, false) then
                TaskPlayAnim(ped, Config.HandsUpAnimDict, Config.HandsUpAnimName, 2.0, 2.0, -1, Config.HandsUpAnimFlags, 0.0, false, false, false)
            end
        end

        local myCoords = localPlayerCoords()
        for id, sound in pairs(activeSounds) do
            local emitterCoords = resolveEmitterCoords(sound)
            local dist = #(myCoords - emitterCoords)
            local vol = computeVolume(dist, sound.maxDistance, sound.baseVolume)
            sendUi('setVolume', { id = id, volume = vol })
            if vol <= 0.001 and dist >= sound.maxDistance + 1.0 then
                stopSound(id)
            end
        end
    end
end)

CreateThread(function()
    while true do
        if handsUp and not uiOpen then
            drawHintBox('Rで設定 / 0でデフォルト / 1-9でお気に入り')
            Wait(0)
        else
            Wait(150)
        end
    end
end)

local function selectHotbarSlot(slot)
    if not handsUp or uiOpen then
        return
    end

    slot = tonumber(slot) or 0
    if slot == 0 then
        local file = settings.defaultPlaySound
        if Config.IsValidSound(file) and not deletedMap[file] then
            applySelection(0, file)
            showNotification(('デフォルト音: %s'):format(Config.GetSoundLabel(file)))
        end
        return
    end

    if slot >= 1 and slot <= 9 then
        local file = settings.favoriteSlots[tostring(slot)]
        if file and Config.IsValidSound(file) and not deletedMap[file] then
            applySelection(slot, file)
            showNotification(('お気に入り %s: %s'):format(slot, Config.GetSoundLabel(file)))
        end
    end
end

for slot = 0, 9 do
    RegisterCommand(('+meme_radio_slot_%s'):format(slot), function()
        selectHotbarSlot(slot)
    end, false)
    RegisterCommand(('-meme_radio_slot_%s'):format(slot), function() end, false)
    RegisterKeyMapping(
        ('+meme_radio_slot_%s'):format(slot),
        ('3rd Meme Radio: スロット%s'):format(slot),
        'keyboard',
        tostring(slot)
    )
end

CreateThread(function()
    while true do
        if showRangePreview and uiOpen then
            local radius = getMaxDistance(settings.rangeLevel)
            local coords = localPlayerCoords()
            DrawMarker(
                Config.RangeMarkerType,
                coords.x, coords.y, coords.z - 0.95,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                radius * 2.0, radius * 2.0, 0.12,
                Config.RangePreviewColor.r, Config.RangePreviewColor.g, Config.RangePreviewColor.b, Config.RangePreviewColor.a,
                false, false, 2, false, nil, nil, false
            )
            Wait(0)
        else
            Wait(150)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()
        local dead = IsEntityDead(ped)
        if dead and not wasDead then
            wasDead = true
            if settings.deathSound and settings.deathSound ~= '' and Config.IsValidSound(settings.deathSound) and not deletedMap[settings.deathSound] then
                TriggerServerEvent('3rd_meme_radio:server:playSound', {
                    file = settings.deathSound,
                    coords = localPlayerCoords(),
                    maxDistance = getMaxDistance(settings.rangeLevel),
                    volume = Config.GetBaseVolume(settings.volumeLevel)
                })
            end
        elseif not dead and wasDead then
            wasDead = false
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if Config.ShopEnabled then
            local coords = localPlayerCoords()
            local dist = #(coords - Config.ShopCoords)
            if dist < 25.0 then
                DrawMarker(2, Config.ShopCoords.x, Config.ShopCoords.y, Config.ShopCoords.z + 0.15, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 213, 74, 180, false, false, 2, false, nil, nil, false)
                if dist <= Config.ShopInteractDistance then
                    showHelp(('E で Meme Radio 購入  $%s'):format(Config.ShopPrice))
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('3rd_meme_radio:server:purchaseItem')
                        Wait(500)
                    end
                end
            else
                Wait(400)
            end
        else
            Wait(1000)
        end
    end
end)

CreateThread(function()
    if not Config.ShopEnabled then return end
    local model = joaat(Config.ShopPedModel)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    local ped = CreatePed(4, model, Config.ShopCoords.x, Config.ShopCoords.y, Config.ShopCoords.z - 1.0, Config.ShopHeading, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    if Config.ShopPedScenario and Config.ShopPedScenario ~= '' then
        TaskStartScenarioInPlace(ped, Config.ShopPedScenario, 0, true)
    end
end)
