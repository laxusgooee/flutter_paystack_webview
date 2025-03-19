class SetupWebviewParameters {
  const SetupWebviewParameters({
    required this.email,
    required this.amount,

    this.accessCode,
  });
  

  final String email;
  final num amount;

  final String? accessCode;
}