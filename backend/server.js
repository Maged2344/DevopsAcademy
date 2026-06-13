const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();

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

const Enrollment = mongoose.model('Enrollment', enrollmentSchema);
const Admin = mongoose.model('Admin', adminSchema);
const Course = mongoose.model('Course', courseSchema);

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

// Submit enrollment application
app.post('/api/enroll', async (req, res) => {
  try {
    const { firstName, lastName, email, phone, course, experience, message } = req.body;

    if (!firstName || !lastName || !email || !phone || !course || !experience) {
      return res.status(400).json({ error: 'All required fields must be filled' });
    }

    const enrollment = new Enrollment({ firstName, lastName, email, phone, course, experience, message });
    await enrollment.save();

    res.status(201).json({ message: 'Application submitted successfully' });
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
    const { status } = req.body;
    if (!['pending', 'approved', 'rejected'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const enrollment = await Enrollment.findByIdAndUpdate(req.params.id, { status }, { new: true });
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
      const revenue = approved * course.price;
      return {
        courseId: course.courseId,
        name: course.name,
        price: course.price,
        level: course.level,
        active: course.active,
        total,
        approved,
        pending,
        rejected,
        revenue
      };
    }));
    res.json(stats);
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
        { courseId: 'devops', name: 'DevOps Engineering Program', price: 25000, duration: '25 Weeks', level: 'all' },
        { courseId: 'linux', name: 'Linux Fundamentals', price: 3500, duration: '4 Weeks', level: 'beginner' },
        { courseId: 'docker', name: 'Docker & Containers', price: 4500, duration: '5 Weeks', level: 'beginner' },
        { courseId: 'kubernetes', name: 'Kubernetes (K8s)', price: 6000, duration: '6 Weeks', level: 'intermediate' },
        { courseId: 'cicd', name: 'CI/CD Pipelines', price: 5500, duration: '5 Weeks', level: 'intermediate' },
        { courseId: 'aws', name: 'AWS Cloud Engineering', price: 7500, duration: '8 Weeks', level: 'intermediate' },
        { courseId: 'terraform', name: 'Terraform & IaC', price: 6500, duration: '6 Weeks', level: 'advanced' },
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
