import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_feedback.dart';
import '../repositories/chatbot_repository.dart';

/// Parameters for SubmitFeedback use case
class SubmitFeedbackParams extends Equatable {
  const SubmitFeedbackParams({required this.feedback});

  final ChatFeedback feedback;

  @override
  List<Object?> get props => [feedback];
}

/// Use case for submitting user feedback on chatbot answers
class SubmitFeedback implements UseCase<void, SubmitFeedbackParams> {
  const SubmitFeedback(this.repository);

  final ChatbotRepository repository;

  @override
  Future<Either<Failure, void>> call(SubmitFeedbackParams params) async {
    return await repository.submitFeedback(params.feedback);
  }
}
