local QBCore = exports['qb-core']:GetCoreObject()
local activeTickets = {}
local noAdminMode = {}
local playerCooldowns = {}
local playerTicketCount = {}
local discordMessages = {} -- Store Discord message IDs for updates

-- Initialize Locales table
Locales = {}

-- Load locales
local locale_file = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. Config.Language .. '.lua')
if locale_file then
    local chunk, err = load(locale_file)
    if chunk then
        chunk()
    else
        print("^1Error loading locale file: " .. err .. "^7")
    end
end

-- Helper function to get localized text
local function _L(key)
    if not Locales or not Locales[Config.Language] then return key end
    return Locales[Config.Language][key] or key
end

-- Format time for cooldown message
local function formatTimeRemaining(seconds)
    if seconds < 60 then
        return seconds .. ' ' .. _L('seconds')
    elseif seconds < 3600 then
        return math.ceil(seconds / 60) .. ' ' .. _L('minutes')
    else
        return math.ceil(seconds / 3600) .. ' ' .. _L('hours')
    end
end

-- Check if player is on cooldown
local function isPlayerOnCooldown(source)
    local lastTicket = playerCooldowns[source]
    if lastTicket then
        local timeRemaining = Config.AntiSpam.Cooldown - (os.time() - lastTicket)
        if timeRemaining > 0 then
            return true, formatTimeRemaining(timeRemaining)
        end
    end
    return false, nil
end

-- Count active tickets for player
local function countPlayerTickets(source)
    local count = 0
    for _, ticket in pairs(activeTickets) do
        if ticket.player == source then
            count = count + 1
        end
    end
    return count
end

-- Generate a unique ticket ID
local function GenerateTicketId()
    return string.format("%x", os.time()) .. string.format("%x", math.random(1000, 9999))
end

-- Check if player has admin permissions
local function IsPlayerAdmin(source)
    return IsPlayerAceAllowed(source, Config.RequiredPermission)
end

-- Helper function to check if player has permission
local function hasPermission(source)
    return IsPlayerAceAllowed(source, Config.RequiredPermission)
end

-- Helper function to check if player is in no-admin mode
local function isNoAdmin(source)
    return noAdminMode[source] == true
end

-- Helper function to get player name
local function getPlayerName(source)
    local Player = QBCore.Functions.GetPlayer(source)
    return Player and Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname or "Unknown"
end

-- Function to send notification based on config settings
local function SendConfiguredNotification(player, notificationType, adminName, data)
    -- Check if notification type is enabled in config
    if not Config.Notifications[notificationType] or not Config.Notifications[notificationType].enabled then
        return
    end
    
    local text
    if Config.Notifications[notificationType].useCustomText and Config.Notifications[notificationType].customText then
        text = Config.Notifications[notificationType].customText
    else
        -- Get translation key based on notification type
        local translationKey = {
            TicketAccepted = 'ticket_accepted',
            TicketClosed = 'ticket_closed',
            TicketUnassigned = 'ticket_unassigned',
            TicketCreated = 'chat_ticket_created'
        }
        
        -- Get translated text
        text = _L(translationKey[notificationType])
        
        -- Replace admin name if configured
        if Config.Notifications[notificationType].showAdmin and adminName then
            text = string.format(text, adminName)
        end
    end
    
    -- Send notification
    if text then
        -- Send QBCore notification
        TriggerClientEvent('QBCore:Notify', player, text, 'info')
        
        -- Send chat message if configured
        if Config.ChatMessages.prefix then
            local prefix = Config.ChatMessages.colors.prefix .. Config.ChatMessages.prefix .. 
                         Config.ChatMessages.colors.text
            
            local message = prefix .. ' ' .. text
            TriggerClientEvent('chat:addMessage', player, {
                color = {255, 255, 255},
                multiline = true,
                args = {message}
            })
        end
    end
end

