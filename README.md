# DevOps Academy Egypt

> Full-stack web application for DevOps Academy Egypt — a training platform offering DevOps engineering courses. Built with HTML/CSS/JS frontend, Node.js/Express/MongoDB backend, Dockerized deployment, and automated CI/CD via Jenkins.

**Live Site:** [https://devopsacademy.cloud-stacks.com](https://devopsacademy.cloud-stacks.com)

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Frontend](#frontend)
- [Backend API](#backend-api)
- [Database](#database)
- [Docker Setup](#docker-setup)
- [Nginx Configuration](#nginx-configuration)
- [CI/CD Pipeline](#cicd-pipeline)
- [Infrastructure](#infrastructure)
- [Local Development](#local-development)
- [Deployment](#deployment)
- [Admin Panel](#admin-panel)
- [Environment Variables](#environment-variables)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Azure VM (Ubuntu)                            │
│                         20.25.62.124                                 │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                    Docker Compose                               │ │
│  │                                                                 │ │
│  │  ┌─────────────┐    ┌──────────────┐    ┌──────────────────┐  │ │
│  │  │   Nginx     │    │   Backend    │    │     MongoDB      │  │ │
│  │  │  (web)      │───▶│  (Node.js)   │───▶│    (mongo:7)     │  │ │
│  │  │  :80/:443   │    │   :3000      │    │    :27017        │  │ │
│  │  └─────────────┘    └──────────────┘    └──────────────────┘  │ │
│  │        │                                        │              │ │
│  │        │ SSL (Let's Encrypt)                    │ Volume       │ │
│  │        ▼                                        ▼              │ │
│  │   /ssl/fullchain.pem                      mongo_data           │ │
│  │   /ssl/privkey.pem                                             │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌──────────────┐                                                   │
│  │   Jenkins    │  Polls GitHub → builds → deploys                  │
│  │   :8080      │                                                   │
│  └──────────────┘                                                   │
└─────────────────────────────────────────────────────────────────────┘
         ▲
         │ DNS (Cloudflare A Record)
         │
   devopsacademy.cloud-stacks.com
```

---

## Project Structure

```
DevopsAcademy/
├── index.html              # Main landing page (courses, enrollment form, etc.)
├── course.html             # Dynamic course detail page (loaded via ?id=<course>)
├── admin.html              # Admin dashboard (login, manage enrollments)
├── styles.css              # All CSS (responsive, animations, components)
├── script.js               # Frontend JS (nav, filters, form submission, animations)
├── logo.png                # Site logo
├── cover.png               # Hero background image
│
├── backend/                # Express.js API server
│   ├── server.js           # API routes, MongoDB models, auth middleware
│   ├── package.json        # Node.js dependencies
│   └── Dockerfile          # Backend container (node:20-alpine)
│
├── nginx.conf              # Nginx config (SSL, reverse proxy, caching rules)
├── Dockerfile              # Frontend container (nginx:alpine)
├── docker-compose.yml      # Multi-service orchestration (web + backend + mongo)
│
├── Jenkinsfile             # CI/CD pipeline definition
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions (alternative deploy via Docker Hub)
│
├── .gitignore              # Ignored files (keys, PDFs, node_modules, ssl)
└── README.md               # This file
```

---

## Tech Stack

| Layer         | Technology                                      |
|---------------|------------------------------------------------|
| Frontend      | HTML5, CSS3, Vanilla JavaScript                |
| Backend       | Node.js 20, Express.js 4                       |
| Database      | MongoDB 7                                      |
| Web Server    | Nginx (Alpine)                                 |
| Containers    | Docker, Docker Compose                         |
| CI/CD         | Jenkins (primary), GitHub Actions (secondary)  |
| SSL           | Let's Encrypt (auto-renewed)                   |
| DNS/CDN       | Cloudflare                                     |
| Cloud         | Azure Virtual Machine (Ubuntu)                 |
| Auth          | JWT (jsonwebtoken) + bcryptjs                  |

---

## Frontend

### Pages

| Page | URL | Description |
|------|-----|-------------|
| Landing | `/` | Hero, courses grid, instructors, testimonials, enrollment form, contact |
| Course Detail | `/course.html?id=<courseId>` | Full course curriculum, sidebar info, roadmap (DevOps) |
| Admin | `/admin.html` | Protected dashboard to manage enrollment applications |

### Main Page Sections (`index.html`)

1. **Navigation** — Sticky navbar with scroll shrink effect and mobile hamburger menu
2. **Hero** — Headline, animated stats counters, CTA buttons
3. **Courses** — Filterable grid (All/Beginner/Intermediate/Advanced), clickable cards
4. **Featured Program** — Full-width DevOps Engineering card at top of grid
5. **Why Us** — Feature cards (Expert Instructors, Hands-On Labs, etc.)
6. **Instructors** — Profile cards with names and bios
7. **Testimonials** — Student review cards
8. **Enrollment Form** — Submits to `/api/enroll` backend endpoint
9. **Contact** — Address, email, phone, working hours
10. **Footer** — Links, social icons, copyright

### Course Detail Page (`course.html`)

Dynamic single page that renders course content based on URL parameter `?id=`:

**Available courses:** `devops`, `linux`, `docker`, `kubernetes`, `cicd`, `aws`, `terraform`, `git`, `devsecops`, `monitoring`

- Shows course description, duration, hours, sessions count
- Detailed curriculum with topic lists per module
- Sidebar with pricing and enrollment button
- DevOps course includes an interactive visual roadmap (8 phases)

### JavaScript Features (`script.js`)

- **Navbar scroll effect** — Adds `scrolled` class after 50px scroll
- **Mobile nav toggle** — Hamburger menu for small screens
- **Course filter** — Buttons use `data-filter` ↔ `data-level` on cards
- **Form submission** — Validates fields then `POST /api/enroll`
- **Scroll reveal** — Cards fade in via `IntersectionObserver`
- **Smooth scroll** — All anchor links scroll smoothly to target

### CSS Variables (`styles.css`)

```css
:root {
    --primary: #1e40af;        /* main blue */
    --primary-light: #3b82f6;  /* lighter blue */
    --accent: #f59e0b;         /* gold/amber accent */
    --dark: #0f172a;           /* dark background */
    --success: #10b981;        /* green for success */
}
```

Fonts: **Cairo** (headings) + **Inter** (body) from Google Fonts.

---

## Backend API

**Location:** `backend/server.js`  
**Runtime:** Node.js 20 (Alpine container)  
**Port:** 3000 (internal, proxied through Nginx)

### Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/api/enroll` | Public | Submit enrollment application |
| `POST` | `/api/admin/login` | Public | Admin login → returns JWT |
| `GET` | `/api/admin/enrollments` | JWT | List enrollments (filter: `?status=`, `?course=`) |
| `GET` | `/api/admin/stats` | JWT | Enrollment counts by status |
| `PATCH` | `/api/admin/enrollments/:id` | JWT | Update enrollment status |
| `DELETE` | `/api/admin/enrollments/:id` | JWT | Delete enrollment |

### Authentication Flow

1. `POST /api/admin/login` with `{ username, password }`
2. Server validates against bcrypt hash in MongoDB
3. Returns JWT token (24h expiry)
4. Client sends `Authorization: Bearer <token>` on protected routes
5. `authMiddleware` verifies and decodes token

### Data Models

**Enrollment:**
```json
{
  "firstName": "String (required)",
  "lastName": "String (required)",
  "email": "String (required)",
  "phone": "String (required)",
  "course": "String (required)",
  "experience": "String (required)",
  "message": "String (optional)",
  "status": "pending | approved | rejected",
  "createdAt": "Date (auto)"
}
```

**Admin:**
```json
{
  "username": "String (unique, required)",
  "password": "String (bcrypt hashed)"
}
```

### Default Admin Account

On first startup (empty admin collection), auto-creates:
- **Username:** `admin`
- **Password:** `admin123`

---

## Database

| Property | Value |
|----------|-------|
| Engine | MongoDB 7 |
| Container | `devopsacademy-mongo` |
| Port | 27017 (internal only) |
| Volume | `mongo_data` (persistent) |
| Collections | `enrollments`, `admins` |

---

## Docker Setup

### Services (`docker-compose.yml`)

| Service | Image | Ports | Purpose |
|---------|-------|-------|---------|
| `web` | `./Dockerfile` (nginx:alpine) | 80, 443 | Frontend + reverse proxy |
| `backend` | `./backend/Dockerfile` (node:20-alpine) | 3000 (internal) | API server |
| `mongo` | `mongo:7` | 27017 (internal) | Database |

### Frontend Dockerfile

```dockerfile
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY index.html admin.html course.html styles.css script.js logo.png /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 443
```

### Backend Dockerfile

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package.json ./
RUN npm install --production
COPY server.js ./
EXPOSE 3000
CMD ["node", "server.js"]
```

### Volumes & Mounts

| Volume | Path | Purpose |
|--------|------|---------|
| `mongo_data` | `/data/db` | Persistent database storage |
| Bind mount | `/home/maged/devopsacademy/ssl` → `/etc/nginx/ssl:ro` | SSL certificates |

---

## Nginx Configuration

**File:** `nginx.conf`

### Routing

| Route | Behavior |
|-------|----------|
| `:80` (HTTP) | 301 redirect → HTTPS |
| `:443` (HTTPS) | SSL termination (TLS 1.2/1.3) |
| `/api/*` | Reverse proxy → `backend:3000` (no-cache) |
| `/` | Serve static HTML (`try_files`) |
| `*.css, *.js` | No-cache (latest version on deploy) |
| `*.png, *.jpg` | 1-day browser cache |

### Security Headers

```
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

---

## CI/CD Pipeline

### Jenkins (Primary)

**File:** `Jenkinsfile`  
**URL:** `http://20.25.62.124:8080`  
**Trigger:** SCM polling every minute

```
GitHub Push → Jenkins detects (1 min) → Clone → Build → Deploy → Live
```

**Stages:**

1. **Clone Repository** — Pulls `main` branch from GitHub
2. **Build Docker Image** — `docker compose build`
3. **Deploy** — Copies files to `/home/maged/devopsacademy/`, runs:
   ```bash
   docker compose down
   docker compose build --no-cache
   docker compose up -d
   docker image prune -f
   ```

### GitHub Actions (Secondary)

**File:** `.github/workflows/deploy.yml`  
**Trigger:** Manual (`workflow_dispatch`)

1. Builds and pushes to Docker Hub (`magedmohamed/devopsacademy:latest`)
2. SSHs into Azure VM → `docker compose pull && up -d`

---

## Infrastructure

### Azure VM

| Property | Value |
|----------|-------|
| Public IP | `20.25.62.124` |
| OS | Ubuntu Noble |
| User | `maged` |
| Deploy directory | `/home/maged/devopsacademy/` |
| SSL certificates | `/home/maged/devopsacademy/ssl/` |

### DNS

- **Provider:** Cloudflare
- **Record:** A `devopsacademy.cloud-stacks.com` → `20.25.62.124`

### SSL/TLS

- **Provider:** Let's Encrypt
- **Certificate:** `ssl/fullchain.pem`
- **Private Key:** `ssl/privkey.pem`
- **Protocols:** TLS 1.2, TLS 1.3

---

## Local Development

### Prerequisites

- Docker & Docker Compose
- Git

### Quick Start

```bash
git clone https://github.com/Maged2344/DevopsAcademy.git
cd DevopsAcademy
docker compose up --build
# Visit http://localhost
```

### Backend Only (without Docker)

```bash
cd backend
npm install

# Requires MongoDB running locally
MONGO_URI=mongodb://localhost:27017/devopsacademy node server.js
# API available at http://localhost:3000
```

### Frontend Only

Open `index.html` in a browser, or:
```bash
npx serve .
# Visit http://localhost:3000
```

> Note: Form submission won't work without the backend running.

---

## Deployment

### Automatic (Recommended)

1. Commit and push to `main`:
   ```bash
   git add -A
   git commit -m "your changes"
   git push origin main
   ```
2. Jenkins detects within 1 minute, builds, and deploys
3. Site is live in ~2 minutes
4. Hard-refresh browser (`Ctrl+Shift+R`) to see changes

### Manual (SSH)

```bash
ssh -i Devops-Academy-VM_key.pem maged@20.25.62.124
cd /home/maged/devopsacademy
docker compose down
docker compose build --no-cache
docker compose up -d
```

---

## Admin Panel

**URL:** [https://devopsacademy.cloud-stacks.com/admin.html](https://devopsacademy.cloud-stacks.com/admin.html)

### Features

- JWT-authenticated login
- Real-time dashboard (auto-refreshes every 5 seconds)
- Enrollment statistics (total, pending, approved, rejected)
- Full enrollment table with filters
- Approve / Reject / Delete actions per application

### Credentials

| Username | Password |
|----------|----------|
| `admin` | `admin123` |

---

## Environment Variables

| Variable | Service | Default | Description |
|----------|---------|---------|-------------|
| `MONGO_URI` | backend | `mongodb://mongo:27017/devopsacademy` | MongoDB connection string |
| `JWT_SECRET` | backend | (set in docker-compose.yml) | JWT signing secret |

---

## .gitignore

```
node_modules/     # Dependencies (installed in containers)
*.pem, *.key      # SSH/SSL private keys
ssl/              # Certificate directory
*.pdf             # Documentation PDFs
.DS_Store         # macOS metadata
Thumbs.db         # Windows thumbnails
```

---

## License

Private — DevOps Academy Egypt © 2024-2026
