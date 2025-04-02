class PaystackConfigException implements Exception {
  const PaystackConfigException(this.message);

  final String message;

  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + message.hashCode;
    return result;
  }

  @override
  bool operator ==(Object other) {
    return other is PaystackConfigException && other.message == message;
  }
}
