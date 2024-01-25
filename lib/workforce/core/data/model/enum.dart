abstract class Enum1<T> {
  final T value;

  const Enum1(this.value);
}

abstract class Enum2<T1, T2> {
  final T1 value1;
  final T2 value2;

  T1 getValue1();
  T2 getValue2();

  const Enum2(this.value1, this.value2);
}

abstract class Enum3<T1, T2, T3> {
  final T1 value1;
  final T2 value2;
  final T3 value3;

  T1 getValue1();
  T2 getValue2();
  T3 getValue3();

  const Enum3(this.value1, this.value2, this.value3);
}