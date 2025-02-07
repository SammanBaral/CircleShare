import 'package:circle_share/features/auth/domain/entity/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const auth1 = AuthEntity(
    userId: "1234567890",
    fName: "John",
    lName: "Doe",
    image: "https://example.com/johndoe.jpg",
    phone: "9876543210",
    username: "johndoe",
    password: "john1234",
  );

  const auth2 = AuthEntity(
    userId: "1234567890",
    fName: "John",
    lName: "Doe",
    image: "https://example.com/johndoe.jpg",
    phone: "9876543210",
    username: "johndoe",
    password: "john1234",
  );

  test('Test: Two AuthEntity objects with the same values should be equal', () {
    expect(auth1, auth2);
  });
}
