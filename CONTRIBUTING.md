# Contributing to DevOps Academy

Guidelines for developers contributing to the DevOps Academy project.

---

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Report security issues privately
- Follow the project's coding standards

---

## Getting Started

### 1. Fork & Clone Repository

```bash
# Fork on GitHub (click Fork button)

# Clone your fork
git clone https://github.com/YOUR_USERNAME/DevopsAcademy.git
cd DevopsAcademy

# Add upstream remote
git remote add upstream https://github.com/Maged2344/DevopsAcademy.git
```

### 2. Create Feature Branch

```bash
# Update main branch
git fetch upstream
git checkout main
git merge upstream/main

# Create feature branch
git checkout -b feature/your-feature-name
# or for bug fixes:
git checkout -b fix/bug-description
```

Branch naming convention:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `test/` - Test additions
- `refactor/` - Code refactoring
- `perf/` - Performance improvements

### 3. Set Up Local Development

```bash
# Install dependencies
cd backend && npm install

# Create .env file
cp .env.example .env
# Edit with your configuration

# Start development environment
docker-compose up -d

# Run tests
cd ../tests && npm install
npm test
```

---

## Development Workflow

### Frontend Development

Frontend files are HTML/CSS/JavaScript (no build process):

```
frontend/
├── index.html          # Main landing page
├── course.html         # Course detail page
├── admin.html          # Admin dashboard
├── styles.css          # All styling (responsive, animations)
└── script.js           # Frontend logic (no framework dependencies)
```

**Guidelines:**
- Use semantic HTML
- Follow BEM methodology for CSS classes
- Write vanilla JavaScript (no jQuery/Vue/React in this project)
- Mobile-first responsive design
- Accessibility: ARIA labels, alt text, semantic HTML
- Test in Chrome, Firefox, Safari, Edge

**Example commit:**
```bash
git add frontend/
git commit -m "feat: add mobile hamburger menu animation"
```

### Backend Development

Backend uses Express.js with MongoDB:

```
backend/
├── server.js           # Main application file
└── package.json        # Dependencies
```

**Guidelines:**
- Follow REST API principles
- Use consistent naming (camelCase)
- Add error handling and validation
- Write async/await (not callbacks)
- Add JSDoc comments for functions
- Use middleware for common operations

**Example:**
```javascript
/**
 * Get all courses with pagination
 * @param {Object} query - Query parameters
 * @param {Number} query.limit - Items per page (default: 10)
 * @param {Number} query.skip - Number of items to skip
 * @returns {Array} Array of courses
 */
app.get('/api/courses', async (req, res) => {
  try {
    const { limit = 10, skip = 0 } = req.query;
    const courses = await Course.find()
      .limit(parseInt(limit))
      .skip(parseInt(skip));
    res.json({ success: true, courses });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});
```

**Example commit:**
```bash
git add backend/
git commit -m "feat: add pagination to /api/courses endpoint"
```

### Testing

All new features must include tests:

```bash
# Add test file
tests/e2e/new-feature.spec.ts

# Write tests using Playwright
import { test, expect } from '@playwright/test';

test.describe('New Feature', () => {
  test('should work as expected', async ({ page }) => {
    await page.goto('https://devopsacademy.cloud-stacks.com');
    const element = page.locator('[data-testid="feature"]');
    await expect(element).toBeVisible();
  });
});

# Run tests
npm test

# Or run specific test
npx playwright test new-feature.spec.ts
```

**Test coverage targets:**
- API endpoints: 100% (security critical)
- Frontend: 80%+ (user interactions)
- Infrastructure: 100% (deployment checks)

---

## Code Standards

### JavaScript/TypeScript

```javascript
// ✓ Good
const getUserById = async (userId) => {
  try {
    const user = await User.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }
    return user;
  } catch (error) {
    console.error('Error fetching user:', error);
    throw error;
  }
};

// ✗ Bad
function GetUser(id) {
  return User.findById(id);  // No error handling
}

// Use const/let, not var
// Use arrow functions for callbacks
// Always use async/await, not .then()
// Add error handling with try/catch
// Use meaningful variable names
```

### CSS

