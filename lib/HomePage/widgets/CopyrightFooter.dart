import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class CopyrightFooter extends StatelessWidget {
  const CopyrightFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: customText(
        "© 2025 Udghosh Sports Fest | IIT Kanpur. All rights reserved.",
        12,
        FontWeight.normal,
        Colors.grey.shade100,
        1,
      ),
    );
  }
}
