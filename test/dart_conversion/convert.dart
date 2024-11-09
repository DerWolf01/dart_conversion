import 'package:dart_conversion/convertable.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_conversion/my_logger.dart';
import 'package:test/test.dart';

import 'convert.reflectable.dart';

abstract class TestUserBase {
  const TestUserBase({required this.mappedFriends});
  final Map<String, TestUser> mappedFriends;
}

@convertable
class TestUser extends TestUserBase {
  final String name;

  final int id;
  final String lastName;
  final List<TestUser> friends;

  const TestUser(
      {required this.id,
      required this.lastName,
      required this.name,
      required this.friends,
      required super.mappedFriends});
}

void main() {
  initializeReflectable();
  group("DartConversion", () {
    MyLogger.init(enabled: true);
    test(
      "TestUser --> Map<String, dynamic>",
      () {
        final testUser = TestUser(
            id: 0,
            lastName: "lastname",
            name: "name",
            friends: [],
            mappedFriends: {});

        final testUser2 = TestUser(
            id: 0,
            lastName: "lastname",
            name: "name",
            friends: [testUser],
            mappedFriends: {"sad": testUser});

        final map = dartConversion.convert(testUser2, to: Map<String, dynamic>);

        expect(map, {
          'name': 'name',
          'id': 0,
          'lastName': 'lastname',
          'friends': [
            {
              'name': 'name',
              'id': 0,
              'lastName': 'lastname',
              'friends': [],
              'mappedFriends': {}
            }
          ],
          'mappedFriends': {
            'sad': {
              'name': 'name',
              'id': 0,
              'lastName': 'lastname',
              'friends': [],
              'mappedFriends': {}
            }
          }
        });
      },
    );
  });
}
