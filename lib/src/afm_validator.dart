/// Result of AFM validation.
class AfmValidationResult {
  /// Whether the AFM is valid.
  final bool isValid;

  /// Human-readable message (null if valid).
  final String? message;

  const AfmValidationResult._({required this.isValid, this.message});

  static const _valid = AfmValidationResult._(isValid: true);

  /// A successful result with no message.
  factory AfmValidationResult.valid() => _valid;

  /// A failed result with the reason in [message].
  factory AfmValidationResult.invalid(String message) =>
      AfmValidationResult._(isValid: false, message: message);
}

/// Validates Greek AFM (VAT/Tax Identification Number).
///
/// The AFM is a 9-digit number used by the Greek tax authority (AADE).
/// The last digit is a check digit computed using a weighted sum with
/// powers of 2.
///
/// ```dart
/// AfmValidator.isValid('090000045'); // true
///
/// final result = AfmValidator.validate('123456789');
/// if (!result.isValid) {
///   print(result.message); // "Invalid AFM checksum"
/// }
/// ```
class AfmValidator {
  AfmValidator._();

  static final _separators = RegExp(r'[\s\-]');
  static final _nineDigits = RegExp(r'^\d{9}$');

  /// Validate an AFM and return a detailed result.
  ///
  /// Whitespace and dashes are ignored, so `090 000 045` and `090-000-045`
  /// are both accepted.
  static AfmValidationResult validate(String afm) {
    afm = afm.replaceAll(_separators, '');

    if (!_nineDigits.hasMatch(afm)) {
      return AfmValidationResult.invalid('AFM must contain exactly 9 digits');
    }

    if (afm == '000000000') {
      return AfmValidationResult.invalid('Invalid AFM');
    }

    // Weights 256, 128, 64, 32, 16, 8, 4, 2 for digits 0-7.
    // Check digit (digit 8) = (sum % 11) % 10
    int sum = 0;
    for (int i = 0; i < 8; i++) {
      sum += int.parse(afm[i]) * (1 << (8 - i));
    }
    final checksum = (sum % 11) % 10;

    if (checksum != int.parse(afm[8])) {
      return AfmValidationResult.invalid('Invalid AFM checksum');
    }

    return AfmValidationResult.valid();
  }

  /// Returns `true` if the AFM is valid.
  static bool isValid(String afm) => validate(afm).isValid;

  /// Formats an AFM by stripping whitespace and dashes.
  /// Returns the cleaned 9-digit string, or null if invalid.
  static String? format(String afm) {
    final cleaned = afm.replaceAll(_separators, '');
    if (isValid(cleaned)) return cleaned;
    return null;
  }

  /// Validator you can pass straight to a `TextFormField`.
  ///
  /// Returns `null` when the AFM is valid, otherwise the error message.
  ///
  /// ```dart
  /// TextFormField(validator: AfmValidator.formValidator)
  /// ```
  static String? formValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'AFM is required';
    return validate(value).message;
  }
}
