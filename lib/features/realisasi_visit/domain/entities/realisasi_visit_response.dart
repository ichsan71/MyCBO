import 'package:equatable/equatable.dart';

class RealisasiVisitResponse extends Equatable {
  final bool status;
  final String message;

  const RealisasiVisitResponse({
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [status, message];
}
