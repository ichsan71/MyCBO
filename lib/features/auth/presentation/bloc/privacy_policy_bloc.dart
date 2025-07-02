import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'privacy_policy_event.dart';
part 'privacy_policy_state.dart';

class PrivacyPolicyBloc extends Bloc<PrivacyPolicyEvent, PrivacyPolicyState> {
  PrivacyPolicyBloc() : super(const PrivacyPolicyState()) {
    on<PrivacyPolicyAgreedChanged>(_onAgreedChanged);
    on<PrivacyPolicyModalVisibilityChanged>(_onModalVisibilityChanged);
  }

  void _onAgreedChanged(
    PrivacyPolicyAgreedChanged event,
    Emitter<PrivacyPolicyState> emit,
  ) {
    emit(state.copyWith(isAgreed: event.isAgreed));
  }

  void _onModalVisibilityChanged(
    PrivacyPolicyModalVisibilityChanged event,
    Emitter<PrivacyPolicyState> emit,
  ) {
    emit(state.copyWith(isModalVisible: event.isVisible));
  }
}
