Locales = Locales or {}
Locales['en'] = {
    -- Commands
    ['cmd_support_help'] = 'Create a support ticket',
    ['cmd_support_arg'] = 'Your message',
    ['cmd_noadmin_help'] = 'Toggle support notifications',
    ['cmd_ap_help'] = 'Open admin panel',
    ['no_permission'] = 'You do not have permission for this action',
    
    -- Command Help Messages
    ['help_support'] = 'Create a support ticket',
    ['help_support_params'] = 'message',
    ['help_ap'] = 'Open the admin panel',
    ['help_noadmin'] = 'Toggle support notifications',
    
    -- UI Elements
    ['support_panel'] = 'Support Panel',
    ['settings'] = 'Settings',
    ['no_tickets'] = 'No support tickets',
    ['pending'] = 'PENDING',
    ['accepted'] = 'ACCEPTED',
    ['player'] = 'PLAYER',
    ['time'] = 'TIME',
    ['assigned_to'] = 'ASSIGNED TO',
    ['not_assigned'] = 'Not assigned',
    ['accept'] = 'Accept',
    ['unassign'] = 'Unassign',
    ['teleport'] = 'Teleport',
    ['waypoint'] = 'Waypoint',
    ['delete'] = 'Delete',
    
    -- Settings
    ['notifications'] = 'Notifications',
    ['enable_sound'] = 'Enable sound',
    ['volume'] = 'Volume',
    ['appearance'] = 'Appearance',
    ['accent_color'] = 'Accent color',
    ['ticket_management'] = 'Ticket Management',
    ['auto_accept_tp'] = 'Auto accept when teleporting',
    ['auto_waypoint'] = 'Auto set waypoint on accept',
    ['confirm_delete'] = 'Confirm deletion',
    
    -- Dialogs
    ['confirmation'] = 'Confirmation',
    ['confirm_delete_msg'] = 'Do you really want to delete this ticket?',
    ['cancel'] = 'Cancel',
    
    -- Notifications
    ['ticket_accepted'] = 'Your ticket has been accepted by %s!',
    ['ticket_closed'] = 'Your support ticket has been closed',
    ['ticket_unassigned'] = 'Your ticket has been returned to the queue',
    ['waypoint_set'] = 'Waypoint set to ticket location',
    ['cooldown'] = 'You need to wait %s before creating a new ticket',
    ['max_tickets'] = 'You have already created the maximum number of tickets',
    ['no_admins'] = 'Note: No admin is currently online. Your ticket has been saved',
    ['notifications_enabled'] = 'Support notifications enabled',
    ['notifications_disabled'] = 'Support notifications disabled',
    ['new_ticket'] = 'New support ticket received!',
    
    -- Chat Messages
    ['chat_prefix'] = '[Support]',
    ['chat_ticket_created'] = 'Support ticket created',
    ['chat_ticket_id'] = 'Ticket ID: #%s',
    ['chat_your_message'] = 'Your message: %s',
    ['chat_waiting'] = 'Waiting for an admin',
    ['chat_new_ticket'] = 'New support ticket',
    ['chat_player'] = 'Player: %s (%s)',
    ['chat_message'] = 'Message: %s',
    ['chat_accepted'] = 'Ticket accepted',
    ['chat_admin'] = 'Admin: %s',
    ['chat_please_wait'] = 'An admin will handle your request',
    ['chat_unassigned'] = 'Ticket unassigned',
    ['chat_other_admin'] = 'Another admin will handle your request',
    
    -- Errors
    ['error_no_message'] = 'Please provide a message for your ticket!',
    ['error_max_tickets'] = 'You have already reached the maximum number of active tickets',
    
    -- Time Units
    ['seconds'] = 'seconds',
    ['minutes'] = 'minutes',
    ['hours'] = 'hours',
    
    -- UI Elements (Additional)
    ['ui_tickets'] = 'Tickets',
    ['ui_settings'] = 'Settings',
    ['ui_close'] = 'Close',
    ['ui_player'] = 'Player',
    ['ui_reason'] = 'Reason',
    ['ui_status'] = 'Status',
    ['ui_actions'] = 'Actions',
    ['ui_close_ticket'] = 'Close Ticket',
    ['ui_open'] = 'Open',
    ['ui_closed'] = 'Closed',
    ['ui_no_tickets'] = 'No active tickets available',

    -- Admin Mode
    ['noadmin_enabled'] = 'Admin mode disabled - You will no longer receive support notifications',
    ['noadmin_disabled'] = 'Admin mode enabled - You will now receive support notifications',
    ['noadmin_active'] = 'You cannot open the admin panel while admin mode is disabled',
} 