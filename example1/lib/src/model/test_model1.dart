class TestMode1 {
  const TestMode1({this.id, this.isTest});
  factory TestMode1.deafult() => const TestMode1(id: 1, isTest: true);
  factory TestMode1.fromJson(Map<String, dynamic> json) =>
      TestMode1(id: json['id'] as int, isTest: json['isTest'] as bool);

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
