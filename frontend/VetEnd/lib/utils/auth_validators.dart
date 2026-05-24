class AuthValidators {
  AuthValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,30}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Introduceți adresa de email';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Introduceți o adresă de email validă';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Introduceți un nume de utilizator';
    }
    if (!_usernameRegex.hasMatch(value.trim())) {
      return 'Folosiți 3–30 caractere: litere, cifre, underscore';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Introduceți numele complet';
    }
    if (value.trim().length < 2) {
      return 'Minim 2 caractere';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Introduceți o parolă';
    }
    if (value.length < 6) {
      return 'Minim 6 caractere';
    }
    return null;
  }
}
