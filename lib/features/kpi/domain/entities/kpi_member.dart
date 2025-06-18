import 'package:equatable/equatable.dart';
import '../../data/models/kpi_model.dart';

class KpiMember extends Equatable {
  final String kodeRayon;
  final List<KpiGrafik> grafik;

  const KpiMember({
    required this.kodeRayon,
    required this.grafik,
  });

  @override
  List<Object?> get props => [kodeRayon, grafik];
} 