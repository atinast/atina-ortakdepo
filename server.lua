local QBCore = exports['qb-core']:GetCoreObject()

MySQL.ready(function()
    local results = MySQL.query.await('SELECT code, name, owner FROM atina_storages')
    for _, v in ipairs(results) do
        exports.ox_inventory:RegisterStash("atina_depo_"..v.code, v.name, 50, 100000, v.owner)
    end
end)

RegisterNetEvent('atina-ortakdepo:server:create', function(name, code, password)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local charName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname

    if string.len(tostring(password)) ~= 4 then
        return TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Sifre 4 haneli olmali!'})
    end

    MySQL.scalar('SELECT 1 FROM atina_storages WHERE code = ?', {code}, function(exists)
        if exists then
            TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Bu depo kodu zaten alinmis!'})
        else
            local members = {{cid = cid, name = charName}}
            MySQL.insert('INSERT INTO atina_storages (owner, name, code, password, members) VALUES (?, ?, ?, ?, ?)', {
                cid, name, code, password, json.encode(members)
            }, function(id)
                exports.ox_inventory:RegisterStash("atina_depo_"..code, name, 50, 100000, cid)
                TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Depo olusturuldu! Kod: '..code})
            end)
        end
    end)
end)

RegisterNetEvent('atina-ortakdepo:server:join', function(code, password)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local charName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname

    MySQL.single('SELECT * FROM atina_storages WHERE code = ?', {code}, function(result)
        if result and tostring(result.password) == tostring(password) then
            local members = json.decode(result.members)
            for _, m in ipairs(members) do
                if m.cid == cid then
                    return TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Zaten bu depoya uyesiniz!'})
                end
            end
            table.insert(members, {cid = cid, name = charName})
            MySQL.update('UPDATE atina_storages SET members = ? WHERE code = ?', {json.encode(members), code})
            TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Depoya katildiniz!'})
        else
            TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Kod veya sifre yanlis!'})
        end
    end)
end)

QBCore.Functions.CreateCallback('atina-ortakdepo:server:getAccessibleStorages', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local cid = Player.PlayerData.citizenid
    MySQL.query('SELECT * FROM atina_storages WHERE owner = ? OR members LIKE ?', {cid, '%'..cid..'%'}, function(results)
        cb(results)
    end)
end)

QBCore.Functions.CreateCallback('atina-ortakdepo:server:getMyStorages', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    MySQL.query('SELECT * FROM atina_storages WHERE owner = ?', {Player.PlayerData.citizenid}, function(results)
        cb(results)
    end)
end)

RegisterNetEvent('atina-ortakdepo:server:openStorage', function(code)
    local src = source
    exports.ox_inventory:forceOpenInventory(src, 'stash', "atina_depo_"..code)
end)

RegisterNetEvent('atina-ortakdepo:server:removeMember', function(code, targetCid)
    local src = source
    MySQL.single('SELECT members FROM atina_storages WHERE code = ?', {code}, function(result)
        if result then
            local members = json.decode(result.members)
            for i, m in ipairs(members) do
                if m.cid == targetCid then
                    table.remove(members, i)
                    break
                end
            end
            MySQL.update('UPDATE atina_storages SET members = ? WHERE code = ?', {json.encode(members), code})
            TriggerClientEvent('ox_lib:notify', src, {type = 'info', description = 'Uye cikarildi.'})
        end
    end)
end)