abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class SmsParsingFailure extends Failure {
  const SmsParsingFailure(super.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class GeneralFailure extends Failure {
  const GeneralFailure(super.message);
}
