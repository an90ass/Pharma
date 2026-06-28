import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

abstract class StreamUseCase<T, P> {
  Stream<Either<Failure, T>> call(P params);
}

class NoParams extends Equatable {
  const NoParams();
  @override List<Object> get props => [];
}