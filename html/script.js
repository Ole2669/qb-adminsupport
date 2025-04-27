const adminPanel = document.getElementById('admin-panel');
const ticketsContainer = document.querySelector('.tickets-container');
const closeButton = document.getElementById('close-panel');

// Create audio element
const audioPlayer = document.createElement('audio');
document.body.appendChild(audioPlayer);

// Add ESC key handler at the start of the file
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closePanel();
    }
});

// Format timestamp
function formatTimestamp(timestamp) {
    const date = new Date(timestamp * 1000);
    return date.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' }) + ' Uhr';
}

// Update settings object
const settings = {
    soundEnabled: true,
    soundVolume: 50,
    accentColor: '#2196f3',
    autoAccept: true,
    autoWaypoint: true,
    confirmDelete: true
};

// Load settings from localStorage
function loadSettings() {
    const savedSettings = localStorage.getItem('adminPanelSettings');
    if (savedSettings) {
        Object.assign(settings, JSON.parse(savedSettings));
        
        // Apply saved settings to UI
        document.getElementById('sound-enabled').checked = settings.soundEnabled;
        document.getElementById('sound-volume').value = settings.soundVolume;
        document.getElementById('auto-accept').checked = settings.autoAccept;
        document.getElementById('auto-waypoint').checked = settings.autoWaypoint;
        document.getElementById('confirm-delete').checked = settings.confirmDelete;
        document.querySelector('.volume-value').textContent = `${settings.soundVolume}%`;
        
        // Apply saved color
        const colorOption = document.querySelector(`[data-color="${settings.accentColor}"]`);
        if (colorOption) {
            colorOption.classList.add('active');
        } else {
            // If it's a custom color
            document.getElementById('custom-color').value = settings.accentColor;
            document.querySelector('.custom-color-picker').classList.add('active');
        }
        applyAccentColor(settings.accentColor);
        
        // Update audio player volume
        audioPlayer.volume = settings.soundVolume / 100;
    }
}

// Save settings to localStorage
function saveSettings() {
    localStorage.setItem('adminPanelSettings', JSON.stringify(settings));
}

// Tab Management
function setupTabs() {
    const tabs = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            const targetTab = tab.getAttribute('data-tab');
            
            // Update active states
            tabs.forEach(t => t.classList.remove('active'));
            tabContents.forEach(content => content.classList.remove('active'));
            
            tab.classList.add('active');
            document.getElementById(`${targetTab}-tab`).classList.add('active');
        });
    });
}

// Apply accent color
function applyAccentColor(color) {
    document.documentElement.style.setProperty('--primary-color', color);
    document.documentElement.style.setProperty('--primary-hover', adjustColor(color, -20));
}

// Adjust color brightness
function adjustColor(color, amount) {
    const hex = color.replace('#', '');
    const r = Math.max(Math.min(parseInt(hex.substring(0, 2), 16) + amount, 255), 0);
    const g = Math.max(Math.min(parseInt(hex.substring(2, 4), 16) + amount, 255), 0);
    const b = Math.max(Math.min(parseInt(hex.substring(4, 6), 16) + amount, 255), 0);
    return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;
}

