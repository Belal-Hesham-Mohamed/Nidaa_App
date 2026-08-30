import 'package:dartz/dartz.dart';
import 'package:nidaa/core/error/failure.dart';
import 'package:nidaa/location/domain/entities/location.dart';

abstract class LocationRepoDomain {
Future<Either<Failure, Location>> getCurrentLocation();

}