// ===== Navbar Scroll Effect =====
const navbar = document.getElementById('navbar');

window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }
});

// ===== Mobile Navigation =====
const navToggle = document.getElementById('navToggle');
const navLinks = document.getElementById('navLinks');

navToggle.addEventListener('click', () => {
    navLinks.classList.toggle('active');
});

// Close mobile nav when clicking a link
navLinks.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
        navLinks.classList.remove('active');
    });
});

// ===== Course Filter =====
const filterBtns = document.querySelectorAll('.filter-btn');
const courseCards = document.querySelectorAll('.course-card');

filterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        // Update active button
        filterBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        const filter = btn.dataset.filter;

        courseCards.forEach(card => {
            if (filter === 'all' || card.dataset.level === filter) {
                card.classList.remove('hidden');
            } else {
                card.classList.add('hidden');
            }
        });
    });
});

// ===== Auto-select course from URL parameter =====
(function() {
    const params = new URLSearchParams(window.location.search);
    const courseParam = params.get('course');
    if (courseParam) {
        const courseSelect = document.getElementById('course');
        if (courseSelect) {
            courseSelect.value = courseParam;
            const enrollSection = document.getElementById('enroll');
            if (enrollSection) {
                setTimeout(() => enrollSection.scrollIntoView({ behavior: 'smooth' }), 300);
            }
        }
    }
})();

// ===== Enroll buttons on course cards pre-select course =====
document.querySelectorAll('.btn-small[data-course]').forEach(btn => {
    btn.addEventListener('click', (e) => {
        e.preventDefault();
        const courseId = btn.dataset.course;
        const courseSelect = document.getElementById('course');
        if (courseSelect) {
            courseSelect.value = courseId;
        }
        const enrollSection = document.getElementById('enroll');
        if (enrollSection) {
            enrollSection.scrollIntoView({ behavior: 'smooth' });
        }
    });
});

// ===== Form Submission =====
const enrollForm = document.getElementById('enrollForm');

enrollForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    const formData = new FormData(enrollForm);
    const data = Object.fromEntries(formData.entries());

    // Basic validation
    if (!data.firstName || !data.lastName || !data.email || !data.phone || !data.course || !data.experience) {
        showNotification('Please fill in all required fields.', 'error');
        return;
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(data.email)) {
        showNotification('Please enter a valid email address.', 'error');
        return;
    }

    // Submit to backend API
    try {
        console.log('Submitting enrollment:', data);
        const res = await fetch('/api/enroll', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        console.log('Response status:', res.status);
        if (res.ok) {
            showNotification('Thank you! Your application has been submitted. We will contact you soon.', 'success');
            enrollForm.reset();
        } else {
            const err = await res.json();
            showNotification(err.error || 'Something went wrong. Please try again.', 'error');
        }
    } catch (err) {
        showNotification('Network error. Please try again later.', 'error');
    }
});

// ===== Notification System =====
function showNotification(message, type) {
    // Remove existing notifications
    const existing = document.querySelector('.notification');
    if (existing) existing.remove();

    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;

    // Style the notification
    Object.assign(notification.style, {
        position: 'fixed',
        top: '100px',
        right: '24px',
        padding: '16px 24px',
        borderRadius: '8px',
        color: '#fff',
        fontWeight: '500',
        zIndex: '9999',
        animation: 'fadeInUp 0.3s ease',
        maxWidth: '400px',
        boxShadow: '0 10px 25px rgba(0,0,0,0.2)'
    });

    notification.style.background = type === 'success' ? '#10b981' : '#ef4444';

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.style.opacity = '0';
        notification.style.transition = 'opacity 0.3s';
        setTimeout(() => notification.remove(), 300);
    }, 4000);
}

// ===== Scroll Reveal Animation =====
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observe elements for animation
document.querySelectorAll('.course-card, .feature-card, .instructor-card, .testimonial-card, .service-card').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// ===== Service request buttons pre-select service type =====
document.querySelectorAll('.btn-small[data-service]').forEach(btn => {
    btn.addEventListener('click', (e) => {
        e.preventDefault();
        const serviceType = btn.dataset.service;
        const svcSelect = document.getElementById('svcType');
        if (svcSelect) {
            svcSelect.value = serviceType;
        }
        const svcSection = document.getElementById('service-request');
        if (svcSection) {
            svcSection.scrollIntoView({ behavior: 'smooth' });
        }
    });
});

// ===== Service Request Form Submission =====
const serviceForm = document.getElementById('serviceForm');
if (serviceForm) {
    serviceForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const formData = new FormData(serviceForm);
        const data = Object.fromEntries(formData.entries());

        if (!data.name || !data.email || !data.phone || !data.serviceType || !data.description) {
            showNotification('Please fill in all required fields.', 'error');
            return;
        }

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(data.email)) {
            showNotification('Please enter a valid email address.', 'error');
            return;
        }

        try {
            const res = await fetch('/api/service-request', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            if (res.ok) {
                showNotification('Thank you! Your service request has been submitted. We will contact you within 24 hours.', 'success');
                serviceForm.reset();
            } else {
                const err = await res.json();
                showNotification(err.error || 'Something went wrong. Please try again.', 'error');
            }
        } catch (err) {
            showNotification('Network error. Please try again later.', 'error');
        }
    });
}

// ===== Smooth scroll for anchor links =====
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
    });
});
