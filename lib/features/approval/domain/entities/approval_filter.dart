import 'package:equatable/equatable.dart';

class ApprovalFilter extends Equatable {
  final String? searchQuery;
  final int? month;
  final int? year;
  final int? status; // 0: pending, 1: approved, 2: rejected
  final int? userId;

  const ApprovalFilter({
    this.searchQuery,
    this.month,
    this.year,
    this.status,
    this.userId,
  });

  ApprovalFilter copyWith({
    String? searchQuery,
    int? month,
    int? year,
    int? status,
    int? userId,
  }) {
    return ApprovalFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      month: month ?? this.month,
      year: year ?? this.year,
      status: status ?? this.status,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [searchQuery, month, year, status, userId];
}
