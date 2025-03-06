import 'package:circle_share/app/constants/hive_table_constant.dart';
import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';

part 'location_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.locationTableId)
class LocationHiveModel extends Equatable {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String name;

  LocationHiveModel({
    String? id,
    required this.name,
  }) : id = id ?? const Uuid().v4();

  const LocationHiveModel.initial()
      : id = '',
        name = '';

  factory LocationHiveModel.fromEntity(LocationEntity entity) {
    return LocationHiveModel(
      id: entity.id,
      name: entity.name,
    );
  }

  LocationEntity toEntity() {
    return LocationEntity(
      id: id,
      name: name,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
