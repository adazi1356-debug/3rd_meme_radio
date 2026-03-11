
local RES_NAME = GetCurrentResourceName()
local Core = nil
pcall(function()
    if GetResourceState('qb-core') == 'started' then
        Core = exports['qb-core']:GetCoreObject()
    end
end)

local settingsStore = {}
local deletedSounds = {}

local function debugLog(...)
    if Config.Debug then
        print(('^6[%s/server]^7'):format(RES_NAME), ...)
    end
end

local function loadJson(path, fallback)
    local raw = LoadResourceFile(RES_NAME, path)
    if not raw or raw == '' then
        return fallback
    end
    local ok, data = pcall(json.decode, raw)
    if ok and type(data) == 'table' then
        return data
    end
    return fallback
end

local function saveJson(path, data)
    SaveResourceFile(RES_NAME, path, json.encode(data, { indent = true }), -1)
end

local function getIdentifier(src, prefix)
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if identifier:sub(1, #prefix) == prefix then
            return identifier
        end
    end
    return nil
end

local function getPlayerKey(src)
    return getIdentifier(src, 'license:') or getIdentifier(src, 'license2:') or ('src:%s'):format(src)
end

local function hasValue(list, value)
    for _, v in ipairs(list or {}) do
        if v == value then
            return true
        end
    end
    return false
end

local function hasAdminAccess(src)
    if Config.UseAdminAce and IsPlayerAceAllowed(src, Config.AdminAce) then
        return true
    end
    local license = getIdentifier(src, 'license:')
    local discord = getIdentifier(src, 'discord:')
    return hasValue(Config.AllowLicenses, license) or hasValue(Config.AllowDiscordIds, discord)
end

local function permissionAllowed(src)
    if not Config.PermissionEnabled then
        return true
    end
    local license = getIdentifier(src, 'license:')
    local discord = getIdentifier(src, 'discord:')
    if hasValue(Config.AllowLicenses, license) then
        return true
    end
    if hasValue(Config.AllowDiscordIds, discord) then
        return true
    end
    return hasAdminAccess(src)
end

local function qbPlayer(src)
    if not Core then return nil end
    return Core.Functions.GetPlayer(src)
end

local function hasQbItem(src, itemName)
    local Player = qbPlayer(src)
    if not Player or not Player.PlayerData or not Player.PlayerData.items then
        return false
    end
    for _, item in pairs(Player.PlayerData.items) do
        if item and item.name == itemName and (tonumber(item.amount) or 0) > 0 then
            return true
        end
    end
    return false
end

local function hasLsInventoryHudItem(src, itemName)
    if GetResourceState('ls-inventoryhud') ~= 'started' then
        return nil
    end

    local ok, result = pcall(function()
        local items = exports['ls-inventoryhud']:GetItems(src)
        if type(items) ~= 'table' then
            return false
        end

        for _, item in pairs(items) do
            if type(item) == 'table' then
                local name = item._name or item.name or item._tpl
                local amount = tonumber((item.info and (item.info.CurrentStack or item.info.currentStack)) or item.amount or 1) or 1
                if name == itemName and amount > 0 then
                    return true
                end
            end
        end

        return false
    end)

    if ok then
        return result and true or false
    end

    return nil
end

local function hasItem(src, itemName)
    if not Config.UseItemRequirement then
        return true
    end

    local ok, result = pcall(function()
        if GetResourceState('ox_inventory') == 'started' then
            local count = exports.ox_inventory:Search(src, 'count', itemName)
            return (tonumber(count) or 0) > 0
        end
    end)
    if ok and result ~= nil then
        return result
    end

    ok, result = pcall(function()
        if GetResourceState('qb-inventory') == 'started' then
            return exports['qb-inventory']:HasItem(src, itemName)
        end
    end)
    if ok and result ~= nil then
        return result and true or false
    end

    ok, result = pcall(function()
        if GetResourceState('qs-inventory') == 'started' then
            local amount = exports['qs-inventory']:GetItemTotalAmount(src, itemName)
            return (tonumber(amount) or 0) > 0
        end
    end)
    if ok and result ~= nil then
        return result
    end

    ok, result = pcall(function()
        if GetResourceState('qs-inventory') == 'started' then
            local item = exports['qs-inventory']:Search(src, itemName)
            return item ~= nil
        end
    end)
    if ok and result ~= nil then
        return result and true or false
    end

    result = hasLsInventoryHudItem(src, itemName)
    if result ~= nil then
        return result
    end

    return hasQbItem(src, itemName)
end

local function addItem(src, itemName, amount)
    amount = tonumber(amount) or 1

    local ok, result = pcall(function()
        if GetResourceState('ox_inventory') == 'started' then
            return exports.ox_inventory:AddItem(src, itemName, amount)
        end
    end)
    if ok and result then return true end

    ok, result = pcall(function()
        if GetResourceState('qb-inventory') == 'started' then
            return exports['qb-inventory']:AddItem(src, itemName, amount)
        end
    end)
    if ok and result then return true end

    ok, result = pcall(function()
        if GetResourceState('qs-inventory') == 'started' then
            return exports['qs-inventory']:AddItem(src, itemName, amount)
        end
    end)
    if ok and result then return true end

    if GetResourceState('ls-inventoryhud') == 'started' then
        ok, result = pcall(function()
            return exports['ls-inventoryhud']:AddItem(src, itemName, amount)
        end)
        if ok then
            return result ~= false
        end
    end

    local Player = qbPlayer(src)
    if Player then
        return Player.Functions.AddItem(itemName, amount)
    end

    return false
end

local function removeCash(src, amount)
    local Player = qbPlayer(src)
    if not Player then
        return false, 'QBCore が見つかりません'
    end

    local cash = Player.PlayerData.money and Player.PlayerData.money.cash or 0
    if cash < amount then
        return false, ('現金が足りません  $%s'):format(amount)
    end

    if Player.Functions.RemoveMoney('cash', amount, '3rd_meme_radio_purchase') then
        return true
    end

    return false, '支払いに失敗しました'
end

local function sanitizeSettings(data)
    data = type(data) == 'table' and data or {}

    local out = {
        defaultPlaySound = Config.NormalizeSoundName(data.defaultPlaySound or Config.DefaultPlaySound),
        deathSound = data.deathSound or Config.DefaultDeathSound,
        rangeLevel = Config.GetRangeLevel(data.rangeLevel),
        volumeLevel = Config.GetVolumeLevel(data.volumeLevel),
        favorites = {},
        favoriteSlots = {},
        favoriteVolumes = {}
    }

    if not Config.IsValidSound(out.defaultPlaySound) or deletedSounds[out.defaultPlaySound] then
        out.defaultPlaySound = Config.DefaultPlaySound
    end

    out.deathSound = Config.NormalizeSoundName(out.deathSound)
    if out.deathSound ~= '' and (not Config.IsValidSound(out.deathSound) or deletedSounds[out.deathSound]) then
        out.deathSound = ''
    end

    if type(data.favorites) == 'table' then
        for file, enabled in pairs(data.favorites) do
            file = Config.NormalizeSoundName(file)
            if enabled and Config.IsValidSound(file) and not deletedSounds[file] then
                out.favorites[file] = true
            end
        end
    end

    if type(data.favoriteSlots) == 'table' then
        for i = 1, 9 do
            local key = tostring(i)
            local file = data.favoriteSlots[key] or data.favoriteSlots[i]
            file = Config.NormalizeSoundName(file)
            if file and out.favorites[file] and Config.IsValidSound(file) and not deletedSounds[file] then
                out.favoriteSlots[key] = file
            end
        end
    end

    if type(data.favoriteVolumes) == 'table' then
        for file, level in pairs(data.favoriteVolumes) do
            file = Config.NormalizeSoundName(file)
            if out.favorites[file] and Config.IsValidSound(file) and not deletedSounds[file] then
                out.favoriteVolumes[file] = Config.GetVolumeLevel(level)
            end
        end
    end

    if type(data.favoriteSlotVolumes) == 'table' then
        for i = 1, 9 do
            local key = tostring(i)
            local file = out.favoriteSlots[key]
            if file and not out.favoriteVolumes[file] then
                out.favoriteVolumes[file] = Config.GetVolumeLevel(data.favoriteSlotVolumes[key] or data.favoriteSlotVolumes[i] or out.volumeLevel)
            end
        end
    end

    for file in pairs(out.favorites) do
        if not out.favoriteVolumes[file] then
            out.favoriteVolumes[file] = out.volumeLevel
        end
    end

    return out
end

local function getSettings(src)
    local key = getPlayerKey(src)
    settingsStore[key] = sanitizeSettings(settingsStore[key])
    return settingsStore[key]
end

local function saveAll()
    saveJson('data/playersettings.json', settingsStore)
    saveJson('data/deleted_sounds.json', deletedSounds)
end

local function syncInit(src)
    TriggerClientEvent('3rd_meme_radio:client:init', src, {
        settings = getSettings(src),
        deletedMap = deletedSounds,
        isAdmin = hasAdminAccess(src)
    })
end

local function canUseRadio(src)
    if Config.PermissionEnabled and not permissionAllowed(src) then
        return false, '使用権限がありません'
    end
    if Config.UseItemRequirement and not hasItem(src, Config.RequiredItemName) then
        return false, ('%s を所持していません'):format(Config.RequiredItemName)
    end
    return true
end

CreateThread(function()
    settingsStore = loadJson('data/playersettings.json', {})
    deletedSounds = loadJson('data/deleted_sounds.json', {})
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RES_NAME then return end
    saveAll()
end)

RegisterNetEvent('3rd_meme_radio:server:init', function()
    syncInit(source)
end)

RegisterNetEvent('3rd_meme_radio:server:requestAccess', function(token)
    local ok, reason = canUseRadio(source)
    TriggerClientEvent('3rd_meme_radio:client:reply', source, token, {
        allowed = ok,
        reason = reason
    })
end)

RegisterNetEvent('3rd_meme_radio:server:saveSettings', function(data)
    local key = getPlayerKey(source)
    settingsStore[key] = sanitizeSettings(data)
    saveJson('data/playersettings.json', settingsStore)
end)

RegisterNetEvent('3rd_meme_radio:server:playSound', function(payload)
    payload = type(payload) == 'table' and payload or {}
    local ok, reason = canUseRadio(source)
    if not ok then
        TriggerClientEvent('3rd_meme_radio:client:notify', source, reason)
        return
    end

    local file = Config.NormalizeSoundName(payload.file)
    if not Config.IsValidSound(file) or deletedSounds[file] then
        return
    end

    local coords = payload.coords or {}
    local maxDistance = tonumber(payload.maxDistance) or 8.0
    local volume = tonumber(payload.volume) or Config.GetBaseVolume(Config.DefaultVolumeLevel)

    TriggerClientEvent('3rd_meme_radio:client:playSound', -1, {
        id = ('%s_%s'):format(source, os.time() .. math.random(1000, 9999)),
        sourceServerId = source,
        file = file,
        coords = {
            x = tonumber(coords.x) or 0.0,
            y = tonumber(coords.y) or 0.0,
            z = tonumber(coords.z) or 0.0
        },
        maxDistance = maxDistance,
        volume = volume
    })
end)

RegisterNetEvent('3rd_meme_radio:server:purchaseItem', function()
    if not Config.ShopEnabled then return end
    local src = source
    local ok, msg = removeCash(src, Config.ShopPrice)
    if not ok then
        TriggerClientEvent('3rd_meme_radio:client:purchaseResult', src, false, msg)
        return
    end

    if addItem(src, Config.RequiredItemName, 1) then
        TriggerClientEvent('3rd_meme_radio:client:purchaseResult', src, true, ('%s を購入しました'):format(Config.RequiredItemName))
        return
    end

    local Player = qbPlayer(src)
    if Player then
        Player.Functions.AddMoney('cash', Config.ShopPrice, '3rd_meme_radio_refund')
    end
    TriggerClientEvent('3rd_meme_radio:client:purchaseResult', src, false, 'アイテム付与に失敗したため返金しました')
end)

RegisterNetEvent('3rd_meme_radio:server:deleteSound', function(file)
    local src = source
    if not hasAdminAccess(src) then return end
    file = Config.NormalizeSoundName(file)
    if not Config.IsValidSound(file) then return end
    deletedSounds[file] = true
    saveAll()
    TriggerClientEvent('3rd_meme_radio:client:syncDeleted', -1, deletedSounds)
    TriggerClientEvent('3rd_meme_radio:client:notify', src, ('削除しました: %s'):format(Config.GetSoundLabel(file)))
end)

RegisterNetEvent('3rd_meme_radio:server:restoreSound', function(file)
    local src = source
    if not hasAdminAccess(src) then return end
    file = Config.NormalizeSoundName(file)
    if not Config.IsValidSound(file) then return end
    deletedSounds[file] = nil
    saveAll()
    TriggerClientEvent('3rd_meme_radio:client:syncDeleted', -1, deletedSounds)
    TriggerClientEvent('3rd_meme_radio:client:notify', src, ('戻しました: %s'):format(Config.GetSoundLabel(file)))
end)
