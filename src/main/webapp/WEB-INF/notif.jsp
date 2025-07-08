<script>
 // Notification function
    function showNotification(type, message) {
        const container = document.getElementById('notificationContainer');
        const notification = document.createElement('div');
        
        // Determine icon and title based on type
        let iconClass, title;
        if (type === 'success') {
            iconClass = 'fa-check-circle';
            title = 'Success!';
        } else if (type === 'error') {
            iconClass = 'fa-exclamation-circle';
            title = 'Error!';
        } else {
            iconClass = 'fa-info-circle';
            title = 'Notice!';
        }
        
        // Build notification HTML
        notification.className = 'notification notification-' + type;
        
        // Add refresh button for success notifications
        const refreshButton = type === 'success' ? 
            '<button class="btn-refresh" style="' +
                'background: rgba(0, 86, 179, 0.1);' +
                'border: none;' +
                'margin-left: 15px;' +
                'padding: 8px 15px;' +
                'border-radius: 6px;' +
                'cursor: pointer;' +
                'color: var(--primary-dark);' +
                'font-weight: 600;' +
            '">' +
                '<i class="fas fa-sync-alt"></i> Refresh' +
            '</button>' : '';
        
        notification.innerHTML = 
            '<i class="fas ' + iconClass + '" style="font-size: 1.5rem; margin-right: 15px;"></i>' +
            '<div style="flex-grow: 1;">' +
                '<strong>' + title + '</strong> ' + 
                escapeHtml(message) +
            '</div>' +
            refreshButton +
            '<button class="notification-close" style="' +
                'background: none;' +
                'border: none;' +
                'margin-left: 15px;' +
                'cursor: pointer;' +
                'color: inherit;' +
            '">' +
                '<i class="fas fa-times"></i>' +
            '</button>';
        
        // Prepend to show newest on top
        container.insertBefore(notification, container.firstChild);
        
        // Auto-remove after 8 seconds (longer for success messages)
        const removeTimeout = setTimeout(() => {
            notification.style.animation = 'fadeOut 0.5s forwards';
            setTimeout(() => notification.remove(), 500);
        }, type === 'success' ? 8000 : 5000);
        
        // Manual close
        notification.querySelector('.notification-close').addEventListener('click', () => {
            clearTimeout(removeTimeout);
            notification.style.animation = 'fadeOut 0.3s forwards';
            setTimeout(() => notification.remove(), 300);
        });
        
        // Add refresh functionality for success notifications
        if (type === 'success') {
            notification.querySelector('.btn-refresh').addEventListener('click', () => {
                location.reload();
            });
        }
    }
    
    // Helper function to escape HTML special characters
    function escapeHtml(unsafe) {
        return unsafe
             .replace(/&/g, "&amp;")
             .replace(/</g, "&lt;")
             .replace(/>/g, "&gt;")
             .replace(/"/g, "&quot;")
             .replace(/'/g, "&#039;");
    }
    
 
    
    
    // Check for URL parameters to show notifications
    document.addEventListener('DOMContentLoaded', function() {
        const urlParams = new URLSearchParams(window.location.search);
        const success = urlParams.get('success');
        const error = urlParams.get('error');
        
        if (success) {
            showNotification('success', success);
        }
        
        if (error) {
            showNotification('error', error);
            
        }
    });
    </script>