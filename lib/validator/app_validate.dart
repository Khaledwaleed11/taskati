class AppValidator {
  AppValidator._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    if (email.contains(' ')) {
      return 'Email must not contain spaces';
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    if (email.contains('..')) {
      return 'Email cannot contain consecutive dots';
    }

    if (email.split('@').length != 2) {
      return 'Invalid email format';
    }

    return null;
  }

  static String? validatePassword(
    String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumber = true,
    bool requireSpecialCharacter = true,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.contains(' ')) {
      return 'Password must not contain spaces';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }

    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }

    if (requireNumber && !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }

    if (requireSpecialCharacter &&
        !RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(value)) {
      return 'Password must contain a special character';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (password == null || password.isEmpty) {
      return 'Please enter your password first';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    final name = value.trim();

    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (name.length > 50) {
      return 'Name must not exceed 50 characters';
    }

    if (!RegExp(r"^[a-zA-Z\u0600-\u06FF\s]+$").hasMatch(name)) {
      return 'Name can only contain letters';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phone = value.trim().replaceAll(RegExp(r'[\s-]'), '');

    final phoneRegex = RegExp(r'^(?:\+20|0020|0)?1[0125][0-9]{8}$');

    if (!phoneRegex.hasMatch(phone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    final username = value.trim();

    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (username.length > 20) {
      return 'Username must not exceed 20 characters';
    }

    if (username.contains(' ')) {
      return 'Username must not contain spaces';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers and _';
    }

    return null;
  }

  static String? validateRequired(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  static String? validateTaskTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Task title is required';
    }

    final title = value.trim();

    if (title.length < 3) {
      return 'Task title must be at least 3 characters';
    }

    if (title.length > 100) {
      return 'Task title must not exceed 100 characters';
    }

    return null;
  }

  static String? validateTaskDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Task description is required';
    }

    final description = value.trim();

    if (description.length < 5) {
      return 'Description must be at least 5 characters';
    }

    if (description.length > 300) {
      return 'Description must not exceed 300 characters';
    }

    return null;
  }
}
