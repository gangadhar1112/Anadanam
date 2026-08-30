import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AnadanamFormData {
  final String name;
  final String type;
  final String foodDetails;
  final String description;
  final String startTime;
  final String endTime;
  final List<String> recurringDays;
  final String imageUrl;
  final String? imagePath;
  final String address;
  final double latitude;
  final double longitude;
  final bool isRecurring;

  AnadanamFormData({
    this.name = '',
    this.type = 'Temple', // Changed from 'Temple Anadanam' to match chips
    this.foodDetails = '',
    this.description = '',
    this.startTime = '12:00 PM',
    this.endTime = '02:00 PM',
    this.recurringDays = const [],
    this.imageUrl = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
    this.imagePath,
    this.address = '',
    this.latitude = 12.9716, // Bengaluru Default
    this.longitude = 77.5946,
    this.isRecurring = false,
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
    String? imagePath,
    String? address,
    double? latitude,
    double? longitude,
    bool? isRecurring,
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
      imagePath: imagePath ?? this.imagePath,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  Map<String, dynamic> toMap(String userId) {
    // Calculate expiration time for the current day
    final now = DateTime.now();
    DateTime expireDateTime;
    
    try {
      // Try parsing common formats (12h and 24h)
      DateTime? parsedTime;
      final formats = [DateFormat.jm(), DateFormat('HH:mm'), DateFormat('H:mm')];
      
      for (var f in formats) {
        try {
          final t = f.parse(endTime);
          parsedTime = DateTime(now.year, now.month, now.day, t.hour, t.minute);
          break;
        } catch (_) {}
      }
      
      expireDateTime = parsedTime ?? now.add(const Duration(hours: 4));
      
      // If the time has already passed today, assume it's for the next session/tomorrow
      // This prevents items from being immediately hidden if uploaded after the end time.
      if (expireDateTime.isBefore(now)) {
        expireDateTime = expireDateTime.add(const Duration(days: 1));
      }
    } catch (e) {
      expireDateTime = now.add(const Duration(hours: 4));
    }

    return {
      'name': name,
      'type': type,
      'foodDetails': foodDetails,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'recurringDays': recurringDays,
      'imageUrl': imageUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isRecurring': isRecurring,
      'userId': userId,
      'isVerified': false,
      'likes': 0,
      'comments': 0,
      'expireAt': Timestamp.fromDate(expireDateTime), // Field for TTL and filtering
    };
  }
}

class AnadanamFormNotifier extends StateNotifier<AnadanamFormData> {
  AnadanamFormNotifier() : super(AnadanamFormData());

  void updateName(String name) => state = state.copyWith(name: name);
  void updateType(String type) => state = state.copyWith(type: type);
  void updateFoodDetails(String details) => state = state.copyWith(foodDetails: details);
  void updateDescription(String desc) => state = state.copyWith(description: desc);
  void updateTime(String start, String end) => state = state.copyWith(startTime: start, endTime: end);
  void updateDays(List<String> days) => state = state.copyWith(recurringDays: days);
  void updateLocation(double lat, double lng) => state = state.copyWith(latitude: lat, longitude: lng);
  void updateAddress(String address) => state = state.copyWith(address: address);
  void updateImagePath(String? path) => state = state.copyWith(imagePath: path);
  void updateIsRecurring(bool isRec) => state = state.copyWith(isRecurring: isRec);
  void updateImageUrl(String url) => state = state.copyWith(imageUrl: url);

  void reset() {
    state = AnadanamFormData();
  }
}

final anadanamFormProvider = StateNotifierProvider<AnadanamFormNotifier, AnadanamFormData>((ref) {
  return AnadanamFormNotifier();
});
