import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String? id;
  final String name;

  const LocationEntity({
    this.id,
    required this.name,
  });

  // Add this factory constructor
  factory LocationEntity.fromJson(Map<String, dynamic> json) {
    return LocationEntity(
      id: json['_id'],
      name: json['name'],
    );
  }

  @override
  List<Object?> get props => [id, name];
}