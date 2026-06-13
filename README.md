# DevOps Academy Egypt — Website Guide

A static website for DevOps Academy Egypt built with plain HTML, CSS, and JavaScript. This document explains how the site works and how to edit its content.

---

## File Structure

```
DevopsAcademy/
├── index.html   — All page content (courses, instructors, testimonials, forms, etc.)
├── styles.css   — All styling, colors, responsive layout, and animations
├── script.js    — Interactivity: navbar, course filter, form validation, scroll animations
├── logo.png     — Logo image used in the navbar and footer
├── cover.png    — Hero section background image
└── README.md    — This file
```

Everything is in `index.html`. There is no backend — the site is fully static.

---

## How the Site Works

### Sections (in order)

| Section | HTML id | What it does |
|---|---|---|
| Navigation | `#navbar` | Top nav bar with links. Shrinks on scroll, has a hamburger menu on mobile. |
| Hero | `#home` | Landing area with headline, stats (graduates, job placement, etc.), and CTA buttons. |
| Courses | `#courses` | Grid of course cards with filter buttons (All / Beginner / Intermediate / Advanced). |
| Why Us | `#why-us` | Six feature cards (Expert Instructors, Hands-On Labs, etc.). |
| Instructors | `#instructors` | Instructor profile cards with name, role, and bio. |
| Testimonials | `#testimonials` | Student review cards. |
| Enrollment | `#enroll` | Application form (client-side only — no data is sent to a server). |
| Contact | `#contact` | Address, email, phone, working hours, and map placeholder. |
| Footer | `.footer` | Brand info, quick links, course links, social links, copyright. |

### JavaScript Features (`script.js`)

- **Navbar scroll effect** — Adds a `scrolled` class when the user scrolls past 50px.
- **Mobile nav toggle** — Opens/closes the nav menu on small screens.
- **Course filter** — Filter buttons use `data-filter` on buttons and `data-level` on cards to show/hide courses.
- **Form validation** — Checks required fields and email format on submit, then shows a success/error notification. **No data is sent anywhere** — the form just resets after "submission".
- **Scroll reveal** — Cards fade in when they scroll into view using `IntersectionObserver`.
- **Smooth scroll** — All anchor links (`href="#..."`) scroll smoothly to their target section.

---

## How to Edit Content

### Change a Course Price

Find the course in `index.html` inside the `<section class="courses">` block. Each course is a `<div class="course-card">`. The price is in:

```html
<div class="course-price">
    <span class="price">EGP 3,500</span>   <!-- change this value -->
    <a href="#enroll" class="btn btn-small">Enroll</a>
</div>
```

Just update the text inside `<span class="price">`.

### Add a New Course

Copy an existing `<div class="course-card">...</div>` block inside `<div class="courses-grid">` and edit the values:

```html
<div class="course-card" data-level="beginner">       <!-- set level: beginner, intermediate, or advanced -->
    <div class="course-badge beginner">Beginner</div>  <!-- match the level + CSS class -->
    <div class="course-icon">&#128187;</div>            <!-- emoji or icon -->
    <h3>Course Name</h3>
    <p>Course description goes here.</p>
    <div class="course-meta">
        <span>&#128336; 4 Weeks</span>                  <!-- duration -->
        <span>&#128218; 20 Lessons</span>               <!-- lesson count -->
    </div>
    <div class="course-price">
        <span class="price">EGP 3,500</span>           <!-- price -->
        <a href="#enroll" class="btn btn-small">Enroll</a>
    </div>
</div>
```

**Important:** Also add the new course to the enrollment form dropdown so users can select it:

```html
<select id="course" name="course" required>
    <option value="">Select a course...</option>
    <!-- add a new option here -->
    <option value="your-course">Your Course Name</option>
</select>
```

And optionally add it to the footer course links list.

### Remove a Course

Delete the entire `<div class="course-card">...</div>` block for that course. Also remove its `<option>` from the enrollment form dropdown.

### Change the Course Filter Levels

The filter buttons are in `index.html`:

