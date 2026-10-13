import 'package:campus_notification_app/pages/announcement_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the announcement id', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AnnouncementPage(id: '3')),
    );

    expect(find.text('Pengumuman kampus #3'), findsOneWidget);
  });
}
