import puppeteer from 'puppeteer';

(async () => {
    try {
        const browser = await puppeteer.launch();
        const page = await browser.newPage();

        page.on('console', msg => console.log('BROWSER CONSOLE:', msg.text()));
        page.on('pageerror', error => console.error('BROWSER ERROR:', error.message));
        page.on('requestfailed', request => console.log('BROWSER REQUEST FAILED:', request.url(), request.failure()?.errorText));

        await page.goto('http://localhost:5173/login', { waitUntil: 'networkidle0' });
        console.log('Page loaded successfully');
        const content = await page.content();
        console.log("HTML Start:", content.substring(0, 100));
        await browser.close();
    } catch (e) {
        console.error(e);
    }
})();