// Settings Event Listeners
function setupSettingsListeners() {
    // Sound toggle
    const soundToggle = document.getElementById('sound-enabled');
    soundToggle.addEventListener('change', (e) => {
        settings.soundEnabled = e.target.checked;
        saveSettings();
    });
    
    // Volume control
    const volumeSlider = document.getElementById('sound-volume');
    const volumeValue = document.querySelector('.volume-value');
    volumeSlider.addEventListener('input', (e) => {
        const value = e.target.value;
        settings.soundVolume = value;
        volumeValue.textContent = `${value}%`;
        audioPlayer.volume = value / 100;
        saveSettings();
    });

    // Auto accept toggle
    const autoAcceptToggle = document.getElementById('auto-accept');
    autoAcceptToggle.addEventListener('change', (e) => {
        settings.autoAccept = e.target.checked;
        saveSettings();
    });

    // Auto waypoint toggle
    const autoWaypointToggle = document.getElementById('auto-waypoint');
    autoWaypointToggle.addEventListener('change', (e) => {
        settings.autoWaypoint = e.target.checked;
        saveSettings();
    });

    // Confirm delete toggle
    const confirmDeleteToggle = document.getElementById('confirm-delete');
    confirmDeleteToggle.addEventListener('change', (e) => {
        settings.confirmDelete = e.target.checked;
        saveSettings();
    });

    // Color picker listeners
    const colorOptions = document.querySelectorAll('.color-option');
    const customColorPicker = document.querySelector('.custom-color-picker');
    const customColorInput = document.getElementById('custom-color');

    colorOptions.forEach(option => {
        option.addEventListener('click', () => {
            const color = option.getAttribute('data-color');
            colorOptions.forEach(opt => opt.classList.remove('active'));
            customColorPicker.classList.remove('active');
            option.classList.add('active');
            settings.accentColor = color;
            applyAccentColor(color);
            saveSettings();
        });
    });

    customColorInput.addEventListener('input', (e) => {
        const color = e.target.value;
        colorOptions.forEach(opt => opt.classList.remove('active'));
        customColorPicker.classList.add('active');
        settings.accentColor = color;
        applyAccentColor(color);
        saveSettings();
    });

    customColorInput.addEventListener('change', (e) => {
        const color = e.target.value;
        document.querySelector('.custom-color-btn').style.backgroundColor = color;
    });
}

// Custom confirmation dialog
function showConfirmDialog(message, onConfirm) {
    const dialog = document.getElementById('confirm-dialog');
    const dialogHeader = dialog.querySelector('.dialog-header h2');
    const content = dialog.querySelector('.dialog-content');
    const confirmBtn = document.getElementById('dialog-confirm');
    const cancelBtn = document.getElementById('dialog-cancel');
    
    // Set translated text
    dialogHeader.textContent = T('confirmation');
    content.textContent = T('confirm_delete_msg');
    cancelBtn.innerHTML = `<i class="fas fa-times"></i> ${T('cancel')}`;
    confirmBtn.innerHTML = `<i class="fas fa-trash-alt"></i> ${T('delete')}`;
    
    // Show dialog
    dialog.classList.remove('hidden');
    
    // Handle confirm
    const handleConfirm = () => {
        dialog.classList.add('hidden');
        confirmBtn.removeEventListener('click', handleConfirm);
        cancelBtn.removeEventListener('click', handleCancel);
        document.removeEventListener('keydown', handleKeydown);
        onConfirm();
    };
    
    // Handle cancel
    const handleCancel = () => {
        dialog.classList.add('hidden');
        confirmBtn.removeEventListener('click', handleConfirm);
        cancelBtn.removeEventListener('click', handleCancel);
        document.removeEventListener('keydown', handleKeydown);
    };
    
    // Handle keydown
    const handleKeydown = (e) => {
        if (e.key === 'Escape') {
            handleCancel();
        } else if (e.key === 'Enter') {
            handleConfirm();
        }
    };
    
    // Add event listeners
    confirmBtn.addEventListener('click', handleConfirm);
    cancelBtn.addEventListener('click', handleCancel);
    document.addEventListener('keydown', handleKeydown);
}

// Update handle ticket function to use custom dialog
function handleTicket(ticketId, action) {
    if (!ticketId) {
        return;
    }

    if (action === 'delete' && settings.confirmDelete) {
        showConfirmDialog('Möchtest du dieses Ticket wirklich löschen?', () => {
            sendTicketAction(ticketId, action);
        });
        return;
    }

    if (action === 'tp' && settings.autoAccept) {
        // Also accept the ticket when teleporting
        sendTicketAction(ticketId, 'accept');
    }

    if (action === 'accept' && settings.autoWaypoint) {
        // Set waypoint when accepting
        sendTicketAction(ticketId, 'waypoint');
    }

    // Send the original action
    sendTicketAction(ticketId, action);
}

// Helper function to send ticket actions to the server
function sendTicketAction(ticketId, action) {
    const endpoint = action === 'tp' ? 'teleportToTicket' :
                    action === 'waypoint' ? 'setWaypoint' : 'handleTicket';
    
    fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            ticketId: ticketId,
            action: action === 'tp' || action === 'waypoint' ? undefined : action
        })
    });
}

