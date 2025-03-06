part of 'location_bloc.dart';

@immutable
sealed class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

final class LoadLocations extends LocationEvent {}

final class AddLocation extends LocationEvent {
  final String locationName;

  const AddLocation(this.locationName);

  @override
  List<Object> get props => [locationName];
}

final class DeleteLocation extends LocationEvent {
  final String locationId;

  const DeleteLocation(this.locationId);

  @override
  List<Object> get props => [locationId];
}
