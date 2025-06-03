import 'package:equatable/equatable.dart';

class ApprovalResponse extends Equatable {
  final bool success;
  final String message;

  const ApprovalResponse({
    required this.success,
    required this.message,
  });

  @override
  List<Object?> get props => [success, message];
}
