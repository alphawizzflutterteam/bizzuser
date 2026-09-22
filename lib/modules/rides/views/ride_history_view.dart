import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../core/widgets/pill_header.dart';
import 'rides_view.dart';

class RideHistoryView extends StatelessWidget {
  const RideHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CreamWashScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: PillHeader(title: AppStrings.rideHistory),
            ),
            SizedBox(height: 16),
            Expanded(child: RidesView(embedded: true)),
          ],
        ),
      ),
    );
  }
}
