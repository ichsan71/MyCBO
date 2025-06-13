import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../schedule/data/models/checkin_request_model.dart';
import '../../../schedule/data/models/checkout_request_model.dart';

abstract class CheckInRepository {
  Future<Either<Failure, void>> checkIn(CheckinRequestModel request);
  Future<Either<Failure, void>> checkOut(CheckoutRequestModel request);
}
