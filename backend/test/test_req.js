
const http = require('http');
const req = http.request({
  hostname: 'localhost', port: 3000, path: '/api/v1/auth/signin', method: 'POST',
  headers: { 'Content-Type': 'application/json' }
}, (res) => {
  let body = ''; res.on('data', d => body += d);
  res.on('end', () => {
    let json = JSON.parse(body);
    let token = json.token || (json.data && json.data.token) || json.accessToken;
    const req2 = http.request({
      hostname: 'localhost', port: 3000, path: '/api/v1/auth/profile', method: 'PUT',
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token }
    }, (res2) => {
      let body2 = ''; res2.on('data', d => body2 += d);
      res2.on('end', () => { 
          require('fs').writeFileSync('payload_dump.txt', body2); 
          console.log('Done!');
      });
    });
    req2.write(JSON.stringify({ phone: '123' })); req2.end();
  });
});
req.write(JSON.stringify({email: 'test_final@example.com', password: 'password123'})); req.end();

