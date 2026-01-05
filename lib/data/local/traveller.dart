import 'package:hive/hive.dart';

part 'traveller.g.dart';

@HiveType(typeId: 0)
class Traveller extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  String? age;

  @HiveField(2)
  String? email;

  @HiveField(3)
  late String mobile;

  @HiveField(4)
  String? travelType;

  @HiveField(5)
  List<String>? interests;

  @HiveField(6, defaultValue: false)
  bool isPreferenceSet = false;

  @HiveField(7)
  String? profileImagePath;

  @override
  String toString() {
    return 'Traveller(name: $name, age: $age, email: $email, mobile: $mobile, travelType: $travelType, interests: $interests, isPreferenceSet: $isPreferenceSet, profileImagePath: $profileImagePath)';
  }
}
