import { PrismaClient } from '@prisma/client';
import PDFDocument from 'pdfkit';
import * as fs from 'fs';
import * as path from 'path';

const prisma = new PrismaClient();

const UPLOADS_DIR = path.join(__dirname, '..', 'uploads', 'documents');

function ensureDir(dir: string) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function generateSPA(filePath: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ size: 'A4', margin: 60 });
    const stream = fs.createWriteStream(filePath);
    doc.pipe(stream);

    const primaryColor = '#1a3a5c';
    const accentColor = '#2c6faa';
    const lightGray = '#f5f5f5';
    const textColor = '#333333';
    const lineColor = '#cccccc';

    // Header bar
    doc.rect(0, 0, doc.page.width, 100).fill(primaryColor);
    doc.fontSize(28).fillColor('#ffffff').font('Helvetica-Bold')
      .text('SANZEN PROPERTIES', 60, 30, { align: 'left' });
    doc.fontSize(10).fillColor('#ccddee').font('Helvetica')
      .text('Excellence in Real Estate Development', 60, 62);

    // Title block
    doc.moveDown(2);
    const titleY = 130;
    doc.rect(60, titleY, doc.page.width - 120, 50).fill(lightGray);
    doc.fontSize(18).fillColor(primaryColor).font('Helvetica-Bold')
      .text('SALES PURCHASE AGREEMENT (SPA)', 60, titleY + 14, { align: 'center' });

    // Reference & Date
    doc.moveDown(1);
    const refY = titleY + 65;
    doc.fontSize(9).fillColor(textColor).font('Helvetica')
      .text(`Reference No: SPA-ZL-2026-0105`, 60, refY)
      .text(`Date: 15 January 2026`, 60, refY + 14)
      .text(`Project: Sukoon by Sanzen - Zen Lagoons`, 60, refY + 28);

    doc.moveTo(60, refY + 48).lineTo(doc.page.width - 60, refY + 48).strokeColor(lineColor).stroke();

    let y = refY + 62;

    // Section helper
    function section(title: string, content: string[]) {
      doc.fontSize(12).fillColor(accentColor).font('Helvetica-Bold')
        .text(title, 60, y);
      y += 18;
      doc.moveTo(60, y).lineTo(250, y).strokeColor(accentColor).lineWidth(1).stroke();
      y += 8;

      doc.fontSize(9.5).fillColor(textColor).font('Helvetica');
      for (const line of content) {
        if (y > 720) {
          doc.addPage();
          y = 60;
        }
        doc.text(line, 70, y, { width: doc.page.width - 140 });
        y += doc.heightOfString(line, { width: doc.page.width - 140 }) + 4;
      }
      y += 12;
    }

    // 1. PARTIES
    section('1. PARTIES', [
      'THE SELLER: Sanzen Properties LLC, a company incorporated under the laws of the United Arab Emirates, with its registered office at Tower B, Sanzen Business Park, Al Majaz 3, Sharjah, UAE (hereinafter referred to as "the Developer").',
      '',
      'THE BUYER: [Buyer Name as per Emirates ID], holder of Emirates ID No. [XXX-XXXX-XXXXXXX-X], residing at [Address], (hereinafter referred to as "the Purchaser").',
    ]);

    // 2. PROPERTY DETAILS
    section('2. PROPERTY DETAILS', [
      'Unit Designation:        Villa ZL-105',
      'Project Name:            Sukoon by Sanzen - Zen Lagoons',
      'Location:                Sharjah Waterfront, Sharjah, UAE',
      'Property Type:           4-Bedroom Detached Villa',
      'Built-Up Area:           4,500 sq. ft. (approximately 418 sq. m.)',
      'Plot Area:               6,200 sq. ft. (approximately 576 sq. m.)',
      'Covered Parking:         2 designated spaces',
      'Handover Condition:      Shell & Core with Standard Finishes',
    ]);

    // 3. PURCHASE PRICE
    section('3. PURCHASE PRICE AND PAYMENT', [
      'The total purchase price for the Property shall be:',
      '',
      '    AED 2,850,000 (Two Million Eight Hundred Fifty Thousand UAE Dirhams)',
      '',
      'The Purchase Price shall be paid in accordance with the following payment plan:',
      '',
      '  Installment 1:    5%    AED 142,500      Upon Booking',
      '  Installment 2:    5%    AED 142,500      30 Days from Booking',
      '  Installment 3:    5%    AED 142,500      120 Days from Booking',
      '  Installment 4:    5%    AED 142,500      240 Days from Booking',
      '  Installment 5:    5%    AED 142,500      360 Days from Booking',
      '  Installment 6:    5%    AED 142,500      480 Days from Booking',
      '  Installment 7:    5%    AED 142,500      600 Days from Booking',
      '  Installment 8:    5%    AED 142,500      720 Days from Booking',
      '  On Handover:     60%    AED 1,710,000    Upon Completion & Handover',
      '',
      'All payments shall be made by cheque or bank transfer to the designated escrow account as specified by the Developer.',
    ]);

    // 4. COMPLETION
    section('4. COMPLETION AND HANDOVER', [
      'The Developer shall use reasonable efforts to complete construction of the Property by Q4 2027, subject to force majeure, regulatory approvals, and other conditions beyond the Developer\'s reasonable control.',
      '',
      'Upon completion, the Developer shall issue a Completion Notice to the Purchaser. The Purchaser shall complete all outstanding payments and collect the keys within 30 days of the Completion Notice.',
      '',
      'A snagging period of 12 months from the handover date shall apply, during which the Developer will rectify any construction defects at no additional cost to the Purchaser.',
    ]);

    // Page 2
    doc.addPage();
    y = 60;

    // 5. TITLE AND REGISTRATION
    section('5. TITLE AND REGISTRATION', [
      'Upon receipt of the full Purchase Price, the Developer shall transfer the title of the Property to the Purchaser and register the same with the Sharjah Real Estate Registration Department (SRERD).',
      '',
      'The Purchaser shall be responsible for all applicable registration fees, transfer fees, and government charges related to the transfer of title.',
    ]);

    // 6. DEFAULT
    section('6. DEFAULT AND TERMINATION', [
      'In the event the Purchaser fails to make any payment within 30 days of its due date, the Developer shall issue a written notice of default. If the Purchaser fails to remedy the default within 60 days of such notice, the Developer shall be entitled to terminate this Agreement.',
      '',
      'Upon termination due to Purchaser default, the Developer may deduct up to 30% of the total purchase price as liquidated damages, refunding the balance within 90 days.',
    ]);

    // 7. GENERAL PROVISIONS
    section('7. GENERAL PROVISIONS', [
      '7.1  This Agreement constitutes the entire agreement between the Parties and supersedes all prior negotiations, representations, or agreements.',
      '7.2  Any amendments must be in writing and signed by both Parties.',
      '7.3  This Agreement shall be governed by and construed in accordance with the laws of the Emirate of Sharjah and the Federal Laws of the UAE.',
      '7.4  Any disputes shall be referred to the Sharjah International Commercial Arbitration Centre (Tahkeem).',
      '7.5  Notices shall be sent to the addresses specified herein or as updated in writing.',
    ]);

    // Signature block
    y += 20;
    doc.fontSize(11).fillColor(primaryColor).font('Helvetica-Bold')
      .text('SIGNATURES', 60, y);
    y += 25;

    doc.fontSize(9.5).fillColor(textColor).font('Helvetica');
    // Seller
    doc.text('For and on behalf of THE DEVELOPER:', 60, y);
    y += 30;
    doc.moveTo(60, y).lineTo(250, y).strokeColor(lineColor).stroke();
    y += 4;
    doc.text('Name: ____________________________', 60, y);
    y += 14;
    doc.text('Title:  Chief Executive Officer', 60, y);
    y += 14;
    doc.text('Date:   _____ / _____ / 2026', 60, y);

    y -= 62;
    // Buyer
    doc.text('For and on behalf of THE PURCHASER:', 310, y);
    y += 30;
    doc.moveTo(310, y).lineTo(500, y).strokeColor(lineColor).stroke();
    y += 4;
    doc.text('Name: ____________________________', 310, y);
    y += 14;
    doc.text('Signature', 310, y);
    y += 14;
    doc.text('Date:   _____ / _____ / 2026', 310, y);

    // Footer
    const footerY = doc.page.height - 40;
    doc.fontSize(7).fillColor('#999999').font('Helvetica')
      .text('Sanzen Properties LLC | Al Majaz 3, Sharjah, UAE | www.sanzenproperties.com | +971 6 XXX XXXX', 60, footerY, { align: 'center', width: doc.page.width - 120 });

    doc.end();
    stream.on('finish', resolve);
    stream.on('error', reject);
  });
}

