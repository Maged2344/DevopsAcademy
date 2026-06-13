# Architecture Documentation - DevOps Academy

Technical architecture and system design of DevOps Academy platform.

---

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      Internet / Cloudflare DNS                  │
└────────────────────────┬────────────────────────────────────────┘
                         │
            ┌────────────▼────────────┐
            │   Azure Public IP       │
            │   20.25.62.124:443      │
            │   (SSL/TLS Termination) │
            └────────────┬────────────┘
                         │
        ┌────────────────▼────────────────────┐
        │         Nginx (Reverse Proxy)       │
        │   - SSL/TLS termination             │
        │   - Static file serving             │
        │   - Request routing                 │
        │   - Load balancing (future)         │
        └────┬────────────────┬──────────────┘
             │                │
      ┌──────▼─────┐    ┌─────▼───────┐
      │   Frontend  │    │   Backend    │
      │ (Static)    │    │  (Node.js)   │
      │ HTML/CSS/JS │    │   Express    │
      │             │    │              │
      │ - index.html│    │ - REST API   │
      │ - styles.css│    │ - Auth       │
      │ - script.js │    │ - DB Models  │
      └─────────────┘    │ - Metrics    │
                         └─────┬────────┘
                               │
                        ┌──────▼──────┐
                        │  MongoDB    │
                        │  (Database) │
                        │             │
                        │ Collections:│
                        │ - courses   │
                        │ - students  │
                        │ - enrollments
                        │ - requests  │
                        │ - visits    │
                        └─────────────┘

                    ┌───────────────────────┐
                    │ Monitoring Stack      │
                    │                       │
                    │ - Prometheus (DB)     │
                    │ - Grafana (UI)        │
                    │ - Exporters (metrics) │
                    └───────────────────────┘
```

---

## Technology Stack

### Frontend (Static)

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Markup | HTML5 | Semantic structure |
| Styling | CSS3 | Responsive design |
| Logic | Vanilla JavaScript | DOM manipulation, form handling |
| Build | None | Direct browser execution |
| Deployment | Nginx | Static file serving |

**Key Files:**
- `index.html` - Landing page with courses listing
- `styles.css` - All styling (responsive, animations)
- `script.js` - Frontend logic (form submission, navigation)

### Backend (API Server)

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Runtime | Node.js 20 | JavaScript server runtime |
| Framework | Express.js | HTTP server & routing |
| Database | MongoDB 7 | NoSQL document database |
| Auth | JWT + bcryptjs | Token-based authentication |
| Validation | express-validator | Input validation |
| Monitoring | prom-client | Prometheus metrics export |

**Key Modules:**
```javascript
// Core dependencies
express         - Web framework
mongoose        - MongoDB ODM
jsonwebtoken    - JWT token generation
bcryptjs        - Password hashing
cors            - Cross-Origin Resource Sharing
dotenv          - Environment variables
prom-client     - Prometheus metrics
nodemailer      - Email sending
```

### Infrastructure (Deployment)

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Orchestration | Docker Compose | Multi-container management |
| Containerization | Docker | Application isolation |
| Web Server | Nginx | Reverse proxy & SSL |
| DNS | Cloudflare | Domain management |
| Cloud | Microsoft Azure | VM hosting |
| CI/CD | Jenkins | Automated testing & deployment |

### Monitoring Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Metrics Collection | prom-client | Application metrics export |
| Time-Series DB | Prometheus | Metrics storage & querying |
| Visualization | Grafana | Metrics dashboard |
| System Metrics | node-exporter | OS & system metrics |
| Nginx Metrics | nginx-exporter | Web server metrics |
| MongoDB Metrics | mongodb-exporter | Database metrics |

---

## Data Models

### MongoDB Collections

#### 1. Courses Collection

```javascript
{
  _id: ObjectId,
  title: String,           // "DevOps Fundamentals"
  description: String,     // Course description
  instructor: String,      // Instructor name
  duration: String,        // "4 weeks"
  level: String,          // "Beginner", "Intermediate", "Advanced"
  price: Number,          // 99.99
  modules: [{
    id: String,
    title: String,
    lessons: Number,
    videoDuration: String
  }],
  studentsEnrolled: Number,
  createdAt: Date,
  updatedAt: Date,
  isActive: Boolean
}
```

#### 2. Students Collection

```javascript
{
  _id: ObjectId,
  name: String,
  email: String,           // Unique
  phone: String,
  passwordHash: String,    // bcrypt hashed
  enrollmentCount: Number,
  totalSpent: Number,
  lastLogin: Date,
  createdAt: Date,
  updatedAt: Date
}
```

#### 3. Enrollments Collection

```javascript
{
  _id: ObjectId,
  studentId: ObjectId,     // Reference to Students
  courseId: ObjectId,      // Reference to Courses
  enrolledAt: Date,
  accessUntil: Date,
  progress: Number,        // 0-100 percentage
  status: String,          // "active", "completed", "cancelled"
  certificateUrl: String,  // Optional
  amount: Number,          // Price paid
  paymentMethod: String,   // "credit_card", "paypal"
  transactionId: String,   // Payment reference
  updatedAt: Date
}
```

#### 4. ServiceRequests Collection

```javascript
{
  _id: ObjectId,
  name: String,
  email: String,
  phone: String,
  service: String,         // Type of service requested
  message: String,
  submittedAt: Date,
  status: String,          // "pending", "in_progress", "completed"
  notes: String,           // Admin notes
  respondedAt: Date,
  respondedBy: String      // Admin email
}
```

#### 5. Visits Collection

```javascript
{
  _id: ObjectId,
  page: String,            // "/", "/courses", "/courses?id=x"
  visitorId: String,       // Anonymous visitor ID
  timestamp: Date,
  userAgent: String,
  referrer: String,
  duration: Number         // Time spent in milliseconds
}
```

---

## API Architecture

### Request/Response Flow

```
Client Request
    │
    ▼
