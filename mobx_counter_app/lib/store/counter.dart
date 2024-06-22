import 'package:mobx/mobx.dart';

part 'counter.g.dart';

class Counter = _Counter with _$Counter;

abstract class _Counter with Store {
  @readonly
  int _count = 0;

  ObservableList<int> a = ObservableList.of([0]);

  @action
  void increment() => _count++;

  @computed
  int get twice => _count * 2;

  @action
  void decrement() => _count--;

  // @action
  void reset() => _count = 0;
}