-- Send Discord webhook notification
-- # Reason: This function sends ticket information to a Discord channel via webhook
local function SendDiscordWebhook(type, data)
    if not Config.Discord.enabled or not Config.Discord.webhook or Config.Discord.webhook == "" then
        return
    end

    -- Only send notifications for new tickets
    if type ~= "ticketCreated" then
        return
    end
    
    -- Get translations directly from the locale system
    local titleText = _L('discord_title')
    local idText = _L('discord_id') .. " `#%s`\n"
    local playerText = _L('discord_player') .. " `%s` (ID: %d)\n"
    local messageText = _L('discord_message') .. "\n```%s```\n"
    local createdText = _L('discord_created') .. " <t:%d:R>"
    
    -- Build the description with clear sections and minimal formatting
    local description = string.format(idText, data.id)
    description = description .. string.format(playerText, data.name, data.player)
    description = description .. string.format(messageText, data.message)
    
    if Config.Discord.design.includeTimestamp then
        description = description .. string.format(createdText, data.timestamp)
    end
    
    -- Create the embed
    local embed = {
        {
            title = titleText,
            color = Config.Discord.color, -- Use the single color setting
            description = description,
            footer = {
                text = Config.Discord.footer
            },
            thumbnail = Config.Discord.thumbnailUrl ~= "" and { url = Config.Discord.thumbnailUrl } or nil,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    local discordData = {
        username = Config.Discord.botName,
        avatar_url = Config.Discord.avatarUrl ~= "" and Config.Discord.avatarUrl or nil,
        embeds = embed
    }
    
    -- Simple function to handle Discord response
    local function HandleDiscordResponse(err, text, headers)
        if err ~= 200 and err ~= 204 then
            print("^1Discord webhook error: " .. err .. "^7")
        end
    end
    
    -- Always use POST since we're only sending new messages
    PerformHttpRequest(
        Config.Discord.webhook, 
        HandleDiscordResponse, 
        'POST', 
        json.encode(discordData), 
        { ['Content-Type'] = 'application/json' }
    )
end

-- Command to create a support ticket
QBCore.Commands.Add(Config.SupportCommand, _L('cmd_support_help'), {{name = 'message', help = _L('cmd_support_arg')}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Check cooldown
    local onCooldown, timeRemaining = isPlayerOnCooldown(src)
    if onCooldown then
        TriggerClientEvent('QBCore:Notify', src, string.format(_L('cooldown'), timeRemaining), 'error')
        return
    end

    -- Check ticket limit
    local ticketCount = countPlayerTickets(src)
    if ticketCount >= Config.AntiSpam.MaxTickets then
        TriggerClientEvent('QBCore:Notify', src, _L('error_max_tickets'), 'error')
        return
    end

    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('QBCore:Notify', src, _L('error_no_message'), 'error')
        return
    end

    local ticketId = GenerateTicketId()
    local coords = GetEntityCoords(GetPlayerPed(src))
    local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    
    activeTickets[ticketId] = {
        id = ticketId,
        player = src,
        name = playerName,
        citizenid = src,
        message = message,
        coords = coords,
        timestamp = os.time(),
        status = 'pending',
        assignedTo = nil
    }

    -- Send Discord webhook notification for ticket creation
    SendDiscordWebhook("ticketCreated", activeTickets[ticketId])

    -- Set cooldown
    playerCooldowns[src] = os.time()

    -- Notify all online admins
    local adminCount = 0
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        if IsPlayerAdmin(v) and not noAdminMode[v] then
            adminCount = adminCount + 1
            
            -- Send detailed notification to admin
            TriggerClientEvent('chat:addMessage', v, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 128, 255, 0.15); border-radius: 3px;">' ..
                    '<i class="fas fa-ticket-alt" style="color: #0080ff;"></i> <b style="color: #0080ff;">' .. _L('chat_new_ticket') .. '</b><br>' ..
                    '<b>' .. string.format(_L('chat_ticket_id'), ticketId) .. '</b><br>' ..
                    '<b>' .. string.format(_L('chat_player'), playerName, src) .. '</b><br>' ..
                    '<b>' .. string.format(_L('chat_message'), message) .. '</b>' ..
                    '</div>',
                args = {}
            })

            -- Play notification sound for admins not in noadmin mode
            TriggerClientEvent('qb-adminsupport:client:playSound', v)

            -- Send notification to admin panel
            TriggerClientEvent('qb-adminsupport:client:NewTicket', v, activeTickets[ticketId])
        end
    end

    -- Always send ticket creation message to player
    TriggerClientEvent('chat:addMessage', src, {
        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 128, 255, 0.15); border-radius: 3px;">' ..
            '<i class="fas fa-check-circle" style="color: #0080ff;"></i> <b style="color: #0080ff;">' .. _L('chat_ticket_created') .. '</b><br>' ..
            '<b>' .. string.format(_L('chat_ticket_id'), ticketId) .. '</b><br>' ..
            '<b>' .. string.format(_L('chat_your_message'), message) .. '</b><br>' ..
            '<b>' .. _L('chat_waiting') .. '</b>' ..
            (adminCount == 0 and '<br><b>' .. _L('no_admins') .. '</b>' or '') ..
            '</div>',
        args = {}
    })

    -- If no admins are online and showNoAdmins is enabled, show additional notification
    if adminCount == 0 and Config.Notifications.TicketCreated.showNoAdmins then
        TriggerClientEvent('QBCore:Notify', src, _L('no_admins'), 'info')
    end
end)

