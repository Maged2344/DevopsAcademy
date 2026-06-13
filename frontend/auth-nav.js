// ===== Shared Auth Navigation Helper =====
// Include this in all pages to show/hide auth buttons based on login state

const studentTokenKey = 'studentToken';

function initAuthNav() {
    const navLinks = document.getElementById('navLinks');
    if (!navLinks) return;

    const token = localStorage.getItem(studentTokenKey);
    const authButtonContainer = navLinks.querySelector('.auth-buttons');
    
    if (!authButtonContainer) return;

    if (token) {
        // User is signed in - show My Portal and Logout
        authButtonContainer.innerHTML = `
            <li><a href="/portal.html" class="btn btn-small">My Portal</a></li>
            <li><a href="javascript:void(0);" onclick="logoutStudent()" class="btn btn-small btn-outline">Logout</a></li>
        `;
    } else {
        // User not signed in - show Register and Sign In
        authButtonContainer.innerHTML = `
            <li><a href="/portal.html?tab=signup" class="btn btn-small btn-outline">Register</a></li>
            <li><a href="/portal.html?tab=signin" class="btn btn-small">Sign In</a></li>
        `;
    }
}

function logoutStudent() {
    if (confirm('Are you sure you want to log out?')) {
        localStorage.removeItem(studentTokenKey);
        window.location.href = '/';
    }
}

// Initialize on page load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAuthNav);
} else {
    initAuthNav();
}

// Re-check auth state when page becomes visible (after tab switch)
document.addEventListener('visibilitychange', () => {
    if (!document.hidden) {
        initAuthNav();
    }
});
