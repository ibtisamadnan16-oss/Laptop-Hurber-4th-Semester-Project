import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/models/support_ticket_model.dart';
import 'package:e_project/screens/support/contact_support_screen.dart';

void main() {
  group('Phase 13 — SupportTicketModel Tests', () {
    test('Contains all 6 required categories', () {
      expect(SupportTicketModel.categories, contains('Order Issue'));
      expect(SupportTicketModel.categories, contains('Payment Issue'));
      expect(SupportTicketModel.categories, contains('Delivery Issue'));
      expect(SupportTicketModel.categories, contains('Product Issue'));
      expect(SupportTicketModel.categories, contains('Account Issue'));
      expect(SupportTicketModel.categories, contains('Other'));
      expect(SupportTicketModel.categories.length, equals(6));
    });

    test('SupportTicketModel serializes and deserializes properly', () {
      final now = DateTime.now();
      final ticket = SupportTicketModel(
        id: 'tick_999',
        name: 'Hamza Khan',
        email: 'hamza@example.com',
        category: 'Delivery Issue',
        subject: 'Late Delivery of HP EliteBook',
        message: 'My laptop delivery was delayed by 3 days. Please assist.',
        userId: 'usr_789',
        status: 'Open',
        createdAt: now,
      );

      expect(ticket.id, equals('tick_999'));
      expect(ticket.name, equals('Hamza Khan'));
      expect(ticket.email, equals('hamza@example.com'));
      expect(ticket.category, equals('Delivery Issue'));
      expect(ticket.subject, equals('Late Delivery of HP EliteBook'));
      expect(ticket.message, contains('delayed by 3 days'));
      expect(ticket.status, equals('Open'));

      final map = ticket.toMap();
      expect(map['name'], equals('Hamza Khan'));
      expect(map['email'], equals('hamza@example.com'));
      expect(map['category'], equals('Delivery Issue'));

      final parsed = SupportTicketModel.fromMap(map, 'tick_999');
      expect(parsed.name, equals('Hamza Khan'));
      expect(parsed.email, equals('hamza@example.com'));
      expect(parsed.category, equals('Delivery Issue'));
      expect(parsed.subject, equals('Late Delivery of HP EliteBook'));
    });
  });

  group('Phase 13 — ContactSupportScreen Widget Tests', () {
    testWidgets(
        'Renders Name, Email, Subject, Message, Category chips and Send button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ContactSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Contact Support'), findsOneWidget);

      expect(find.text('Order Issue'), findsWidgets);
      expect(find.text('Payment Issue'), findsWidgets);
      expect(find.text('Delivery Issue'), findsWidgets);
      expect(find.text('Product Issue'), findsWidgets);
      expect(find.text('Account Issue'), findsWidgets);
      expect(find.text('Other'), findsWidgets);

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Subject'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);

      expect(find.text('Send'), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('Validates empty form fields on Send click', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ContactSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Send'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Please enter a subject'), findsOneWidget);
      expect(find.text('Please enter your message'), findsOneWidget);
    });

    testWidgets('Validates short inputs and format rules', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ContactSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(4));

      await tester.enterText(textFields.at(0), 'A');
      await tester.enterText(textFields.at(1), 'invalid-email');
      await tester.enterText(textFields.at(2), 'Hi');
      await tester.enterText(textFields.at(3), 'Too short');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Send'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
      expect(find.text('Please enter a valid email (e.g. name@domain.com)'),
          findsOneWidget);
      expect(
          find.text('Subject must be at least 3 characters'), findsOneWidget);
      expect(
          find.text('Message must be at least 10 characters'), findsOneWidget);
    });

    testWidgets(
        'Selecting a category chip updates selection and auto-fills subject placeholder',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ContactSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Payment Issue'));
      await tester.pumpAndSettle();

      expect(find.text('Payment Issue Inquiry'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Delivery Issue'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ChoiceChip, 'Delivery Issue'), findsOneWidget);
    });
  });
}
