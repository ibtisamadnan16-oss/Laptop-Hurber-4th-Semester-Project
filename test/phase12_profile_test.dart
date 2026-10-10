import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/models/user_model.dart';
import 'package:e_project/screens/profile/profile_screen.dart';
import 'package:e_project/screens/profile/edit_profile_screen.dart';
import 'package:e_project/screens/profile/change_password_screen.dart';

void main() {
  group('Phase 12 — User Profile Models & Serialization', () {
    test('UserModel preserves Profile Picture, Name, Email, Phone and Address',
        () {
      final user = UserModel(
        userId: 'usr_phase12',
        email: 'user@laptopharbor.com',
        name: 'Sarah Connor',
        phone: '+92 321 9876543',
        address: 'Suite 404, Cyber Tower, Karachi',
        profileImage:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        role: 'customer',
      );

      expect(user.userId, equals('usr_phase12'));
      expect(user.email, equals('user@laptopharbor.com'));
      expect(user.name, equals('Sarah Connor'));
      expect(user.phone, equals('+92 321 9876543'));
      expect(user.address, equals('Suite 404, Cyber Tower, Karachi'));
      expect(
          user.profileImage,
          equals(
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400'));

      final map = user.toMap();
      expect(map['name'], equals('Sarah Connor'));
      expect(map['email'], equals('user@laptopharbor.com'));
      expect(map['phone'], equals('+92 321 9876543'));
      expect(map['address'], equals('Suite 404, Cyber Tower, Karachi'));
      expect(
          map['profileImage'],
          equals(
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400'));

      final parsed = UserModel.fromMap('usr_phase12', map);
      expect(parsed.name, equals('Sarah Connor'));
      expect(parsed.email, equals('user@laptopharbor.com'));
      expect(parsed.phone, equals('+92 321 9876543'));
      expect(parsed.address, equals('Suite 404, Cyber Tower, Karachi'));
      expect(
          parsed.profileImage,
          equals(
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400'));
    });
  });

  group('Phase 12 — ChangePasswordScreen Widget Tests', () {
    testWidgets(
        'Renders all password fields, visibility toggles and submit button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsWidgets);
      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
      expect(find.text('Update Password'), findsOneWidget);

      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(3));
    });

    testWidgets('Validates empty inputs and password mismatch', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Password'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your current password'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Please confirm your new password'), findsOneWidget);

      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(3));

      await tester.enterText(textFields.at(0), 'OldPass123');
      await tester.enterText(textFields.at(1), 'NewPass123');
      await tester.enterText(textFields.at(2), 'DifferentPass123');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Password'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Toggles password visibility on eye icon tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final eyeButtons = find.byIcon(Icons.visibility_off_outlined);
      expect(eyeButtons, findsNWidgets(3));

      await tester.tap(eyeButtons.first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
    });
  });

  group('Phase 12 — EditProfileScreen Widget Tests', () {
    testWidgets(
        'Renders Full Name, Phone, Address fields, Avatar and Save button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Shipping Address'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('Opens avatar selector modal on avatar tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      expect(find.text('Choose Profile Picture'), findsOneWidget);
      expect(find.text('Select an avatar:'), findsOneWidget);
      expect(find.text('Or enter Image URL:'), findsOneWidget);
    });

    testWidgets('Validates form inputs on Save Changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'A');
      await tester.enterText(textFields.at(1), '123');
      await tester.enterText(textFields.at(2), 'ab');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
      expect(find.text('Phone number must have at least 10 digits'),
          findsOneWidget);
      expect(find.text('Please enter a complete address'), findsOneWidget);
    });
  });

  group('Phase 12 — ProfileScreen Integration UI Tests', () {
    testWidgets(
        'ProfileScreen renders guest view or navigation when not logged in',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Guest Session'), findsOneWidget);
      expect(find.text('Sign In Now'), findsOneWidget);
      expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    });
  });
}
