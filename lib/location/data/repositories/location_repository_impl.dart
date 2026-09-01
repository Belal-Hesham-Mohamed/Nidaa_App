import 'package:dartz/dartz.dart';
import 'package:nidaa/core/error/exception.dart';
import 'package:nidaa/core/error/failure.dart';
import 'package:nidaa/location/data/datasource/location_local_data_source.dart';
import 'package:nidaa/location/domain/entities/location.dart';
import 'package:nidaa/location/domain/repositories/location_repo_domain.dart';

class LocationRepositoryImpl implements LocationRepoDomain {
  LocationLocalDataSource localDataSource;
  LocationRepositoryImpl(this.localDataSource);
  @override
  
  Future<Either<Failure, Location>> getCurrentLocation() async {
    try{
    final location = await localDataSource.getCurrentLocation();
    return Right(location as Location);
      } on LocationPermissionException  {
    return Left(PermissionFailure());
  } on LocationServiceException {
    return Left(LocationServiceFailure());
  } on LocationException {
    return Left(LocationFailure());
  
    }
  }
}
