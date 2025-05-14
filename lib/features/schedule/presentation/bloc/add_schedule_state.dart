import 'package:equatable/equatable.dart';
import 'package:test_cbo/features/schedule/data/models/responses/doctor_response.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic.dart';
import 'package:test_cbo/features/schedule/domain/entities/product.dart';
import 'package:test_cbo/features/schedule/domain/entities/schedule_type.dart';

abstract class AddScheduleState extends Equatable {
  const AddScheduleState();

  @override
  List<Object?> get props => [];
}

class AddScheduleInitial extends AddScheduleState {}

class AddScheduleLoading extends AddScheduleState {}

class DoctorsAndClinicsLoaded extends AddScheduleState {
  final List<DoctorClinic> doctorsAndClinics;

  const DoctorsAndClinicsLoaded({required this.doctorsAndClinics});

  @override
  List<Object?> get props => [doctorsAndClinics];
}

class DoctorsLoaded extends AddScheduleState {
  final DoctorResponse doctorResponse;

  const DoctorsLoaded({required this.doctorResponse});

  @override
  List<Object?> get props => [doctorResponse];
}

class ScheduleTypesLoaded extends AddScheduleState {
  final List<ScheduleType> scheduleTypes;

  const ScheduleTypesLoaded({required this.scheduleTypes});

  @override
  List<Object?> get props => [scheduleTypes];
}

class ProductsLoaded extends AddScheduleState {
  final List<Product> products;

  const ProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class AddScheduleSuccess extends AddScheduleState {}

class AddScheduleError extends AddScheduleState {
  final String message;

  const AddScheduleError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AddScheduleFormLoaded extends AddScheduleState {
  final List<DoctorClinic> doctorsAndClinics;
  final List<ScheduleType> scheduleTypes;
  final List<Product> products;
  final DoctorResponse? doctorResponse;

  const AddScheduleFormLoaded({
    required this.doctorsAndClinics,
    required this.scheduleTypes,
    required this.products,
    this.doctorResponse,
  });

  @override
  List<Object?> get props =>
      [doctorsAndClinics, scheduleTypes, products, doctorResponse];
}
