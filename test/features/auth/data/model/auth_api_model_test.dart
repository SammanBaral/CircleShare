import 'package:flutter_test/flutter_test.dart';
import 'package:circle_share/features/auth/data/model/auth_api_model.dart';
import 'package:circle_share/features/auth/domain/entity/auth_entity.dart';

void main() {
  group('AuthApiModel Tests', () {
    final json = {
      '_id': '123',
      'fname': 'John',
      'lname': 'Doe',
      'image': 'profile.jpg',
      'phone': '1234567890',
      'username': 'johndoe',
      'password': 'password123',
    };

    test('should convert from JSON correctly', () {
      final model = AuthApiModel.fromJson(json);

      expect(model.id, '123');
      expect(model.fname, 'John');
      expect(model.lname, 'Doe');
      expect(model.image, 'profile.jpg');
      expect(model.phone, '1234567890');
      expect(model.username, 'johndoe');
      expect(model.password, 'password123');
    });

    test('should convert to JSON correctly', () {
      final model = AuthApiModel.fromJson(json);
      final convertedJson = model.toJson();

      expect(convertedJson['_id'], '123');
      expect(convertedJson['fname'], 'John');
      expect(convertedJson['lname'], 'Doe');
      expect(convertedJson['image'], 'profile.jpg');
      expect(convertedJson['phone'], '1234567890');
      expect(convertedJson['username'], 'johndoe');
      expect(convertedJson['password'], 'password123');
    });

    test('should convert between Entity and Model correctly', () {
      const entity = AuthEntity(
        userId: '123',
        fName: 'John',
        lName: 'Doe',
        image: 'profile.jpg',
        phone: '1234567890',
        username: 'johndoe',
        password: 'password123',
      );

      final model = AuthApiModel.fromEntity(entity);
      final convertedEntity = model.toEntity();

      expect(convertedEntity, equals(entity));
    });
  });
}
