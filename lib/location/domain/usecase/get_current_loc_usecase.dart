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

class GetSavedLocation {
  final LocationRepoDomain repository;

  const GetSavedLocation(this.repository);

  Location? call() => repository.getSavedLocation();
}

class SaveLocation {
  final LocationRepoDomain repository;

  const SaveLocation(this.repository);

  Future<void> call(Location location) => repository.saveLocation(location);
}