Nginx (Reverse Proxy)
    │ - SSL/TLS termination
    │ - Request routing
    │ - Caching headers
    ▼
Express.js Server
    │ - CORS middleware
    │ - Request logging
    │ - JWT authentication
    │ - Input validation
    ▼
Route Handler
    │ - Business logic
    │ - Database queries
    │ - Error handling
    ▼
MongoDB
    │ - Data storage
    │ - Indexing
    │ - Transactions
    ▼
Response Generation
    │ - JSON formatting
    │ - Error response
    │ - Status codes
    ▼
Nginx Response
    │ - Compression
    │ - Caching
    │ - SSL/TLS wrapping
    ▼
Client Response
```

### Authentication Flow

```
1. User Login
   POST /api/student/login
   ├─ Verify email exists
   ├─ Compare password with bcrypt hash
   └─ Generate JWT token

2. Token Structure (JWT)
   Header: { alg: "HS256", typ: "JWT" }
   Payload: { userId, email, iat, exp }
   Signature: HMAC-SHA256(secret)

3. Authenticated Request
   GET /api/student/enrollments
   Header: Authorization: Bearer <token>
   ├─ Verify JWT signature
   ├─ Check token expiration
   └─ Extract userId from payload

4. Protected Route Handler
   app.get('/api/student/enrollments', authenticateToken, (req, res) => {
     const userId = req.user.id;  // From JWT payload
     // Fetch enrollments for this user
   });
```

### Error Handling Strategy

```javascript
// Centralized error handling
app.use((error, req, res, next) => {
  // Error classification
  if (error.name === 'MongooseValidationError') {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      errors: error.errors
    });
  }
  
  if (error.name === 'JsonWebTokenError') {
    return res.status(401).json({
      success: false,
      message: 'Invalid token'
    });
  }
  
  if (error.statusCode === 404) {
    return res.status(404).json({
      success: false,
      message: 'Resource not found'
    });
  }
  
  // Default error
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? error.message : undefined
  });
});
```

---

## Frontend Architecture

### Page Structure

```
index.html (Multi-section single page)
├── Header/Navigation
│   ├── Logo
│   ├── Nav Links
│   └── Auth Buttons
│
├── Hero Section
│   ├── Tagline
│   └── CTA Buttons
│
├── About Section
│   └── Value Proposition
│
├── Courses Section
│   ├── Course Filters
│   └── Course Cards (grid)
│
├── Why Us Section
│   └── Benefits
│
├── Instructors Section
│   └── Team Cards
│
├── Contact Section
│   └── Contact Form
│
└── Footer
    ├── Links
    ├── Social Media
    └── Copyright
```

### JavaScript Architecture

```javascript
// Global state management (simple approach)
const AppState = {
  currentUser: null,
  token: localStorage.getItem('token'),
  courses: [],
  enrollments: [],
  isDarkMode: localStorage.getItem('theme') === 'dark'
};

// Event listeners on page load
document.addEventListener('DOMContentLoaded', () => {
  initializeApp();
  loadCourses();
  checkAuthStatus();
  setupEventListeners();
  applyTheme();
});