```css
/* ✓ Good */
.button-primary {
  background-color: #007bff;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.button-primary:hover {
  background-color: #0056b3;
}

/* Mobile first - add responsive styles at bottom */
@media (max-width: 768px) {
  .button-primary {
    width: 100%;
  }
}

/* ✗ Bad */
.btn { /* Use descriptive names */
  background: blue;
}
.btn:active { /* Use more specific selectors */
  color: red;
}
```

### HTML

```html
<!-- ✓ Good -->
<button 
  class="button-primary" 
  data-testid="submit-btn"
  aria-label="Submit form">
  Submit
</button>

<img 
  src="logo.png" 
  alt="Company logo"
  width="200" 
  height="50">

<!-- ✗ Bad -->
<button onclick="submit()">Submit</button>
<img src="logo.png">
```

---

## Git Workflow

### Commit Messages

Follow conventional commits format:

```
type(scope): description

[optional body]
[optional footer]

Examples:
feat(api): add pagination to courses endpoint
fix(frontend): correct mobile menu alignment
docs: update deployment guide
test(auth): add login validation tests
refactor(backend): simplify error handling
perf(db): add index to courses collection
```

### Making a Commit

```bash
# Stage changes
git add .

# Commit with clear message
git commit -m "feat(frontend): add dark mode toggle"

# View commit history
git log --oneline -5

# Amend last commit (if not yet pushed)
git commit --amend -m "feat(frontend): add dark mode toggle with persistence"
```

### Push & Create Pull Request

```bash
# Push feature branch
git push origin feature/your-feature-name

# On GitHub:
# 1. Go to repository
# 2. Click "Compare & pull request"
# 3. Fill in PR description
# 4. Select reviewers
# 5. Click "Create pull request"
```

### PR Description Template

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] Bug fix (non-breaking change)
- [ ] New feature (non-breaking change)
- [ ] Documentation update
- [ ] Performance improvement

## Related Issue
Fixes #123

## Testing
- [ ] Tested locally
- [ ] Test suite passes
- [ ] Added new tests

## Screenshots/Demo (if applicable)
[Add screenshots or video]

## Checklist
- [ ] Code follows style guidelines
- [ ] No console errors/warnings
- [ ] Comments added for complex logic
- [ ] Documentation updated
```

---

## Deployment

### Development Deployment

```bash
# Developers can test locally:
docker-compose up -d

# Or on staging environment:
git push origin feature/name
# Staging CI/CD auto-deploys
```

### Production Deployment

Only merged pull requests to `main` branch are deployed:

```
1. Feature branch → PR
2. Code review & approval
3. Merge to main
4. GitHub webhook triggers Jenkins
5. Jenkins runs tests
6. If tests pass → builds Docker image
7. Deploys to Azure VM
```

---

## Issue Reporting

### Bug Report

```markdown
## Description
What is the bug?

## Steps to Reproduce
1. Go to...
2. Click on...
3. Observe...

## Expected Behavior
What should happen?

## Actual Behavior
What happens instead?

## Environment
- Browser: Chrome 90
- OS: Windows 10
- URL: https://devopsacademy.cloud-stacks.com

## Screenshots
[Attach relevant screenshots]
```

### Feature Request

```markdown
## Title
Brief feature description

## Problem
What problem does this solve?

## Solution
How should it work?

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Additional Context
Any other information...
```

---

## Performance Guidelines

### Frontend Performance

```javascript
// Use debounce for frequent events
const debounce = (fn, delay) => {
  let timeout;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => fn(...args), delay);
  };
};

// Example: search input
const handleSearch = debounce((query) => {
  fetchResults(query);
}, 300);
```

### API Performance

```javascript
// Use pagination for large datasets
app.get('/api/courses', (req, res) => {
  const { page = 1, limit = 10 } = req.query;
  const skip = (page - 1) * limit;
  
  Course.find()
    .limit(parseInt(limit))
    .skip(skip)
    .then(courses => res.json(courses));
});

// Add database indexes
db.courses.createIndex({ category: 1 });
db.students.createIndex({ email: 1 });
```

### Database Optimization

```javascript
// Use lean() for read-only queries
Course.find().lean();  // Faster than normal queries

