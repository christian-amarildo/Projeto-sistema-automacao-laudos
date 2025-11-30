import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Platform override works', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return Text('Platform: ${defaultTargetPlatform}');
      }),
    ));

    expect(find.text('Platform: TargetPlatform.android'), findsOneWidget);

    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return Text('Platform: ${defaultTargetPlatform}');
      }),
    ));

    expect(find.text('Platform: TargetPlatform.windows'), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });
}
