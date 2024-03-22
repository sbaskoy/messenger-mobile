extension ListExtension<T> on List<T> {
  void changeFirstItem(T item) {
    if (isEmpty) {
      add(item);
    } else {
      this[0] = item;
    }
  }

  Map<K, List<T>> groupBy<K>(K Function(T item) keyFunction) => fold(<K, List<T>>{},
      (Map<K, List<T>> map, T element) => map..putIfAbsent(keyFunction(element), () => <T>[]).add(element));
}
