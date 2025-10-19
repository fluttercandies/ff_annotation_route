class User {
  factory User() => _user;
  User._();
  static final User _user = User._();

  bool _hasLogin = false;
  bool get hasLogin => _hasLogin;

  String _role = '';
  String get role => _role;

  bool get isAmdin => hasLogin && role == 'admin';

  void logout() {
    _hasLogin = false;
    _role = '';
  }

  void login(String username) {
    _hasLogin = true;
    _role = username;
  }
}
