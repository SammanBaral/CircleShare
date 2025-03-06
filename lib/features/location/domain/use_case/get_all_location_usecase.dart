import 'package:circle_share/app/usecase/usecase.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:circle_share/features/location/domain/repository/location_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllLocationUseCase
    implements UsecaseWithoutParams<List<LocationEntity>> {
  final ILocationRepository locationRepository;

  GetAllLocationUseCase({required this.locationRepository});

  @override
  Future<Either<Failure, List<LocationEntity>>> call() async {
    return await locationRepository.getLocations();
  }
}