// Select only needed fields
Course.find({}, 'title price instructor');

// Use aggregation for complex queries
db.enrollments.aggregate([
  { $match: { status: 'active' } },
  { $group: { _id: '$courseId', count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]);
```

---

## Security Guidelines

### Input Validation

```javascript
// Validate all user inputs
const { body, validationResult } = require('express-validator');

app.post('/api/enroll', [
  body('courseId').isMongoId().notEmpty(),
  body('paymentMethod').isIn(['credit_card', 'paypal']),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  // Process enrollment
});
```

### SQL/NoSQL Injection Prevention

```javascript
// ✓ Good - parameterized queries
const user = await User.findOne({ email: userInput });

// ✗ Bad - string concatenation
const query = `db.users.findOne({ email: '${userInput}' })`;
```

### XSS Prevention

```html
<!-- ✓ Good - framework escaping -->
<h1><%= user.name %></h1>

<!-- ✗ Bad - innerHTML -->
<h1 id="name"></h1>
<script>
  document.getElementById('name').innerHTML = userInput;
</script>
```

### Password Security

```javascript
// Hash passwords with bcrypt
const bcrypt = require('bcryptjs');

const hash = await bcrypt.hash(password, 10);
const isValid = await bcrypt.compare(inputPassword, hash);

// Never log passwords
console.log(`Login attempt for user ${email}`); // Good
console.log(`Login: ${email} ${password}`);     // Bad
```

---

## Documentation Standards

### README Updates

When adding features, update relevant documentation:
- README.md (main overview)
- API.md (if adding endpoints)
- DEPLOYMENT.md (if changing deployment)

### Code Comments

```javascript
// Good comments explain WHY, not WHAT
const timeout = 5000; // Wait 5 seconds for MongoDB connection

// Bad comments just repeat the code
const timeout = 5000; // Set timeout to 5000

// Good JSDoc for functions
/**
 * Calculate course completion percentage
 * @param {Array} completedModules - Modules user completed
 * @param {Array} totalModules - All course modules
 * @returns {Number} Completion percentage (0-100)
 */
const getProgress = (completedModules, totalModules) => {
  return Math.round((completedModules.length / totalModules.length) * 100);
};
```

---

## Common Tasks

### Add a New API Endpoint

1. **Add route to backend/server.js:**
```javascript
app.get('/api/new-endpoint', async (req, res) => {
  try {
    const data = await Model.find();
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});
```

2. **Add test to tests/e2e/api.spec.ts:**
```javascript
test('GET /api/new-endpoint returns data', async ({ request }) => {
  const response = await request.get(`${API_URL}/new-endpoint`);
  expect(response.status()).toBe(200);
  expect(response.json()).toHaveProperty('data');
});
```

3. **Document in API.md**

4. **Commit and push:**
```bash
git add backend/ tests/ API.md
git commit -m "feat(api): add new-endpoint"
git push origin feature/new-endpoint
```

### Add a New Feature to Frontend

1. **Add HTML to frontend/index.html**
2. **Add CSS to frontend/styles.css**
3. **Add JavaScript to frontend/script.js**
4. **Add test to tests/e2e/buttons.spec.ts or new test file**
5. **Update README.md if needed**
6. **Commit and push:**
```bash
git add frontend/ tests/ README.md
git commit -m "feat(frontend): add new feature"
```

### Fix a Bug

```bash
# Create fix branch
git checkout -b fix/bug-description

# Make changes
# Add tests to verify fix
npm test

# Commit
git commit -m "fix: correct bug description"

# Push and create PR
git push origin fix/bug-description
```

---

## Helpful Resources

- [Git Documentation](https://git-scm.com/doc)
- [Express.js Guide](https://expressjs.com/)
- [MongoDB Manual](https://docs.mongodb.com/manual/)
- [Playwright Testing](https://playwright.dev/)
- [Docker Documentation](https://docs.docker.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

## Questions?

- Check existing issues/discussions
- Ask in PR comments
- Open a new discussion
- Email: devopsacademy@example.com

**Thank you for contributing! 🙏**
