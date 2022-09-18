class TestMode3 {
  const TestMode3({this.id, this.isTest});
  factory TestMode3.deafult() => const TestMode3(id: 1, isTest: true);
  final int? id;
  final bool? isTest;
  @override
  String toString() {
    return 'id:$id,isTest:$isTest';
  }
}
