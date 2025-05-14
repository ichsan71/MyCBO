import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:test_cbo/core/error/failures.dart';
import 'package:test_cbo/core/usecases/usecase.dart';
import 'package:test_cbo/features/schedule/domain/entities/product.dart';
import 'package:test_cbo/features/schedule/domain/repositories/add_schedule_repository.dart';

class GetProducts implements UseCase<List<Product>, ProductParams> {
  final AddScheduleRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(ProductParams params) {
    return repository.getProducts(params.userId);
  }
}

class ProductParams extends Equatable {
  final int userId;

  const ProductParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
