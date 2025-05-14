import 'package:equatable/equatable.dart';

class ApprovalResponse extends Equatable {
  final int status;
  final String message;

  const ApprovalResponse({
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [status, message];
}
