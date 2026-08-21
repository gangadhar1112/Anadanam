import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnadanamFormData {
  final String name;
  final String type;
  final String foodDetails;
  final String description;
  final String startTime;
  final String endTime;
  final List<String> recurringDays;
  final String imageUrl;
  final double latitude;
  final double longitude;

  AnadanamFormData({
    this.name = '',
    this.type = 'Temple Anadanam',
    this.foodDetails = '',
    this.description = '',
    this.startTime = '12:00 PM',
    this.endTime = '02:00 PM',
    this.recurringDays = const [],
    this.imageUrl = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  AnadanamFormData copyWith({
    String? name,
    String? type,
    String? foodDetails,
    String? description,
    String? startTime,
    String? endTime,
    List<String>? recurringDays,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) {
    return AnadanamFormData(
      name: name ?? this.name,
      type: type ?? this.type,
      foodDetails: foodDetails ?? this.foodDetails,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      recurringDays: recurringDays ?? this.recurringDays,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'name': name,
      'type': type,
      'foodDetails': foodDetails,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'recurringDays': recurringDays,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
      'isVerified': false,
      'likes': 0,
      'comments': 0,
    };
  }
}

class AnadanamFormNotifier extends StateNotifier<AnadanamFormData> {
  AnadanamFormNotifier() : super(AnadanamFormData());

  void updateName(String name) => state = state.copyWith(name: name);
  void updateFoodDetails(String details) => state = state.copyWith(foodDetails: details);
  void updateDescription(String desc) => state = state.copyWith(description: desc);
  void updateTime(String start, String end) => state = state.copyWith(startTime: start, endTime: end);
  void updateDays(List<String> days) => state = state.copyWith(recurringDays: days);
  void updateLocation(double lat, double lng) => state = state.copyWith(latitude: lat, longitude: lng);
}

final anadanamFormProvider = StateNotifierProvider<AnadanamFormNotifier, AnadanamFormData>((ref) {
  return AnadanamFormNotifier();
});
