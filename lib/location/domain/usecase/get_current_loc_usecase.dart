
import 'package:dartz/dartz.dart';
import 'package:nidaa/core/error/failure.dart';
import 'package:nidaa/location/domain/entities/location.dart';
import 'package:nidaa/location/domain/repositories/location_repo_domain.dart';

class GetCurrentLocation {
  final LocationRepoDomain repository;

  const GetCurrentLocation(this.repository);

  Future<Either<Failure, Location>> call() async {
    
    return await repository.getCurrentLocation();

  }
  
}
