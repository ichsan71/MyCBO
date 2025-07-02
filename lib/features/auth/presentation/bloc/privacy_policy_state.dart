part of 'privacy_policy_bloc.dart';

class PrivacyPolicyState extends Equatable {
  final bool isAgreed;
  final bool isModalVisible;

  const PrivacyPolicyState({
    this.isAgreed = false,
    this.isModalVisible = false,
  });

  PrivacyPolicyState copyWith({
    bool? isAgreed,
    bool? isModalVisible,
  }) {
    return PrivacyPolicyState(
      isAgreed: isAgreed ?? this.isAgreed,
      isModalVisible: isModalVisible ?? this.isModalVisible,
    );
  }

  @override
  List<Object?> get props => [isAgreed, isModalVisible];
}
