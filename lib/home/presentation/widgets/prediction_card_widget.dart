import 'package:flutter/material.dart';
import '../../domain/home_prediction_model.dart';
import '../../../core/constants/k_sizes.dart';

class PredictionCardWidget extends StatelessWidget {
  final HomePredictionModel prediction;
  const PredictionCardWidget({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: KSizes.margin2x),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusDefault),
      ),
      child: Padding(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sun Sign: ${prediction.sunSign}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              prediction.prediction,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: KSizes.margin4x),
            Row(
              children: [
                Text('Lucky Number: ${prediction.luckyNumber}'),
                SizedBox(width: KSizes.margin2x),
                Text('Lucky Color: ${prediction.luckyColor}'),
              ],
            ),
            SizedBox(height: KSizes.margin2x),
            Text('Mood: ${prediction.mood}'),
          ],
        ),
      ),
    );
  }
}
