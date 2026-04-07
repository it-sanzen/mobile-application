const http = require('http');

const data = JSON.stringify({
  email: 'test_final@example.com',
  password: 'password123'
});

const req = http.request({
  hostname: 'localhost',
  port: 3000,
  path: '/api/v1/auth/signin',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
}, (res) => {
  let body = '';
  res.on('data', d => body += d);
  res.on('end', () => {
    let token = JSON.parse(body).token;
    console.log('Token len:', token.length);
    if (!token) {
       console.log('Login failed:', body); return;
    }
    const updateData = JSON.stringify({ phone: '12345' });
    const req2 = http.request({
      hostname: 'localhost',
      port: 3000,
      path: '/api/v1/auth/profile',
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token,
        'Content-Length': updateData.length
      }
    }, (res2) => {
      let body2 = '';
      res2.on('data', d => body2 += d);
      res2.on('end', () => console.log('Profile update response:', res2.statusCode, body2));
    });
    req2.write(updateData);
    req2.end();
  });
});
req.write(data);
req.end();