// Update play sound function to respect notification settings
function playNotificationSound(soundFile) {
    if (!settings.soundEnabled) return;
    
    audioPlayer.src = `../audio/${soundFile}`;
    audioPlayer.volume = settings.soundVolume / 100;
    audioPlayer.play();
}

// Copy helper function
function copyToClipboard(text, button) {
    // Create temporary input element
    const input = document.createElement('input');
    input.style.position = 'fixed';
    input.style.opacity = 0;
    input.value = text;
    document.body.appendChild(input);
    
    // Select and copy
    input.select();
    document.execCommand('copy');
    document.body.removeChild(input);
    
    // Update icon
    const icon = button.querySelector('i');
    icon.classList.remove('fa-copy');
    icon.classList.add('fa-check');
    
    // Reset after 1 second
    setTimeout(() => {
        icon.classList.remove('fa-check');
        icon.classList.add('fa-copy');
    }, 1000);
}

// Translation function and data
let currentLanguage = 'de';
let translations = {};

// Update the message event listener
window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'openAdminPanel') {
        adminPanel.classList.remove('hidden');
        translations = data.translations || {};
        updateUITranslations();
        updateTickets(data.tickets);
    } else if (data.action === 'updateTickets') {
        updateTickets(data.tickets);
    } else if (data.action === 'playSound') {
        playNotificationSound(data.file);
    }
});

