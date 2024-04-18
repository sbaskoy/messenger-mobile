import 'package:flutter/material.dart';
import 'package:multi_image_layout/multi_image_layout.dart';
import 'package:planner_messenger/widgets/buttons/custom_text_button.dart';

import 'package:scrollable_positioned_list_extended/scrollable_positioned_list_extended.dart';

import 'scrollable_list_view.dart';

class ScrollableListViewTest extends StatefulWidget {
  const ScrollableListViewTest({super.key});

  @override
  State<ScrollableListViewTest> createState() => _ScrollableListViewTestState();
}

class _ScrollableListViewTestState extends State<ScrollableListViewTest> {
  List<String> _items = [];
  final ItemScrollController itemScrollController = ItemScrollController();
  @override
  void initState() {
    super.initState();
    _items = List.generate(20, (index) => "item $index");
  }

  void _addBottom() {
    var currentIndex = _items.length;
    var newItems = List.generate(20, (index) => " new bottom Items  ${_items.length + index}");
    _items.insertAll(0, newItems);

    setState(() {});
    _scrollToIndex(_items.length - currentIndex);
  }

  void _addTop() {
    var newItems = List.generate(20, (index) => " new bottom Items  ${_items.length + index}");
    _items.addAll(newItems);
    setState(() {});
  }

  void _scrollToIndex(int index) {
    itemScrollController.scrollTo(index: index, duration: Durations.medium1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                CustomTextButton(
                  text: "add bottom",
                  onTap: _addBottom,
                ),
                CustomTextButton(
                  text: "add top",
                  onTap: _addTop,
                ),
              ],
            ),
            Flexible(
              child: ScrollableListView(
                itemScrollController: itemScrollController,
                items: _items,
                itemBuilder: (p0, index) {
                  return SizedBox(
                    height: 60,
                    child: Card(
                      child: Center(child: Text(_items[index])),
                    ),
                  );
                },
                itemPositionsListener: ItemPositionsListener.create(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
