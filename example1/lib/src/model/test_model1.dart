import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';

class TestMode1 {
  const TestMode1({this.id, this.isTest});
  factory TestMode1.deafult() => const TestMode1(id: 1, isTest: true);
  factory TestMode1.fromJson(Map<dynamic, dynamic> json) =>
      TestMode1(id: asT<int>(json['id']), isTest: asT<bool>(json['isTest']));

  final int? id;
  final bool? isTest;
  Map<String, dynamic> get toJson => <String, dynamic>{
        'id': id,
        'isTest': isTest,
      };
  @override
  String toString() {
    return 'id:$id,isTest:$isTest';
  }
}

class TestMode3 {}
