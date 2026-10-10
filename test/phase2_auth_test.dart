import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/utils/validators.dart';
import 'package:e_project/models/user_model.dart';

void main() {
  group('Phase 2 - AppValidators Test', () {
    test('Email validation tests', () {
      expect(AppValidators.validateEmail(''), 'Email address is required');
      expect(AppValidators.validateEmail(null), 'Email address is required');
      expect(AppValidators.validateEmail('invalid-email'),
          'Please enter a valid email (e.g. name@domain.com)');
      expect(AppValidators.validateEmail('user@domain'),
          'Please enter a valid email (e.g. name@domain.com)');
      expect(AppValidators.validateEmail('user@domain.com'), isNull);
      expect(AppValidators.validateEmail('test.user+tag@laptop-harbor.org'),
          isNull);
    });

    test('Password validation tests', () {
      expect(AppValidators.validatePassword(''), 'Password is required');
      expect(AppValidators.validatePassword(null), 'Password is required');
      expect(AppValidators.validatePassword('12345'),
          'Password must be at least 6 characters');
      expect(AppValidators.validatePassword('123456'), isNull);
      expect(AppValidators.validatePassword('SecurePass@2026'), isNull);
    });

    test('Confirm password tests', () {
      expect(AppValidators.validateConfirmPassword('', 'abc'),
          'Please confirm your password');
      expect(AppValidators.validateConfirmPassword('123456', 'abcdef'),
          'Passwords do not match');
      expect(
          AppValidators.validateConfirmPassword('password123', 'password123'),
          isNull);
    });

    test('Name, Phone and Address validation tests', () {
      expect(AppValidators.validateName('A'),
          'Name must be at least 2 characters');
      expect(AppValidators.validateName('John Doe'), isNull);

      expect(AppValidators.validatePhone('123'),
          'Phone number must have at least 10 digits');
      expect(AppValidators.validatePhone('+92 300 1234567'), isNull);

      expect(AppValidators.validateAddress('Main'),
          'Please enter a complete address');
      expect(AppValidators.validateAddress('123 Tech Street, Karachi'), isNull);
    });
  });

  group('Phase 2 - UserModel Serialization Test', () {
    test('UserModel mapping to/from Firestore map', () {
      final user = UserModel(
        userId: 'usr_123',
        email: 'test@laptopharbor.com',
        name: 'Ali Ahmed',
        phone: '+923001234567',
        address: 'House 42, Street 7, Islamabad',
        profileImage: 'https://example.com/avatar.jpg',
        role: 'user',
      );

      final map = user.toMap();
      expect(map['userId'], 'usr_123');
      expect(map['email'], 'test@laptopharbor.com');
      expect(map['name'], 'Ali Ahmed');
      expect(map['phone'], '+923001234567');
      expect(map['address'], 'House 42, Street 7, Islamabad');
      expect(map['profileImage'], 'https://example.com/avatar.jpg');

      final reconstructed = UserModel.fromMap('usr_123', map);
      expect(reconstructed.userId, 'usr_123');
      expect(reconstructed.email, 'test@laptopharbor.com');
      expect(reconstructed.phone, '+923001234567');
      expect(reconstructed.address, 'House 42, Street 7, Islamabad');
    });
  });
}
