typedef AFunction = int Function(String s);

typedef MyInt = int;

AFunction aFunction = (String s) => 1;

typedef MyTypedefClass = TypedefClass;

const MyTypedefClass myTypedefClassConst = MyTypedefClass(1);

class TypedefClass {
  const TypedefClass(this.index);
  final int index;
}