// API calls to backend
const api = {
  async getCourses() {
    const response = await fetch('/api/courses');
    return response.json();
  },
  
  async login(email, password) {
    const response = await fetch('/api/student/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    const data = await response.json();
    if (data.token) {
      AppState.token = data.token;
      localStorage.setItem('token', data.token);
    }
    return data;
  }
};

// DOM manipulation
const DOM = {
  getCourseCard: (course) => `
    <div class="course-card">
      <h3>${course.title}</h3>
      <p>${course.description}</p>
      <p>$${course.price}</p>
      <button onclick="enrollCourse('${course._id}')">Enroll Now</button>
    </div>
  `,
  
  renderCourses: (courses) => {
    const container = document.getElementById('courses-container');
    container.innerHTML = courses.map(c => DOM.getCourseCard(c)).join('');
  }
};
```

### CSS Architecture

```css
/* 1. Root variables */
:root {
  --primary-color: #007bff;
  --secondary-color: #6c757d;
  --success-color: #28a745;
  --spacing-unit: 8px;
  --border-radius: 4px;
}

/* 2. Global styles */
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: Arial, sans-serif; }

/* 3. Component classes */
.button-primary { ... }
.button-secondary { ... }
.card { ... }
.form-group { ... }

/* 4. Utility classes */
.text-center { text-align: center; }
.mt-20 { margin-top: 20px; }
.flex { display: flex; }

/* 5. Responsive breakpoints */
@media (max-width: 768px) { ... }
@media (max-width: 480px) { ... }
```

---

## Backend Architecture

### Directory Structure

```
backend/
├── server.js          # Main application file
├── package.json       # Dependencies
├── .env               # Environment variables
│
├── middleware/        # (Optional organization)
│   ├── auth.js        # JWT verification
│   └── validation.js  # Input validation
│
├── models/            # Mongoose schemas
│   ├── Course.js
│   ├── Student.js
│   └── Enrollment.js
│
├── routes/            # API routes
│   ├── courses.js
│   ├── auth.js
│   └── admin.js
│
└── controllers/       # Business logic (optional)
    └── courseController.js
```

### Middleware Architecture

```javascript
// Middleware stack order matters
app.use(express.json());                    // Parse JSON bodies
app.use(express.urlencoded());              // Parse form data
app.use(cors());                            // CORS headers
app.use(requestLogger);                     // Log requests
app.use(metricsMiddleware);                 // Collect metrics

// Protected routes
app.use('/api/student', authenticateToken);
app.use('/api/admin', authenticateToken, authorizeAdmin);

// Unprotected routes
app.get('/api/courses', getCourses);
app.post('/api/student/login', login);
```

### Database Connection

```javascript
const mongoose = require('mongoose');

mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  retryWrites: true,
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000
})
.then(() => console.log('MongoDB connected'))
.catch(err => {
  console.error('MongoDB connection error:', err);
  process.exit(1);
});

// Handle connection events
mongoose.connection.on('disconnected', () => {
  console.log('MongoDB disconnected');
});

mongoose.connection.on('error', (err) => {
  console.error('MongoDB error:', err);
});
```

---

## Monitoring Architecture

### Metrics Collection

```
Application Metrics (prom-client)
├── http_requests_total
│   └── Labels: method, route, status
│
├── http_request_duration_seconds
│   └── Buckets: 0.1s, 0.5s, 1s, 2s, 5s
│
├── http_active_connections
│   └── Gauge tracking concurrent requests
│
└── Custom metrics (optional)
    ├── enrollment_count
    ├── active_students
    └── revenue_total

                    ↓
            Prometheus Scraper
    (pulls metrics every 15 seconds)
                    ↓
        Prometheus Time-Series DB
    (stores metrics with timestamps)
                    ↓
            Grafana Dashboard
    (queries Prometheus, visualizes data)
```

### Alert Rules

```yaml
groups:
  - name: Application Health
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 10m
        
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, http_request_duration_seconds) > 3
        for: 5m
        
      - alert: DatabaseDown
        expr: up{job="mongodb"} == 0
        for: 1m
