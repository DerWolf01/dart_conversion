import '../../lib/src/class_mirror_extension.dart';
import '../../lib/src/collection_of.dart';
import '../../lib/src/convertable.dart';
import '../../lib/src/my_logger.dart';
import 'package:reflectable/mirrors.dart';
import 'package:test/test.dart';

import 'class_mirror_extension_test.reflectable.dart';

@convertable
class TestUserBase {
  const TestUserBase(this.ids);
  final List<int> ids;
}

@convertable
class TestUser extends TestUserBase {
  const TestUser(
      this.names, super.ids, this.name, this.friends, this.friendsList);
  final List<String> names;
  final Map<String, int> friends;
  final String name;
  @CollectionOf(valueType: TestUser)
  final List<dynamic> friendsList;
}

void main() {
  initializeReflectable();
  MyLogger.init(enabled: true);
  group("ClassMirrorExtension", () {
    test("variables", () {
      final variables =
          (convertable.reflectType(TestUser) as ClassMirror).variables;
      expect(variables, containsPair("names", isA<VariableMirror>()));
      expect(variables, containsPair("ids", isA<VariableMirror>()));
      expect(variables, containsPair("name", isA<VariableMirror>()));
      expect(variables, containsPair("friends", isA<VariableMirror>()));
    });

    test(
      "findFields",
      () {
        final fields = (convertable.reflectType(TestUser) as ClassMirror)
            .findFields(["names", "ids"]);
        expect(fields, containsPair("names", isA<VariableMirror>()));
        expect(fields, containsPair("ids", isA<VariableMirror>()));
        expect(fields, isNot(containsPair("name", isA<VariableMirror>())));
        expect(fields, isNot(containsPair("friends", isA<VariableMirror>())));
      },
    );

    test(
      "findField",
      () {
        final field = (convertable.reflectType(TestUser) as ClassMirror)
            .findField("names");
        expect(field, isA<VariableMirror>());
        expect(field?.simpleName, equals("names"));
      },
    );

    test(
      "findTypeArguments",
      () {
        final namesTypeArguments =
            (convertable.reflectType(TestUser) as ClassMirror)
                .findTypeArguments("names");
        expect(namesTypeArguments, isA<List<TypeMirror>>());
        expect(namesTypeArguments?.firstOrNull, isA<TypeMirror>());
        expect(namesTypeArguments?.firstOrNull?.reflectedType, String);

        final idsTypeArguments =
            (convertable.reflectType(TestUser) as ClassMirror)
                .findTypeArguments("ids");
        expect(idsTypeArguments, isA<List<TypeMirror>>());
        expect(idsTypeArguments?.firstOrNull, isA<TypeMirror>());
        expect(idsTypeArguments?.firstOrNull?.reflectedType, int);
      },
    );

    test(
      "findTypeArgument",
      () {
        final friendsKeyTypeArgument =
            (convertable.reflectType(TestUser) as ClassMirror)
                .findTypeArgument("friends", 0);
        final friendsValueTypeArgument =
            (convertable.reflectType(TestUser) as ClassMirror)
                .findTypeArgument("friends", 1);

        expect(friendsKeyTypeArgument, isA<TypeMirror>());
        expect(friendsKeyTypeArgument?.reflectedType, String);

        expect(friendsValueTypeArgument, isA<TypeMirror>());
        expect(friendsValueTypeArgument?.reflectedType, int);
      },
    );

    test("getCollectionOf", () {
      final classMirror = convertable.reflectType(TestUser) as ClassMirror;
      myLogger.w(classMirror.declarations.values
              .where(
                (element) => element.simpleName == "friendsList",
              )
              .firstOrNull
              ?.runtimeType
              .toString() ??
          "");
      expect(classMirror.getCollectionOfUsingName("friendsList"),
          isA<CollectionOf>());
    });
  });
}
