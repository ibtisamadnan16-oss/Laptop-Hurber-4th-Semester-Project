class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final trimmed = value.trim();

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email (e.g. name@domain.com)';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateProductAvailability(int stockQuantity) {
    if (stockQuantity <= 0) {
      return 'Product unavailable (out of stock)';
    }
    return null;
  }

  static String? validateCartNotEmpty(int itemCount) {
    if (itemCount <= 0) {
      return 'Cart is empty. Please add items before checkout';
    }
    return null;
  }

  static String? validateNetwork(bool isConnected) {
    if (!isConnected) {
      return 'Internet unavailable. Please check your network connection.';
    }
    return null;
  }

  static String mapAuthError(String? errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address. Please register first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Login failed: Incorrect email or password.';
      case 'email-already-in-use':
        return 'Registration failed: This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'weak-password':
        return 'Password too short: Must be at least 6 characters.';
      case 'user-disabled':
        return 'Your account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Internet unavailable: Network request failed.';
      default:
        return 'Login failed. Please verify your credentials and try again.';
    }
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final trimmed = value.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');

    if (digitsOnly.length < 10) {
      return 'Phone number must have at least 10 digits';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }

    if (value.trim().length < 5) {
      return 'Please enter a complete address';
    }

    return null;
  }
}
