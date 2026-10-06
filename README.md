# AquaTrack Staff Mobile Application

The native Android and iOS mobile application for **AquaTrack** field staff and meter readers, built with **Flutter 3.x** and **Dart**.

Designed for field operations in the Municipality of Sinacaban, allowing technicians to inspect meters, scan physical QR codes, review household water accounts, and record consumption.

---

## 📱 App Features & Screens

1. **Sign-In Screen (`SignInScreen`)**:
   - Field technician authentication with staff credentials.
   - Quick pre-fill toggle for instant field testing.
   - Direct connection to the backend REST API (`POST /api/v1/auth/login`).

2. **Terms & Operating Guidelines (`TermsScreen`)**:
   - Municipal field staff data privacy policies and meter inspection compliance.

3. **QR Scanner (`QrScanScreen`)**:
   - Camera scanner interface for reading physical meter tokens.
   - Simulated QR token shortcut buttons for desktop / emulator testing (`MTR-TOKEN-0001`, `MTR-TOKEN-0002`).

4. **Manual Meter Lookup (`MeterLookupScreen`)**:
   - Quick search by stamped casing serial number (`MTR-SIN-0001`).
   - Offline fallback handling.

5. **Household Account & Meter Details (`AccountDetailsScreen`)**:
   - Displays registered consumer name, account reference, physical installation address, and barangay.
   - Current meter status and scannable token validation.
   - Field consumption logging input (m³).

---

## 🎨 Design System & Constraints

- **Strict 3-Color Palette:**
  - **Brand Blue (`Color(0xFF1E6FD9)`):** Primary buttons, header banners, active badges.
  - **White (`Color(0xFFFFFFFF)`):** Background surfaces and card layouts.
  - **Black (`Color(0xFF000000)`):** All typography, borders, and icon lines.
- **Typography:** Strict **10px** font size (`fontSize: 10.0`) applied across all text widgets, inputs, buttons, and app bars. Single typeface: **Inter**.

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK >= 3.x
- Dart SDK >= 3.x
- Android Studio / Xcode or VS Code with Flutter extension
- Android device, iOS simulator, or Chrome/Desktop for testing

### 2. Installation
```bash
# Navigate to the staff_app directory
cd staff_app

# Get Flutter packages
flutter pub get
```

### 3. Backend Configuration
Ensure the backend API is running (`php artisan serve --port=8000`).
The mobile app default base URL is configured in `lib/services/api_service.dart`:
- **Android Emulator:** `http://10.0.2.2:8000/api/v1`
- **Physical Device / Local Network:** `http://<YOUR_LOCAL_IP>:8000/api/v1`
- **Web / Desktop:** `http://127.0.0.1:8000/api/v1`

### 4. Running the Application
```bash
# Run on connected device or simulator
flutter run

# Run on Chrome for web preview
flutter run -d chrome
```

---

## 🧪 Testing & Analysis

```bash
# Run static analysis (0 warnings / 0 errors)
flutter analyze

# Run Flutter unit and widget tests (7/7 tests passing)
flutter test
```

---

## 🔑 Demo Field Staff Credentials

- **Email / Login:** `staff@siwass.gov`
- **Password:** `password123`
- **Assigned Area:** Sinacaban Municipal Coverage Zones