-- Command to toggle admin notifications
QBCore.Commands.Add(Config.NoAdminCommand, _L('cmd_noadmin_help'), {}, false, function(source)
    local src = source
    if not IsPlayerAdmin(src) then 
        TriggerClientEvent('QBCore:Notify', src, _L('no_permission'), 'error')
        return 
    end
    
    noAdminMode[src] = not noAdminMode[src]
    TriggerClientEvent('QBCore:Notify', src, noAdminMode[src] and _L('notifications_disabled') or _L('notifications_enabled'), 'primary')
end)

-- Get all active tickets
QBCore.Functions.CreateCallback('qb-adminsupport:server:GetTickets', function(source, cb)
    if not IsPlayerAdmin(source) then cb({}) return end
    cb(activeTickets)
end)

-- Handle ticket actions (accept, teleport, waypoint, delete)
RegisterNetEvent('qb-adminsupport:server:HandleTicket', function(ticketId, action)
    local src = source
    if not IsPlayerAdmin(src) then return end
    
    local ticket = activeTickets[ticketId]
    if not ticket then return end

    if action == 'accept' then
        ticket.status = 'accepted'
        local adminName = GetPlayerName(src)
        ticket.assignedTo = adminName
        
        -- Send Discord webhook notification for ticket acceptance
        SendDiscordWebhook("ticketAccepted", ticket)
        
        -- Send styled accept notification
        TriggerClientEvent('chat:addMessage', ticket.player, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 128, 255, 0.15); border-radius: 3px;">' ..
                '<i class="fas fa-headset" style="color: #0080ff;"></i> <b style="color: #0080ff;">' .. _L('chat_accepted') .. '</b><br>' ..
                (Config.Notifications.TicketAccepted.showAdmin and '<b>' .. string.format(_L('chat_admin'), adminName) .. '</b><br>' or '') ..
                '<b>' .. _L('chat_please_wait') .. '</b>' ..
                '</div>',
            args = {}
        })

        -- Also send QBCore notification if enabled
        if Config.Notifications.TicketAccepted.enabled then
            if Config.Notifications.TicketAccepted.showAdmin then
                TriggerClientEvent('QBCore:Notify', ticket.player, string.format(_L('ticket_accepted'), adminName), 'success')
            else
                TriggerClientEvent('QBCore:Notify', ticket.player, _L('ticket_accepted_no_admin'), 'success')
            end
        end

    elseif action == 'unassign' then
        local previousAdmin = ticket.assignedTo
        
        -- Create a copy of the ticket data with the previous admin for Discord webhook
        local ticketData = table.copy(ticket)
        ticketData.previousAdmin = previousAdmin
        
        ticket.status = 'pending'
        ticket.assignedTo = nil
        
        -- Send Discord webhook notification for ticket unassignment
        SendDiscordWebhook("ticketUnassigned", ticketData)
        
        -- Send styled unassign notification
        TriggerClientEvent('chat:addMessage', ticket.player, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 128, 255, 0.15); border-radius: 3px;">' ..
                '<i class="fas fa-sync" style="color: #0080ff;"></i> <b style="color: #0080ff;">' .. _L('chat_unassigned') .. '</b><br>' ..
                (Config.Notifications.TicketUnassigned.showAdmin and previousAdmin and '<b>' .. string.format(_L('chat_admin'), previousAdmin) .. '</b><br>' or '') ..
                '<b>' .. _L('chat_other_admin') .. '</b>' ..
                '</div>',
            args = {}
        })

        -- Also send QBCore notification if enabled
        if Config.Notifications.TicketUnassigned.enabled then
            if Config.Notifications.TicketUnassigned.showAdmin and previousAdmin then
                TriggerClientEvent('QBCore:Notify', ticket.player, string.format(_L('ticket_unassigned'), previousAdmin), 'info')
            else
                TriggerClientEvent('QBCore:Notify', ticket.player, _L('ticket_unassigned_no_admin'), 'info')
            end
        end

    elseif action == 'delete' then
        if activeTickets[ticketId] then
            local playerSrc = activeTickets[ticketId].player
            local adminName = GetPlayerName(src)
            
            -- Create a copy of the ticket data with the closing admin for Discord webhook
            local ticketData = table.copy(activeTickets[ticketId])
            ticketData.closedBy = adminName
            
            -- Send Discord webhook notification for ticket closing
            SendDiscordWebhook("ticketClosed", ticketData)
            
            playerCooldowns[playerSrc] = nil
            
            -- Send styled close notification
            TriggerClientEvent('chat:addMessage', playerSrc, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 128, 255, 0.15); border-radius: 3px;">' ..
                    '<i class="fas fa-check-double" style="color: #0080ff;"></i> <b style="color: #0080ff;">' .. _L('chat_ticket_closed') .. '</b><br>' ..
                    (Config.Notifications.TicketClosed.showAdmin and '<b>' .. string.format(_L('chat_admin'), adminName) .. '</b><br>' or '') ..
                    '<b>' .. (Config.Notifications.TicketClosed.showAdmin and string.format(_L('ticket_closed'), adminName) or _L('ticket_closed_no_admin')) .. '</b>' ..
                    '</div>',
                args = {}
            })

            -- Also send QBCore notification if enabled
            if Config.Notifications.TicketClosed.enabled then
                if Config.Notifications.TicketClosed.showAdmin then
                    TriggerClientEvent('QBCore:Notify', playerSrc, string.format(_L('ticket_closed'), adminName), 'info')
                else
                    TriggerClientEvent('QBCore:Notify', playerSrc, _L('ticket_closed_no_admin'), 'info')
                end
            end
            
            activeTickets[ticketId] = nil
        end
    end

    -- Update all admin panels
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        if IsPlayerAdmin(v) then
            TriggerClientEvent('qb-adminsupport:client:UpdateTickets', v, activeTickets)
        end
    end
end)

-- Teleport admin to ticket location
RegisterNetEvent('qb-adminsupport:server:TeleportToTicket', function(ticketId)
    local src = source
    if not IsPlayerAdmin(src) then return end
    
    local ticket = activeTickets[ticketId]
    if not ticket then return end

    TriggerClientEvent('qb-adminsupport:client:TeleportToLocation', src, ticket.coords)
end)

-- Set waypoint for ticket location
RegisterNetEvent('qb-adminsupport:server:SetWaypoint', function(ticketId)
    local src = source
    if not IsPlayerAdmin(src) then return end
    
    local ticket = activeTickets[ticketId]
    if not ticket then return end

    TriggerClientEvent('qb-adminsupport:client:SetWaypoint', src, ticket.coords)
end)

-- Cleanup tickets and cooldowns when player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    -- Remove player's tickets
    for ticketId, ticket in pairs(activeTickets) do
        if ticket.player == src then
            activeTickets[ticketId] = nil
        end
    end
    -- Clear cooldown
    playerCooldowns[src] = nil
    noAdminMode[src] = nil
end)

-- Helper function to create a deep copy of a table
function table.copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.copy(orig_key)] = table.copy(orig_value)
        end
        setmetatable(copy, table.copy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end 