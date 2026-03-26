const fs = require('fs');
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, HeadingLevel, BorderStyle, WidthType, ShadingType, PageBreak, Header, Footer, PageNumber } = require('docx');

const border = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
const borders = { top: border, bottom: border, left: border, right: border };
const cm = { top: 60, bottom: 60, left: 100, right: 100 };

function hc(text, w) {
  return new TableCell({ borders, width: { size: w, type: WidthType.DXA }, shading: { fill: "1B4332", type: ShadingType.CLEAR }, margins: cm,
    children: [new Paragraph({ children: [new TextRun({ text, bold: true, color: "FFFFFF", font: "Arial", size: 18 })] })] });
}
function tc(text, w) {
  return new TableCell({ borders, width: { size: w, type: WidthType.DXA }, margins: cm,
    children: [new Paragraph({ children: [new TextRun({ text: text || "", font: "Arial", size: 18 })] })] });
}
function mt(headers, rows, widths) {
  return new Table({ width: { size: widths.reduce((a,b)=>a+b,0), type: WidthType.DXA }, columnWidths: widths,
    rows: [new TableRow({ children: headers.map((h,i) => hc(h, widths[i])) }), ...rows.map(r => new TableRow({ children: r.map((c,i) => tc(c, widths[i])) }))] });
}
function h1(t) { return new Paragraph({ heading: HeadingLevel.HEADING_1, spacing: { before: 360, after: 200 }, children: [new TextRun({ text: t, bold: true, font: "Arial", size: 32, color: "1B4332" })] }); }
function h2(t) { return new Paragraph({ heading: HeadingLevel.HEADING_2, spacing: { before: 280, after: 160 }, children: [new TextRun({ text: t, bold: true, font: "Arial", size: 26, color: "1B4332" })] }); }
function h3(t) { return new Paragraph({ heading: HeadingLevel.HEADING_3, spacing: { before: 200, after: 120 }, children: [new TextRun({ text: t, bold: true, font: "Arial", size: 22, color: "333333" })] }); }
function p(t) { return new Paragraph({ spacing: { after: 100 }, children: [new TextRun({ text: t, font: "Arial", size: 20 })] }); }
function sp() { return new Paragraph({ spacing: { after: 60 }, children: [] }); }

const w4 = [2200, 1800, 1200, 4160];
const w3 = [3000, 2000, 4360];
const w2 = [4000, 5360];

