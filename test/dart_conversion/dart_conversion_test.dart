import 'package:dart_conversion/convertable.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_conversion/dart_conversion.old.dart';
import 'package:dart_conversion/my_logger.dart';
import 'package:test/test.dart';

import 'dart_conversion_test.reflectable.dart';

abstract class TestUserBase {
  const TestUserBase(
      {@CollectionOf(valueType: TestUser, keyType: String)
      required this.mappedFriends});

  @CollectionOf(valueType: TestUser, keyType: String)
  final Map<String, TestUser> mappedFriends;
}

@convertable
class TestUser extends TestUserBase {
  final String name;

  final int id;
  final String lastName;
  @CollectionOf(valueType: TestUser)
  final List<TestUser> friends;

  const TestUser(
      {required this.id,
      required this.lastName,
      required this.name,
      @CollectionOf(valueType: TestUser) required this.friends,
      required super.mappedFriends});
}

void main() {
  initializeReflectable();
  group("DartConversion", () {
    MyLogger.init(enabled: true);
    test(
      "objectToMap",
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

    test("mapToObject<dynamic>(type: TestUser)", () {
      final testUser = TestUser(
          id: 0,
          lastName: "lastname",
          name: "name",
          friends: [],
          mappedFriends: {});

      final testUserMap = dartConversion.objectToMap(testUser);

      final reconstructedTestUser =
          dartConversion.mapToObject(testUserMap, type: TestUser);

      expect(reconstructedTestUser, isA<TestUser>());
    });
    test("mapToObject<T>(type: dynamic)", () {
      final testUser = TestUser(
          id: 0,
          lastName: "lastname",
          name: "name",
          friends: [],
          mappedFriends: {});

      final testUserMap = dartConversion.objectToMap(testUser);

      final reconstructedTestUser =
          dartConversion.mapToObject<TestUser>(testUserMap);

      expect(reconstructedTestUser, isA<TestUser>());
    });
  });
}
