Config = {}

-- Language Settings
Config.Language = 'en' -- Available: 'de', 'en'

-- Permission Settings
Config.RequiredPermission = "command" -- The ace permission required to use admin features

-- Command Settings
Config.AdminPanelCommand = "ap" -- Command to open the admin panel
Config.NoAdminCommand = "noadmin" -- Command to toggle admin mode
Config.SupportCommand = "support" -- Command to create a support ticket

-- Notification Settings
Config.NotificationSound = "incoming_support_msg.mp3" -- Sound file to play for notifications
Config.NotificationDuration = 5000 -- Duration in ms to show notifications

-- Anti-Spam Settings
Config.AntiSpam = {
    MaxTickets = 3, -- Maximum number of active tickets per player
    Cooldown = 300, -- Time in seconds before a player can create another ticket
}

-- Chat Settings
Config.ChatPrefix = "[Support]" -- Prefix for chat messages

-- Notification settings
Config.NotificationDistance = 100.0 -- Distance in meters to show waypoint marker

-- UI Settings
Config.RefreshInterval = 5000 -- How often to refresh the admin panel (in ms)

-- Notification Settings
Config.Notifications = {
    -- Ticket Accepted
    TicketAccepted = {
        enabled = true,              -- Enable/disable the notification
        showAdmin = false,            -- Show admin name in notification
        useCustomText = false,       -- Use custom text instead of translation
        customText = nil             -- Custom text (only used if useCustomText = true)
    },
    
    -- Ticket Closed/Deleted
    TicketClosed = {
        enabled = true,
        showAdmin = false,
        useCustomText = false,
        customText = nil
    },
    
    -- Ticket Unassigned
    TicketUnassigned = {
        enabled = true,
        showAdmin = false,
        useCustomText = false,
        customText = nil
    },
    
    -- New Ticket Created
    TicketCreated = {
        enabled = true,              -- Show confirmation to player when ticket is created
        showNoAdmins = true,        -- Show "no admins online" message
        useCustomText = false,
        customText = nil
    }
}

-- Chat Message Settings
Config.ChatMessages = {
    prefix = '[Support]',  -- Prefix for all chat messages
    colors = {
        prefix = '^5',     -- Color for prefix
        text = '^7',       -- Color for regular text
        highlight = '^2'   -- Color for highlighted text (IDs, names, etc.)
    }
}

return Config 