import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Profile & Settings
      'profile': 'Profile',
      'language': 'Language',
      'personal_details': 'Personal Details',
      'notifications': 'Notifications',
      'security': 'Security',
      'my_properties': 'My Properties',
      'documents': 'Documents',
      'payments': 'Payments',
      'support_help': 'Support & Help',
      'about_sanzen': 'About Sanzen',
      'logout': 'Logout',
      'edit_profile': 'Edit Profile',
      'account_settings': 'Account Settings',
      'preferences': 'Preferences',
      'confirm': 'Confirm',
      'language_set_to': 'Language set to',
      // Home Page
      'good_morning': 'Good Morning,',
      'my_property': 'My Property',
      'details': 'DETAILS',
      'foundation_stage': 'Foundation Stage',
      'est_completion': 'Est. Completion:',
      'view_timeline': 'View Timeline',
      'unit_updates': 'Unit Updates',
      'company_news': 'Company News',
      'exclusive_addons': 'Exclusive Add-ons',
      'view_offer': 'View Offer',
      'home': 'Home',
      'properties': 'Properties',
      // Documents Page
      'your_files': 'Your Files',
      'my_documents': 'My Documents',
      'all': 'All',
      'contracts': 'Contracts',
      'receipts': 'Receipts',
      'noc': 'NOC',
      'sales_purchase_agreement': 'Sales Purchase Agreement',
      'payment_receipt': 'Payment Receipt',
      'no_objection_certificate': 'No Objection Certificate',
      'unit_handover_agreement': 'Unit Handover Agreement',
      'parking_noc': 'Parking NOC',
      'interior_modification_contract': 'Interior Modification Contract',
      // Properties Page
      'properties_owned': 'properties owned',
      'total': 'Total',
      'building': 'Building',
      'ready': 'Ready',
      'villa': 'Villa',
      'apartment': 'Apartment',
      'townhouse': 'Townhouse',
      'under_construction': 'Under Construction',
      'construction_progress': 'Construction Progress',
      'view_details': 'View Details',
      // Edit Profile Page
      'full_name': 'Full Name',
      'email_address': 'Email Address',
      'phone_number': 'Phone Number',
      'address': 'Address',
      'save_changes': 'Save Changes',
      'profile_updated': 'Profile updated successfully!',
      'failed_update_profile': 'Failed to update profile',
      // Change Password Page
      'change_password': 'Change Password',
      'keep_account_secure': 'Keep your account secure',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'update_password': 'Update Password',
      'passwords_not_match': 'New passwords do not match',
      'password_updated': 'Password updated successfully! Please log in with your new password.',
      'failed_update_password': 'Failed to update password',
      'password_must_contain': 'Password must contain:',
      'at_least_8_chars': 'At least 8 characters',
      'one_uppercase': 'One uppercase letter',
      'one_number': 'One number',
      'one_special_char': 'One special character',
      // Notification Preferences Page
      'notification_preferences': 'Notification Preferences',
      'notification_types': 'Notification Types',
      'construction_progress_info': 'Construction progress & unit info',
      'latest_announcements': 'Latest announcements & events',
      'payment_reminders': 'Payment Reminders',
      'upcoming_overdue': 'Upcoming & overdue payment alerts',
      'construction_milestones': 'Construction Milestones',
      'phase_completion': 'Phase completion notifications',
      'promotions_offers': 'Promotions & Offers',
      'exclusive_seasonal': 'Exclusive add-ons & seasonal offers',
      'delivery_channels': 'Delivery Channels',
      'email_notifications': 'Email Notifications',
      'receive_via_email': 'Receive updates via email',
      'push_notifications': 'Push Notifications',
      'receive_push_alerts': 'Receive push alerts on your device',
      // Help & Support Page
      'help_support': 'Help & Support',
      'need_help': 'Need Help?',
      'support_hours': 'Our support team is available\nSun–Thu, 9 AM – 6 PM (GST)',
      'call_us': 'Call Us',
      'email': 'Email',
      'faq': 'Frequently Asked Questions',
      'faq_q1': 'How do I track my construction progress?',
      'faq_a1': 'You can view your construction timeline from the home screen by tapping "View Timeline". This shows all construction milestones, including completed, in-progress, and upcoming phases.',
      'faq_q2': 'How do I make a payment?',
      'faq_a2': 'Navigate to the Documents tab to view your payment schedule. You can make payments through bank transfer using the details provided in your Sales Purchase Agreement, or contact your property manager for assistance.',
      'faq_q3': 'Can I customize my unit?',
      'faq_a3': 'Yes! Check out the Exclusive Add-ons section on the home screen for available customization options including Private Pool, EV Charger, Home Automation, and more.',
      'faq_q4': 'How do I download my documents?',
      'faq_a4': 'Go to the Documents tab from the bottom navigation bar. You\'ll find all your contracts, receipts, and NOC documents. Tap the download icon next to any document to save it to your device.',
      'faq_q5': 'When will my unit be ready for handover?',
      'faq_a5': 'The estimated completion date is shown on your property card on the home screen and in the construction timeline. You\'ll receive a notification when the handover date is confirmed.',
      'submit_request': 'Submit a Request',
      'support_submitted': 'Support request submitted! We\'ll get back to you within 24 hours.',
      'dialing': 'Dialing +971 56 666 0839...',
      'opening_email': 'Opening email to it.sanzenae@gmail.com...',
      // About Sanzen Page
      'our_story': 'Our Story',
      'our_story_text': 'Sanzen Properties is a premier real estate developer based in Dubai, UAE. Founded with a vision to redefine modern living, Sanzen creates exceptional residential communities that blend architectural excellence with sustainable design.\n\nWith over 15 years of experience in the UAE\'s dynamic real estate market, we have developed award-winning projects that set new benchmarks in quality, innovation, and customer satisfaction.',
      'our_mission': 'Our Mission',
      'our_mission_text': 'To build sustainable, innovative living spaces that enhance the quality of life for our homeowners, while setting new standards of excellence in the real estate industry.',
      'our_vision': 'Our Vision',
      'our_vision_text': 'Our vision is to lead mindful development in the UAE - creating communities that balance beauty with proof. We design for quiet, publish our measures, honor time and trust, and leave every family with a deeper ease that improves with age.',
      'by_the_numbers': 'By the Numbers',
      'years': 'Years',
      'units': 'Units',
      'projects': 'Projects',
      'rating': 'Rating',
      'follow_us': 'Follow Us',
      'website': 'Website',
      'app_version': 'Sanzen App v1.0.0',
      'copyright': '© 2025 Sanzen Properties LLC. All rights reserved.',
      // Privacy Policy Page
      'privacy_policy': 'Privacy Policy',
      'last_updated': 'Last Updated: January 1, 2025',
      'pp_s1_title': '1. Information We Collect',
      'pp_s1': 'Sanzen Properties ("we", "us", or "our") collects personal information that you voluntarily provide when you register for an account, express interest in obtaining information about us or our products, or otherwise contact us.\n\nPersonal information may include your name, email address, phone number, mailing address, property preferences, payment information, and any other information you choose to provide.',
      'pp_s2_title': '2. How We Use Your Information',
      'pp_s2': 'We use the information we collect to:\n\n• Provide, operate, and maintain our services\n• Process transactions and send related information\n• Send you construction updates and property notifications\n• Respond to your comments, questions, and requests\n• Send you technical notices, updates, and security alerts\n• Provide personalized content and recommendations\n• Monitor and analyze usage trends and preferences',
      'pp_s3_title': '3. Information Sharing',
      'pp_s3': 'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this privacy policy.\n\nWe may share your information with trusted service providers who assist us in operating our platform, conducting our business, or servicing you, so long as those parties agree to keep this information confidential.',
      'pp_s4_title': '4. Data Security',
      'pp_s4': 'We implement industry-standard security measures to maintain the safety of your personal information. Your data is encrypted in transit and at rest using AES-256 encryption.\n\nHowever, no method of transmission over the Internet or method of electronic storage is 100% secure, and we cannot guarantee its absolute security.',
      'pp_s5_title': '5. Data Retention',
      'pp_s5': 'We retain your personal information only for as long as necessary to fulfill the purposes for which we collected it, including for the purposes of satisfying any legal, accounting, or reporting requirements.\n\nUpon account deletion or request, your personal data will be removed within 30 days, unless retention is required by law.',
      'pp_s6_title': '6. Your Rights',
      'pp_s6': 'Depending on your location, you may have the following rights regarding your personal data:\n\n• Right to access your personal information\n• Right to rectify inaccurate data\n• Right to erasure of your data\n• Right to restrict processing\n• Right to data portability\n• Right to object to processing',
      'pp_s7_title': '7. Contact Us',
      'pp_s7': 'If you have questions or concerns about this privacy policy, please contact us at:\n\nSanzen Properties LLC\nEmail: privacy@sanzen.ae\nPhone: +971 4 123 4567\nAddress: Downtown Dubai, UAE',
      // Notifications Page
      'mark_all_read': 'Mark all read',
      'today': 'Today',
      'earlier': 'Earlier',
      // Property Details Page
      'type': 'Type',
      'bedrooms': 'Bedrooms',
      'area': 'Area',
      'unit_details': 'Unit Details',
      'unit_code': 'Unit Code',
      'floor': 'Floor',
      'second_floor': '2nd Floor',
      'parking': 'Parking',
      'two_covered_spaces': '2 Covered Spaces',
      'balcony': 'Balcony',
      'lake_view': 'Yes — Lake View',
      'furnished': 'Furnished',
      'semi_furnished': 'Semi-Furnished',
      'overall_completion': 'Overall Completion',
      'current_phase': 'Current Phase',
      'structure': 'Structure',
      'est_completion_date': 'Est. Completion',
      'payment_plan': 'Payment Plan',
      'down_payment': 'Down Payment',
      'during_construction': 'During Construction',
      'on_handover': 'On Handover',
      'amenities': 'Amenities',
      'pool': 'Pool',
      'gym': 'Gym',
      'garden': 'Garden',
      'kids_area': 'Kids Area',
      'spa': 'Spa',
      'bbq_area': 'BBQ Area',
      'contact_property_manager': 'Contact Property Manager',
      'manager_will_contact': 'Your property manager will contact you shortly.',
      // View Timeline Page
      'construction_timeline': 'Construction Timeline',
      'land_preparation': 'Land Preparation',
      'land_preparation_desc': 'Site clearing, grading & soil testing',
      'foundation': 'Foundation',
      'foundation_desc': 'Piling, raft foundation & waterproofing',
      'structure_desc': 'Columns, slabs & structural framework',
      'mep_roughin': 'MEP Rough-in',
      'mep_roughin_desc': 'Mechanical, electrical & plumbing rough installation',
      'interior_finishing': 'Interior Finishing',
      'interior_finishing_desc': 'Flooring, painting, fixtures & cabinetry',
      'handover': 'Handover',
      'handover_desc': 'Final inspection, snagging & key handover',
      'in_progress': 'In Progress',
      // Addon Offer Page
      'about_addon': 'About This Add-on',
      'pricing': 'Pricing',
      'base_package': 'Base Package',
      'premium_package': 'Premium Package',
      'custom_package': 'Custom Package',
      'get_quote': 'Get Quote',
      'whats_included': "What's Included",
      'feature_1': 'Professional installation by certified experts',
      'feature_2': 'Premium quality materials and components',
      'feature_3': '2-year comprehensive warranty',
      'feature_4': '24/7 after-sales support',
      'feature_5': 'Free maintenance for the first year',
      'request_quote': 'Request a Quote',
      'schedule_callback': 'Schedule a Callback',
      'request_sent': 'Request sent! Our team will contact you shortly.',
      'callback_scheduled': 'Callback scheduled! We\'ll reach out soon.',
      // Auth Pages
      'welcome_back': 'Welcome Back',
      'sign_in': 'Sign in',
      'remember_me': 'Remember me',
      'forgot_password': 'Forgot Password?',
      'please_enter_email_password': 'Please enter an email and password',
      'sign_in_failed': 'Sign in failed',
      'forgot_password_title': 'Forgot Password',
      'forgot_password_subtitle': 'Enter your email address and we will send you a verification code',
      'send_otp': 'Send OTP',
      'verification_sent': 'Verification code sent to your email',
      'failed_send_otp': 'Failed to send OTP',
      'enter_otp': 'Enter OTP',
      'sent_verification_to': 'We have sent a verification code to ',
      'verify': 'Verify',
      'didnt_receive': "Didn't receive code? ",
      'resend': 'Resend',
      'resend_in': 'Resend in',
      'otp_sent': 'OTP sent successfully!',
      'failed_resend_otp': 'Failed to resend OTP',
      'invalid_otp': 'Invalid OTP',
      'reset_password': 'Reset Password',
      'reset_password_subtitle': "Create a new password. Make sure it's at least 8 characters long.",
      'confirm_password': 'Confirm Password',
      'failed_reset_password': 'Failed to reset password',
      'password_reset_successful': 'Password Reset\nSuccessful!',
      'password_reset_message': 'Your password has been successfully reset.\nYou can now sign in with your new password.',
      'back_to_sign_in': 'Back to Sign In',
      'password': 'Password',
      'email_hint': 'Email',
    },
    'ar': {
      // Profile & Settings
      'profile': 'الملف الشخصي',
      'language': 'اللغة',
      'personal_details': 'التفاصيل الشخصية',
      'notifications': 'الإشعارات',
      'security': 'الأمان',
      'my_properties': 'عقاراتي',
      'documents': 'المستندات',
      'payments': 'المدفوعات',
      'support_help': 'الدعم والمساعدة',
      'about_sanzen': 'عن سانزن',
      'logout': 'تسجيل الخروج',
      'edit_profile': 'تعديل الملف الشخصي',
      'account_settings': 'إعدادات الحساب',
      'preferences': 'التفضيلات',
      'confirm': 'تأكيد',
      'language_set_to': 'تم تغيير اللغة إلى',
      // Home Page
      'good_morning': 'صباح الخير،',
      'my_property': 'عقاري',
      'details': 'التفاصيل',
      'foundation_stage': 'مرحلة الأساس',
      'est_completion': 'تاريخ الانتهاء المقدر:',
      'view_timeline': 'عرض الجدول الزمني',
      'unit_updates': 'تحديثات الوحدة',
      'company_news': 'أخبار الشركة',
      'exclusive_addons': 'إضافات حصرية',
      'view_offer': 'عرض تفاصيل العرض',
      'home': 'الرئيسية',
      'properties': 'العقارات',
      // Documents Page
      'your_files': 'ملفاتك',
      'my_documents': 'مستنداتي',
      'all': 'الكل',
      'contracts': 'العقود',
      'receipts': 'الإيصالات',
      'noc': 'شهادة عدم ممانعة',
      'sales_purchase_agreement': 'اتفاقية البيع والشراء',
      'payment_receipt': 'إيصال الدفع',
      'no_objection_certificate': 'شهادة عدم ممانعة',
      'unit_handover_agreement': 'اتفاقية تسليم الوحدة',
      'parking_noc': 'شهادة عدم ممانعة مواقف',
      'interior_modification_contract': 'عقد تعديل داخلي',
      // Properties Page
      'properties_owned': 'عقارات مملوكة',
      'total': 'الإجمالي',
      'building': 'قيد الإنشاء',
      'ready': 'جاهز',
      'villa': 'فيلا',
      'apartment': 'شقة',
      'townhouse': 'تاون هاوس',
      'under_construction': 'قيد الإنشاء',
      'construction_progress': 'تقدم البناء',
      'view_details': 'عرض التفاصيل',
      // Edit Profile Page
      'full_name': 'الاسم الكامل',
      'email_address': 'البريد الإلكتروني',
      'phone_number': 'رقم الهاتف',
      'address': 'العنوان',
      'save_changes': 'حفظ التغييرات',
      'profile_updated': 'تم تحديث الملف الشخصي بنجاح!',
      'failed_update_profile': 'فشل في تحديث الملف الشخصي',
      // Change Password Page
      'change_password': 'تغيير كلمة المرور',
      'keep_account_secure': 'حافظ على أمان حسابك',
      'current_password': 'كلمة المرور الحالية',
      'new_password': 'كلمة المرور الجديدة',
      'confirm_new_password': 'تأكيد كلمة المرور الجديدة',
      'update_password': 'تحديث كلمة المرور',
      'passwords_not_match': 'كلمات المرور الجديدة غير متطابقة',
      'password_updated': 'تم تحديث كلمة المرور بنجاح! يرجى تسجيل الدخول بكلمة المرور الجديدة.',
      'failed_update_password': 'فشل في تحديث كلمة المرور',
      'password_must_contain': 'يجب أن تحتوي كلمة المرور على:',
      'at_least_8_chars': '٨ أحرف على الأقل',
      'one_uppercase': 'حرف كبير واحد',
      'one_number': 'رقم واحد',
      'one_special_char': 'رمز خاص واحد',
      // Notification Preferences Page
      'notification_preferences': 'تفضيلات الإشعارات',
      'notification_types': 'أنواع الإشعارات',
      'construction_progress_info': 'تقدم البناء ومعلومات الوحدة',
      'latest_announcements': 'أحدث الإعلانات والفعاليات',
      'payment_reminders': 'تذكيرات الدفع',
      'upcoming_overdue': 'تنبيهات الدفع القادمة والمتأخرة',
      'construction_milestones': 'مراحل البناء',
      'phase_completion': 'إشعارات إتمام المراحل',
      'promotions_offers': 'العروض والترقيات',
      'exclusive_seasonal': 'إضافات حصرية وعروض موسمية',
      'delivery_channels': 'قنوات التوصيل',
      'email_notifications': 'إشعارات البريد الإلكتروني',
      'receive_via_email': 'استلام التحديثات عبر البريد الإلكتروني',
      'push_notifications': 'الإشعارات الفورية',
      'receive_push_alerts': 'استلام التنبيهات على جهازك',
      // Help & Support Page
      'help_support': 'المساعدة والدعم',
      'need_help': 'تحتاج مساعدة؟',
      'support_hours': 'فريق الدعم متاح\nالأحد–الخميس، ٩ ص – ٦ م (توقيت الخليج)',
      'call_us': 'اتصل بنا',
      'email': 'البريد',
      'faq': 'الأسئلة الشائعة',
      'faq_q1': 'كيف أتابع تقدم البناء؟',
      'faq_a1': 'يمكنك عرض الجدول الزمني للبناء من الشاشة الرئيسية بالضغط على "عرض الجدول الزمني". يعرض جميع مراحل البناء بما في ذلك المكتملة والجارية والقادمة.',
      'faq_q2': 'كيف أقوم بالدفع؟',
      'faq_a2': 'انتقل إلى علامة تبويب المستندات لعرض جدول الدفع. يمكنك الدفع عبر التحويل البنكي باستخدام التفاصيل الموجودة في اتفاقية البيع والشراء، أو التواصل مع مدير العقار.',
      'faq_q3': 'هل يمكنني تخصيص وحدتي؟',
      'faq_a3': 'نعم! تحقق من قسم الإضافات الحصرية على الشاشة الرئيسية للخيارات المتاحة بما في ذلك المسبح الخاص وشاحن السيارة الكهربائية والتحكم الذكي بالمنزل والمزيد.',
      'faq_q4': 'كيف أحمّل مستنداتي؟',
      'faq_a4': 'انتقل إلى علامة تبويب المستندات من شريط التنقل السفلي. ستجد جميع عقودك وإيصالاتك وشهادات عدم الممانعة. اضغط على أيقونة التحميل بجانب أي مستند لحفظه.',
      'faq_q5': 'متى ستكون وحدتي جاهزة للتسليم؟',
      'faq_a5': 'تاريخ الانتهاء المقدر معروض على بطاقة العقار في الشاشة الرئيسية وفي الجدول الزمني. ستتلقى إشعاراً عند تأكيد تاريخ التسليم.',
      'submit_request': 'إرسال طلب',
      'support_submitted': 'تم إرسال طلب الدعم! سنرد عليك خلال ٢٤ ساعة.',
      'dialing': 'جاري الاتصال بـ ٩٧١ ٥٦ ٦٦٦ ٠٨٣٩+...',
      'opening_email': 'جاري فتح البريد إلى it.sanzenae@gmail.com...',
      // About Sanzen Page
      'our_story': 'قصتنا',
      'our_story_text': 'سانزن العقارية هي شركة تطوير عقاري رائدة مقرها دبي، الإمارات العربية المتحدة. تأسست برؤية لإعادة تعريف الحياة العصرية، وتبتكر سانزن مجتمعات سكنية استثنائية تمزج بين التميز المعماري والتصميم المستدام.\n\nمع أكثر من ١٥ عاماً من الخبرة في سوق العقارات الديناميكي في الإمارات، طورنا مشاريع حائزة على جوائز وضعت معايير جديدة في الجودة والابتكار ورضا العملاء.',
      'our_mission': 'مهمتنا',
      'our_mission_text': 'بناء مساحات معيشية مستدامة ومبتكرة تعزز جودة حياة أصحاب المنازل، مع وضع معايير جديدة للتميز في صناعة العقارات.',
      'our_vision': 'رؤيتنا',
      'our_vision_text': 'رؤيتنا هي قيادة التطوير الواعي في دولة الإمارات - بناء مجتمعات توازن بين الجمال والبرهان. نحن نصمم للهدوء، وننشر مقاييسنا، ونحترم الوقت والثقة، ونترك كل عائلة مع راحة أعمق تتحسن مع مرور الزمن.',
      'by_the_numbers': 'بالأرقام',
      'years': 'سنة',
      'units': 'وحدة',
      'projects': 'مشروع',
      'rating': 'تقييم',
      'follow_us': 'تابعنا',
      'website': 'الموقع',
      'app_version': 'تطبيق سانزن الإصدار ١.٠.٠',
      'copyright': '© ٢٠٢٥ سانزن العقارية ذ.م.م. جميع الحقوق محفوظة.',
      // Privacy Policy Page
      'privacy_policy': 'سياسة الخصوصية',
      'last_updated': 'آخر تحديث: ١ يناير ٢٠٢٥',
      'pp_s1_title': '١. المعلومات التي نجمعها',
      'pp_s1': 'تجمع سانزن العقارية ("نحن" أو "لنا") المعلومات الشخصية التي تقدمها طوعاً عند تسجيل حساب أو الاستفسار عن خدماتنا أو التواصل معنا.\n\nقد تشمل المعلومات الشخصية اسمك وبريدك الإلكتروني ورقم هاتفك وعنوانك البريدي وتفضيلاتك العقارية ومعلومات الدفع وأي معلومات أخرى تختار تقديمها.',
      'pp_s2_title': '٢. كيف نستخدم معلوماتك',
      'pp_s2': 'نستخدم المعلومات التي نجمعها لـ:\n\n• توفير وتشغيل وصيانة خدماتنا\n• معالجة المعاملات وإرسال المعلومات ذات الصلة\n• إرسال تحديثات البناء وإشعارات العقار\n• الرد على تعليقاتك وأسئلتك وطلباتك\n• إرسال إشعارات تقنية وتحديثات وتنبيهات أمنية\n• تقديم محتوى وتوصيات مخصصة\n• مراقبة وتحليل اتجاهات وتفضيلات الاستخدام',
      'pp_s3_title': '٣. مشاركة المعلومات',
      'pp_s3': 'لا نبيع أو نتاجر أو ننقل معلوماتك الشخصية إلى أطراف ثالثة دون موافقتك، إلا كما هو موضح في سياسة الخصوصية هذه.\n\nقد نشارك معلوماتك مع مزودي خدمات موثوقين يساعدوننا في تشغيل منصتنا أو إدارة أعمالنا أو خدمتك، طالما وافقت تلك الأطراف على الحفاظ على سرية هذه المعلومات.',
      'pp_s4_title': '٤. أمن البيانات',
      'pp_s4': 'ننفذ إجراءات أمنية معيارية للحفاظ على سلامة معلوماتك الشخصية. يتم تشفير بياناتك أثناء النقل وفي حالة السكون باستخدام تشفير AES-256.\n\nومع ذلك، لا توجد طريقة نقل عبر الإنترنت أو تخزين إلكتروني آمنة بنسبة ١٠٠%، ولا يمكننا ضمان أمانها المطلق.',
      'pp_s5_title': '٥. الاحتفاظ بالبيانات',
      'pp_s5': 'نحتفظ بمعلوماتك الشخصية فقط طالما كان ذلك ضرورياً للأغراض التي جمعناها من أجلها، بما في ذلك تلبية أي متطلبات قانونية أو محاسبية أو إعداد تقارير.\n\nعند حذف الحساب أو الطلب، ستتم إزالة بياناتك الشخصية خلال ٣٠ يوماً، ما لم يكن الاحتفاظ مطلوباً بموجب القانون.',
      'pp_s6_title': '٦. حقوقك',
      'pp_s6': 'حسب موقعك، قد يكون لديك الحقوق التالية بشأن بياناتك الشخصية:\n\n• الحق في الوصول إلى معلوماتك الشخصية\n• الحق في تصحيح البيانات غير الدقيقة\n• الحق في محو بياناتك\n• الحق في تقييد المعالجة\n• الحق في نقل البيانات\n• الحق في الاعتراض على المعالجة',
      'pp_s7_title': '٧. اتصل بنا',
      'pp_s7': 'إذا كانت لديك أسئلة أو مخاوف بشأن سياسة الخصوصية هذه، يرجى التواصل معنا على:\n\nسانزن العقارية ذ.م.م\nالبريد: privacy@sanzen.ae\nالهاتف: ٩٧١ ٤ ١٢٣ ٤٥٦٧+\nالعنوان: وسط دبي، الإمارات',
      // Notifications Page
      'mark_all_read': 'تحديد الكل كمقروء',
      'today': 'اليوم',
      'earlier': 'سابقاً',
      // Property Details Page
      'type': 'النوع',
      'bedrooms': 'غرف النوم',
      'area': 'المساحة',
      'unit_details': 'تفاصيل الوحدة',
      'unit_code': 'رمز الوحدة',
      'floor': 'الطابق',
      'second_floor': 'الطابق الثاني',
      'parking': 'مواقف السيارات',
      'two_covered_spaces': 'موقفان مغطيان',
      'balcony': 'الشرفة',
      'lake_view': 'نعم — إطلالة على البحيرة',
      'furnished': 'التأثيث',
      'semi_furnished': 'نصف مفروش',
      'overall_completion': 'نسبة الإنجاز الكلية',
      'current_phase': 'المرحلة الحالية',
      'structure': 'الهيكل',
      'est_completion_date': 'تاريخ الإنجاز المقدر',
      'payment_plan': 'خطة الدفع',
      'down_payment': 'الدفعة الأولى',
      'during_construction': 'أثناء البناء',
      'on_handover': 'عند التسليم',
      'amenities': 'المرافق',
      'pool': 'مسبح',
      'gym': 'صالة رياضية',
      'garden': 'حديقة',
      'kids_area': 'منطقة أطفال',
      'spa': 'سبا',
      'bbq_area': 'منطقة شواء',
      'contact_property_manager': 'تواصل مع مدير العقار',
      'manager_will_contact': 'سيتواصل معك مدير العقار قريباً.',
      // View Timeline Page
      'construction_timeline': 'الجدول الزمني للبناء',
      'land_preparation': 'تحضير الأرض',
      'land_preparation_desc': 'تنظيف الموقع والتسوية واختبار التربة',
      'foundation': 'الأساس',
      'foundation_desc': 'الخوازيق والأساس العائم والعزل المائي',
      'structure_desc': 'الأعمدة والبلاطات والإطار الهيكلي',
      'mep_roughin': 'التمديدات الأولية',
      'mep_roughin_desc': 'التمديدات الميكانيكية والكهربائية والسباكة',
      'interior_finishing': 'التشطيبات الداخلية',
      'interior_finishing_desc': 'الأرضيات والدهان والتركيبات والخزائن',
      'handover': 'التسليم',
      'handover_desc': 'الفحص النهائي والمعاينة وتسليم المفاتيح',
      'in_progress': 'قيد التنفيذ',
      // Addon Offer Page
      'about_addon': 'عن هذه الإضافة',
      'pricing': 'الأسعار',
      'base_package': 'الباقة الأساسية',
      'premium_package': 'الباقة المميزة',
      'custom_package': 'باقة مخصصة',
      'get_quote': 'احصل على عرض سعر',
      'whats_included': 'ما يتضمنه',
      'feature_1': 'تركيب احترافي بواسطة خبراء معتمدين',
      'feature_2': 'مواد ومكونات عالية الجودة',
      'feature_3': 'ضمان شامل لمدة سنتين',
      'feature_4': 'دعم ما بعد البيع على مدار الساعة',
      'feature_5': 'صيانة مجانية للسنة الأولى',
      'request_quote': 'طلب عرض سعر',
      'schedule_callback': 'جدولة مكالمة',
      'request_sent': 'تم إرسال الطلب! سيتواصل معك فريقنا قريباً.',
      'callback_scheduled': 'تمت جدولة المكالمة! سنتواصل معك قريباً.',
      // Auth Pages
      'welcome_back': 'مرحباً بعودتك',
      'sign_in': 'تسجيل الدخول',
      'remember_me': 'تذكرني',
      'forgot_password': 'نسيت كلمة المرور؟',
      'please_enter_email_password': 'يرجى إدخال البريد الإلكتروني وكلمة المرور',
      'sign_in_failed': 'فشل تسجيل الدخول',
      'forgot_password_title': 'نسيت كلمة المرور',
      'forgot_password_subtitle': 'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق',
      'send_otp': 'إرسال رمز التحقق',
      'verification_sent': 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
      'failed_send_otp': 'فشل في إرسال رمز التحقق',
      'enter_otp': 'أدخل رمز التحقق',
      'sent_verification_to': 'لقد أرسلنا رمز التحقق إلى ',
      'verify': 'تحقق',
      'didnt_receive': 'لم تستلم الرمز؟ ',
      'resend': 'إعادة إرسال',
      'resend_in': 'إعادة إرسال خلال',
      'otp_sent': 'تم إرسال رمز التحقق بنجاح!',
      'failed_resend_otp': 'فشل في إعادة إرسال رمز التحقق',
      'invalid_otp': 'رمز التحقق غير صالح',
      'reset_password': 'إعادة تعيين كلمة المرور',
      'reset_password_subtitle': 'أنشئ كلمة مرور جديدة. تأكد أنها ٨ أحرف على الأقل.',
      'confirm_password': 'تأكيد كلمة المرور',
      'failed_reset_password': 'فشل في إعادة تعيين كلمة المرور',
      'password_reset_successful': 'تمت إعادة التعيين\nبنجاح!',
      'password_reset_message': 'تمت إعادة تعيين كلمة المرور بنجاح.\nيمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.',
      'back_to_sign_in': 'العودة لتسجيل الدخول',
      'password': 'كلمة المرور',
      'email_hint': 'البريد الإلكتروني',
    },
  };

  String _t(String key, String fallback) => _localizedValues[locale.languageCode]?[key] ?? fallback;

  // Profile & Settings
  String get profile => _t('profile', 'Profile');
  String get language => _t('language', 'Language');
  String get personalDetails => _t('personal_details', 'Personal Details');
  String get notifications => _t('notifications', 'Notifications');
  String get security => _t('security', 'Security');
  String get myProperties => _t('my_properties', 'My Properties');
  String get documents => _t('documents', 'Documents');
  String get payments => _t('payments', 'Payments');
  String get supportHelp => _t('support_help', 'Support & Help');
  String get aboutSanzen => _t('about_sanzen', 'About Sanzen');
  String get logout => _t('logout', 'Logout');
  String get editProfile => _t('edit_profile', 'Edit Profile');
  String get accountSettings => _t('account_settings', 'Account Settings');
  String get preferences => _t('preferences', 'Preferences');
  String get confirm => _t('confirm', 'Confirm');
  String get languageSetTo => _t('language_set_to', 'Language set to');
  // Home Page
  String get goodMorning => _t('good_morning', 'Good Morning,');
  String get myProperty => _t('my_property', 'My Property');
  String get details => _t('details', 'DETAILS');
  String get foundationStage => _t('foundation_stage', 'Foundation Stage');
  String get estCompletion => _t('est_completion', 'Est. Completion:');
  String get viewTimeline => _t('view_timeline', 'View Timeline');
  String get unitUpdates => _t('unit_updates', 'Unit Updates');
  String get companyNews => _t('company_news', 'Company News');
  String get exclusiveAddons => _t('exclusive_addons', 'Exclusive Add-ons');
  String get viewOffer => _t('view_offer', 'View Offer');
  String get home => _t('home', 'Home');
  String get properties => _t('properties', 'Properties');
  // Documents Page
  String get yourFiles => _t('your_files', 'Your Files');
  String get myDocuments => _t('my_documents', 'My Documents');
  String get all => _t('all', 'All');
  String get contracts => _t('contracts', 'Contracts');
  String get receipts => _t('receipts', 'Receipts');
  String get noc => _t('noc', 'NOC');
  String get salesPurchaseAgreement => _t('sales_purchase_agreement', 'Sales Purchase Agreement');
  String get paymentReceipt => _t('payment_receipt', 'Payment Receipt');
  String get noObjectionCertificate => _t('no_objection_certificate', 'No Objection Certificate');
  String get unitHandoverAgreement => _t('unit_handover_agreement', 'Unit Handover Agreement');
  String get parkingNoc => _t('parking_noc', 'Parking NOC');
  String get interiorModificationContract => _t('interior_modification_contract', 'Interior Modification Contract');
  // Properties Page
  String get propertiesOwned => _t('properties_owned', 'properties owned');
  String get total => _t('total', 'Total');
  String get building => _t('building', 'Building');
  String get ready => _t('ready', 'Ready');
  String get villa => _t('villa', 'Villa');
  String get apartment => _t('apartment', 'Apartment');
  String get townhouse => _t('townhouse', 'Townhouse');
  String get underConstruction => _t('under_construction', 'Under Construction');
  String get constructionProgress => _t('construction_progress', 'Construction Progress');
  String get viewDetails => _t('view_details', 'View Details');
  // Edit Profile Page
  String get fullName => _t('full_name', 'Full Name');
  String get emailAddress => _t('email_address', 'Email Address');
  String get phoneNumber => _t('phone_number', 'Phone Number');
  String get address => _t('address', 'Address');
  String get saveChanges => _t('save_changes', 'Save Changes');
  String get profileUpdated => _t('profile_updated', 'Profile updated successfully!');
  String get failedUpdateProfile => _t('failed_update_profile', 'Failed to update profile');
  // Change Password Page
  String get changePassword => _t('change_password', 'Change Password');
  String get keepAccountSecure => _t('keep_account_secure', 'Keep your account secure');
  String get currentPassword => _t('current_password', 'Current Password');
  String get newPassword => _t('new_password', 'New Password');
  String get confirmNewPassword => _t('confirm_new_password', 'Confirm New Password');
  String get updatePassword => _t('update_password', 'Update Password');
  String get passwordsNotMatch => _t('passwords_not_match', 'New passwords do not match');
  String get passwordUpdated => _t('password_updated', 'Password updated successfully!');
  String get failedUpdatePassword => _t('failed_update_password', 'Failed to update password');
  String get passwordMustContain => _t('password_must_contain', 'Password must contain:');
  String get atLeast8Chars => _t('at_least_8_chars', 'At least 8 characters');
  String get oneUppercase => _t('one_uppercase', 'One uppercase letter');
  String get oneNumber => _t('one_number', 'One number');
  String get oneSpecialChar => _t('one_special_char', 'One special character');
  // Notification Preferences
  String get notificationPreferences => _t('notification_preferences', 'Notification Preferences');
  String get notificationTypes => _t('notification_types', 'Notification Types');
  String get constructionProgressInfo => _t('construction_progress_info', 'Construction progress & unit info');
  String get latestAnnouncements => _t('latest_announcements', 'Latest announcements & events');
  String get paymentReminders => _t('payment_reminders', 'Payment Reminders');
  String get upcomingOverdue => _t('upcoming_overdue', 'Upcoming & overdue payment alerts');
  String get constructionMilestones => _t('construction_milestones', 'Construction Milestones');
  String get phaseCompletion => _t('phase_completion', 'Phase completion notifications');
  String get promotionsOffers => _t('promotions_offers', 'Promotions & Offers');
  String get exclusiveSeasonal => _t('exclusive_seasonal', 'Exclusive add-ons & seasonal offers');
  String get deliveryChannels => _t('delivery_channels', 'Delivery Channels');
  String get emailNotifications => _t('email_notifications', 'Email Notifications');
  String get receiveViaEmail => _t('receive_via_email', 'Receive updates via email');
  String get pushNotifications => _t('push_notifications', 'Push Notifications');
  String get receivePushAlerts => _t('receive_push_alerts', 'Receive push alerts on your device');
  // Help & Support
  String get helpSupport => _t('help_support', 'Help & Support');
  String get needHelp => _t('need_help', 'Need Help?');
  String get supportHours => _t('support_hours', 'Our support team is available\nSun–Thu, 9 AM – 6 PM (GST)');
  String get callUs => _t('call_us', 'Call Us');
  String get emailLabel => _t('email', 'Email');
  String get faq => _t('faq', 'Frequently Asked Questions');
  String get faqQ1 => _t('faq_q1', 'How do I track my construction progress?');
  String get faqA1 => _t('faq_a1', '');
  String get faqQ2 => _t('faq_q2', 'How do I make a payment?');
  String get faqA2 => _t('faq_a2', '');
  String get faqQ3 => _t('faq_q3', 'Can I customize my unit?');
  String get faqA3 => _t('faq_a3', '');
  String get faqQ4 => _t('faq_q4', 'How do I download my documents?');
  String get faqA4 => _t('faq_a4', '');
  String get faqQ5 => _t('faq_q5', 'When will my unit be ready for handover?');
  String get faqA5 => _t('faq_a5', '');
  String get submitRequest => _t('submit_request', 'Submit a Request');
  String get supportSubmitted => _t('support_submitted', '');
  String get dialing => _t('dialing', 'Dialing +971 56 666 0839...');
  String get openingEmail => _t('opening_email', 'Opening email to it.sanzenae@gmail.com...');
  // About Sanzen
  String get ourStory => _t('our_story', 'Our Story');
  String get ourStoryText => _t('our_story_text', '');
  String get ourMission => _t('our_mission', 'Our Mission');
  String get ourMissionText => _t('our_mission_text', '');
  String get ourVision => _t('our_vision', 'Our Vision');
  String get ourVisionText => _t('our_vision_text', 'Our vision is to lead mindful development in the UAE - creating communities that balance beauty with proof. We design for quiet, publish our measures, honor time and trust, and leave every family with a deeper ease that improves with age.');
  String get byTheNumbers => _t('by_the_numbers', 'By the Numbers');
  String get years => _t('years', 'Years');
  String get units => _t('units', 'Units');
  String get projects => _t('projects', 'Projects');
  String get rating => _t('rating', 'Rating');
  String get followUs => _t('follow_us', 'Follow Us');
  String get website => _t('website', 'Website');
  String get appVersion => _t('app_version', 'Sanzen App v1.0.0');
  String get copyright => _t('copyright', '© 2025 Sanzen Properties LLC. All rights reserved.');
  // Privacy Policy
  String get privacyPolicy => _t('privacy_policy', 'Privacy Policy');
  String get lastUpdated => _t('last_updated', 'Last Updated: January 1, 2025');
  String get ppS1Title => _t('pp_s1_title', '1. Information We Collect');
  String get ppS1 => _t('pp_s1', '');
  String get ppS2Title => _t('pp_s2_title', '2. How We Use Your Information');
  String get ppS2 => _t('pp_s2', '');
  String get ppS3Title => _t('pp_s3_title', '3. Information Sharing');
  String get ppS3 => _t('pp_s3', '');
  String get ppS4Title => _t('pp_s4_title', '4. Data Security');
  String get ppS4 => _t('pp_s4', '');
  String get ppS5Title => _t('pp_s5_title', '5. Data Retention');
  String get ppS5 => _t('pp_s5', '');
  String get ppS6Title => _t('pp_s6_title', '6. Your Rights');
  String get ppS6 => _t('pp_s6', '');
  String get ppS7Title => _t('pp_s7_title', '7. Contact Us');
  String get ppS7 => _t('pp_s7', '');
  // Notifications Page
  String get markAllRead => _t('mark_all_read', 'Mark all read');
  String get todayLabel => _t('today', 'Today');
  String get earlierLabel => _t('earlier', 'Earlier');
  // Property Details
  String get typeLabel => _t('type', 'Type');
  String get bedroomsLabel => _t('bedrooms', 'Bedrooms');
  String get areaLabel => _t('area', 'Area');
  String get unitDetails => _t('unit_details', 'Unit Details');
  String get unitCode => _t('unit_code', 'Unit Code');
  String get floor => _t('floor', 'Floor');
  String get secondFloor => _t('second_floor', '2nd Floor');
  String get parking => _t('parking', 'Parking');
  String get twoCoveredSpaces => _t('two_covered_spaces', '2 Covered Spaces');
  String get balcony => _t('balcony', 'Balcony');
  String get lakeView => _t('lake_view', 'Yes — Lake View');
  String get furnished => _t('furnished', 'Furnished');
  String get semiFurnished => _t('semi_furnished', 'Semi-Furnished');
  String get overallCompletion => _t('overall_completion', 'Overall Completion');
  String get currentPhase => _t('current_phase', 'Current Phase');
  String get structure => _t('structure', 'Structure');
  String get estCompletionDate => _t('est_completion_date', 'Est. Completion');
  String get paymentPlan => _t('payment_plan', 'Payment Plan');
  String get downPayment => _t('down_payment', 'Down Payment');
  String get duringConstruction => _t('during_construction', 'During Construction');
  String get onHandover => _t('on_handover', 'On Handover');
  String get amenities => _t('amenities', 'Amenities');
  String get poolLabel => _t('pool', 'Pool');
  String get gymLabel => _t('gym', 'Gym');
  String get gardenLabel => _t('garden', 'Garden');
  String get kidsArea => _t('kids_area', 'Kids Area');
  String get spaLabel => _t('spa', 'Spa');
  String get bbqArea => _t('bbq_area', 'BBQ Area');
  String get contactPropertyManager => _t('contact_property_manager', 'Contact Property Manager');
  String get managerWillContact => _t('manager_will_contact', 'Your property manager will contact you shortly.');
  // View Timeline
  String get constructionTimeline => _t('construction_timeline', 'Construction Timeline');
  String get landPreparation => _t('land_preparation', 'Land Preparation');
  String get landPreparationDesc => _t('land_preparation_desc', 'Site clearing, grading & soil testing');
  String get foundationLabel => _t('foundation', 'Foundation');
  String get foundationDesc => _t('foundation_desc', 'Piling, raft foundation & waterproofing');
  String get structureDesc => _t('structure_desc', 'Columns, slabs & structural framework');
  String get mepRoughin => _t('mep_roughin', 'MEP Rough-in');
  String get mepRoughinDesc => _t('mep_roughin_desc', 'Mechanical, electrical & plumbing rough installation');
  String get interiorFinishing => _t('interior_finishing', 'Interior Finishing');
  String get interiorFinishingDesc => _t('interior_finishing_desc', 'Flooring, painting, fixtures & cabinetry');
  String get handover => _t('handover', 'Handover');
  String get handoverDesc => _t('handover_desc', 'Final inspection, snagging & key handover');
  String get inProgress => _t('in_progress', 'In Progress');
  // Addon Offer
  String get aboutAddon => _t('about_addon', 'About This Add-on');
  String get pricing => _t('pricing', 'Pricing');
  String get basePackage => _t('base_package', 'Base Package');
  String get premiumPackage => _t('premium_package', 'Premium Package');
  String get customPackage => _t('custom_package', 'Custom Package');
  String get getQuote => _t('get_quote', 'Get Quote');
  String get whatsIncluded => _t('whats_included', "What's Included");
  String get feature1 => _t('feature_1', 'Professional installation by certified experts');
  String get feature2 => _t('feature_2', 'Premium quality materials and components');
  String get feature3 => _t('feature_3', '2-year comprehensive warranty');
  String get feature4 => _t('feature_4', '24/7 after-sales support');
  String get feature5 => _t('feature_5', 'Free maintenance for the first year');
  String get requestQuote => _t('request_quote', 'Request a Quote');
  String get scheduleCallback => _t('schedule_callback', 'Schedule a Callback');
  String get requestSent => _t('request_sent', 'Request sent! Our team will contact you shortly.');
  String get callbackScheduled => _t('callback_scheduled', "Callback scheduled! We'll reach out soon.");
  // Auth
  String get welcomeBack => _t('welcome_back', 'Welcome Back');
  String get signIn => _t('sign_in', 'Sign in');
  String get rememberMe => _t('remember_me', 'Remember me');
  String get forgotPassword => _t('forgot_password', 'Forgot Password?');
  String get pleaseEnterEmailPassword => _t('please_enter_email_password', 'Please enter an email and password');
  String get signInFailed => _t('sign_in_failed', 'Sign in failed');
  String get forgotPasswordTitle => _t('forgot_password_title', 'Forgot Password');
  String get forgotPasswordSubtitle => _t('forgot_password_subtitle', 'Enter your email address and we will send you a verification code');
  String get sendOtp => _t('send_otp', 'Send OTP');
  String get verificationSent => _t('verification_sent', 'Verification code sent to your email');
  String get failedSendOtp => _t('failed_send_otp', 'Failed to send OTP');
  String get enterOtp => _t('enter_otp', 'Enter OTP');
  String get sentVerificationTo => _t('sent_verification_to', 'We have sent a verification code to ');
  String get verify => _t('verify', 'Verify');
  String get didntReceive => _t('didnt_receive', "Didn't receive code? ");
  String get resend => _t('resend', 'Resend');
  String get resendIn => _t('resend_in', 'Resend in');
  String get otpSent => _t('otp_sent', 'OTP sent successfully!');
  String get failedResendOtp => _t('failed_resend_otp', 'Failed to resend OTP');
  String get invalidOtp => _t('invalid_otp', 'Invalid OTP');
  String get resetPassword => _t('reset_password', 'Reset Password');
  String get resetPasswordSubtitle => _t('reset_password_subtitle', "Create a new password. Make sure it's at least 8 characters long.");
  String get confirmPasswordLabel => _t('confirm_password', 'Confirm Password');
  String get failedResetPassword => _t('failed_reset_password', 'Failed to reset password');
  String get passwordResetSuccessful => _t('password_reset_successful', 'Password Reset\nSuccessful!');
  String get passwordResetMessage => _t('password_reset_message', 'Your password has been successfully reset.\nYou can now sign in with your new password.');
  String get backToSignIn => _t('back_to_sign_in', 'Back to Sign In');
  String get passwordHint => _t('password', 'Password');
  String get emailHint => _t('email_hint', 'Email');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
