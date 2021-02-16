class TestMode {
  const TestMode({this.id, this.isTest});
  factory TestMode.test() => const TestMode(id: 1, isTest: true);
  factory TestMode.fromJson(Map<String, dynamic> json) =>
      TestMode(id: json['id'] as int, isTest: json['isTest'] as bool);

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
