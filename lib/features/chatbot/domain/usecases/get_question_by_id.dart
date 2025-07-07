import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_question.dart';
import '../repositories/chatbot_repository.dart';

/// Parameters for GetQuestionById use case
class GetQuestionByIdParams extends Equatable {
  const GetQuestionByIdParams({required this.questionId});

  final String questionId;

  @override
  List<Object?> get props => [questionId];
}

/// Use case for getting a specific question by its ID
class GetQuestionById implements UseCase<ChatQuestion, GetQuestionByIdParams> {
  const GetQuestionById(this.repository);

  final ChatbotRepository repository;

  @override
  Future<Either<Failure, ChatQuestion>> call(
    GetQuestionByIdParams params,
  ) async {
    return await repository.getQuestionById(params.questionId);
  }
}
