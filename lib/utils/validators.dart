/// Form validators for use with [TextFormField] and [CcTextField].
abstract final class Validators {
  static String? required(String? value, {String message = 'This field is required'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!re.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? label}) {
    if (value == null || value.length < min) {
      return '${label ?? 'This field'} must be at least $min characters';
    }
    return null;
  }

  static String? combine(String? value, List<String? Function(String?)> rules) {
    for (final rule in rules) {
      final err = rule(value);
      if (err != null) {
        return err;
      }
    }
    return null;
  }
}