```

---

## Deployment Architecture

### Docker Compose Services

```yaml
services:
  web:                      # Nginx (Port 80/443)
    ├── Volumes: frontend files, SSL certs
    └── Networks: backend, external
    
  backend:                  # Node.js (Port 3000)
    ├── Depends on: mongo, prometheus
    ├── Env: MONGODB_URI, JWT_SECRET
    └── Volumes: config files
    
  mongo:                    # MongoDB (Port 27017)
    ├── Volumes: persistent data
    └── Networks: backend only
    
  prometheus:              # Prometheus (Port 9090)
    ├── Volumes: config, time-series data
    └── Networks: monitoring
    
  grafana:                 # Grafana (Port 3001)
    ├── Volumes: dashboard configs
    └── Networks: monitoring
    
  node-exporter:           # System metrics (Port 9100)
  nginx-exporter:          # Nginx metrics (Port 9113)
  mongodb-exporter:        # MongoDB metrics (Port 9216)
```

### Network Architecture

```
┌─────────────────────────────────┐
│     External Network (80/443)   │
│   Accessible from internet      │
└──────┬──────────────────────────┘
       │
   ┌───▼───────────┐
   │     Nginx     │
   └───┬───────────┘
       │
   ┌───▼──────────────────┐
   │  Backend Network     │
   │  (internal only)     │
   │                      │
   │ ├── backend (3000)   │
   │ ├── mongodb (27017)  │
   │ └── node-exporter    │
   └──────────────────────┘
       │
   ┌───▼──────────────────┐
   │  Monitoring Network  │
   │  (restricted access) │
   │                      │
   │ ├── prometheus       │
   │ ├── grafana (3001)   │
   │ └── exporters        │
   └──────────────────────┘
```

### Volume Strategy

```
Persistent Volumes:
├── mongo_data/
│   └── MongoDB database files (persistent)
│
├── prometheus_data/
│   └── Time-series database
│
├── grafana_data/
│   └── Dashboard configs, preferences
│
└── nginx_logs/
    └── Access and error logs

Config Mounts:
├── nginx.conf
├── prometheus.yml
└── grafana/provisioning/
```

---

## Security Architecture

### SSL/TLS Termination

```
                    ┌─────────────┐
Client (HTTPS)──────┤   Nginx     │
                    │ (443 SSL)   │
                    └──────┬──────┘
                           │ (HTTP - internal)
                    ┌──────▼──────┐
                    │  Backend    │
                    │ (3000 HTTP) │
                    └─────────────┘
```

### Authentication & Authorization

```
JWT Authentication Flow:
1. Login: POST /api/student/login
   ├─ Verify credentials
   ├─ Hash password with bcryptjs
   └─ Generate JWT

2. Protected Request: GET /api/student/enrollments
   ├─ Extract token from header
   ├─ Verify signature & expiration
   └─ Extract userId from payload

3. Role-Based Access:
   - Student: Can access own enrollments
   - Admin: Can access all data
   - Public: Can access course listings
```

### Input Validation

```javascript
// Validation schema example
const enrollmentSchema = {
  courseId: {
    notEmpty: true,
    isMongoId: true
  },
  paymentMethod: {
    notEmpty: true,
    isIn: ['credit_card', 'paypal']
  }
};

// All user inputs validated before DB operations
```

---

## Performance Optimization

### Caching Strategy

```
Browser Cache (Frontend Assets)
├── CSS/JS files: 365 days
├── Images: 90 days
└── HTML: 1 hour (no cache)

Server-Side Cache (Future)
├── Course listings: 1 hour
├── Student enrollments: 15 minutes
└── Admin dashboards: 5 minutes

Database Indexes
├── Students: email (unique)
├── Enrollments: studentId, courseId
├── Courses: category, level
└── Visits: timestamp
```

### Database Query Optimization

```javascript
// Use indexes for frequently queried fields
db.students.createIndex({ email: 1 }, { unique: true });
db.enrollments.createIndex({ studentId: 1, courseId: 1 });

// Use lean() for read-only queries
Course.find().lean();

// Use pagination
Course.find().limit(10).skip((page - 1) * 10);

// Select only needed fields
Course.find({}, 'title price instructor');
```

---

## Scalability Considerations

### Horizontal Scaling (Future)

```
Load Balancer
├── Backend Instance 1
├── Backend Instance 2
└── Backend Instance 3
     ↓
MongoDB Replica Set
├── Primary
├── Secondary 1
└── Secondary 2
```

### Vertical Scaling

- Increase VM CPU/memory
- Upgrade database instance
- Implement caching layer (Redis)

---

## Disaster Recovery

### Backup Strategy

- Daily MongoDB backups
- Daily configuration backups
- Weekly full system backups
- Monthly archive storage

### High Availability Goals

- RTO (Recovery Time Objective): 1 hour
- RPO (Recovery Point Objective): 1 day

---

**Last Updated:** June 2026  
**Version:** 1.0
