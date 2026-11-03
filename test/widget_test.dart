import 'package:flutter_test/flutter_test.dart';
import 'package:deepamatchbox/main.dart';

void main() {
  testWidgets('Deeba Match House Customer & Admin Portal smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DeebaMatchHouseApp());

    expect(find.text('DEEBA MATCH HOUSE'), findsWidgets);
    expect(find.text('Eagle Matches'), findsWidgets);
    expect(find.text('Pulli Matches'), findsWidgets);
    expect(find.text('Joker Matches'), findsWidgets);
  });
}
