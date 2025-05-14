import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

// Interface untuk semua usecase
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Class untuk usecase yang tidak memerlukan parameter
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
