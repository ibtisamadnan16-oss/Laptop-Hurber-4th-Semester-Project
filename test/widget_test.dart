import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/main.dart';

void main() {
  testWidgets('LaptopHarborApp launches and shows SplashScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LaptopHarborApp());
    expect(find.text('LaptopHarbor'), findsOneWidget);
    expect(find.text('Premium Laptops & Tech Ecosystem'), findsOneWidget);
  });
}
