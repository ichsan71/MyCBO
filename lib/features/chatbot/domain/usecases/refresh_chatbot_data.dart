import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chatbot_repository.dart';

/// Use case for refreshing chatbot data from remote source
class RefreshChatbotData implements UseCase<void, NoParams> {
  const RefreshChatbotData(this.repository);

  final ChatbotRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.refreshData();
  }
}
