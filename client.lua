local QBCore = exports['qb-core']:GetCoreObject()

local npcModel = `a_m_m_prolhost_01`
local npcCoords = vec4(231.5, -788.1, 29.6, 157.3)

Citizen.CreateThread(function()
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do Wait(1) end
    local npc = CreatePed(4, npcModel, npcCoords.x, npcCoords.y, npcCoords.z, npcCoords.w, false, false)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    exports.qtarget:AddTargetEntity(npc, {
        options = {{ event = "atina-ortakdepo:client:mainMenu", icon = "fas fa-warehouse", label = "Atina Ortak Depo" }},
        distance = 2.0
    })
end)

RegisterNetEvent('atina-ortakdepo:client:mainMenu', function()
    lib.registerContext({
        id = 'atina_main',
        title = 'Atina Ortak Depo',
        options = {
            {
                title = 'Depoyu Ac',
                description = 'Uyesi oldugunuz depolari goruntuleyin',
                icon = 'box-open',
                onSelect = function() OpenAccessibleStorages() end
            },
            {
                title = 'Depo Olustur',
                icon = 'plus',
                onSelect = function()
                    local input = lib.inputDialog('Yeni Depo Kaydi', {
                        {type = 'input', label = 'Depo Adi', required = true},
                        {type = 'number', label = 'Depo Kodu (0-10000)', min = 0, max = 10000, required = true},
                        {type = 'input', label = 'Sifre (4 Haneli)', password = true, required = true},
                    })
                    if input then TriggerServerEvent('atina-ortakdepo:server:create', input[1], input[2], input[3]) end
                end
            },
            {
                title = 'Depoya Katil',
                icon = 'door-open',
                onSelect = function()
                    local input = lib.inputDialog('Depo Girisi', {
                        {type = 'number', label = 'Depo Kodu', required = true},
                        {type = 'input', label = 'Sifre', password = true, required = true},
                    })
                    if input then TriggerServerEvent('atina-ortakdepo:server:join', input[1], input[2]) end
                end
            },
            {
                title = 'Deponu Yonet',
                icon = 'gears',
                onSelect = function()
                    QBCore.Functions.TriggerCallback('atina-ortakdepo:server:getMyStorages', function(storages)
                        if not storages or #storages == 0 then 
                            lib.notify({title='Hata', description='Yonetebileceginiz bir deponuz yok!', type='error'})
                        else
                            local options = {}
                            for _, v in ipairs(storages) do
                                table.insert(options, {
                                    title = v.name .. " [" .. v.code .. "]",
                                    onSelect = function() OpenMemberManagement(v) end
                                })
                            end
                            lib.registerContext({id = 'atina_manage_list', title = 'Depolarim', options = options})
                            lib.showContext('atina_manage_list')
                        end
                    end)
                end
            }
        }
    })
    lib.showContext('atina_main')
end)

function OpenAccessibleStorages()
    QBCore.Functions.TriggerCallback('atina-ortakdepo:server:getAccessibleStorages', function(storages)
        if not storages or #storages == 0 then
            lib.notify({title = 'Hata', description = 'Erisiminiz olan depo bulunamadi!', type = 'error'})
            return
        end
        local options = {}
        for _, v in ipairs(storages) do
            table.insert(options, {
                title = v.name,
                description = "Kod: " .. v.code,
                icon = 'warehouse',
                onSelect = function() TriggerServerEvent('atina-ortakdepo:server:openStorage', v.code) end
            })
        end
        lib.registerContext({id = 'atina_access_list', title = 'Erisilebilir Depolar', menu = 'atina_main', options = options})
        lib.showContext('atina_access_list')
    end)
end

function OpenMemberManagement(storageData)
    local members = json.decode(storageData.members)
    local options = {}
    for _, m in ipairs(members) do
        table.insert(options, {
            title = m.name,
            description = "CitizenID: " .. m.cid,
            icon = 'user',
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Uveyi Cikar',
                    content = m.name .. ' depodan cikarilsin mi?',
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('atina-ortakdepo:server:removeMember', storageData.code, m.cid)
                end
            end
        })
    end
    lib.registerContext({id = 'atina_members', title = storageData.name .. ' Uyeleri', options = options})
    lib.showContext('atina_members')
end