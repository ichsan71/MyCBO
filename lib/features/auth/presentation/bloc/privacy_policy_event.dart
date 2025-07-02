part of 'privacy_policy_bloc.dart';

abstract class PrivacyPolicyEvent extends Equatable {
  const PrivacyPolicyEvent();

  @override
  List<Object?> get props => [];
}

class PrivacyPolicyAgreedChanged extends PrivacyPolicyEvent {
  final bool isAgreed;

  const PrivacyPolicyAgreedChanged(this.isAgreed);

  @override
  List<Object?> get props => [isAgreed];
}

class PrivacyPolicyModalVisibilityChanged extends PrivacyPolicyEvent {
  final bool isVisible;

  const PrivacyPolicyModalVisibilityChanged(this.isVisible);

  @override
  List<Object?> get props => [isVisible];
}