const doc = new Document({
  styles: { default: { document: { run: { font: "Arial", size: 20 } } } },
  sections: [{
    properties: {
      page: { size: { width: 12240, height: 15840 }, margin: { top: 1200, right: 1080, bottom: 1200, left: 1080 } }
    },
    headers: { default: new Header({ children: [new Paragraph({ children: [new TextRun({ text: "Sanzen App - Admin Portal Documentation", font: "Arial", size: 16, color: "888888", italics: true })] })] }) },
    footers: { default: new Footer({ children: [new Paragraph({ children: [new TextRun({ text: "Page ", font: "Arial", size: 16, color: "888888" }), new TextRun({ children: [PageNumber.CURRENT], font: "Arial", size: 16, color: "888888" })] })] }) },
    children: [
      // TITLE PAGE
      sp(), sp(), sp(), sp(), sp(),
      new Paragraph({ spacing: { after: 200 }, children: [new TextRun({ text: "SANZEN APP", font: "Arial", size: 52, bold: true, color: "1B4332" })] }),
      new Paragraph({ spacing: { after: 100 }, children: [new TextRun({ text: "Admin Portal Documentation", font: "Arial", size: 36, color: "C2A563" })] }),
      sp(),
      new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ text: "Complete System Reference for Portal Development", font: "Arial", size: 22, color: "666666" })] }),
      new Paragraph({ spacing: { after: 60 }, children: [new TextRun({ text: "Version 1.0 | March 2026", font: "Arial", size: 20, color: "888888" })] }),
      sp(), sp(),
      mt(["Component", "Details"], [
        ["Backend API", "NestJS + Prisma ORM | http://localhost:3000/api/v1"],
        ["Database", "PostgreSQL | 72.60.186.20:5432/snzn_9366_db_prod | schema: sanzenapp"],
        ["Flutter App", "Flutter Web | http://localhost:4000"],
        ["Admin Panel", "React + Vite | http://localhost:5173"],
        ["Auth", "JWT Bearer Token | JwtAuthGuard + AdminGuard"],
      ], [3000, 6360]),

      new Paragraph({ children: [new PageBreak()] }),

      // SECTION 1: DATABASE SCHEMA
      h1("1. Database Schema (18 Tables)"),
      p("All tables are in the 'sanzenapp' schema on PostgreSQL."),
      sp(),

      h2("1.1 User"),
      mt(["Column","Type","Notes"], [
        ["id","UUID","Primary key"],["email","String","Unique, indexed"],["password","String","Hashed"],["name","String",""],["phone","String?",""],["address","String?",""],["unit","String?",""],["isAdmin","Boolean","Default false"],["resetToken","String?","Password reset"],["resetTokenExpiry","DateTime?",""],["createdAt","DateTime",""],["updatedAt","DateTime",""],
      ], w3),
      sp(),

      h2("1.2 Property"),
      mt(["Column","Type","Notes"], [
        ["id","UUID","Primary key"],["name","String","e.g. Sukoon by Sanzen"],["location","String","e.g. Sharjah Waterfront"],["propertyType","Enum","VILLA, APARTMENT, TOWNHOUSE, PENTHOUSE"],["imageUrl","String?",""],["bedrooms","Int",""],["area","Float","sqft"],["status","Enum","UNDER_CONSTRUCTION, READY, HANDOVER_COMPLETE"],["completionPercentage","Float","0-100"],["currentPhase","String?","e.g. Structure"],["estimatedCompletion","String?","e.g. Q4 2027"],["floor","String?","e.g. Second Floor"],["parking","String?","e.g. Two Covered Spaces"],["balcony","String?","e.g. Lake View"],["furnishedStatus","String?","e.g. Semi Furnished"],["amenities","String[]","e.g. [Pool, Gym, Parking]"],["downPayment","Float?","Percent e.g. 20"],["constructionPayment","Float?","Percent e.g. 50"],["handoverPayment","Float?","Percent e.g. 30"],
      ], w3),
      sp(),

      h2("1.3 UserProperty (Junction)"),
      mt(["Column","Type","Notes"], [
        ["id","UUID",""],["userId","FK -> User",""],["propertyId","FK -> Property",""],["unitCode","String","e.g. ZL-105"],["isPrimary","Boolean",""],
      ], w3),
      sp(),

      h2("1.4 Payment"),
      mt(["Column","Type","Notes"], [
        ["id","UUID",""],["userId","FK -> User",""],["propertyId","FK -> Property",""],["amount","Float",""],["currency","String","Default AED"],["paymentType","Enum","INSTALLMENT, MAINTENANCE_FEE, SERVICE_CHARGE, ADDON_PAYMENT, OTHER"],["status","Enum","PENDING, PAID, OVERDUE, CANCELLED"],["dueDate","DateTime?",""],["paidDate","DateTime?",""],["description","String?",""],["invoiceNumber","String?",""],["receiptUrl","String?",""],["installmentNumber","Int?",""],["totalInstallments","Int?",""],["percentage","Float?",""],["paymentGateway","String?",""],["paymentMethod","String?",""],["transactionId","String?",""],
      ], w3),

      new Paragraph({ children: [new PageBreak()] }),

      h2("1.5 TimelineMilestone"),
      mt(["Column","Type","Notes"], [
        ["id","UUID",""],["propertyId","FK -> Property",""],["phase","String","e.g. Phase 3"],["title","String","e.g. Structure"],["description","String?",""],["status","Enum","COMPLETED, IN_PROGRESS, PENDING, DELAYED"],["completionPercentage","Float","0-100"],["completedDate","DateTime?",""],["estimatedDate","String?",""],["orderIndex","Int","Sort order"],
      ], w3),
      sp(),

      h2("1.6 MilestoneUpdate"),
      mt(["Column","Type","Notes"], [["id","UUID",""],["milestoneId","FK -> TimelineMilestone",""],["notes","String","Update text"],["createdAt","DateTime",""],], w3),
      sp(),

      h2("1.7 MilestonePhoto"),
      mt(["Column","Type","Notes"], [["id","UUID",""],["milestoneId","FK -> TimelineMilestone",""],["milestoneUpdateId","FK -> MilestoneUpdate?",""],["photoUrl","String",""],["caption","String?",""],["photoType","Enum","BEFORE, AFTER, PROGRESS"],], w3),
      sp(),

      h2("1.8 ChangeRequest"),
      mt(["Column","Type","Notes"], [
        ["id","UUID",""],["userId","FK -> User",""],["propertyId","FK -> Property",""],["title","String",""],["description","String",""],["category","Enum","STRUCTURAL, INTERIOR, ELECTRICAL, PLUMBING, LAYOUT, MATERIAL, OTHER"],["status","Enum","SUBMITTED, UNDER_REVIEW, APPROVED, REJECTED"],["adminNotes","String?",""],["costImpact","Float?","AED amount"],["timelineImpact","String?","e.g. 2 weeks delay"],
      ], w3),
      sp(),

      h2("1.9 ReferralCode"),
      mt(["Column","Type","Notes"], [["id","UUID",""],["userId","FK -> User",""],["code","String","Unique, SANZEN-XXXXXX"],["createdAt","DateTime",""],], w3),
      sp(),

      h2("1.10 Referral"),
      mt(["Column","Type","Notes"], [
        ["id","UUID",""],["referrerId","FK -> User",""],["referralCodeId","FK -> ReferralCode",""],["referredName","String",""],["referredPhone","String",""],["referredEmail","String?",""],["status","Enum","PENDING, VERIFIED, REWARD_APPLIED, REJECTED"],["rewardAmount","Float?","AED"],["appliedToInstallment","Int?",""],["adminNotes","String?",""],
      ], w3),
      sp(),

      h2("1.11 AddonOffer"),
      mt(["Column","Type","Notes"], [["id","UUID",""],["title","String",""],["description","String",""],["imageUrl","String?",""],["icon","String?","Emoji"],["price","Float?","AED"],["category","Enum","UPGRADE, SMART_HOME, OUTDOOR, VEHICLE, SECURITY, OTHER"],["isActive","Boolean",""],], w3),
      sp(),

      h2("1.12 AddonQuote"),
      mt(["Column","Type","Notes"], [["id","UUID",""],["userId","FK -> User",""],["propertyId","FK -> Property",""],["totalPrice","Float","Sum of items"],["status","Enum","PENDING, REVIEWED, APPROVED, REJECTED"],["adminNotes","String?",""],], w3),
      sp(),

      h2("1.13 AddonQuoteItem"),
      mt(["Column","Type","Notes"], [["id","UUID",""],["quoteId","FK -> AddonQuote",""],["addonOfferId","FK -> AddonOffer",""],["price","Float",""],], w3),
      sp(),

      h2("1.14 UnitUpdate"),
      mt(["Column","Type","Notes"], [["id","UUID",""],["userId","FK -> User","Targeted user"],["updateType","Enum","GENERAL, ELECTRICAL, PLUMBING, CONSTRUCTION, INSPECTION, MILESTONE"],["title","String",""],["description","String",""],["time","String?",""],["isPublished","Boolean",""],["publishedAt","DateTime?",""],], w3),
      sp(),

      h2("1.15 CompanyNews"),
      mt(["Column","Type","Notes"], [["id","UUID",""],["category","Enum","ANNOUNCEMENT, AWARD, EVENT, SUSTAINABILITY, COMMUNITY"],["title","String",""],["description","String",""],["time","String?",""],["isPublished","Boolean",""],["isFeatured","Boolean",""],["publishedAt","DateTime?",""],], w3),
      sp(),

      h2("1.16 Document"),
      mt(["Column","Type","Notes"], [["id","UUID",""],["userId","FK -> User",""],["title","String",""],["type","String","Contract, Receipt, NOC, etc."],["fileUrl","String","Uploaded file path"],], w3),
      sp(),

      h2("1.17 Notification"),
      mt(["Column","Type","Notes"], [["id","UUID",""],["userId","FK -> User",""],["title","String",""],["message","String",""],["type","Enum","PAYMENT, DOCUMENT, UNIT_UPDATE, COMPANY_NEWS, CONSTRUCTION, SYSTEM, CHANGE_REQUEST, REFERRAL"],["isRead","Boolean",""],["relatedEntityId","String?",""],], w3),
      sp(),

      h2("1.18 Session"),
      mt(["Column","Type","Notes"], [["id","UUID",""],["userId","FK -> User",""],["token","String","JWT"],["userAgent","String?",""],["ipAddress","String?",""],["expiresAt","DateTime",""],], w3),

      new Paragraph({ children: [new PageBreak()] }),

      // SECTION 2: API ENDPOINTS
      h1("2. All API Endpoints"),
      p("Base URL: /api/v1 | Auth: JWT = Bearer token required, Admin = JwtAuthGuard + AdminGuard"),
      sp(),

      h2("2.1 Auth (/auth)"),
      mt(["Method","Endpoint","Auth","Description"], [
        ["POST","/signup","None","Register user"],["POST","/signin","None","Login, returns JWT"],["POST","/logout","JWT","Logout"],["POST","/forgot-password","None","Send OTP"],["POST","/verify-otp","None","Verify OTP"],["POST","/reset-password","None","Reset password"],["GET","/profile","JWT","Get profile"],["PUT","/profile","JWT","Update profile"],["POST","/change-password","JWT","Change password"],
      ], w4),
      sp(),

      h2("2.2 Users (/admin/users)"),
      mt(["Method","Endpoint","Auth","Description"], [["POST","/","Admin","Create user"],["GET","/","Admin","List all users"],], w4),
      sp(),

      h2("2.3 Properties (/properties)"),
      mt(["Method","Endpoint","Auth","Description"], [
        ["GET","/my-primary","JWT","User primary property"],["GET","/my","JWT","User properties (?propertyType=)"],["GET","/all","Admin","All properties"],["POST","/","Admin","Create property"],["PUT","/:id","Admin","Update property"],["DELETE","/:id","Admin","Delete property"],
      ], w4),
      sp(),

      h2("2.4 Timeline (/timeline)"),
      mt(["Method","Endpoint","Auth","Description"], [
        ["GET","/:propertyId","JWT","Get milestones"],["POST","/:propertyId","Admin","Create milestone"],["PATCH","/milestone/:id","Admin","Update milestone"],["DELETE","/milestone/:id","Admin","Delete milestone"],["POST","/milestone/:id/updates","Admin","Post update (multipart)"],["GET","/milestone/:id/updates","JWT","Get updates"],["POST","/milestone/:id/photos","Admin","Upload photo"],["GET","/:propertyId/feed","JWT","Paginated feed"],["DELETE","/update/:id","Admin","Delete update"],["DELETE","/photo/:id","Admin","Delete photo"],
      ], w4),
      sp(),

      h2("2.5 Payments (/payments)"),
      mt(["Method","Endpoint","Auth","Description"], [["GET","/my","JWT","User payments (?status=)"],["GET","/summary","JWT","Payment summary"],["GET","/:id","JWT","Payment by ID"],], w4),
      sp(),

      h2("2.6 Documents (/documents)"),
      mt(["Method","Endpoint","Auth","Description"], [
        ["POST","/upload","None","Upload (multipart)"],["GET","/","None","All documents"],["GET","/user/:userId","None","By user"],["GET","/my","JWT","User documents"],["GET","/:id/download","None","Download"],["DELETE","/:id","None","Delete"],
      ], w4),
      sp(),

      h2("2.7 Change Requests (/change-requests)"),
      mt(["Method","Endpoint","Auth","Description"], [
        ["POST","/","JWT","Submit request"],["GET","/","JWT","User requests"],["GET","/admin/all","Admin","All requests"],["GET","/:id","JWT","By ID"],["PATCH","/:id/status","Admin","Update status + notes, cost, timeline"],["PATCH","/:id","JWT","User edits own (SUBMITTED only)"],
      ], w4),
      sp(),

      h2("2.8 Referrals (/referrals)"),
      mt(["Method","Endpoint","Auth","Description"], [
        ["GET","/my-code","JWT","Get/create referral code"],["POST","/","JWT","Submit referral"],["GET","/dashboard","JWT","Dashboard with stats"],["GET","/admin/all","Admin","All referrals"],["GET","/:id","JWT","By ID"],["PATCH","/:id/status","Admin","Update status + reward, installment, notes"],
      ], w4),
      sp(),

      h2("2.9 Addon Offers (/addon-offers)"),
      mt(["Method","Endpoint","Auth","Description"], [["GET","/","JWT","All active offers"],], w4),
      sp(),

      h2("2.10 Addon Quotes (/addon-quotes)"),
      mt(["Method","Endpoint","Auth","Description"], [
        ["POST","/","JWT","Submit quote (propertyId, addonOfferIds[])"],["GET","/","JWT","User quotes"],["GET","/admin/all","Admin","All quotes"],["GET","/:id","JWT","By ID"],["PATCH","/:id/status","Admin","Update status + notes"],
      ], w4),
      sp(),

      h2("2.11 Unit Updates (/unit-updates)"),
      mt(["Method","Endpoint","Auth","Description"], [["GET","/","JWT","User updates"],["POST","/","Admin","Create"],["PUT","/:id","Admin","Update"],["DELETE","/:id","Admin","Delete"],], w4),
      sp(),

      h2("2.12 Company News (/company-news)"),
      mt(["Method","Endpoint","Auth","Description"], [["GET","/","JWT","All news"],["POST","/","Admin","Create"],["PUT","/:id","Admin","Update"],["DELETE","/:id","Admin","Delete"],], w4),
      sp(),

      h2("2.13 Notifications (/notifications)"),
      mt(["Method","Endpoint","Auth","Description"], [["GET","/","JWT","User notifications (last 50)"],["PATCH","/:id/read","JWT","Mark read"],["PATCH","/read-all","JWT","Mark all read"],], w4),

      new Paragraph({ children: [new PageBreak()] }),

      // SECTION 3: CURRENT ADMIN PANEL
      h1("3. Current Admin Panel Pages"),
      mt(["Page","Route","What It Manages"], [
        ["Users","/dashboard","Create users/admins"],
        ["Documents","/documents","Upload/delete documents for users"],
        ["Company News","/company-news","Post announcements, events, awards"],
        ["Unit Updates","/unit-updates","Send personalized updates to users"],
        ["Properties","/properties","Create/edit/delete properties"],
        ["Timeline","/timeline","Manage milestones, construction updates"],
        ["Add-on Quotes","/addon-quotes","Review/approve/reject quote requests"],
        ["Login","/login","Admin authentication"],
      ], [2500, 2500, 4360]),

      new Paragraph({ children: [new PageBreak()] }),

      // SECTION 4: WHAT PORTAL NEEDS
      h1("4. What the New Portal Needs to Build"),
      sp(),

      h2("4.1 Backend API Ready - Need UI Only"),
      mt(["Feature","Admin Endpoints Available","What Portal Needs"], [
        ["Change Requests Manager","GET /change-requests/admin/all, PATCH /:id/status","UI to review, approve/reject with cost & timeline impact"],
        ["Referrals Manager","GET /referrals/admin/all, PATCH /:id/status","UI to verify, apply rewards to installments"],
      ], [2500, 3500, 3360]),
      sp(),

      h2("4.2 Need Both API Endpoints + UI"),
      mt(["Feature","What Backend Needs","What Portal Needs"], [
        ["Payments Manager","Admin CRUD: create plans, mark paid, track overdue","Dashboard with payment overview, create/edit payments"],
        ["Addon Offers Manager","Admin CRUD: create/edit/deactivate products","Product management with images, pricing, categories"],
        ["Notifications Manager","Admin send endpoint","Send custom notifications to users/groups"],
        ["User Manager (Full)","Edit/delete/search endpoints","Full user list, search, edit profiles, delete accounts"],
      ], [2500, 3500, 3360]),

      new Paragraph({ children: [new PageBreak()] }),

      // SECTION 5: STATUS WORKFLOWS
      h1("5. Status Workflows"),
      sp(),
      mt(["Feature","Workflow"], [
        ["Change Request","SUBMITTED -> UNDER_REVIEW -> APPROVED / REJECTED"],
        ["Referral","PENDING -> VERIFIED -> REWARD_APPLIED / REJECTED"],
        ["Addon Quote","PENDING -> REVIEWED -> APPROVED / REJECTED"],
        ["Payment","PENDING -> PAID / OVERDUE / CANCELLED"],
        ["Milestone","PENDING -> IN_PROGRESS -> COMPLETED / DELAYED"],
      ], [3000, 6360]),

      sp(), sp(),

      // SECTION 6: ENUMS
      h1("6. All Enums Reference"),
      mt(["Enum Name","Values"], [
        ["PropertyType","VILLA, APARTMENT, TOWNHOUSE, PENTHOUSE"],
        ["PropertyStatus","UNDER_CONSTRUCTION, READY, HANDOVER_COMPLETE"],
        ["MilestoneStatus","COMPLETED, IN_PROGRESS, PENDING, DELAYED"],
        ["PhotoType","BEFORE, AFTER, PROGRESS"],
        ["PaymentType","INSTALLMENT, MAINTENANCE_FEE, SERVICE_CHARGE, ADDON_PAYMENT, OTHER"],
        ["PaymentStatus","PENDING, PAID, OVERDUE, CANCELLED"],
        ["ChangeRequestCategory","STRUCTURAL, INTERIOR, ELECTRICAL, PLUMBING, LAYOUT, MATERIAL, OTHER"],
        ["ChangeRequestStatus","SUBMITTED, UNDER_REVIEW, APPROVED, REJECTED"],
        ["AddonCategory","UPGRADE, SMART_HOME, OUTDOOR, VEHICLE, SECURITY, OTHER"],
        ["AddonQuoteStatus","PENDING, REVIEWED, APPROVED, REJECTED"],
        ["ReferralStatus","PENDING, VERIFIED, REWARD_APPLIED, REJECTED"],
        ["UpdateType","GENERAL, ELECTRICAL, PLUMBING, CONSTRUCTION, INSPECTION, MILESTONE"],
        ["NewsCategory","ANNOUNCEMENT, AWARD, EVENT, SUSTAINABILITY, COMMUNITY"],
        ["NotificationType","PAYMENT, DOCUMENT, UNIT_UPDATE, COMPANY_NEWS, CONSTRUCTION, SYSTEM, CHANGE_REQUEST, REFERRAL"],
      ], [3500, 5860]),
    ]
  }]
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync("C:\\Users\\Administrator\\Desktop\\Sanzen-app-new\\Sanzen_Admin_Portal_Documentation.docx", buffer);
  console.log("Document created successfully!");
});
