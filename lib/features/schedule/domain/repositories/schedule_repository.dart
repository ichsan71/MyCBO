import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/schedule.dart';
import '../../data/models/edit/edit_schedule_response_model.dart';
import '../../data/models/edit_schedule_data_model.dart';
import '../../data/models/update_schedule_request_model.dart';

abstract class ScheduleRepository {
  Future<Either<Failure, List<Schedule>>> getSchedules(int userId, {int page = 1});
  Future<Either<Failure, List<Schedule>>> getSchedulesByRangeDate(
      int userId, String rangeDate, int page);
  Future<Either<Failure, List<Schedule>>> getRejectedSchedules(int userId);
  Future<Either<Failure, EditScheduleDataModel>> getEditScheduleData(
      int scheduleId);
  Future<Either<Failure, Unit>> updateSchedule(
      UpdateScheduleRequestModel requestModel);
  Future<Either<Failure, EditScheduleResponseModel>> fetchEditScheduleData(
      int scheduleId);
  Future<Either<Failure, Unit>> saveEditedSchedule(Schedule schedule);
}
