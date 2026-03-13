/// Result of AFM validation.
class AfmValidationResult {
  /// Whether the AFM is valid.
  final bool isValid;

  /// Human-readable message (null if valid).
  final String? message;

  const AfmValidationResult._({required this.isValid, this.message});

  static const _valid = AfmValidationResult._(isValid: true);

  factory AfmValidationResult.valid() => _valid;

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
/// AfmValidator.isValid('123456789'); // true or false
///
/// final result = AfmValidator.validate('123456789');
/// if (result.isValid) {
///   print('Valid AFM');
/// } else {
///   print(result.message); // e.g., "Invalid checksum"
/// }
/// ```
class AfmValidator {
  AfmValidator._();

  /// Validate an AFM and return a detailed result.
  static AfmValidationResult validate(String afm) {
    // Strip whitespace and dashes
    afm = afm.replaceAll(RegExp(r'[\s\-]'), '');

    // Must be exactly 9 digits
    if (!RegExp(r'^\d{9}$').hasMatch(afm)) {
      return AfmValidationResult.invalid(
        'AFM must contain exactly 9 digits',
      );
    }

    // All zeros is invalid
    if (afm == '000000000') {
      return AfmValidationResult.invalid('Invalid AFM');
    }

    // Checksum: weighted sum using powers of 2
    // Weights: 256, 128, 64, 32, 16, 8, 4, 2 for digits 0-7
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
    final cleaned = afm.replaceAll(RegExp(r'[\s\-]'), '');
    if (isValid(cleaned)) return cleaned;
    return null;
  }
}
