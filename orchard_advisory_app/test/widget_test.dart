import 'package:flutter_test/flutter_test.dart';
import 'package:orchard_advisory_app/main.dart';

void main() {
  testWidgets('Orchard Advisory app loads diagnose tab', (tester) async {
    await tester.pumpWidget(const OrchardAdvisoryApp());
    await tester.pump();

    expect(find.text('Orchard Advisory'), findsOneWidget);
    expect(find.text('What is wrong with your tree?'), findsOneWidget);
    expect(find.text('Diagnose'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
  });
}
