import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/courses_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_shell.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/group_model.dart';
import 'models/user_model.dart';
import 'models/store_item_model.dart';
import 'firebase_options.dart';

// ─────────────────────────────────────────────────────────────
// Database Health Check — temporary diagnostic function
// Safe to remove after verifying Firestore connectivity & models
// ─────────────────────────────────────────────────────────────
Future<void> testDashboardConnection() async {
  print('');
  print('╔══════════════════════════════════════════════════════════╗');
  print('║          🔍 DATABASE HEALTH CHECK — START               ║');
  print('╚══════════════════════════════════════════════════════════╝');
  print('');

  final firestore = FirebaseFirestore.instance;
  int passed = 0;
  int failed = 0;

  // ── Helper: Validate field keys ──
  void validateFields({
    required String collectionName,
    required Map<String, dynamic> rawData,
    required Set<String> expectedKeys,
  }) {
    final actualKeys = rawData.keys.toSet();
    final missingInFirestore = expectedKeys.difference(actualKeys);
    final extraInFirestore = actualKeys.difference(expectedKeys);

    if (missingInFirestore.isEmpty && extraInFirestore.isEmpty) {
      print('   🟢 تطابق الحقول: جميع المفاتيح متطابقة تماماً');
    } else {
      if (missingInFirestore.isNotEmpty) {
        print('   ⚠️  حقول موجودة في Model لكن غير موجودة في Firestore: $missingInFirestore');
      }
      if (extraInFirestore.isNotEmpty) {
        print('   ⚠️  حقول موجودة في Firestore لكن غير موجودة في Model: $extraInFirestore');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 1. Test Groups Collection
  // ═══════════════════════════════════════════════════════════
  print('━━━ [1/3] مجموعة groups ━━━');
  try {
    final groupsSnapshot = await firestore.collection('groups').limit(1).get();
    if (groupsSnapshot.docs.isEmpty) {
      print('   ✅ نجح الربط مع مجموعة groups (لكنها فارغة — لا توجد مستندات)');
      passed++;
    } else {
      final doc = groupsSnapshot.docs.first;
      final rawData = doc.data();
      print('   📄 Document ID: ${doc.id}');
      print('   📦 Raw Firestore Data: $rawData');

      // Parse through model
      final group = GroupModel.fromMap(rawData, doc.id);
      print('   ✅ نجح الربط والتحويل (fromMap) مع مجموعة groups');
      print('   📋 عينة البيانات المحوّلة:');
      print('      - name: ${group.name}');
      print('      - createdBy: ${group.createdBy}');
      print('      - members count: ${group.members.length}');
      print('      - academicYear: ${group.academicYear}');
      print('      - createdAt: ${group.createdAt}');

      // Validate field keys
      final expectedGroupKeys = {'name', 'description', 'createdBy', 'createdAt', 'members', 'lastMessage', 'lastMessageTime', 'academicYear'};
      validateFields(collectionName: 'groups', rawData: rawData, expectedKeys: expectedGroupKeys);
      passed++;
    }
  } catch (e, stackTrace) {
    print('   ❌ فشل الاتصال مع مجموعة groups!');
    print('   🔴 Exception Type: ${e.runtimeType}');
    print('   🔴 Exception: $e');
    print('   📌 StackTrace (أول 5 أسطر):');
    final lines = stackTrace.toString().split('\n').take(5);
    for (final line in lines) {
      print('      $line');
    }
    _diagnoseError(e);
    failed++;
  }
  print('');

  // ═══════════════════════════════════════════════════════════
  // 2. Test Users Collection
  // ═══════════════════════════════════════════════════════════
  print('━━━ [2/3] مجموعة users ━━━');
  try {
    final usersSnapshot = await firestore.collection('users').limit(1).get();
    if (usersSnapshot.docs.isEmpty) {
      print('   ✅ نجح الربط مع مجموعة users (لكنها فارغة — لا توجد مستندات)');
      passed++;
    } else {
      final doc = usersSnapshot.docs.first;
      final rawData = doc.data();
      print('   📄 Document ID: ${doc.id}');
      print('   📦 Raw Firestore Data: $rawData');

      // Parse through model
      final user = UserModel.fromMap(rawData, doc.id);
      print('   ✅ نجح الربط والتحويل (fromMap) مع مجموعة users');
      print('   📋 عينة البيانات المحوّلة:');
      print('      - name: ${user.name}');
      print('      - email: ${user.email}');
      print('      - role: ${user.role}');
      print('      - status: ${user.status}');
      print('      - isAdmin: ${user.isAdmin}');
      print('      - createdAt: ${user.createdAt}');

      // Validate field keys
      final expectedUserKeys = {'name', 'email', 'role', 'photoUrl', 'createdAt', 'status', 'phoneNumber'};
      validateFields(collectionName: 'users', rawData: rawData, expectedKeys: expectedUserKeys);
      passed++;
    }
  } catch (e, stackTrace) {
    print('   ❌ فشل الاتصال مع مجموعة users!');
    print('   🔴 Exception Type: ${e.runtimeType}');
    print('   🔴 Exception: $e');
    print('   📌 StackTrace (أول 5 أسطر):');
    final lines = stackTrace.toString().split('\n').take(5);
    for (final line in lines) {
      print('      $line');
    }
    _diagnoseError(e);
    failed++;
  }
  print('');

  // ═══════════════════════════════════════════════════════════
  // 3. Test Store Items Collection
  // ═══════════════════════════════════════════════════════════
  print('━━━ [3/3] مجموعة store_items ━━━');
  try {
    final storeSnapshot = await firestore.collection('store_items').limit(1).get();
    if (storeSnapshot.docs.isEmpty) {
      print('   ✅ نجح الربط مع مجموعة store_items (لكنها فارغة — لا توجد مستندات)');
      passed++;
    } else {
      final doc = storeSnapshot.docs.first;
      final rawData = doc.data();
      print('   📄 Document ID: ${doc.id}');
      print('   📦 Raw Firestore Data: $rawData');

      // Parse through model
      final storeItem = StoreItemModel.fromMap(rawData, doc.id);
      print('   ✅ نجح الربط والتحويل (fromMap) مع مجموعة store_items');
      print('   📋 عينة البيانات المحوّلة:');
      print('      - name: ${storeItem.name}');
      print('      - price: ${storeItem.price}');
      print('      - quantity: ${storeItem.quantity}');
      print('      - category: ${storeItem.category}');
      print('      - isAvailable: ${storeItem.isAvailable}');
      print('      - createdAt: ${storeItem.createdAt}');

      // Validate field keys
      validateFields(collectionName: 'store_items', rawData: rawData, expectedKeys: StoreItemModel.expectedKeys);
      passed++;
    }
  } catch (e, stackTrace) {
    print('   ❌ فشل الاتصال مع مجموعة store_items!');
    print('   🔴 Exception Type: ${e.runtimeType}');
    print('   🔴 Exception: $e');
    print('   📌 StackTrace (أول 5 أسطر):');
    final lines = stackTrace.toString().split('\n').take(5);
    for (final line in lines) {
      print('      $line');
    }
    _diagnoseError(e);
    failed++;
  }
  print('');

  // ═══════════════════════════════════════════════════════════
  // Summary
  // ═══════════════════════════════════════════════════════════
  print('╔══════════════════════════════════════════════════════════╗');
  print('║          📊 HEALTH CHECK SUMMARY                        ║');
  print('╠══════════════════════════════════════════════════════════╣');
  print('║  ✅ Passed: $passed / 3                                      ║');
  print('║  ❌ Failed: $failed / 3                                      ║');
  if (failed == 0) {
    print('║  🎉 جميع الاختبارات نجحت — جاهز للدمج المرئي (UI Merge) ║');
  } else {
    print('║  ⛔ يوجد أخطاء — يجب حلها قبل الدمج المرئي             ║');
  }
  print('╚══════════════════════════════════════════════════════════╝');
  print('');
}

/// Diagnose common Firestore errors
void _diagnoseError(Object error) {
  final errorStr = error.toString().toLowerCase();
  if (errorStr.contains('permission-denied') || errorStr.contains('permission_denied')) {
    print('   🔐 التشخيص: مشكلة صلاحيات (Security Rules) — تحقق من قواعد Firestore');
    print('   💡 الحل: تأكد أن المستخدم الحالي لديه إذن قراءة على هذه المجموعة');
  } else if (errorStr.contains('not-found')) {
    print('   📂 التشخيص: المجموعة أو المستند غير موجود');
  } else if (errorStr.contains('unavailable') || errorStr.contains('network')) {
    print('   🌐 التشخيص: مشكلة في الشبكة أو Firestore غير متاح');
  } else if (errorStr.contains('unauthenticated')) {
    print('   🔑 التشخيص: المستخدم غير مسجل الدخول — يجب تسجيل الدخول أولاً');
  } else {
    print('   ❓ التشخيص: خطأ غير معروف — راجع رسالة الاستثناء أعلاه');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Health Check moved to DashboardShell.initState (post-auth)

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = AuthProvider();
            provider.toggleMockMode(false); // Start in Firebase Live Mode (disable mock)
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => CoursesProvider(),
        ),
      ],
      child: const StuStepAdminApp(),
    ),
  );
}

class StuStepAdminApp extends StatelessWidget {
  const StuStepAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Elegant Dark Theme Color Swatches
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF2DD4BF),
      scaffoldBackgroundColor: const Color(0xFF0B0F19),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF2DD4BF),
        secondary: Color(0xFF6366F1),
        surface: Color(0xFF1E293B),
        background: Color(0xFF0B0F19),
        error: Colors.redAccent,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'system-ui', color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: 'system-ui', color: Colors.white, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontFamily: 'system-ui', color: Color(0xDEFFFFFF)),
        bodyMedium: TextStyle(fontFamily: 'system-ui', color: Color(0x99FFFFFF)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white10,
        thickness: 1,
      ),
    );

    return MaterialApp(
      title: 'STUSTEP Admin Dashboard',
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Sync mock mode to CoursesProvider when mode changes
          final coursesProvider = Provider.of<CoursesProvider>(context, listen: false);
          if (coursesProvider.useMock != authProvider.useMock) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              coursesProvider.toggleMockMode(authProvider.useMock);
            });
          }

          if (authProvider.isAuthenticated) {
            return const DashboardShell();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
