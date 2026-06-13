const http = require('http');

// Test admin login
const loginData = JSON.stringify({ username: 'admin', password: 'admin123' });
const loginReq = http.request({
  hostname: 'localhost',
  port: 3000,
  path: '/api/admin/login',
  method: 'POST',
  headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(loginData) }
}, function(res) {
  let b = '';
  res.on('data', function(c) { b += c });
  res.on('end', function() {
    console.log('Login:', res.statusCode, b);
    const token = JSON.parse(b).token;
    
    // Get stats
    http.get({
      hostname: 'localhost',
      port: 3000,
      path: '/api/admin/stats',
      headers: { 'Authorization': 'Bearer ' + token }
    }, function(res2) {
      let b2 = '';
      res2.on('data', function(c) { b2 += c });
      res2.on('end', function() { console.log('Stats:', res2.statusCode, b2) });
    });

    // Get enrollments
    http.get({
      hostname: 'localhost',
      port: 3000,
      path: '/api/admin/enrollments',
      headers: { 'Authorization': 'Bearer ' + token }
    }, function(res3) {
      let b3 = '';
      res3.on('data', function(c) { b3 += c });
      res3.on('end', function() { console.log('Enrollments:', res3.statusCode, b3) });
    });
  });
});
loginReq.write(loginData);
loginReq.end();
