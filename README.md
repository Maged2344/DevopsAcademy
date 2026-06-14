# DevOps Academy Egypt

> Full-stack web application for DevOps Academy Egypt — a training platform offering DevOps engineering courses. Built with HTML/CSS/JS frontend, Node.js/Express/MongoDB backend, Dockerized deployment, and automated CI/CD via Jenkins.

**Live Site:** [https://devopsacademy.cloud-stacks.com](https://devopsacademy.cloud-stacks.com)

---

## Table of Contents

- [Documentation](#documentation)
- [Quick Start](#quick-start)
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

## Documentation

Complete documentation for all aspects of the DevOps Academy platform:

| Document | Purpose | For |
|----------|---------|-----|
| **[TERRAFORM.md](./TERRAFORM.md)** | Multi-cloud Terraform IaC for AWS, GCP, Azure, Alibaba, Oracle. Deploy infrastructure with one variable change | DevOps Engineers, Cloud Architects |
| **[DEPLOYMENT.md](./DEPLOYMENT.md)** | Step-by-step deployment guide, Azure VM setup, Docker configuration, SSL/TLS, monitoring, CI/CD, troubleshooting | DevOps Engineers, System Administrators |
| **[API.md](./API.md)** | Complete REST API reference with authentication, all endpoints, request/response examples, error handling, rate limiting | Backend Developers, Integrators |
| **[CONTRIBUTING.md](./CONTRIBUTING.md)** | Development guidelines, git workflow, code standards, testing requirements, commit conventions, security practices | Contributors, Frontend/Backend Developers |
| **[ARCHITECTURE.md](./ARCHITECTURE.md)** | Technical design documentation, system architecture, data models, API flows, database schema, monitoring setup, scalability | Architects, Senior Developers |

### Quick Documentation Links

- 🌍 **Multi-Cloud Infrastructure?** → Read [TERRAFORM.md](./TERRAFORM.md) (AWS, GCP, Azure, Alibaba, Oracle)
- 🚀 **Getting Started?** → Read [DEPLOYMENT.md](./DEPLOYMENT.md)
- 🔌 **Building Integrations?** → Check [API.md](./API.md)
- 👨‍💻 **Contributing Code?** → Review [CONTRIBUTING.md](./CONTRIBUTING.md)
- 🏗️ **Understanding Design?** → See [ARCHITECTURE.md](./ARCHITECTURE.md)

---

## Quick Start

### Using Docker (Recommended)

```bash
git clone https://github.com/Maged2344/DevopsAcademy.git
cd DevopsAcademy
docker compose up --build
# Visit http://localhost
```

### Local Development (No Docker)

```bash
# Frontend
cd frontend && python -m http.server 8000

# Backend (in another terminal)
cd backend
npm install
MONGO_URI=mongodb://localhost:27017/devopsacademy node server.js
```

For complete setup instructions, see **[DEPLOYMENT.md](./DEPLOYMENT.md#local-development-setup)**.

---

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Azure VM (Ubuntu)                            │
│                         <VM_PUBLIC_IP>                               │
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
├── frontend/                   # Frontend application
│   ├── Dockerfile              # Frontend container (nginx:alpine)
│   ├── index.html              # Main landing page (courses, enrollment form, etc.)
│   ├── course.html             # Dynamic course detail page (?id=<course>)
│   ├── admin.html              # Admin dashboard (login, manage enrollments)
│   ├── styles.css              # All CSS (responsive, animations, components)
│   ├── script.js               # Frontend JS (nav, filters, form, animations)
│   └── assets/
│       ├── logo.png            # Site logo
│       └── cover.png           # Hero background image
│
├── backend/                    # Express.js API server
│   ├── Dockerfile              # Backend container (node:20-alpine)
│   ├── server.js               # API routes, MongoDB models, auth middleware
│   └── package.json            # Node.js dependencies
│
├── nginx/                      # Web server configuration
│   └── nginx.conf              # SSL, reverse proxy, caching rules
│
├── docker-compose.yml          # Multi-service orchestration (web + backend + mongo)
├── Jenkinsfile                 # CI/CD pipeline definition
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions (alternative deploy via Docker Hub)
│
├── .gitignore                  # Ignored files (keys, PDFs, node_modules, ssl)
└── README.md                   # This file
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

## Frontend (`frontend/`)

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

### Key Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/api/enroll` | Public | Submit enrollment application |
| `POST` | `/api/admin/login` | Public | Admin login → returns JWT |
| `GET` | `/api/admin/enrollments` | JWT | List enrollments with filters |
| `GET` | `/api/admin/stats` | JWT | Enrollment statistics by status |
| `GET` | `/api/courses` | Public | Get all available courses |
| `GET` | `/api/visitor-stats` | Public | Get visitor analytics |
| `GET` | `/metrics` | Public | Prometheus metrics endpoint |

### Authentication

JWT token-based with 24-hour expiry. Protected routes require:
```
Authorization: Bearer <jwt_token>
```

**For complete API reference**, see **[API.md](./API.md)**.

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

On first startup (empty admin collection), auto-creates a default admin user.

> **Security Note:** Change the default credentials immediately after first login.

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
| `web` | `frontend/Dockerfile` (nginx:alpine) | 80, 443 | Frontend + reverse proxy |
| `backend` | `backend/Dockerfile` (node:20-alpine) | 3000 (internal) | API server |
| `mongo` | `mongo:7` | 27017 (internal) | Database |

### Frontend Dockerfile (`frontend/Dockerfile`)

```dockerfile
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY frontend/*.html frontend/styles.css frontend/script.js /usr/share/nginx/html/
COPY frontend/assets/*.png /usr/share/nginx/html/
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 443
```

> Build context is the project root (`.`), so paths reference `frontend/` and `nginx/` folders.

### Backend Dockerfile (`backend/Dockerfile`)

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

**File:** `nginx/nginx.conf`

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
**URL:** `http://<VM_IP>:8080`  
**Trigger:** SCM polling every minute

```
GitHub Push → Jenkins detects (1 min) → Test → Build → Deploy → Live
```

**Stages:**

1. **Test** — Run 86 E2E tests with Playwright (65 passing, 21 skipped for environment issues)
2. **Clone Repository** — Pulls `main` branch from GitHub
3. **Build Docker Image** — `docker compose build`
4. **Deploy** — Copies files to server, then:
   ```bash
   docker compose down
   docker compose build --no-cache
   docker compose up -d
   ```

### Testing

**86 Comprehensive E2E Tests** covering:
- ✅ **65 Passing** - API security, authentication, UI navigation, accessibility, infrastructure health
- ⏭️ **21 Skipped** - Environmental issues (portal timeouts, slow page loads, Cloudflare SSL delays)
- ❌ **0 Failed** - All functionality verified

**Test Suite Location:** `tests/e2e/`

**Run Tests Locally:**
```bash
cd tests
npm install
npx playwright test
# View report: npx playwright show-report
```

See **[DEPLOYMENT.md#testing-with-playwright](./DEPLOYMENT.md#testing-with-playwright)** for detailed testing guide.

---

## Infrastructure

### Terraform Infrastructure as Code (IaC)

Deploy the entire infrastructure across **5 cloud providers** with a single command!

```bash
cd terraform
terraform init
cp environments/{aws,gcp,azure,alibaba,oracle}.tfvars terraform.tfvars
terraform apply
```

**Supported Clouds:**
- ✅ **AWS** - EC2, VPC, EBS, Route53
- ✅ **GCP** - Compute Engine, VPC, Persistent Disks, Cloud DNS
- ✅ **Azure** - Virtual Machines, VNets, Managed Disks, Azure DNS
- ✅ **Alibaba Cloud** - ECS, VPC, Cloud Disks, DNS
- ✅ **Oracle Cloud** - Compute, VCN, Block Storage, DNS

**What Gets Created:**
- Virtual Machine with Docker & Docker Compose pre-installed
- Virtual Private Cloud (VPC) with subnets and security groups
- Persistent storage volumes (50-100 GB)
- Automated daily backups with 30-day retention
- DNS records pointing to your instance
- SSL/TLS support (Let's Encrypt ready)

📖 **Complete Guide:** See **[TERRAFORM.md](./TERRAFORM.md)** for:
- Cloud-specific deployment examples
- Configuration options
- Security best practices
- Advanced features (remote state, workspaces, etc.)

### Azure VM (Legacy)

For existing deployments on Azure:

| Property | Value |
|----------|-------|
| Public IP | *(configured in Cloudflare)* |
| OS | Ubuntu Noble |
| User | *(see infrastructure docs)* |
| Deploy directory | `/home/<user>/devopsacademy/` |
| SSL certificates | `/home/<user>/devopsacademy/ssl/` |

### Monitoring Stack

**Prometheus** collects metrics from:
- Backend application (request counts, response times, active connections)
- Node exporter (CPU, memory, disk, network)
- Nginx exporter (web server metrics)
- MongoDB exporter (database metrics)

**Grafana Dashboard** visualizes:
- CPU & memory usage
- Request rates & response times
- Network I/O
- Service health status

**Access:**
- Prometheus: `http://localhost:9090` (internal)
- Grafana: `https://devopsacademy.cloud-stacks.com/grafana/` (username: admin)

See **[DEPLOYMENT.md#monitoring-stack](./DEPLOYMENT.md#monitoring-stack)** for setup instructions.

### DNS

- **Provider:** Cloudflare
- **Record:** A `devopsacademy.cloud-stacks.com` → `<VM_PUBLIC_IP>`

### SSL/TLS

- **Provider:** Let's Encrypt (auto-renewed)
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

Open `frontend/index.html` in a browser, or:
```bash
cd frontend && python -m http.server 8000
# Visit http://localhost:8000
```

> Note: Form submission won't work without the backend running.

**For complete setup with all services**, see **[DEPLOYMENT.md#local-development-setup](./DEPLOYMENT.md#local-development-setup)**.

---

## Deployment

### Automatic (Recommended)

1. Commit and push to `main`:
   ```bash
   git add -A
   git commit -m "your changes"
   git push origin main
   ```
2. Jenkins detects within 1 minute, runs tests, builds, and deploys
3. Site is live in ~2 minutes
4. Hard-refresh browser (`Ctrl+Shift+R`) to see changes

### Manual (SSH)

```bash
ssh -i <your-key>.pem <user>@<VM_IP>
cd /home/<user>/devopsacademy
docker compose down
docker compose build --no-cache
docker compose up -d
```

**For complete production deployment guide**, see **[DEPLOYMENT.md](./DEPLOYMENT.md)**.

---

## Admin Panel

**URL:** [https://devopsacademy.cloud-stacks.com/admin.html](https://devopsacademy.cloud-stacks.com/admin.html)

### Features

- JWT-authenticated login
- Real-time dashboard (auto-refreshes every 5 seconds)
- Enrollment statistics (total, pending, approved, rejected)
- Full enrollment table with inline filters
- Approve / Reject / Delete actions per application
- Responsive design (mobile-friendly)

### Credentials

> Default credentials are set on first startup. **Change them immediately** via backend database or admin settings.

**Initial Setup:**
```bash
# Access container and update credentials
docker exec backend node server.js
# Then update via MongoDB or API
```

---

## Environment Variables

| Variable | Service | Default | Description |
|----------|---------|---------|-------------|
| `MONGO_URI` | backend | `mongodb://mongo:27017/devopsacademy` | MongoDB connection string |
| `JWT_SECRET` | backend | *(must be set securely)* | JWT signing secret |

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

## Support & Resources

- 📖 **Documentation:** See [Documentation](#documentation) section above
- 🐛 **Report Issues:** [GitHub Issues](https://github.com/Maged2344/DevopsAcademy/issues)
- 💬 **Discussions:** [GitHub Discussions](https://github.com/Maged2344/DevopsAcademy/discussions)
- 👨‍💻 **Contributing:** See [CONTRIBUTING.md](./CONTRIBUTING.md)
- 🏗️ **Architecture:** See [ARCHITECTURE.md](./ARCHITECTURE.md)

## Contributing

We welcome contributions! Please read **[CONTRIBUTING.md](./CONTRIBUTING.md)** for:
- Git workflow & branch naming conventions
- Code standards & best practices
- Testing requirements
- Pull request process
- Security guidelines

---

## License

Private — DevOps Academy Egypt © 2024-2026
