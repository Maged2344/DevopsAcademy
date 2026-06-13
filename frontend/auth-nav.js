// ===== Shared Auth Navigation Helper =====
// Include this in all pages to show/hide auth buttons based on login state

const studentTokenKey = 'studentToken';

function initAuthNav() {
    const navLinks = document.getElementById('navLinks');
    if (!navLinks) return;

    const token = localStorage.getItem(studentTokenKey);
    const authButtonsLi = navLinks.querySelector('li.auth-buttons');
    
    if (!authButtonsLi) return;

    if (token) {
        // User is signed in - show My Portal and Logout
        authButtonsLi.innerHTML = `
            <a href="/portal.html" class="btn btn-small">My Portal</a>
            <a href="javascript:void(0);" onclick="logoutStudent()" class="btn btn-small btn-outline">Logout</a>
        `;
    } else {
        // User not signed in - show Register and Sign In
        authButtonsLi.innerHTML = `
            <a href="/portal.html?tab=signup" class="btn btn-small btn-outline">Register</a>
            <a href="/portal.html?tab=signin" class="btn btn-small">Sign In</a>
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
