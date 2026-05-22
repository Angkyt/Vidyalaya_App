# Vidyalaya — Student Planner (Flutter)

A student-planner mobile app built in Flutter. Plan classes, track assignments,
view a unified calendar of classes + due dates, and look after your wellbeing.

## What's new in v3

1. Logo polished to match the Figma design.
2. Successful sign up now shows a **"Sign Up Completed"** screen and routes you to
   Sign In (auto-fills the email) — you log in deliberately rather than being
   auto-logged-in.
3. **Phone number is now mandatory** on registration.
4. Bottom navigation label changed from **Home → Dashboard**.
5. Notification bell added on the **Course** and **Calendar** screens.
6. **Student ID is locked** in Edit Profile (cannot be edited).
7. Dashboard stat cards (**Courses / Pending / Urgent**) scroll to their section
   when tapped.
8. **Urgent** section now automatically includes overdue assignments — anything
   past its due date appears there with an `OVERDUE` badge.
9. Placeholder "eg" hints removed from input fields.
10. Adding a course now uses a proper **Day-of-week picker + Start/End time
    pickers**. Classes appear automatically in the **Calendar** on every
    matching weekday.
11. Course search now matches **name, course code, and lecturer name**.
12. Assignment Details has a **Save Changes** button (in addition to Mark
    Complete / Edit / Delete) for when you tweak progress.
13. Removed the duplicate **Change Password** entry from Settings — it's still
    available via **Settings → Profile → Change Password**.
14. Profile picture: round avatar with a camera badge, tap to upload from
    Library or Camera. Stored locally and persists across sessions.
15. **Full Name** replaced with separate **First Name** / **Last Name** in both
    Sign Up and Edit Profile.
16. Password rules tightened — must include:
    * 8+ characters
    * at least one uppercase letter
    * at least one number
    * at least one special character
    A live checklist shows which rules are met as you type.

## Running the app

Tested on iOS Simulator (iPhone 16e) using macOS + Xcode 15.

```bash
# 1. From the unzipped folder
flutter create .              # regenerates iOS/Android folders
flutter pub get

# 2. iOS Simulator
open -a Simulator
flutter run

# Android emulator (alternative)
flutter run -d emulator-5554
```

### iOS — Photo Library / Camera permissions (required for v3 photo upload)

After `flutter create .`, open `ios/Runner/Info.plist` and add these entries
inside the top-level `<dict>`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Vidyalaya needs access to your photo library so you can set a profile picture.</string>
<key>NSCameraUsageDescription</key>
<string>Vidyalaya needs camera access so you can take a profile picture.</string>
```

If these are missing the app will crash the first time you tap "Change photo".

### Android — gallery permission

Android 13+ uses scoped photo picker so no manifest changes are required for
`image_picker` 1.x in most cases. If your minimum SDK is older than 19, raise
it in `android/app/build.gradle` (`minSdkVersion 21`).

## Tech

* Flutter 3 (Material 3)
* Provider for state management
* SharedPreferences for offline persistence
* TableCalendar for the calendar view
* image_picker + path_provider for profile photos
* SHA-256 + per-user salt for password storage

## Migration notes

* v3 storage keys are bumped (`courses_<userId>_v2`, `assignments_<userId>_v2`)
  to avoid clashing with v2 free-text schedules. Existing v2 users will see a
  fresh seeded course set on first launch.
* User records are migrated in-place: a stored `fullName` is split into
  `firstName` + `lastName` automatically on load. Existing accounts still work.
