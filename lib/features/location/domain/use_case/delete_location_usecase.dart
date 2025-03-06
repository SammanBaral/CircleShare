import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:circle_share/app/usecase/usecase.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/location/domain/repository/location_repository.dart';

class DeleteLocationParams extends Equatable {
  final String locationId;

  const DeleteLocationParams({required this.locationId});

  @override
  List<Object?> get props => [locationId];
}

class DeleteLocationUseCase implements UsecaseWithParams<void, DeleteLocationParams> {
  final ILocationRepository locationRepository;

  DeleteLocationUseCase({required this.locationRepository});

  @override
  Future<Either<Failure, void>> call(DeleteLocationParams params) async {
    return await locationRepository.deleteLocation(params.locationId);
  }
}
