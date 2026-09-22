class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.errors,
    this.data,
  });

  final String message;
  final int? statusCode;
  final dynamic errors;
  final Map<String, dynamic>? data;

  @override
  String toString() => message;
}
