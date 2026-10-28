import 'package:flutter/material.dart';
import '../../../trips/presentation/screens/plan_trip_screen.dart';

class CreateTab extends StatelessWidget {
  final VoidCallback? onTripCreated;

  const CreateTab({super.key, this.onTripCreated});

  @override
  Widget build(BuildContext context) {
    return PlanTripScreen(
      onCompleted: onTripCreated,
    );
  }
}
