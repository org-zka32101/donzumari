import 'package:flutter_test/flutter_test.dart';
import 'package:donzumari/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel from JSON', () {
      final json = {
        'uid': 'user123',
        'displayName': 'TestPlayer',
        'doorwayId': 'doorway456',
        'streak': 5,
        'ownedSkins': ['skin1', 'skin2'],
        'createdAt': DateTime.now().toIso8601String(),
      };

      final user = UserModel.fromJson(json);

      expect(user.uid, 'user123');
      expect(user.displayName, 'TestPlayer');
      expect(user.doorwayId, 'doorway456');
      expect(user.streak, 5);
      expect(user.ownedSkins.length, 2);
    });

    test('should convert UserModel to JSON', () {
      final now = DateTime.now();
      final user = UserModel(
        uid: 'user123',
        displayName: 'TestPlayer',
        doorwayId: 'doorway456',
        streak: 5,
        ownedSkins: ['skin1'],
        createdAt: now,
      );

      final json = user.toJson();

      expect(json['uid'], 'user123');
      expect(json['displayName'], 'TestPlayer');
      expect(json['doorwayId'], 'doorway456');
      expect(json['streak'], 5);
    });

    test('should create default UserModel', () {
      final user = UserModel(
        uid: 'user123',
        displayName: 'TestPlayer',
        doorwayId: 'doorway456',
        createdAt: DateTime.now(),
      );

      expect(user.streak, 0);
      expect(user.ownedSkins, []);
    });
  });
}
