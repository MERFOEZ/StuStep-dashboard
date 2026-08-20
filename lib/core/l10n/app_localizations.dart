import 'package:flutter/material.dart';

/// All UI strings — Arabic (default) and English.
/// Access via `S.of(context).someKey`.
class S {
  final Locale locale;
  S(this.locale);

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  // ─── General ────────────────────────────────────────────────────────
  String get appTitle => _t('لوحة التحكم StuStep', 'StuStep Dashboard');
  String get save => _t('حفظ', 'Save');
  String get cancel => _t('إلغاء', 'Cancel');
  String get delete => _t('حذف', 'Delete');
  String get edit => _t('تعديل', 'Edit');
  String get add => _t('إضافة', 'Add');
  String get actions => _t('الإجراءات', 'Actions');
  String get yes => _t('نعم', 'Yes');
  String get no => _t('لا', 'No');
  String get loading => _t('جار التحميل...', 'Loading...');
  String get error => _t('حدث خطأ', 'An error occurred');
  String get success => _t('تم بنجاح', 'Success');
  String get requiredField => _t('هذا الحقل مطلوب', 'This field is required');
  String get invalidUrl => _t('رابط غير صالح', 'Invalid URL');
  String get confirmDelete =>
      _t('هل أنت متأكد من الحذف؟', 'Are you sure you want to delete?');
  String get deleteWarning =>
      _t('لا يمكن التراجع عن هذا الإجراء', 'This action cannot be undone');
  String get noData => _t('لا توجد بيانات', 'No data');
  String get cascadeDeleteCollegeWarning =>
      _t('سيتم حذف هذه الكلية وجميع التخصصات والدورات التابعة لها نهائياً. هل أنت متأكد؟',
         'This will permanently delete the college and ALL its majors and courses. Are you sure?');
  String get cascadeDeleteDepartmentWarning =>
      _t('سيتم حذف هذا التخصص وجميع الدورات التابعة له نهائياً. هل أنت متأكد؟',
         'This will permanently delete the major and ALL its courses. Are you sure?');

  // ─── Navigation ─────────────────────────────────────────────────────
  String get colleges => _t('الكليات', 'Colleges');
  String get academicStructure => _t('الهيكلة الأكاديمية', 'Academic Structure');
  String get departments => _t('التخصصات', 'Majors');
  String get courses => _t('الدورات', 'Courses');
  String get store => _t('المتجر', 'Store');
  String get back => _t('رجوع', 'Back');
  String get viewMajors => _t('عرض التخصصات', 'View Majors');
  String get viewLevels => _t('عرض الدورات', 'View Courses');

  // ─── Colleges ───────────────────────────────────────────────────────
  String get collegeName => _t('اسم الكلية', 'College Name');
  String get addCollege => _t('إضافة كلية', 'Add College');
  String get editCollege => _t('تعديل الكلية', 'Edit College');
  String get isActive => _t('نشط', 'Active');
  String get active => _t('نشط', 'Active');
  String get inactive => _t('غير نشط', 'Inactive');
  String get noColleges =>
      _t('لا توجد كليات بعد — أضف واحدة!', 'No colleges yet — add one!');
  String get collegeAdded => _t('تمت إضافة الكلية بنجاح', 'College added successfully');
  String get collegeUpdated =>
      _t('تم تحديث الكلية بنجاح', 'College updated successfully');
  String get collegeDeleted =>
      _t('تم حذف الكلية بنجاح', 'College deleted successfully');

  // ─── Departments (Majors) ───────────────────────────────────────────
  String get departmentName => _t('اسم التخصص', 'Major Name');
  String get addDepartment => _t('إضافة تخصص', 'Add Major');
  String get editDepartment => _t('تعديل التخصص', 'Edit Major');
  String get selectCollege => _t('اختر الكلية', 'Select College');
  String get college => _t('الكلية', 'College');
  String get noDepartments =>
      _t('لا توجد تخصصات بعد — أضف واحداً!', 'No majors yet — add one!');
  String get departmentAdded =>
      _t('تمت إضافة التخصص بنجاح', 'Major added successfully');
  String get departmentUpdated =>
      _t('تم تحديث التخصص بنجاح', 'Major updated successfully');
  String get departmentDeleted =>
      _t('تم حذف التخصص بنجاح', 'Major deleted successfully');

