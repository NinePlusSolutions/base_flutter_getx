class ErrorResponse {
  final String message;
  final int statusCode;
  final String? messageCode;

  ErrorResponse({
    required this.message,
    this.statusCode = 500,
    this.messageCode,
  });
}
