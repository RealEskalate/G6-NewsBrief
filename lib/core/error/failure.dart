abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([super.message = 'Server failure']);
}

class CacheFailure extends Failure {
  CacheFailure([super.message = 'Cache failure']);
}

class ValidationFailure extends Failure {
  ValidationFailure([super.message = 'Validation failed']);
}