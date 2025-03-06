part of 'location_bloc.dart';

class LocationState extends Equatable {
  final List<LocationEntity> locations;
  final bool isLoading;
  final String? error;

  const LocationState({
    required this.locations,
    required this.isLoading,
    this.error,
  });

  factory LocationState.initial() {
    return const LocationState(
      locations: [],
      isLoading: false,
    );
  }

  LocationState copyWith({
    List<LocationEntity>? locations,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [locations, isLoading, error];
}