function generateNOC(filePath: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ size: 'A4', margin: 60 });
    const stream = fs.createWriteStream(filePath);
    doc.pipe(stream);

    const primaryColor = '#1a3a5c';
    const accentColor = '#2c6faa';
    const lightGray = '#f5f5f5';
    const textColor = '#333333';
    const lineColor = '#cccccc';

    // Header bar
    doc.rect(0, 0, doc.page.width, 100).fill(primaryColor);
    doc.fontSize(28).fillColor('#ffffff').font('Helvetica-Bold')
      .text('SANZEN PROPERTIES', 60, 30, { align: 'left' });
    doc.fontSize(10).fillColor('#ccddee').font('Helvetica')
      .text('Excellence in Real Estate Development', 60, 62);

    // Title block
    const titleY = 130;
    doc.rect(60, titleY, doc.page.width - 120, 50).fill(lightGray);
    doc.fontSize(18).fillColor(primaryColor).font('Helvetica-Bold')
      .text('NO OBJECTION CERTIFICATE (NOC)', 60, titleY + 14, { align: 'center' });

    // Reference & Date
    const refY = titleY + 65;
    doc.fontSize(9).fillColor(textColor).font('Helvetica')
      .text('Reference No: NOC-ZL-2026-0042', 60, refY)
      .text('Date of Issue: 10 March 2026', 60, refY + 14)
      .text('Valid Until: 10 September 2026', 60, refY + 28);

    doc.moveTo(60, refY + 48).lineTo(doc.page.width - 60, refY + 48).strokeColor(lineColor).stroke();

    let y = refY + 65;

    // TO WHOM IT MAY CONCERN
    doc.fontSize(12).fillColor(primaryColor).font('Helvetica-Bold')
      .text('TO WHOM IT MAY CONCERN', 60, y, { align: 'center', width: doc.page.width - 120 });
    y += 30;

    doc.fontSize(10).fillColor(textColor).font('Helvetica');

    const para1 = 'This is to certify that Sanzen Properties LLC, the developer of the "Sukoon by Sanzen - Zen Lagoons" project located at Sharjah Waterfront, Sharjah, United Arab Emirates, hereby issues this No Objection Certificate in favor of the unit owner detailed below:';
    doc.text(para1, 60, y, { width: doc.page.width - 120, lineGap: 3 });
    y += doc.heightOfString(para1, { width: doc.page.width - 120 }) + 20;

    // Owner Details box
    doc.rect(60, y, doc.page.width - 120, 110).fill('#f8fafb').stroke(lineColor);
    y += 12;
    doc.fontSize(10).fillColor(primaryColor).font('Helvetica-Bold')
      .text('UNIT OWNER DETAILS', 75, y);
    y += 20;
    doc.fontSize(9.5).fillColor(textColor).font('Helvetica');
    const details = [
      ['Owner Name:', '[As per Title Deed / SPA]'],
      ['Unit Number:', 'Villa ZL-105'],
      ['Project:', 'Sukoon by Sanzen - Zen Lagoons'],
      ['SPA Reference:', 'SPA-ZL-2026-0105'],
    ];
    for (const [label, value] of details) {
      doc.font('Helvetica-Bold').text(label, 75, y, { continued: true, width: 130 });
      doc.font('Helvetica').text(`  ${value}`, { width: 300 });
      y += 16;
    }
    y += 20;

    // Purpose
    doc.fontSize(11).fillColor(accentColor).font('Helvetica-Bold')
      .text('PURPOSE OF NOC', 60, y);
    y += 5;
    doc.moveTo(60, y).lineTo(210, y).strokeColor(accentColor).lineWidth(1).stroke();
    y += 12;

    doc.fontSize(10).fillColor(textColor).font('Helvetica');
    const purpose = 'Sanzen Properties LLC has no objection to the unit owner carrying out the following interior modification works within the above-referenced unit, subject to compliance with the conditions stated herein:';
    doc.text(purpose, 60, y, { width: doc.page.width - 120, lineGap: 3 });
    y += doc.heightOfString(purpose, { width: doc.page.width - 120 }) + 15;

    // Scope of work
    const scopeItems = [
      'Interior painting and wall finishing (non-structural)',
      'Installation of built-in wardrobes and kitchen cabinetry',
      'Flooring replacement (tiles, marble, or engineered wood)',
      'Electrical fixture upgrades (lighting, switches, outlets)',
      'Plumbing fixture replacement (sanitary ware, faucets)',
      'Installation of smart home systems and automation',
      'False ceiling installation with integrated lighting',
      'Interior landscaping of private courtyard area',
    ];

    for (const item of scopeItems) {
      doc.fontSize(9.5).fillColor(textColor).font('Helvetica');
      doc.text(`    \u2022  ${item}`, 60, y, { width: doc.page.width - 120 });
      y += 15;
    }
    y += 10;

    // Conditions
    doc.fontSize(11).fillColor(accentColor).font('Helvetica-Bold')
      .text('CONDITIONS', 60, y);
    y += 5;
    doc.moveTo(60, y).lineTo(165, y).strokeColor(accentColor).lineWidth(1).stroke();
    y += 12;

    doc.fontSize(9.5).fillColor(textColor).font('Helvetica');
    const conditions = [
      '1.  No structural modifications shall be made to load-bearing walls, columns, beams, or the building facade without prior written approval from the Developer\'s structural engineer.',
      '2.  All works must comply with Sharjah Municipality building codes and civil defense regulations.',
      '3.  The unit owner shall engage only licensed and insured contractors approved by Sharjah Municipality.',
      '4.  Work shall be carried out during permitted hours (8:00 AM to 6:00 PM, Saturday to Thursday) to minimize disturbance to neighboring units.',
      '5.  The unit owner shall be solely responsible for any damage caused to common areas during the modification works and shall restore any damage at their own expense.',
      '6.  A refundable security deposit of AED 10,000 shall be held by the Developer to cover potential damage to common areas.',
    ];

    for (const cond of conditions) {
      if (y > 680) {
        doc.addPage();
        y = 60;
      }
      doc.text(cond, 60, y, { width: doc.page.width - 120, lineGap: 2 });
      y += doc.heightOfString(cond, { width: doc.page.width - 120 }) + 6;
    }

    // Page 2 if needed, or continue
    if (y > 550) {
      doc.addPage();
      y = 60;
    }

    y += 15;

    // Disclaimer
    doc.fontSize(9).fillColor('#666666').font('Helvetica-Oblique');
    const disclaimer = 'This NOC is issued solely for the purpose stated above and does not constitute approval for any works beyond the scope described herein. This certificate is valid for a period of six (6) months from the date of issue. The Developer reserves the right to revoke this NOC if any conditions are violated.';
    doc.text(disclaimer, 60, y, { width: doc.page.width - 120, lineGap: 2 });
    y += doc.heightOfString(disclaimer, { width: doc.page.width - 120 }) + 30;

    // Authorized signatory
    doc.fontSize(10).fillColor(textColor).font('Helvetica')
      .text('Issued by:', 60, y);
    y += 20;
    doc.font('Helvetica-Bold').text('Sanzen Properties LLC', 60, y);
    y += 14;
    doc.font('Helvetica').text('Property Management Division', 60, y);
    y += 30;
    doc.moveTo(60, y).lineTo(250, y).strokeColor(lineColor).stroke();
    y += 5;
    doc.text('Authorized Signatory', 60, y);
    y += 14;
    doc.text('Name: Ahmed Al Rashid', 60, y);
    y += 14;
    doc.text('Title: Director of Property Management', 60, y);

    // Stamp placeholder
    y -= 42;
    doc.rect(350, y, 130, 60).strokeColor(accentColor).lineWidth(2).dash(3, { space: 3 }).stroke();
    doc.undash();
    doc.fontSize(8).fillColor(accentColor).font('Helvetica')
      .text('[Company Stamp]', 375, y + 24);

    // Footer
    const footerY = doc.page.height - 40;
    doc.fontSize(7).fillColor('#999999').font('Helvetica')
      .text('Sanzen Properties LLC | Al Majaz 3, Sharjah, UAE | www.sanzenproperties.com | +971 6 XXX XXXX', 60, footerY, { align: 'center', width: doc.page.width - 120 });

    doc.end();
    stream.on('finish', resolve);
    stream.on('error', reject);
  });
}

