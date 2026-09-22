class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic json)? parseData,
  }) {
    return ApiResponse<T>(
      success: json['success'] == true || json['status'] == true,
      data: parseData != null && json['data'] != null
          ? parseData(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
    );
  }
}
