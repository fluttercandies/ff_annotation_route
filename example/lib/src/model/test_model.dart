class TestMode {
  const TestMode({this.id, this.isTest});
  factory TestMode.deafult() => const TestMode(id: 1, isTest: true);
  final int id;
  final bool isTest;

  @override
  String toString() {
    return 'id:$id,isTest:$isTest';
  }
}