// Initialize translations
function initTranslations() {
    fetch(`https://${GetParentResourceName()}/getTranslations`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(data => {
        translations = data;
        updateUITranslations();
    });
}

// Translation helper function
function T(key) {
    return translations[key] || key;
}

// Update UI translations
function updateUITranslations() {
    // Panel header
    document.getElementById('panel-title').textContent = T('support_panel');
    
    // Tabs
    document.querySelector('[data-tab="tickets"] .tab-text').textContent = T('ui_tickets');
    document.querySelector('[data-tab="settings"] .tab-text').textContent = T('ui_settings');
    
    // No tickets message
    const noTicketsSpan = document.querySelector('.no-tickets span');
    if (noTicketsSpan) {
        noTicketsSpan.textContent = T('ui_no_tickets');
    }
    
    // Settings sections
    document.querySelectorAll('.settings-title').forEach(title => {
        if (title.textContent === 'Notifications') title.textContent = T('notifications');
        if (title.textContent === 'Appearance') title.textContent = T('appearance');
        if (title.textContent === 'Ticket Management') title.textContent = T('ticket_management');
    });
    
    // Settings labels
    document.querySelectorAll('.setting-label').forEach(label => {
        if (label.textContent === 'Enable sound') label.textContent = T('enable_sound');
        if (label.textContent === 'Volume') label.textContent = T('volume');
        if (label.textContent === 'Accent color') label.textContent = T('accent_color');
        if (label.textContent === 'Auto accept when teleporting') label.textContent = T('auto_accept_tp');
        if (label.textContent === 'Auto set waypoint on accept') label.textContent = T('auto_waypoint');
        if (label.textContent === 'Confirm deletion') label.textContent = T('confirm_delete');
    });
}

// Create ticket element
function createTicketElement(ticket) {
    const ticketElement = document.createElement('div');
    ticketElement.className = 'ticket';
    ticketElement.setAttribute('data-ticket-id', ticket.id);

    const handleTicketAction = (action) => {
        const ticketId = ticketElement.getAttribute('data-ticket-id');
        handleTicket(ticketId, action);
    };

    ticketElement.innerHTML = `
        <div class="ticket-header">
            <span class="ticket-id"><i class="fas fa-ticket-alt"></i> #${ticket.id}</span>
            <span class="status-${ticket.status}">
                <i class="fas ${ticket.status === 'pending' ? 'fa-clock' : 'fa-check-circle'}"></i>
                ${T(ticket.status === 'pending' ? 'pending' : 'accepted')}
            </span>
        </div>
        <div class="info-cards">
            <div class="info-card">
                <i class="fas fa-user"></i>
                <div class="info-content">
                    <span class="info-label">${T('player')}</span>
                    <div class="info-value-container">
                        <span class="info-value">${ticket.name}</span>
                        <button class="copy-btn" onclick="copyToClipboard('${ticket.name}', this)" type="button">
                            <i class="fas fa-copy fa-xs"></i>
                        </button>
                    </div>
                    <div class="info-value-container">
                        <span class="info-value citizen-id">ID: ${ticket.citizenid}</span>
                        <button class="copy-btn" onclick="copyToClipboard('${ticket.citizenid}', this)" type="button">
                            <i class="fas fa-copy fa-xs"></i>
                        </button>
                    </div>
                </div>
            </div>
            <div class="info-card">
                <i class="fas fa-clock"></i>
                <div class="info-content">
                    <span class="info-label">${T('time')}</span>
                    <span class="info-value">${formatTimestamp(ticket.timestamp)}</span>
                </div>
            </div>
            <div class="info-card ${!ticket.assignedTo ? 'not-assigned' : ''}">
                <i class="fas fa-user-shield"></i>
                <div class="info-content">
                    <span class="info-label">${T('assigned_to')}</span>
                    <span class="info-value">${ticket.assignedTo || T('not_assigned')}</span>
                </div>
            </div>
        </div>
        <div class="ticket-message">
            <i class="fas fa-comment"></i> ${ticket.message}
        </div>
        <div class="ticket-actions">
            ${ticket.status === 'pending' ? `
                <button class="btn btn-accept" data-action="accept">
                    <i class="fas fa-check"></i> ${T('accept')}
                </button>
            ` : `
                <button class="btn btn-unassign" data-action="unassign">
                    <i class="fas fa-user-minus"></i> ${T('unassign')}
                </button>
            `}
            <button class="btn btn-tp" data-action="tp">
                <i class="fas fa-location-arrow"></i> ${T('teleport')}
            </button>
            <button class="btn btn-waypoint" data-action="waypoint">
                <i class="fas fa-map-marker-alt"></i> ${T('waypoint')}
            </button>
            <button class="btn btn-delete" data-action="delete">
                <i class="fas fa-trash-alt"></i> ${T('delete')}
            </button>
        </div>
    `;

    // Add click handlers to all action buttons
    ticketElement.querySelectorAll('[data-action]').forEach(button => {
        button.addEventListener('click', () => {
            handleTicketAction(button.getAttribute('data-action'));
        });
    });

    return ticketElement;
}

// Update tickets in the panel
function updateTickets(tickets) {
    const ticketArray = Object.values(tickets);
    
    // Clear existing tickets but keep the no-tickets message
    const existingTickets = ticketsContainer.querySelectorAll('.ticket');
    existingTickets.forEach(ticket => ticket.remove());
    
    if (ticketArray.length === 0) {
        // If no tickets and no message div exists, create it
        let noTicketsDiv = ticketsContainer.querySelector('.no-tickets');
        if (!noTicketsDiv) {
            noTicketsDiv = document.createElement('div');
            noTicketsDiv.className = 'no-tickets';
            noTicketsDiv.innerHTML = `
                <i class="fas fa-ticket-alt"></i>
                <span>${T('ui_no_tickets')}</span>
            `;
            ticketsContainer.appendChild(noTicketsDiv);
        }
        noTicketsDiv.style.display = 'flex';
    } else {
        // Hide no tickets message if it exists
        const noTicketsDiv = ticketsContainer.querySelector('.no-tickets');
        if (noTicketsDiv) {
            noTicketsDiv.style.display = 'none';
        }
        
        // Add tickets
        ticketArray.forEach(ticket => {
            ticketsContainer.appendChild(createTicketElement(ticket));
        });
    }
}

// Separate the close panel logic into its own function
function closePanel() {
    adminPanel.classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closePanel`, {
        method: 'POST'
    });
}

// Update the close button event listener to use the new function
closeButton.addEventListener('click', closePanel);

// Initialize translations when the script loads
document.addEventListener('DOMContentLoaded', () => {
    initTranslations();
    setupTabs();
    setupSettingsListeners();
    loadSettings();
}); 