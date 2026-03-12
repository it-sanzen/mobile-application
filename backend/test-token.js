const http = require('http');

async function testNotification() {
    // 1. Get Token
    const loginData = JSON.stringify({ email: 'admin@admin.com', password: '123' });
    const token = await new Promise((resolve) => {
        const req = http.request({ hostname: 'localhost', port: 3000, path: '/api/v1/auth/signin', method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': loginData.length } }, (res) => {
            let body = '';
            res.on('data', d => body += d);
            res.on('end', () => resolve(JSON.parse(body).data?.accessToken));
        });
        req.write(loginData); req.end();
    });

    if (!token) return console.log('Login failed');

    // 2. Trigger Unit Update (which should internally trigger Notification DB insert)
    // Let's get the user ID first
    const profileData = await new Promise((resolve) => {
        const pReq = http.request({ hostname: 'localhost', port: 3000, path: '/api/v1/auth/profile', method: 'GET', headers: { 'Authorization': `Bearer ${token}` } }, (res) => {
            let body = ''; res.on('data', d => body += d); res.on('end', () => resolve(JSON.parse(body).data));
        });
        pReq.end();
    });

    const updateData = JSON.stringify({ userId: profileData.id, updateType: 'PLUMBING', title: 'Test DB Notification', description: 'Checking persistent Inbox.', time: 'Now', isPublished: true });

    const req = http.request({ hostname: 'localhost', port: 3000, path: '/api/v1/unit-updates', method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': updateData.length, 'Authorization': `Bearer ${token}` } }, (res) => {
        let body = '';
        res.on('data', d => body += d);
        res.on('end', () => console.log('Update Created:', body));
    });
    req.write(updateData); req.end();
}

testNotification();
