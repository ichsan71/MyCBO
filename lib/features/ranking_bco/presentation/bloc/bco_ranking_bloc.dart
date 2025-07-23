import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_bco_ranking.dart';
import 'bco_ranking_event.dart';
import 'bco_ranking_state.dart';

class BcoRankingBloc extends Bloc<BcoRankingEvent, BcoRankingState> {
  final GetBcoRanking getBcoRanking;
  BcoRankingBloc({required this.getBcoRanking}) : super(BcoRankingInitial()) {
    on<FetchBcoRanking>(_onFetch);
  }

  Future<void> _onFetch(
      FetchBcoRanking event, Emitter<BcoRankingState> emit) async {
    emit(BcoRankingLoading());
    try {
      final rankings = await getBcoRanking(
        token: event.token,
        year: event.year,
        month: event.month,
      );
      emit(BcoRankingLoaded(rankings));
    } catch (e) {
      emit(BcoRankingError(e.toString()));
    }
  }
}
