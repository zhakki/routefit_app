import 'package:flutter_test/flutter_test.dart';
import 'package:routefit_app/main.dart';

void main() {
  testWidgets('RouteFit home screen is shown', (WidgetTester tester) async {
    await tester.pumpWidget(const RouteFitApp());

    expect(find.text('RouteFit App'), findsOneWidget);
    expect(find.text('Firebase connected successfully'), findsOneWidget);
  });
}