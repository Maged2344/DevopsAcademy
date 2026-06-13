// ===== Dark Mode Theme Manager =====
// Load in <head> on all pages. Applies saved theme immediately to prevent flash.

(function() {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'dark') {
        document.documentElement.classList.add('dark-mode');
    }
})();

function initThemeToggle() {
    const toggle = document.getElementById('themeToggle');
    if (!toggle) return;

    // Set initial icon
    const isDark = document.documentElement.classList.contains('dark-mode');
    toggle.textContent = isDark ? '\u2600\uFE0F' : '\uD83C\uDF19';

    toggle.addEventListener('click', () => {
        document.documentElement.classList.toggle('dark-mode');
        document.body.classList.toggle('dark-mode');
        const nowDark = document.documentElement.classList.contains('dark-mode');
        localStorage.setItem('theme', nowDark ? 'dark' : 'light');
        toggle.textContent = nowDark ? '\u2600\uFE0F' : '\uD83C\uDF19';
    });
}

document.addEventListener('DOMContentLoaded', () => {
    // Also apply to body once loaded
    if (localStorage.getItem('theme') === 'dark') {
        document.body.classList.add('dark-mode');
    }
    initThemeToggle();
});