async function main() {
  ensureDir(UPLOADS_DIR);

  console.log('Finding demo user...');
  const user = await prisma.user.findUnique({
    where: { email: 'firstuser@gmail.com' },
  });

  if (!user) {
    console.error('User firstuser@gmail.com not found! Run the main seed first.');
    process.exit(1);
  }

  console.log(`Found user: ${user.id}`);

  // Generate PDFs
  const spaFilename = 'SPA-ZL105-2026.pdf';
  const nocFilename = 'NOC-ZL105-Interior-2026.pdf';
  const spaPath = path.join(UPLOADS_DIR, spaFilename);
  const nocPath = path.join(UPLOADS_DIR, nocFilename);

  console.log('Generating Sales Purchase Agreement PDF...');
  await generateSPA(spaPath);
  console.log(`  Created: ${spaPath}`);

  console.log('Generating No Objection Certificate PDF...');
  await generateNOC(nocPath);
  console.log(`  Created: ${nocPath}`);

  // Delete existing documents with same titles to avoid duplicates
  await prisma.document.deleteMany({
    where: {
      userId: user.id,
      title: {
        in: [
          'Sales Purchase Agreement - Villa ZL-105',
          'NOC - Interior Modifications - Villa ZL-105',
        ],
      },
    },
  });

  // Create database records
  console.log('Creating Document records in database...');
  const spa = await prisma.document.create({
    data: {
      title: 'Sales Purchase Agreement - Villa ZL-105',
      type: 'Contract',
      fileUrl: `/uploads/documents/${spaFilename}`,
      userId: user.id,
    },
  });
  console.log(`  SPA Document ID: ${spa.id}`);

  const noc = await prisma.document.create({
    data: {
      title: 'NOC - Interior Modifications - Villa ZL-105',
      type: 'NOC',
      fileUrl: `/uploads/documents/${nocFilename}`,
      userId: user.id,
    },
  });
  console.log(`  NOC Document ID: ${noc.id}`);

  console.log('\nDone! 2 documents seeded successfully.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
