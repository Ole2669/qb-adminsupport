local QBCore = exports['qb-core']:GetCoreObject()
local isAdminPanelVisible = false

-- Get translations for current language
local function GetTranslations()
    return Locales[Config.Language] or Locales['en']
end

-- Play notification sound
RegisterNetEvent('qb-adminsupport:client:playSound')
AddEventHandler('qb-adminsupport:client:playSound', function(soundFile)
    SendNUIMessage({
        action = 'playSound',
        file = Config.NotificationSound
    })
end)

-- Send chat message
local function SendChatMessage(message)
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {Config.ChatPrefix, message}
    })
end

-- Open Admin Panel
RegisterCommand(Config.AdminPanelCommand, function()
    QBCore.Functions.TriggerCallback('qb-adminsupport:server:GetTickets', function(tickets)
        SendNUIMessage({
            action = 'openAdminPanel',
            tickets = tickets,
            language = Config.Language,
            translations = GetTranslations()
        })
        SetNuiFocus(true, true)
        isAdminPanelVisible = true
    end)
end)

-- Handle new ticket notification
RegisterNetEvent('qb-adminsupport:client:NewTicket')
AddEventHandler('qb-adminsupport:client:NewTicket', function(ticket)
    if isAdminPanelVisible then
        QBCore.Functions.TriggerCallback('qb-adminsupport:server:GetTickets', function(tickets)
            SendNUIMessage({
                action = 'updateTickets',
                tickets = tickets
            })
        end)
    end
end)

-- Update tickets in admin panel
RegisterNetEvent('qb-adminsupport:client:UpdateTickets', function(tickets)
    if isAdminPanelVisible then
        SendNUIMessage({
            action = 'updateTickets',
            tickets = tickets
        })
    end
end)

-- Teleport to ticket location
RegisterNetEvent('qb-adminsupport:client:TeleportToLocation', function(coords)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
end)

-- Set waypoint to ticket location
RegisterNetEvent('qb-adminsupport:client:SetWaypoint', function(coords)
    SetNewWaypoint(coords.x, coords.y)
    QBCore.Functions.Notify('Waypoint set to ticket location', 'success', Config.NotificationDuration)
end)

-- NUI Callbacks
RegisterNUICallback('closePanel', function(data, cb)
    SetNuiFocus(false, false)
    isAdminPanelVisible = false
    cb('ok')
end)

RegisterNUICallback('handleTicket', function(data, cb)
    TriggerServerEvent('qb-adminsupport:server:HandleTicket', data.ticketId, data.action)
    cb('ok')
end)

RegisterNUICallback('teleportToTicket', function(data, cb)
    TriggerServerEvent('qb-adminsupport:server:TeleportToTicket', data.ticketId)
    cb('ok')
end)

RegisterNUICallback('setWaypoint', function(data, cb)
    TriggerServerEvent('qb-adminsupport:server:SetWaypoint', data.ticketId)
    cb('ok')
end)

-- Register NUI Callback for translations
RegisterNUICallback('getTranslations', function(data, cb)
    local translations = {}
    for key, value in pairs(Locales[Config.Language]) do
        translations[key] = value
    end
    cb(translations)
end) 