  // ─── Courses ────────────────────────────────────────────────────────
  String get courseTitle => _t('اسم الدورة', 'Course Name');
  String get addCourse => _t('إضافة دورة', 'Add Course');
  String get editCourse => _t('تعديل الدورة', 'Edit Course');
  String get selectDepartment => _t('اختر التخصص', 'Select Major');
  String get department => _t('التخصص', 'Major');
  String get coverImage => _t('صورة الغلاف', 'Cover Image');
  String get coverImageUrl => _t('رابط صورة الغلاف', 'Cover Image URL');
  String get noCourses =>
      _t('لا توجد دورات بعد — أضف واحدة!', 'No courses yet — add one!');
  String get courseAdded =>
      _t('تمت إضافة الدورة بنجاح', 'Course added successfully');
  String get courseUpdated =>
      _t('تم تحديث الدورة بنجاح', 'Course updated successfully');
  String get courseDeleted =>
      _t('تم حذف الدورة بنجاح', 'Course deleted successfully');

  // ─── Store ──────────────────────────────────────────────────────────
  String get itemTitle => _t('عنوان العنصر', 'Item Title');
  String get addItem => _t('إضافة عنصر', 'Add Item');
  String get editItem => _t('تعديل العنصر', 'Edit Item');
  String get requiredPoints => _t('النقاط المطلوبة', 'Required Points');
  String get downloadLink => _t('رابط التحميل', 'Download Link');
  String get noItems =>
      _t('لا توجد عناصر بعد — أضف واحداً!', 'No items yet — add one!');
  String get itemAdded =>
      _t('تمت إضافة العنصر بنجاح', 'Item added successfully');
  String get itemUpdated =>
      _t('تم تحديث العنصر بنجاح', 'Item updated successfully');
  String get itemDeleted =>
      _t('تم حذف العنصر بنجاح', 'Item deleted successfully');
  String get pointsValidation =>
      _t('يجب أن تكون القيمة 0 أو أكثر', 'Value must be 0 or greater');

  // ─── Auth ───────────────────────────────────────────────────────────
  String get welcomeBack => _t('مرحباً بعودتك', 'Welcome Back');
  String get signInToContinue =>
      _t('سجّل دخولك للمتابعة', 'Sign in to continue');
  String get email => _t('البريد الإلكتروني', 'Email');
  String get password => _t('كلمة المرور', 'Password');
  String get signIn => _t('تسجيل الدخول', 'Sign In');
  String get signingIn => _t('جارٍ تسجيل الدخول...', 'Signing In...');
  String get signOut => _t('تسجيل الخروج', 'Sign Out');
  String get accessDenied =>
      _t('تم الرفض: صلاحيات إدارية مطلوبة', 'Access Denied: Administrative privileges required.');
  String get dashboardComingSoon =>
      _t('لوحة التحكم قريباً — سيتم بناؤها في المرحلة التالية', 'Dashboard coming soon — will be built in the next phase');
  String get welcomeAdmin => _t('مرحباً', 'Welcome');
  String get invalidEmail => _t('بريد إلكتروني غير صالح', 'Invalid email address');

  // ─── Dashboard ──────────────────────────────────────────────────────
  String get dashboard => _t('لوحة التحكم', 'Dashboard');
  String get quickActions => _t('إجراءات سريعة', 'Quick Actions');
  String get recentActivity => _t('آخر النشاطات', 'Recent Activity');
  String get systemReady => _t('النظام جاهز', 'System Ready');
  String get allServicesRunning => _t('جميع الخدمات تعمل بشكل طبيعي', 'All services running normally');
  String get successfulLogin => _t('تسجيل دخول ناجح', 'Successful Login');
  String get firebaseConnected => _t('Firebase متصل', 'Firebase Connected');
  String get dbConnectionActive => _t('الاتصال بقاعدة البيانات نشط', 'Database connection active');
  String get now => _t('الآن', 'Now');
  String get ongoing => _t('مستمر', 'Ongoing');
  String get totalColleges => _t('إجمالي عدد الكليات المسجلة', 'Total registered colleges');
  String get totalDepartments => _t('إجمالي عدد التخصصات', 'Total majors');
  String get totalCourses => _t('إجمالي عدد الدورات', 'Total courses');
  String get totalStoreItems => _t('إجمالي عناصر المتجر', 'Total store items');
  String get expand => _t('توسيع', 'Expand');
  String get collapse => _t('طي', 'Collapse');
  String get notifications => _t('الإشعارات', 'Notifications');

  // ─── Helper ─────────────────────────────────────────────────────────
  String _t(String ar, String en) =>
      locale.languageCode == 'ar' ? ar : en;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) async => S(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<S> old) => false;
}
