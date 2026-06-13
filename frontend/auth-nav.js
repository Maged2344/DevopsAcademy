// ===== Shared Auth Navigation Helper =====
// Loaded in <head> so initAuthNav() is available to inline scripts on all pages.
// Runs automatically on DOMContentLoaded and can be called manually after login/logout.

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
            <a href="javascript:void(0);" class="btn btn-small btn-outline" id="navLogoutBtn">Logout</a>
        `;
        document.getElementById('navLogoutBtn').addEventListener('click', logoutStudent);
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

// Run when DOM is ready
document.addEventListener('DOMContentLoaded', initAuthNav);
