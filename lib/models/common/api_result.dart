import '../../core/error/app_exception.dart';

/// Lightweight result type for repository returns.
/// Avoids throwing exceptions across layer boundaries.
sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.exception);
  final AppException exception;
}

extension ApiResultX<T> on ApiResult<T> {
  T get dataOrThrow => switch (this) {
        ApiSuccess<T>(:final data) => data,
        ApiFailure<T>(:final exception) => throw exception,
      };

  T? get dataOrNull => switch (this) {
        ApiSuccess<T>(:final data) => data,
        ApiFailure<T>() => null,
      };
}
