# API Documentation - DevOps Academy

Complete REST API reference for DevOps Academy backend.

---

## API Base URL

```
Development:  http://localhost:3000
Production:   https://devopsacademy.cloud-stacks.com/api
```

---

## Authentication

### JWT Token-Based Authentication

Protected endpoints require a JWT token in the `Authorization` header:

```
Authorization: Bearer <jwt_token>
```

### Login Endpoints

#### Student Login

```http
POST /api/student/login
Content-Type: application/json

{
  "email": "student@example.com",
  "password": "password123"
}

Response 200:
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "student_id",
    "name": "John Doe",
    "email": "student@example.com"
  }
}

Response 401:
{
  "success": false,
  "message": "Invalid credentials"
}
```

#### Admin Login

```http
POST /api/admin/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin_password"
}

Response 200:
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "admin"
}
```

---

## Public Endpoints (No Auth Required)

### Get All Courses

```http
GET /api/courses

Response 200:
{
  "success": true,
  "courses": [
    {
      "id": "course_1",
      "title": "DevOps Fundamentals",
      "description": "Introduction to DevOps principles",
      "duration": "4 weeks",
      "price": 99.99,
      "instructor": "Ahmed Mohamed",
      "level": "Beginner",
      "modules": 12,
      "students": 45
    },
    {
      "id": "course_2",
      "title": "Kubernetes Mastery",
      "description": "Advanced Kubernetes deployment",
      "duration": "6 weeks",
      "price": 149.99,
      "instructor": "Hana Al-Dosari",
      "level": "Advanced",
      "modules": 18,
      "students": 32
    }
  ]
}
```

### Get Course Details

```http
GET /api/courses/:courseId

Response 200:
{
  "success": true,
  "course": {
    "id": "course_1",
    "title": "DevOps Fundamentals",
    "description": "Introduction to DevOps principles and practices",
    "duration": "4 weeks",
    "price": 99.99,
    "instructor": "Ahmed Mohamed",
    "level": "Beginner",
    "modules": [
      {
        "id": "mod_1",
        "title": "What is DevOps?",
        "lessons": 5,
        "video_duration": "45 min"
      },
      {
        "id": "mod_2",
        "title": "CI/CD Pipelines",
        "lessons": 6,
        "video_duration": "60 min"
      }
    ]
  }
}
```

### Get Visitor Statistics

```http
GET /api/visitor-stats

Response 200:
{
  "success": true,
  "stats": {
    "totalVisits": 5234,
    "uniqueVisitors": 892,
    "pageStats": [
      {
        "page": "/",
        "visits": 2100,
        "uniqueVisitors": 450
      },
      {
        "page": "/courses",
        "visits": 1800,
        "uniqueVisitors": 320
      },
      {
        "page": "/courses?id=course_1",
        "visits": 890,
        "uniqueVisitors": 89
      }
    ]
  }
}
```

### Get Metrics (Prometheus Format)

```http
GET /metrics

Response 200:
# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",status="200",route="/"} 5234
http_requests_total{method="POST",status="201",route="/api/enroll"} 432

# HELP http_request_duration_seconds HTTP request duration
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{le="0.1",route="/api/courses"} 2100
http_request_duration_seconds_bucket{le="1",route="/api/courses"} 2145

# HELP http_active_connections Active HTTP connections
# TYPE http_active_connections gauge
http_active_connections{type="total"} 23
```

---

## Student Endpoints (Auth Required)

### Student Signup

```http
POST /api/student/signup
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "01234567890",
  "password": "SecurePass123!"
}

Response 201:
{
  "success": true,
  "message": "Student registered successfully",
  "student": {
    "id": "student_123",
    "name": "John Doe",
    "email": "john@example.com"
  }
}

Response 400:
{
  "success": false,
  "message": "Email already registered"
}
```

### Enroll in Course

```http
POST /api/enroll
Content-Type: application/json
Authorization: Bearer <token>

{
  "courseId": "course_1",
  "paymentMethod": "credit_card"
}

Response 201:
{
  "success": true,
  "message": "Enrollment successful",
  "enrollment": {
    "id": "enroll_456",
    "studentId": "student_123",
    "courseId": "course_1",
    "enrolledAt": "2026-06-14T10:30:00Z",
    "status": "active",
    "accessUntil": "2026-08-14"
  }
}

Response 409:
{
  "success": false,
  "message": "Already enrolled in this course"
}
```

