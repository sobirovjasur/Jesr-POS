class SignUpParams {
  final String phone;
  final String password;
  final String name;

  const SignUpParams({
    required this.phone,
    required this.password,
    required this.name,
  });
}

class SignInParams {
  final String phone;
  final String password;

  const SignInParams({
    required this.phone,
    required this.password,
  });
}
