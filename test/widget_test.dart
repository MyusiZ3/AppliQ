import 'package:flutter_test/flutter_test.dart';
import 'package:appliq/main.dart';
import 'package:appliq/data/repositories/mock_job_repository.dart';

void main() {
  testWidgets('AppliQ launches successfully in mock mode', (WidgetTester tester) async {
    final mockRepo = MockJobRepository();
    await tester.pumpWidget(AppliQApp(repository: mockRepo));
    await tester.pumpAndSettle();

    // Verify main screen shows header
    expect(find.text('Pelacak Lamaran'), findsOneWidget);
  });
}