### Get Student Enrollments

```http
GET /api/student/enrollments
Authorization: Bearer <token>

Response 200:
{
  "success": true,
  "enrollments": [
    {
      "id": "enroll_456",
      "courseId": "course_1",
      "courseTitle": "DevOps Fundamentals",
      "enrolledAt": "2026-06-14T10:30:00Z",
      "status": "active",
      "progress": 45,
      "accessUntil": "2026-08-14"
    },
    {
      "id": "enroll_789",
      "courseId": "course_3",
      "courseTitle": "Docker Essentials",
      "enrolledAt": "2026-05-20T15:45:00Z",
      "status": "active",
      "progress": 85,
      "accessUntil": "2026-07-20"
    }
  ]
}
```

---

## Admin Endpoints (Admin Auth Required)

### Get All Enrollments

```http
GET /api/admin/enrollments
Authorization: Bearer <admin_token>

Response 200:
{
  "success": true,
  "total": 432,
  "enrollments": [
    {
      "id": "enroll_1",
      "studentName": "John Doe",
      "studentEmail": "john@example.com",
      "courseId": "course_1",
      "courseTitle": "DevOps Fundamentals",
      "enrolledAt": "2026-06-14T10:30:00Z",
      "status": "active",
      "amount": 99.99
    }
  ]
}

Query Parameters:
  ?page=1&limit=20     # Pagination
  ?courseId=course_1   # Filter by course
  ?status=active       # Filter by status
```

### Get All Users

```http
GET /api/admin/users
Authorization: Bearer <admin_token>

Response 200:
{
  "success": true,
  "total": 892,
  "users": [
    {
      "id": "student_1",
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "01234567890",
      "registeredAt": "2026-05-01T08:15:00Z",
      "enrollmentCount": 3,
      "totalSpent": 349.97,
      "lastLogin": "2026-06-14T09:30:00Z"
    }
  ]
}
```

### Get Dashboard Analytics

```http
GET /api/admin/analytics
Authorization: Bearer <admin_token>

Response 200:
{
  "success": true,
  "analytics": {
    "totalStudents": 892,
    "totalEnrollments": 1234,
    "activeEnrollments": 1100,
    "totalRevenue": 127890.50,
    "averageEnrollmentPerStudent": 1.38,
    "topCourses": [
      {
        "courseId": "course_1",
        "title": "DevOps Fundamentals",
        "enrollments": 345
      },
      {
        "courseId": "course_2",
        "title": "Kubernetes Mastery",
        "enrollments": 289
      }
    ],
    "revenueByMonth": [
      {
        "month": "2026-05",
        "revenue": 15234.50
      },
      {
        "month": "2026-06",
        "revenue": 18956.00
      }
    ]
  }
}
```

### Create Course (Admin Only)

```http
POST /api/admin/courses
Content-Type: application/json
Authorization: Bearer <admin_token>

{
  "title": "Advanced Kubernetes",
  "description": "Master Kubernetes in production",
  "duration": "8 weeks",
  "price": 199.99,
  "instructor": "Khalid Al-Rashid",
  "level": "Advanced",
  "modules": [
    {
      "title": "K8s Architecture",
      "lessons": 8
    },
    {
      "title": "Security Best Practices",
      "lessons": 6
    }
  ]
}

Response 201:
{
  "success": true,
  "message": "Course created successfully",
  "course": {
    "id": "course_new_1",
    "title": "Advanced Kubernetes",
    ...
  }
}
```

### Update Course (Admin Only)

```http
PUT /api/admin/courses/:courseId
Content-Type: application/json
Authorization: Bearer <admin_token>

{
  "title": "Advanced Kubernetes 2026",
  "price": 219.99
}

Response 200:
{
  "success": true,
  "message": "Course updated successfully"
}
```

### Delete Course (Admin Only)

