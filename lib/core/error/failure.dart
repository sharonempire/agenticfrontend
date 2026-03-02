abstract class Failure implements Exception {
  const Failure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Please try again.']);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class ApiFailure extends Failure {
  const ApiFailure(super.message, {super.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Session expired. Please log in again.',
  ]) : super(statusCode: 401);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.statusCode});
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected error occurred.']);
}
