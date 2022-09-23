import 'dart:ui';

typedef AFunction = int Function(String s);

typedef MyInt = int;

AFunction aFunction = (String s) => 1;

typedef MyTypedefClass = TypedefClass;

const MyTypedefClass myTypedefClassConst = MyTypedefClass(BoxWidthStyle.max);

class TypedefClass {
  const TypedefClass(this.style);
  final BoxWidthStyle style;
}

class TypedefClass1 {
  const TypedefClass1(this.test);
  final int test;
}
