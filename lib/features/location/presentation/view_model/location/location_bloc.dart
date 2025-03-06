import 'package:bloc/bloc.dart';
import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:circle_share/features/location/domain/use_case/add_location_usecase.dart';
import 'package:circle_share/features/location/domain/use_case/delete_location_usecase.dart';
import 'package:circle_share/features/location/domain/use_case/get_all_location_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final AddLocationUseCase _addLocationUseCase;
  final GetAllLocationUseCase _getAllLocationUseCase;
  final DeleteLocationUseCase _deleteLocationUseCase;

  LocationBloc({
    required AddLocationUseCase addLocationUseCase,
    required GetAllLocationUseCase getAllLocationUseCase,
    required DeleteLocationUseCase deleteLocationUseCase,
  })  : _addLocationUseCase = addLocationUseCase,
        _getAllLocationUseCase = getAllLocationUseCase,
        _deleteLocationUseCase = deleteLocationUseCase,
        super(LocationState.initial()) {
    on<LoadLocations>(_onLoadLocations);
    on<AddLocation>(_onAddLocation);
    on<DeleteLocation>(_onDeleteLocation);

    add(LoadLocations());
  }

  Future<void> _onLoadLocations(
      LoadLocations event, Emitter<LocationState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _getAllLocationUseCase.call();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (locations) =>
          emit(state.copyWith(isLoading: false, locations: locations)),
    );
  }

  Future<void> _onAddLocation(
      AddLocation event, Emitter<LocationState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _addLocationUseCase
        .call(AddLocationParams(locationName: event.locationName));
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) {
        emit(state.copyWith(isLoading: false, error: null));
        add(LoadLocations());
      },
    );
  }

  Future<void> _onDeleteLocation(
      DeleteLocation event, Emitter<LocationState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _deleteLocationUseCase
        .call(DeleteLocationParams(locationId: event.locationId));
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) {
        emit(state.copyWith(isLoading: false, error: null));
        add(LoadLocations());
      },
    );
  }
}
