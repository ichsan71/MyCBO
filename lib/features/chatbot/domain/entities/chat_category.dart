import 'package:equatable/equatable.dart';

/// Entity representing a category of chatbot questions
class ChatCategory extends Equatable {
  const ChatCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.order,
    this.isActive = true,
    this.allowedRoles = const [],
  });

  /// Unique identifier for the category
  final String id;

  /// Display name of the category
  final String name;

  /// Icon representing the category (could be icon name or emoji)
  final String icon;

  /// Brief description of what questions this category contains
  final String description;

  /// Order for displaying categories (lower numbers appear first)
  final int order;

  /// Whether this category is currently active/visible
  final bool isActive;

  /// List of roles that can access this category. Empty list means all roles can access
  final List<String> allowedRoles;

  /// Creates a copy of this category with updated fields
  ChatCategory copyWith({
    String? id,
    String? name,
    String? icon,
    String? description,
    int? order,
    bool? isActive,
    List<String>? allowedRoles,
  }) {
    return ChatCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      allowedRoles: allowedRoles ?? this.allowedRoles,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        description,
        order,
        isActive,
        allowedRoles,
      ];
}
