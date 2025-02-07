import 'package:circle_share/features/auth/domain/entity/auth_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_api_model.g.dart';

@JsonSerializable()
class AuthApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String fname;
  final String lname;
  final String? image;
  final String phone;
  final String username;
  final String? password;

  const AuthApiModel({
    this.id,
    required this.fname,
    required this.lname,
    required this.image,
    required this.phone,
    required this.username,
    required this.password,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  AuthEntity toEntity() {
    return AuthEntity(
      userId: id,
      fName: fname,
      lName: lname,
      image: image,
      phone: phone,
      username: username,
      password: password ?? '',
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.userId,
      fname: entity.fName,
      lname: entity.lName,
      image: entity.image,
      phone: entity.phone,
      username: entity.username,
      password: entity.password,
    );
  }

  @override
  List<Object?> get props =>
      [id, fname, lname, image, phone, username, password];
}
