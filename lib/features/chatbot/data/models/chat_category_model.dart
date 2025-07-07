import '../../domain/entities/chat_category.dart';

/// Data model for ChatCategory with JSON serialization
class ChatCategoryModel extends ChatCategory {
  const ChatCategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.description,
    required super.order,
    super.isActive = true,
    super.allowedRoles = const [],
  });

  /// Create ChatCategoryModel from JSON
  factory ChatCategoryModel.fromJson(Map<String, dynamic> json) {
    return ChatCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      isActive: json['isActive'] as bool? ?? true,
      allowedRoles: (json['allowedRoles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  /// Convert ChatCategoryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'order': order,
      'isActive': isActive,
      'allowedRoles': allowedRoles,
    };
  }

  /// Create ChatCategoryModel from ChatCategory entity
  factory ChatCategoryModel.fromEntity(ChatCategory category) {
    return ChatCategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      description: category.description,
      order: category.order,
      isActive: category.isActive,
      allowedRoles: category.allowedRoles,
    );
  }

  /// Convert to ChatCategory entity
  ChatCategory toEntity() {
    return ChatCategory(
      id: id,
      name: name,
      icon: icon,
      description: description,
      order: order,
      isActive: isActive,
      allowedRoles: allowedRoles,
    );
  }

  /// Create a copy with updated fields
  @override
  ChatCategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? description,
    int? order,
    bool? isActive,
    List<String>? allowedRoles,
  }) {
    return ChatCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      allowedRoles: allowedRoles ?? this.allowedRoles,
    );
  }
}
