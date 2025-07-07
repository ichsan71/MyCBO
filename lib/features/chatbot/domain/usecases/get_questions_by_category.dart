import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_question.dart';
import '../repositories/chatbot_repository.dart';

/// Parameters for GetQuestionsByCategory use case
class GetQuestionsByCategoryParams extends Equatable {
  const GetQuestionsByCategoryParams({required this.categoryId});

  final String categoryId;

  @override
  List<Object?> get props => [categoryId];
}

/// Use case for getting all active questions for a specific category
class GetQuestionsByCategory
    implements UseCase<List<ChatQuestion>, GetQuestionsByCategoryParams> {
  const GetQuestionsByCategory(this.repository);

  final ChatbotRepository repository;

  @override
  Future<Either<Failure, List<ChatQuestion>>> call(
    GetQuestionsByCategoryParams params,
  ) async {
    return await repository.getQuestionsByCategory(params.categoryId);
  }
}
