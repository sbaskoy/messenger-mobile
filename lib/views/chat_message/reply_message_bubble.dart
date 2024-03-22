import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:planner_messenger/models/message/message.dart';

class ReplyMessageBubble extends StatelessWidget {
  final Message data;
  final Widget? trailing;
  final bool? hideStartBorder;
  const ReplyMessageBubble({super.key, required this.data, this.trailing, this.hideStartBorder});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        height: 50,
        child: Row(
          children: [
            if (hideStartBorder != true)
              Container(
                width: 10,
                height: 50,
                decoration: BoxDecoration(
                  color: context.theme.primaryColor,
                ),
              ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.user?.fullName ?? "",
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: context.theme.primaryColor,
                      ),
                    ),
                    Text(
                      data.message ?? "",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ));
  }
}
