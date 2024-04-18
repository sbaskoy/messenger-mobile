import 'package:flutter/cupertino.dart';

import 'package:scrollable_positioned_list_extended/scrollable_positioned_list_extended.dart';

class ScrollableListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final bool reverse;
  const ScrollableListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.itemScrollController,
    required this.itemPositionsListener,
    this.reverse = true,
  });

  @override
  State<ScrollableListView<T>> createState() => _ScrollableListViewState<T>();
}

class _ScrollableListViewState<T> extends State<ScrollableListView<T>> {
  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemCount: widget.items.length,
      reverse: widget.reverse,
      physics: const ClampingScrollPhysics(),
      itemBuilder: widget.itemBuilder,
      itemScrollController: widget.itemScrollController,
      itemPositionsListener: widget.itemPositionsListener,
    );
  }
}
