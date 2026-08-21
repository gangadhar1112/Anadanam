# Walkthrough - AnnaDaan Mobile App UI

The complete UI for **AnnaDaan** has been implemented, providing a modern, warm, and community-focused experience for free food discovery and sharing.

## Key Features Implemented

### 1. Design System & Theming
- **Colors**: Saffron (#FF9933) and Natural Green (#2E7D32) palette.
- **Typography**: Poppins font family for a friendly and modern feel.
- **Components**: Material 3 cards, custom badges, and high-impact action buttons.

### 2. User Journey
- **Onboarding & Auth**: Splash screen, multi-step onboarding, and OTP-based mobile authentication.
- **Discovery**: A polished dashboard with location-based filtering, serving status badges, and interactive food service cards.
- **Map Experience**: Integrated map view with custom markers for active, starting soon, and upcoming services.
- **Service Details**: Comprehensive detail page with food items, serving times, location preview, and navigation actions.

### 3. Contribution Flow
- **Sharing**: A multi-step flow for users to upload food services, including photo capture, location pinning, and recurring schedule setup.
- **Success Feedback**: Immediate positive reinforcement after community contribution.

### 4. Community & Moderation
- **Profiles**: User history, liked posts, and personalized settings.
- **Moderation**: Admin dashboard for reviewing and approving community submissions to ensure trust and reliability.

## File Structure Highlights

- [app_theme.dart](file:///Users/bgpc-gangadhar/AndroidStudioProjects/anadanaapp/lib/core/theme/app_theme.dart): Core Material 3 configuration.
- [annadaana_card.dart](file:///Users/bgpc-gangadhar/AndroidStudioProjects/anadanaapp/lib/core/widgets/annadaana_card.dart): The primary UI component for discovery.
- [main_dashboard.dart](file:///Users/bgpc-gangadhar/AndroidStudioProjects/anadanaapp/lib/features/dashboard/main_dashboard.dart): The heart of the application.
- [anadanam_details_screen.dart](file:///Users/bgpc-gangadhar/AndroidStudioProjects/anadanaapp/lib/features/anadanam/anadanam_details_screen.dart): Detailed service view.
- [create_anadanam_screen.dart](file:///Users/bgpc-gangadhar/AndroidStudioProjects/anadanaapp/lib/features/upload/create_anadanam_screen.dart): Contribution initiation.

## Verification
- Verified all navigation routes and UI components.
- Ensured responsiveness across standard mobile screen widths.
- Accessibility-focused typography and touch targets applied throughout.
