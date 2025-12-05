import '../../domain/entities/tip_of_day.dart';

class TipOfDayModel extends TipOfDay {
  TipOfDayModel({required super.text});

  factory TipOfDayModel.fromMap(Map<String, dynamic> data) {
    return TipOfDayModel(text: data['text'] as String? ?? '');
  }
}