```http
DELETE /api/admin/courses/:courseId
Authorization: Bearer <admin_token>

Response 200:
{
  "success": true,
  "message": "Course deleted successfully"
}
```

---

## Service Request Endpoint

### Submit Service Request

```http
POST /api/service-request
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "01234567890",
  "service": "Corporate Training",
  "message": "We need DevOps training for our team"
}

Response 201:
{
  "success": true,
  "message": "Request received successfully",
  "requestId": "req_123456",
  "estimatedResponse": "24 hours"
}
```

### Get Service Requests (Admin)

```http
GET /api/admin/service-requests
Authorization: Bearer <admin_token>

Response 200:
{
  "success": true,
  "requests": [
    {
      "id": "req_123456",
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "01234567890",
      "service": "Corporate Training",
      "message": "We need DevOps training for our team",
      "submittedAt": "2026-06-14T14:30:00Z",
      "status": "pending",
      "notes": ""
    }
  ]
}
```

---

## Error Responses

### 400 Bad Request

```json
{
  "success": false,
  "message": "Invalid input data",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

### 401 Unauthorized

```json
{
  "success": false,
  "message": "Authentication required",
  "code": "AUTH_REQUIRED"
}
```

### 403 Forbidden

```json
{
  "success": false,
  "message": "Insufficient permissions",
  "code": "FORBIDDEN"
}
```

### 404 Not Found

```json
{
  "success": false,
  "message": "Resource not found",
  "code": "NOT_FOUND"
}
```

### 409 Conflict

```json
{
  "success": false,
  "message": "Resource already exists",
  "code": "CONFLICT"
}
```

### 500 Internal Server Error

```json
{
  "success": false,
  "message": "Internal server error",
  "code": "SERVER_ERROR"
}
```

---

## Rate Limiting

API endpoints are rate-limited to prevent abuse:

```
Rate Limit: 100 requests per 15 minutes per IP
Endpoints affected: All /api/* endpoints
Headers returned:
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 45
  X-RateLimit-Reset: 1623768900
```

When rate limit exceeded:

```json
HTTP 429 Too Many Requests

{
  "success": false,
  "message": "Rate limit exceeded",
  "retryAfter": 60
}
```

---

## CORS Configuration

```
Allowed Origins: https://devopsacademy.cloud-stacks.com, http://localhost:3000
Allowed Methods: GET, POST, PUT, DELETE, OPTIONS
Allowed Headers: Content-Type, Authorization
Credentials: true
```

---

## Example Client Code

### JavaScript/Node.js

```javascript
const API_BASE = 'https://devopsacademy.cloud-stacks.com/api';

// Login
async function login(email, password) {
  const response = await fetch(`${API_BASE}/student/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });
  const data = await response.json();
  localStorage.setItem('token', data.token);
  return data;
}

// Get courses with token
async function getCourses() {
  const token = localStorage.getItem('token');
  const response = await fetch(`${API_BASE}/courses`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  return response.json();
}

// Enroll in course
async function enrollCourse(courseId) {
  const token = localStorage.getItem('token');
  const response = await fetch(`${API_BASE}/enroll`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ courseId })
  });
  return response.json();
}
```

### cURL Examples

```bash
# Get all courses
curl -X GET https://devopsacademy.cloud-stacks.com/api/courses

# Student login
curl -X POST https://devopsacademy.cloud-stacks.com/api/student/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"pass123"}'

# Enroll in course (with token)
curl -X POST https://devopsacademy.cloud-stacks.com/api/enroll \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"courseId":"course_1"}'

# Get visitor stats
curl -X GET https://devopsacademy.cloud-stacks.com/api/visitor-stats

# Get Prometheus metrics
curl -X GET https://devopsacademy.cloud-stacks.com/metrics
```

---

## Webhooks (Future Feature)

```javascript
// Admin can configure webhooks for:
POST https://your-service.com/webhook
Headers: X-Webhook-Signature: <HMAC-SHA256>

Events:
  enrollment.created
  enrollment.completed
  student.registered
  course.created
  payment.received
```

---

**Last Updated:** June 2026  
**API Version:** 1.0  
**Status:** Stable
