import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stustep_admin/main.dart';
import 'package:stustep_admin/providers/auth_provider.dart';

void main() {
  testWidgets('Admin Dashboard Login Render Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            final provider = AuthProvider();
            provider.toggleMockMode(true);
            return provider;
          }),
        ],
        child: const StuStepAdminApp(),
      ),
    );

    // Verify that the login portal text is rendered.
    expect(find.text('STUSTEP'), findsOneWidget);
    expect(find.text('Academic Chat Control Center'), findsOneWidget);
    expect(find.text('Sign In to Dashboard'), findsOneWidget);
  });
}
