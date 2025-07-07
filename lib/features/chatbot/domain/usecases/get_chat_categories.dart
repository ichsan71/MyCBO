import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_category.dart';
import '../repositories/chatbot_repository.dart';

/// Parameters for getting chat categories with role filtering
class GetChatCategoriesParams extends Equatable {
  const GetChatCategoriesParams({
    required this.userRole,
  });

  final String userRole;

  @override
  List<Object?> get props => [userRole];
}

/// Use case for getting chat categories filtered by user role
class GetChatCategories
    implements UseCase<List<ChatCategory>, GetChatCategoriesParams> {
  const GetChatCategories(this.repository);

  final ChatbotRepository repository;

  @override
  Future<Either<Failure, List<ChatCategory>>> call(
      GetChatCategoriesParams params) async {
    final result = await repository.getCategories();

    return result.map((categories) {
      // Filter categories based on user role
      final filteredCategories = categories.where((category) {
        // If allowedRoles is empty, category is accessible to all roles
        if (category.allowedRoles.isEmpty) {
          return true;
        }

        // Check if user role is in allowed roles (case insensitive)
        return category.allowedRoles
            .map((role) => role.toUpperCase())
            .contains(params.userRole.toUpperCase());
      }).toList();

      return filteredCategories;
    });
  }
}
