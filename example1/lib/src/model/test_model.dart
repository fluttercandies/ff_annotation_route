import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';

class TestMode {
  const TestMode({this.id, this.isTest});
  factory TestMode.test() => const TestMode(id: 1, isTest: true);
  factory TestMode.fromJson(Map<dynamic, dynamic> json) =>
      TestMode(id: asT<int>(json['id']), isTest: asT<bool>(json['isTest']));

  final int id;
  final bool isTest;
  Map<String, dynamic> get toJson => <String, dynamic>{
        'id': id,
        'isTest': isTest,
      };

  @override
  String toString() {
    return 'id:$id,isTest:$isTest';
  }
}
