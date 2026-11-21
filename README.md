# CosmoKundli App

Flutter app for CosmoKundli - Vedic Astrology Software.

## Setup

```bash
# Generate platform files
flutter create .

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Architecture

- **State Management**: GetX
- **Networking**: Dio
- **Design**: Glassmorphism dark cosmic theme
- **Fonts**: Plus Jakarta Sans, Inter, Manrope, Lexend Giga

## Project Structure

```
lib/
├── controllers/     # GetX controllers
├── models/          # API response models
├── network/         # Dio HTTP services
├── repos/           # Repository layer
├── screens/         # UI screens
│   ├── auth/        # Login, signup, splash
│   ├── client_detail/ # Client management
│   ├── home/        # Home + tabs
│   ├── kundali/     # Birth chart screens
│   ├── mb_algo/     # Algorithm screens
│   ├── others/      # Melapak matching
│   └── profile/     # User profile
├── services/        # Utilities
├── theme/           # App theme + design system
├── values/          # Constants, routes, URLs
└── widgets/         # Reusable UI components
```
