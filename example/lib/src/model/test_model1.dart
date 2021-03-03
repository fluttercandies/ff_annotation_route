class TestMode1 {
  const TestMode1({this.id, this.isTest});
  factory TestMode1.deafult() => const TestMode1(id: 1, isTest: true);
  final int? id;
  final bool? isTest;
  @override
  String toString() {
    return 'id:$id,isTest:$isTest';
  }
}

class TestMode3
{

}