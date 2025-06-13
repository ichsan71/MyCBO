import 'package:equatable/equatable.dart';
import 'package:test_cbo/features/schedule/data/models/responses/doctor_response.dart';
import 'package:test_cbo/features/schedule/domain/entities/doctor_clinic_base.dart';
import 'package:test_cbo/features/schedule/domain/entities/product.dart';
import 'package:test_cbo/features/schedule/domain/entities/schedule_type.dart';

abstract class AddScheduleState extends Equatable {
  const AddScheduleState();

  @override
  List<Object?> get props => [];
}

class AddScheduleInitial extends AddScheduleState {
  const AddScheduleInitial();
}

class AddScheduleLoading extends AddScheduleState {
  const AddScheduleLoading();
}

class AddScheduleError extends AddScheduleState {
  final String message;

  const AddScheduleError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AddScheduleSuccess extends AddScheduleState {
  const AddScheduleSuccess();
}

class DoctorsAndClinicsLoaded extends AddScheduleState {
  final List<DoctorClinicBase> doctorsAndClinics;

  const DoctorsAndClinicsLoaded({required this.doctorsAndClinics});

  @override
  List<Object?> get props => [doctorsAndClinics];
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

class AddScheduleFormLoaded extends AddScheduleState {
  final List<DoctorClinicBase> doctorsAndClinics;
  final List<ScheduleType> scheduleTypes;
  final List<Product> products;

  const AddScheduleFormLoaded({
    required this.doctorsAndClinics,
    required this.scheduleTypes,
    required this.products,
  });

  @override
  List<Object?> get props => [doctorsAndClinics, scheduleTypes, products];
}
