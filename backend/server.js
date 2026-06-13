const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');

const app = express();

// ===== Email Notification Setup =====
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: process.env.SMTP_SECURE === 'true',
  auth: {
    user: process.env.SMTP_USER || '',
    pass: process.env.SMTP_PASS || ''
  }
});

const NOTIFY_EMAIL = process.env.NOTIFY_EMAIL || process.env.SMTP_USER || '';

async function sendEnrollmentNotification(enrollment) {
  if (!NOTIFY_EMAIL || !process.env.SMTP_USER) return;
  try {
    await transporter.sendMail({
      from: `"DevOps Academy" <${process.env.SMTP_USER}>`,
      to: NOTIFY_EMAIL,
      subject: `🎓 New Enrollment: ${enrollment.firstName} ${enrollment.lastName} — ${enrollment.course}`,
      html: `
        <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;padding:20px;">
          <h2 style="color:#1e40af;border-bottom:2px solid #3b82f6;padding-bottom:10px;">New Enrollment Application</h2>
          <table style="width:100%;border-collapse:collapse;margin-top:16px;">
            <tr><td style="padding:8px;font-weight:bold;color:#374151;">Name</td><td style="padding:8px;">${enrollment.firstName} ${enrollment.lastName}</td></tr>
            <tr style="background:#f8fafc;"><td style="padding:8px;font-weight:bold;color:#374151;">Email</td><td style="padding:8px;">${enrollment.email}</td></tr>
            <tr><td style="padding:8px;font-weight:bold;color:#374151;">Phone</td><td style="padding:8px;">${enrollment.phone}</td></tr>
            <tr style="background:#f8fafc;"><td style="padding:8px;font-weight:bold;color:#374151;">Course</td><td style="padding:8px;color:#1e40af;font-weight:bold;">${enrollment.course}</td></tr>
            <tr><td style="padding:8px;font-weight:bold;color:#374151;">Experience</td><td style="padding:8px;">${enrollment.experience}</td></tr>
            ${enrollment.message ? `<tr style="background:#f8fafc;"><td style="padding:8px;font-weight:bold;color:#374151;">Message</td><td style="padding:8px;">${enrollment.message}</td></tr>` : ''}
          </table>
          <p style="margin-top:20px;color:#64748b;font-size:0.85rem;">Submitted: ${new Date().toLocaleString('en-EG', { timeZone: 'Africa/Cairo' })}</p>
          <a href="https://devopsacademy.cloud-stacks.com/admin.html" style="display:inline-block;margin-top:16px;padding:10px 24px;background:#1e40af;color:#fff;text-decoration:none;border-radius:6px;">View in Admin Panel</a>
        </div>
      `
    });
    console.log('📧 Enrollment notification sent to', NOTIFY_EMAIL);
  } catch (err) {
    console.error('❌ Email notification failed:', err.message);
  }
}

async function sendServiceNotification(request) {
  if (!NOTIFY_EMAIL || !process.env.SMTP_USER) return;
  try {
    await transporter.sendMail({
      from: `"DevOps Academy" <${process.env.SMTP_USER}>`,
      to: NOTIFY_EMAIL,
      subject: `🛠️ New Service Request: ${request.name} — ${request.serviceType}`,
      html: `
        <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;padding:20px;">
          <h2 style="color:#f59e0b;border-bottom:2px solid #f59e0b;padding-bottom:10px;">New Service Request</h2>
          <table style="width:100%;border-collapse:collapse;margin-top:16px;">
            <tr><td style="padding:8px;font-weight:bold;color:#374151;">Name</td><td style="padding:8px;">${request.name}</td></tr>
            <tr style="background:#f8fafc;"><td style="padding:8px;font-weight:bold;color:#374151;">Company</td><td style="padding:8px;">${request.company || '-'}</td></tr>
            <tr><td style="padding:8px;font-weight:bold;color:#374151;">Email</td><td style="padding:8px;">${request.email}</td></tr>
            <tr style="background:#f8fafc;"><td style="padding:8px;font-weight:bold;color:#374151;">Phone</td><td style="padding:8px;">${request.phone}</td></tr>
            <tr><td style="padding:8px;font-weight:bold;color:#374151;">Service</td><td style="padding:8px;color:#f59e0b;font-weight:bold;">${request.serviceType}</td></tr>
            <tr style="background:#f8fafc;"><td style="padding:8px;font-weight:bold;color:#374151;">Budget</td><td style="padding:8px;">${request.budget || '-'}</td></tr>
            <tr><td style="padding:8px;font-weight:bold;color:#374151;">Description</td><td style="padding:8px;">${request.description}</td></tr>
          </table>
          <p style="margin-top:20px;color:#64748b;font-size:0.85rem;">Submitted: ${new Date().toLocaleString('en-EG', { timeZone: 'Africa/Cairo' })}</p>
          <a href="https://devopsacademy.cloud-stacks.com/admin.html" style="display:inline-block;margin-top:16px;padding:10px 24px;background:#f59e0b;color:#fff;text-decoration:none;border-radius:6px;">View in Admin Panel</a>
        </div>
      `
    });
    console.log('📧 Service notification sent to', NOTIFY_EMAIL);
  } catch (err) {
    console.error('❌ Email notification failed:', err.message);
  }
}

