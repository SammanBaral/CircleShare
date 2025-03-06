import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location_api_model.g.dart';

@JsonSerializable()
class LocationApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String name;

  const LocationApiModel({
    this.id,
    required this.name,
  });

  factory LocationApiModel.fromJson(Map<String, dynamic> json) =>
      _$LocationApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationApiModelToJson(this);

  LocationEntity toEntity() {
    return LocationEntity(
      id: id,
      name: name,
    );
  }

  factory LocationApiModel.fromEntity(LocationEntity entity) {
    return LocationApiModel(
      id: entity.id,
      name: entity.name,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
