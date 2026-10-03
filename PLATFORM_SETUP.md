# Platform setup note

The Dart application code is complete.

For the most reliable platform integration with your installed Flutter SDK,
run these commands once from the project root if the generated platform
folders need refreshing:

```bash
flutter create --platforms=android,ios,web .
flutter pub get
```

After that, restore the assignment-specific changes:
- Android Maps API key in `android/app/src/main/AndroidManifest.xml`
- Android location permissions in the same manifest
- iOS `GMSServices.provideAPIKey(...)` in `ios/Runner/AppDelegate.swift`
- iOS location usage descriptions in `ios/Runner/Info.plist`

The Dart files and README in this ZIP are the source of truth for the assignment.