// Disable ETag to prevent 304 responses
app.set('etag', false);

// Parse JSON with error handling
app.use((req, res, next) => {
  express.json()(req, res, (err) => {
    if (err) {
      return res.status(400).json({ error: 'Invalid JSON in request body' });
    }
    next();
  });
});
app.use(cors());

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
  next();
});

const JWT_SECRET = process.env.JWT_SECRET || 'devopsacademy-secret-key-change-in-production';
const MONGO_URI = process.env.MONGO_URI || 'mongodb://mongo:27017/devopsacademy';

// ===== MongoDB Schemas =====
const enrollmentSchema = new mongoose.Schema({
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  email: { type: String, required: true },
  phone: { type: String, required: true },
  course: { type: String, required: true },
  experience: { type: String, required: true },
  message: { type: String, default: '' },
  status: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
  paid: { type: Boolean, default: false },
  amountPaid: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
});

const adminSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true }
});

const courseSchema = new mongoose.Schema({
  courseId: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  price: { type: Number, required: true },
  duration: { type: String, default: '' },
  level: { type: String, enum: ['beginner', 'intermediate', 'advanced', 'all'], default: 'beginner' },
  active: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

const serviceRequestSchema = new mongoose.Schema({
  name: { type: String, required: true },
  company: { type: String, default: '' },
  email: { type: String, required: true },
  phone: { type: String, required: true },
  serviceType: { type: String, required: true, enum: ['deployment', 'automation', 'website', 'monitoring', 'migration', 'consulting'] },
  budget: { type: String, default: '' },
  description: { type: String, required: true },
  status: { type: String, enum: ['new', 'contacted', 'in-progress', 'completed', 'cancelled'], default: 'new' },
  notes: { type: String, default: '' },
  createdAt: { type: Date, default: Date.now }
});

const visitSchema = new mongoose.Schema({
  page: { type: String, required: true },
  ip: { type: String, default: '' },
  userAgent: { type: String, default: '' },
  referrer: { type: String, default: '' },
  createdAt: { type: Date, default: Date.now }
});

const Enrollment = mongoose.model('Enrollment', enrollmentSchema);
const Admin = mongoose.model('Admin', adminSchema);
const Course = mongoose.model('Course', courseSchema);
const ServiceRequest = mongoose.model('ServiceRequest', serviceRequestSchema);
const Visit = mongoose.model('Visit', visitSchema);

// ===== Auth Middleware =====
function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'No token provided' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.admin = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}

// ===== Public Routes =====

// Get all active courses (public - no auth needed)
app.get('/api/courses', async (req, res) => {
  try {
    const courses = await Course.find({ active: true }).sort({ createdAt: 1 });
    res.json(courses);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Submit enrollment application
app.post('/api/enroll', async (req, res) => {
  try {
    const { firstName, lastName, email, phone, course, experience, message } = req.body;

    if (!firstName || !lastName || !email || !phone || !course || !experience) {
      return res.status(400).json({ error: 'All required fields must be filled' });
    }

    const enrollment = new Enrollment({ firstName, lastName, email, phone, course, experience, message });
    await enrollment.save();

    // Send email notification (non-blocking)
    sendEnrollmentNotification(enrollment);

    res.status(201).json({ message: 'Application submitted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Submit service request
app.post('/api/service-request', async (req, res) => {
  try {
    const { name, company, email, phone, serviceType, budget, description } = req.body;

    if (!name || !email || !phone || !serviceType || !description) {
      return res.status(400).json({ error: 'All required fields must be filled' });
    }

    const serviceRequest = new ServiceRequest({ name, company, email, phone, serviceType, budget, description });
    await serviceRequest.save();

    // Send email notification (non-blocking)
    sendServiceNotification(serviceRequest);

    res.status(201).json({ message: 'Service request submitted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Track page visit (public)
app.post('/api/track', async (req, res) => {
  try {
    const { page } = req.body;
    if (!page || typeof page !== 'string' || page.length > 200) {
      return res.status(400).json({ error: 'Invalid page' });
    }
    const ip = req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.socket.remoteAddress || '';
    const userAgent = (req.headers['user-agent'] || '').substring(0, 500);
    const referrer = (req.headers['referer'] || '').substring(0, 500);
    await Visit.create({ page, ip, userAgent, referrer });
    res.status(201).json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// ===== Admin Auth Routes =====

// Admin login
app.post('/api/admin/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    const admin = await Admin.findOne({ username });

    if (!admin || !(await bcrypt.compare(password, admin.password))) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign({ id: admin._id, username: admin.username }, JWT_SECRET, { expiresIn: '24h' });
    res.json({ token, username: admin.username });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// ===== Admin Protected Routes =====

// Get all enrollments
app.get('/api/admin/enrollments', authMiddleware, async (req, res) => {
  try {
    const { status, course } = req.query;
    const filter = {};
    if (status) filter.status = status;
    if (course) filter.course = course;

    const enrollments = await Enrollment.find(filter).sort({ createdAt: -1 });
    res.json(enrollments);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get enrollment stats
app.get('/api/admin/stats', authMiddleware, async (req, res) => {
  try {
    const total = await Enrollment.countDocuments();
    const pending = await Enrollment.countDocuments({ status: 'pending' });
    const approved = await Enrollment.countDocuments({ status: 'approved' });
    const rejected = await Enrollment.countDocuments({ status: 'rejected' });

    res.json({ total, pending, approved, rejected });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Update enrollment status
app.patch('/api/admin/enrollments/:id', authMiddleware, async (req, res) => {
  try {
    const { status, paid, amountPaid } = req.body;
    const update = {};
    if (status) {
      if (!['pending', 'approved', 'rejected'].includes(status)) {
        return res.status(400).json({ error: 'Invalid status' });
      }
      update.status = status;
    }
    if (paid !== undefined) update.paid = paid;
    if (amountPaid !== undefined) update.amountPaid = amountPaid;

    const enrollment = await Enrollment.findByIdAndUpdate(req.params.id, update, { new: true });
    if (!enrollment) return res.status(404).json({ error: 'Enrollment not found' });

    res.json(enrollment);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete enrollment
app.delete('/api/admin/enrollments/:id', authMiddleware, async (req, res) => {
  try {
    const enrollment = await Enrollment.findByIdAndDelete(req.params.id);
    if (!enrollment) return res.status(404).json({ error: 'Enrollment not found' });

    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// ===== Course Management Routes =====

// Get all courses
app.get('/api/admin/courses', authMiddleware, async (req, res) => {
  try {
    const courses = await Course.find().sort({ createdAt: 1 });
    res.json(courses);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Add a new course
app.post('/api/admin/courses', authMiddleware, async (req, res) => {
  try {
    const { courseId, name, price, duration, level } = req.body;
    if (!courseId || !name || price === undefined) {
      return res.status(400).json({ error: 'courseId, name, and price are required' });
    }

    const existing = await Course.findOne({ courseId });
    if (existing) {
      return res.status(409).json({ error: 'Course ID already exists' });
    }

    const course = new Course({ courseId, name, price, duration, level });
    await course.save();
    res.status(201).json(course);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Update a course (price, name, etc.)
app.put('/api/admin/courses/:id', authMiddleware, async (req, res) => {
  try {
    const { name, price, duration, level, active } = req.body;
    const update = {};
    if (name !== undefined) update.name = name;
    if (price !== undefined) update.price = price;
    if (duration !== undefined) update.duration = duration;
    if (level !== undefined) update.level = level;
    if (active !== undefined) update.active = active;

    const course = await Course.findByIdAndUpdate(req.params.id, update, { new: true });
    if (!course) return res.status(404).json({ error: 'Course not found' });

    res.json(course);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete a course
app.delete('/api/admin/courses/:id', authMiddleware, async (req, res) => {
  try {
    const course = await Course.findByIdAndDelete(req.params.id);
    if (!course) return res.status(404).json({ error: 'Course not found' });

    res.json({ message: 'Course deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get per-course enrollment stats and revenue
app.get('/api/admin/course-stats', authMiddleware, async (req, res) => {
  try {
    const courses = await Course.find();
    const stats = await Promise.all(courses.map(async (course) => {
      const total = await Enrollment.countDocuments({ course: course.courseId });
      const approved = await Enrollment.countDocuments({ course: course.courseId, status: 'approved' });
      const pending = await Enrollment.countDocuments({ course: course.courseId, status: 'pending' });
      const rejected = await Enrollment.countDocuments({ course: course.courseId, status: 'rejected' });
      const paidStudents = await Enrollment.countDocuments({ course: course.courseId, paid: true });
      const paidEnrollments = await Enrollment.find({ course: course.courseId, paid: true });
      const totalPaid = paidEnrollments.reduce((sum, e) => sum + (e.amountPaid || 0), 0);
      const expectedRevenue = approved * course.price;
      return {
        courseId: course.courseId,
        name: course.name,
        price: course.price,
        duration: course.duration,
        level: course.level,
        active: course.active,
        total,
        approved,
        pending,
        rejected,
        paidStudents,
        totalPaid,
        expectedRevenue
      };
    }));
    res.json(stats);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// ===== Admin Service Request Routes =====

// Get all service requests
app.get('/api/admin/service-requests', authMiddleware, async (req, res) => {
  try {
    const { status, serviceType } = req.query;
    const filter = {};
    if (status) filter.status = status;
    if (serviceType) filter.serviceType = serviceType;
    const requests = await ServiceRequest.find(filter).sort({ createdAt: -1 });
    res.json(requests);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get service request stats
app.get('/api/admin/service-stats', authMiddleware, async (req, res) => {
  try {
    const total = await ServiceRequest.countDocuments();
    const newReqs = await ServiceRequest.countDocuments({ status: 'new' });
    const contacted = await ServiceRequest.countDocuments({ status: 'contacted' });
    const inProgress = await ServiceRequest.countDocuments({ status: 'in-progress' });
    const completed = await ServiceRequest.countDocuments({ status: 'completed' });
    const cancelled = await ServiceRequest.countDocuments({ status: 'cancelled' });
    res.json({ total, new: newReqs, contacted, inProgress, completed, cancelled });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Update service request status/notes
app.patch('/api/admin/service-requests/:id', authMiddleware, async (req, res) => {
  try {
    const { status, notes } = req.body;
    const update = {};
    if (status) update.status = status;
    if (notes !== undefined) update.notes = notes;
    const request = await ServiceRequest.findByIdAndUpdate(req.params.id, update, { new: true });
    if (!request) return res.status(404).json({ error: 'Service request not found' });
    res.json(request);
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete service request
app.delete('/api/admin/service-requests/:id', authMiddleware, async (req, res) => {
  try {
    const request = await ServiceRequest.findByIdAndDelete(req.params.id);
    if (!request) return res.status(404).json({ error: 'Service request not found' });
    res.json({ message: 'Service request deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// ===== Visitor Analytics Routes =====

// Get visitor stats
app.get('/api/admin/visitor-stats', authMiddleware, async (req, res) => {
  try {
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const weekStart = new Date(todayStart);
    weekStart.setDate(weekStart.getDate() - 7);
    const monthStart = new Date(todayStart);
    monthStart.setDate(monthStart.getDate() - 30);

    const total = await Visit.countDocuments();
    const today = await Visit.countDocuments({ createdAt: { $gte: todayStart } });
    const thisWeek = await Visit.countDocuments({ createdAt: { $gte: weekStart } });
    const thisMonth = await Visit.countDocuments({ createdAt: { $gte: monthStart } });

    // Unique visitors (by IP)
    const uniqueTotal = await Visit.distinct('ip').then(ips => ips.length);
    const uniqueToday = await Visit.distinct('ip', { createdAt: { $gte: todayStart } }).then(ips => ips.length);

    // Per-page breakdown
    const perPage = await Visit.aggregate([
      { $group: { _id: '$page', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    // Daily visits for the last 7 days
    const dailyVisits = await Visit.aggregate([
      { $match: { createdAt: { $gte: weekStart } } },
      { $group: {
        _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
        count: { $sum: 1 }
      }},
      { $sort: { _id: 1 } }
    ]);

    res.json({ total, today, thisWeek, thisMonth, uniqueTotal, uniqueToday, perPage, dailyVisits });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

// ===== Connect to MongoDB and Start Server =====
async function start() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('Connected to MongoDB');

    // Create default admin if none exists
    const adminCount = await Admin.countDocuments();
    if (adminCount === 0) {
      const hashedPassword = await bcrypt.hash('admin123', 10);
      await Admin.create({ username: 'admin', password: hashedPassword });
      console.log('Default admin created: admin / admin123');
    }

    // Seed default courses if none exist
    const courseCount = await Course.countDocuments();
    if (courseCount === 0) {
      const defaultCourses = [
        { courseId: 'devops', name: 'DevOps Engineering Program', price: 15000, duration: '12 Weeks', level: 'all' },
        { courseId: 'linux', name: 'Linux Administration', price: 3500, duration: '6 Weeks', level: 'beginner' },
        { courseId: 'docker', name: 'Docker & Containers', price: 4500, duration: '5 Weeks', level: 'beginner' },
        { courseId: 'kubernetes', name: 'Kubernetes (K8s)', price: 6000, duration: '6 Weeks', level: 'intermediate' },
        { courseId: 'cicd', name: 'CI/CD Pipelines', price: 5500, duration: '5 Weeks', level: 'intermediate' },
        { courseId: 'aws', name: 'AWS Cloud', price: 7500, duration: '6 Weeks', level: 'intermediate' },
        { courseId: 'azure', name: 'Microsoft Azure', price: 5500, duration: '4 Weeks', level: 'intermediate' },
        { courseId: 'gcp', name: 'Google Cloud Platform (GCP)', price: 5500, duration: '4 Weeks', level: 'intermediate' },
        { courseId: 'alibaba', name: 'Alibaba Cloud', price: 3500, duration: '3 Weeks', level: 'intermediate' },
        { courseId: 'oracle', name: 'Oracle Cloud (OCI)', price: 3500, duration: '3 Weeks', level: 'intermediate' },
        { courseId: 'terraform', name: 'Terraform — IaC', price: 4500, duration: '4 Weeks', level: 'advanced' },
        { courseId: 'ansible', name: 'Ansible — Configuration Management', price: 4000, duration: '4 Weeks', level: 'advanced' },
        { courseId: 'git', name: 'Git & Version Control', price: 2500, duration: '3 Weeks', level: 'beginner' },
        { courseId: 'devsecops', name: 'DevSecOps', price: 7000, duration: '6 Weeks', level: 'advanced' },
        { courseId: 'monitoring', name: 'Monitoring & Observability', price: 5500, duration: '5 Weeks', level: 'advanced' }
      ];
      await Course.insertMany(defaultCourses);
      console.log('Default courses seeded');
    }

    app.listen(3000, '0.0.0.0', () => {
      console.log('Backend API running on port 3000');
    });
  } catch (err) {
    console.error('Failed to start:', err);
    process.exit(1);
  }
}

start();