```html
<div class="course-filters">
    <button class="filter-btn active" data-filter="all">All</button>
    <button class="filter-btn" data-filter="beginner">Beginner</button>
    <button class="filter-btn" data-filter="intermediate">Intermediate</button>
    <button class="filter-btn" data-filter="advanced">Advanced</button>
</div>
```

The `data-filter` value must match the `data-level` on the course cards. To add a new level (e.g., "expert"), add a button with `data-filter="expert"` and set `data-level="expert"` on the relevant course cards. The JS in `script.js` handles it automatically.

### Edit Hero Stats (Graduates, Job Placement, etc.)

In the `<section class="hero">` block, find:

```html
<div class="hero-stats">
    <div class="stat">
        <span class="stat-number">2000+</span>    <!-- change the number -->
        <span class="stat-label">Graduates</span>  <!-- change the label -->
    </div>
    ...
</div>
```

### Add or Edit an Instructor

Instructor cards are in `<section class="instructors">`. Each card:

```html
<div class="instructor-card">
    <div class="instructor-avatar">AH</div>              <!-- initials -->
    <h3>Ahmed Hassan</h3>                                  <!-- name -->
    <p class="instructor-role">Senior DevOps Engineer</p>  <!-- title -->
    <p class="instructor-bio">15 years experience...</p>   <!-- bio -->
</div>
```

Copy/paste the block to add a new instructor, or edit the text to update one.

### Add or Edit a Testimonial

Testimonial cards are in `<section class="testimonials">`:

```html
<div class="testimonial-card">
    <div class="stars">&#9733;&#9733;&#9733;&#9733;&#9733;</div>  <!-- 5 stars -->
    <p>"Quote from the student."</p>
    <div class="testimonial-author">
        <strong>Student Name</strong>
        <span>Job Title at Company</span>
    </div>
</div>
```

### Change Contact Information

In `<section class="contact">`, update the text inside each `.contact-item`:

```html
<div class="contact-item">
    <span class="contact-icon">&#128231;</span>
    <div>
        <strong>Email</strong>
        <p>info@devopsacademy.eg</p>   <!-- change here -->
    </div>
</div>
```

### Change Social Media Links

In the `<footer>`, update the `href` values:

```html
<div class="social-links">
    <a href="#" aria-label="Facebook">FB</a>    <!-- replace # with your URL -->
    <a href="#" aria-label="LinkedIn">LI</a>
    <a href="#" aria-label="Twitter">TW</a>
    <a href="#" aria-label="YouTube">YT</a>
</div>
```

### Change the Logo or Cover Image

Replace `logo.png` or `cover.png` in the project folder with your new image (keep the same filename). The logo is used in the navbar and footer. The cover image is the hero section background.

---

## Styling

All styles are in `styles.css`. Key things to know:

### Colors

The site uses CSS variables defined at the top of `styles.css`:

```css
:root {
    --primary: #1e40af;        /* main blue */
    --primary-light: #3b82f6;  /* lighter blue */
    --accent: #f59e0b;         /* gold/amber accent */
    --dark: #0f172a;           /* dark background */
    --success: #10b981;        /* green for success messages */
}
```

Change these values to restyle the entire site at once.

### Fonts

The site loads **Cairo** (for headings) and **Inter** (for body text) from Google Fonts via the `<link>` tag in `index.html`. To change fonts, update the Google Fonts URL and the `font-family` rules in `styles.css`.

### Responsive Design

The layout is responsive using CSS Grid and media queries in `styles.css`. Course cards, feature cards, and other grids automatically adjust from multi-column to single-column on smaller screens.

---

## Making the Form Actually Work

Currently the enrollment form only validates and shows a notification — it doesn't send data anywhere. To connect it to a real backend:

1. **Option A — Form service:** Use a service like Formspree, Netlify Forms, or Google Forms. Set the form `action` attribute and method to `POST`.
2. **Option B — Custom backend:** In `script.js`, replace the `enrollForm.addEventListener('submit', ...)` handler to send a `fetch()` request to your API endpoint instead of just resetting the form.

---

## Running Locally

Open `index.html` directly in a browser, or use a local server:

```bash
# Python
python -m http.server 8000

# Node.js
npx serve .
```

Then open `http://localhost:8000`.
