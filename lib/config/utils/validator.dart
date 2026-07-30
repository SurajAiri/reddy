class InputValidator {
  static String? validatePassword(String? value) {
    final regex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    if (value == null || value == "") {
      return "Password is required field";
    } else if (value.length < 6) {
      return "at least 8 characters.";
    } else if (!regex.hasMatch(value)) {
      return 'Enter a valid password';
    } else if (value.length > 36) {
      return 'maximum 36 characters.';
    }
    return null;
  }

  static String? validateInt(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter years of experience";
    } else if (int.tryParse(value) == null) {
      return "invalid value";
    }
  }

  static String? validateEmail(String? value) {
    if (value == null || value == "") {
      return "Email is required field";
    } else if (value.length < 6) {
      return "Invalid Email";
    } else if (!value.contains('@') || !value.contains('.')) {
      return 'Invalid Email';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value == "") {
      return "Name is required field";
    } else if (value.length < 3) {
      return "Invalid Name";
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value == "") {
      return "Phone is required field";
    } else if (value.length < 10) {
      return "Invalid Phone Number";
    } else if (int.tryParse(value) == null) {
      return "Invalid Phone Number";
    }
    return null;
  }

  static String? validateRequiredField(String? value, {int minLen = 3}) {
    if (value == null || value == "") {
      return "Required field";
    } else if (value.length < minLen) {
      return "Invalid Name";
    }
    return null;
  }
}
