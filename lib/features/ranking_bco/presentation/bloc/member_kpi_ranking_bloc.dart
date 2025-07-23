import 'package:flutter_bloc/flutter_bloc.dart';
import 'member_kpi_ranking_event.dart';
import 'member_kpi_ranking_state.dart';
import '../../domain/usecases/get_member_kpi_ranking.dart';

class MemberKpiRankingBloc
    extends Bloc<MemberKpiRankingEvent, MemberKpiRankingState> {
  final GetMemberKpiRanking getMemberKpiRanking;
  MemberKpiRankingBloc({required this.getMemberKpiRanking})
      : super(MemberKpiRankingInitial()) {
    on<FetchMemberKpiRanking>(_onFetch);
  }

  Future<void> _onFetch(
      FetchMemberKpiRanking event, Emitter<MemberKpiRankingState> emit) async {
    emit(MemberKpiRankingLoading());
    try {
      final members = await getMemberKpiRanking(
        bcoId: event.bcoId,
        year: event.year,
        month: event.month,
      );
      emit(MemberKpiRankingLoaded(members));
    } catch (e) {
      emit(MemberKpiRankingError(e.toString()));
    }
  }
}
