# Implement Nearby Anadanam Notifications (3km Radius)

This plan outlines how to notify users within a 3km radius when a new Anadanam is shared.

## Proposed Changes

### Core Services

#### [MODIFY] [firestore_service.dart](file:///D:/Anadanam/lib/core/services/firestore_service.dart)
- Add `updateUserLocation(String uid, double lat, double lng)` to store user's current coordinates.
- Add `notifyNearbyUsers(Map<String, dynamic> postData, String currentUserId)` to:
    1. Fetch all users from Firestore.
    2. Filter users within 3km of the post location using `Geolocator`.
    3. Add a notification to each nearby user's `notifications` sub-collection.
- Update `addAnadanam` to trigger `notifyNearbyUsers` after a successful upload.

### Dashboard

#### [MODIFY] [main_dashboard.dart](file:///D:/Anadanam/lib/features/dashboard/main_dashboard.dart)
- Update the location fetch logic to call `updateUserLocation` when the app starts or location changes.

## Verification Plan

### Manual Verification
1. **Setup**: Have two users (User A and User B).
2. **Location Update**: Log in as User B and ensure their location is updated in Firestore (simulated by the app fetching their GPS).
3. **Sharing**: Log in as User A and share a new Anadanam within 3km of User B's location.
4. **Verification**: Check if User B receives an in-app notification in their notifications screen.
5. **Distance Check**: Share another Anadanam from User A that is > 3km away from User B, and verify User B does NOT get a notification.
