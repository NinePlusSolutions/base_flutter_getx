class BaseResponse<T> {
  final String? message;
  final bool? success;
  final T? data;

  BaseResponse({
    this.message,
    this.success,
    this.data,
  });

  BaseResponse<T> copyWith({
    String? message,
    bool? success,
    T? data,
  }) {
    return BaseResponse<T>(
      message: message ?? this.message,
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }
}
