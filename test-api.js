const http = require('http');
const d = JSON.stringify({
  firstName: 'Ahmed',
  lastName: 'Hassan',
  email: 'ahmed@example.com',
  phone: '01112345678',
  course: 'kubernetes',
  experience: 'intermediate',
  message: 'Test from script'
});
const r = http.request({
  hostname: 'localhost',
  port: 3000,
  path: '/api/enroll',
  method: 'POST',
  headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(d) }
}, function(res) {
  let b = '';
  res.on('data', function(c) { b += c });
  res.on('end', function() { console.log('Enroll response:', res.statusCode, b) });
});
r.write(d);
r.end();
