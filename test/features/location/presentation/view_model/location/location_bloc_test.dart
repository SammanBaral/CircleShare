import 'package:bloc_test/bloc_test.dart';
import 'package:circle_share/core/error/failure.dart';
import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:circle_share/features/location/domain/use_case/add_location_usecase.dart';
import 'package:circle_share/features/location/domain/use_case/delete_location_usecase.dart';
import 'package:circle_share/features/location/domain/use_case/get_all_location_usecase.dart';
import 'package:circle_share/features/location/presentation/view_model/location/location_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockAddLocationUseCase extends Mock implements AddLocationUseCase {}

class MockGetAllLocationUseCase extends Mock implements GetAllLocationUseCase {}

class MockDeleteLocationUseCase extends Mock implements DeleteLocationUseCase {}

void main() {
  late LocationBloc locationBloc;
  late MockAddLocationUseCase mockAddLocationUseCase;
  late MockGetAllLocationUseCase mockGetAllLocationUseCase;
  late MockDeleteLocationUseCase mockDeleteLocationUseCase;

  setUp(() {
    mockAddLocationUseCase = MockAddLocationUseCase();
    mockGetAllLocationUseCase = MockGetAllLocationUseCase();
    mockDeleteLocationUseCase = MockDeleteLocationUseCase();

    locationBloc = LocationBloc(
      addLocationUseCase: mockAddLocationUseCase,
      getAllLocationUseCase: mockGetAllLocationUseCase,
      deleteLocationUseCase: mockDeleteLocationUseCase,
    );
  });

  tearDown(() {
    locationBloc.close();
  });

  // Test 1: Successful loading of locations
  blocTest<LocationBloc, LocationState>(
    'emits [loading, success] when locations are loaded successfully',
    build: () {
      when(() => mockGetAllLocationUseCase.call()).thenAnswer(
        (_) async => Right([LocationEntity(id: '1', name: 'Test Location')]),
      );
      return locationBloc;
    },
    act: (bloc) => bloc.add(LoadLocations()),
    expect: () => [
      LocationState(isLoading: true, locations: []),
      LocationState(
          isLoading: false,
          locations: [LocationEntity(id: '1', name: 'Test Location')]),
    ],
  );

  // Test 2: Adding a location successfully
  blocTest<LocationBloc, LocationState>(
    'emits [loading, success] when a location is added successfully',
    build: () {
      when(() => mockAddLocationUseCase.call(any()))
          .thenAnswer((_) async => Right(null));
      when(() => mockGetAllLocationUseCase.call()).thenAnswer(
        (_) async => Right([LocationEntity(id: '1', name: 'Test Location')]),
      );
      return locationBloc;
    },
    act: (bloc) => bloc.add(AddLocation('New Location')),
    expect: () => [
      LocationState(isLoading: true, locations: []),
      LocationState(
          isLoading: false,
          locations: [LocationEntity(id: '1', name: 'Test Location')]),
    ],
  );

  // Test 3: Deleting a location successfully
  blocTest<LocationBloc, LocationState>(
    'emits [loading, success] when a location is deleted successfully',
    build: () {
      when(() => mockDeleteLocationUseCase.call(any()))
          .thenAnswer((_) async => Right(null));
      when(() => mockGetAllLocationUseCase.call()).thenAnswer(
        (_) async => Right([LocationEntity(id: '1', name: 'Test Location')]),
      );
      return locationBloc;
    },
    act: (bloc) => bloc.add(DeleteLocation('1')),
    expect: () => [
      LocationState(
          isLoading: true,
          locations: [LocationEntity(id: '1', name: 'Test Location')]),
      LocationState(
          isLoading: false,
          locations: [LocationEntity(id: '1', name: 'Test Location')]),
    ],
  );

  // Test 4: Handle empty list response
  blocTest<LocationBloc, LocationState>(
    'emits [loading, success] when no locations are returned',
    build: () {
      when(() => mockGetAllLocationUseCase.call()).thenAnswer(
        (_) async => Right([]),
      );
      return locationBloc;
    },
    act: (bloc) => bloc.add(LoadLocations()),
    expect: () => [
      LocationState(isLoading: true, locations: []),
      LocationState(isLoading: false, locations: []),
    ],
  );

  // Test 5: Test error response when loading locations
  blocTest<LocationBloc, LocationState>(
    'emits [loading, failure] when loading locations fails',
    build: () {
      when(() => mockGetAllLocationUseCase.call()).thenAnswer(
        (_) async => Left(NetworkFailure(
            message: 'Error loading locations')), // Concrete failure class used
      );
      return locationBloc;
    },
    act: (bloc) => bloc.add(LoadLocations()),
    expect: () => [
      LocationState(isLoading: true, locations: []),
      LocationState(isLoading: false, locations: []),
    ],
  );

  // Test 6: Test error response when adding a location
  blocTest<LocationBloc, LocationState>(
    'emits [loading, failure] when adding a location fails',
    build: () {
      when(() => mockAddLocationUseCase.call(any())).thenAnswer((_) async =>
          Left(NetworkFailure(
              message: 'Error adding locations'))); // Concrete failure class
      return locationBloc;
    },
    act: (bloc) => bloc.add(AddLocation('New Location')),
    expect: () => [
      LocationState(isLoading: true, locations: []),
      LocationState(isLoading: false, locations: []),
    ],
  );

  // Test 7: Test error response when deleting a location
  blocTest<LocationBloc, LocationState>(
    'emits [loading, failure] when deleting a location fails',
    build: () {
      when(() => mockDeleteLocationUseCase.call(any())).thenAnswer((_) async =>
          Left(NetworkFailure(
              message: 'Error deleting location'))); // Concrete failure class
      return locationBloc;
    },
    act: (bloc) => bloc.add(DeleteLocation('1')),
    expect: () => [
      LocationState(isLoading: true, locations: []),
      LocationState(isLoading: false, locations: []),
    ],
  );

  // Test 8: Simulate multiple locations being loaded
  blocTest<LocationBloc, LocationState>(
    'emits [loading, success] when multiple locations are loaded successfully',
    build: () {
      when(() => mockGetAllLocationUseCase.call()).thenAnswer(
        (_) async => Right([
          LocationEntity(id: '1', name: 'Test Location 1'),
          LocationEntity(id: '2', name: 'Test Location 2'),
        ]),
      );
      return locationBloc;
    },
    act: (bloc) => bloc.add(LoadLocations()),
    expect: () => [
      LocationState(isLoading: true, locations: []),
      LocationState(isLoading: false, locations: [
        LocationEntity(id: '1', name: 'Test Location 1'),
        LocationEntity(id: '2', name: 'Test Location 2'),
      ]),
    ],
  );

  // Test 9: Test adding location with existing name
  blocTest<LocationBloc, LocationState>(
    'emits [loading, failure] when adding a location with an existing name',
    build: () {
      when(() => mockAddLocationUseCase.call(any())).thenAnswer((_) async =>
          Left(NetworkFailure(
              message: 'Location already exists'))); // Concrete failure class
      return locationBloc;
    },
    act: (bloc) => bloc.add(AddLocation('Test Location 1')),
    expect: () => [
      LocationState(isLoading: true, locations: []),
      LocationState(isLoading: false, locations: []),
    ],
  );

  // Test 10: Test loading state without triggering any event
  blocTest<LocationBloc, LocationState>(
    'emits [loading] without any event trigger',
    build: () {
      return locationBloc;
    },
    act: (bloc) {},
    expect: () => [
      LocationState(isLoading: true, locations: []),
    ],
  );
}
