import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;
  @override List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String? d]) : super(d ?? 'Server error.');
}
class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection.');
}
class CacheFailure extends Failure {
  const CacheFailure([String? d]) : super(d ?? 'Storage error.');
}
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}
class NotFoundFailure extends Failure {
  const NotFoundFailure([String? d]) : super(d ?? 'Not found.');
}
class InsufficientStockFailure extends Failure {
  const InsufficientStockFailure([String? d]) : super(d ?? 'Insufficient stock.');
}
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String? d]) : super(d ?? 'Unexpected error.');
}