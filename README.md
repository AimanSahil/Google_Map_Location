# Google Maps & Location - Flutter Assignment

This project implements the assignment requirements:

- Google Map displayed when the app starts
- Zoom controls
- Current-location button
- Real device location using `geolocator`
- Proper location permission handling
- At least 3 favorite locations
- Favorite markers on the map
- Marker tap dialog showing name, ID, latitude and longitude
- Favorite Locations list
- Tapping a favorite moves the map camera to that location

## Favorite locations

1. Khulna University
   - ID: 1
   - Latitude: 22.8026
   - Longitude: 89.3709

2. Khulna Railway Station
   - ID: 2
   - Latitude: 22.8456
   - Longitude: 89.5400

3. Shibbari More
   - ID: 3
   - Latitude: 22.8149
   - Longitude: 89.5434

## Google Maps API key setup

A Google Maps API key is intentionally NOT included in this project.

### Android

Open:

`android/app/src/main/AndroidManifest.xml`

Find:

`YOUR_GOOGLE_MAPS_API_KEY`

Replace it with your Google Maps API key.

For the Google Maps Android API, enable:
- Maps SDK for Android

### iOS

Open:

`ios/Runner/AppDelegate.swift`

Find:

`YOUR_GOOGLE_MAPS_API_KEY`

Replace it with your Google Maps API key.

For iOS, enable:
- Maps SDK for iOS

## Location permissions

Android permission is already added to:

`android/app/src/main/AndroidManifest.xml`

iOS location usage text is already added to:

`ios/Runner/Info.plist`

## Run

```bash
flutter pub get
flutter run
```

For Android:

```bash
flutter run
```

For iOS:

```bash
cd ios
pod install
cd ..
flutter run
```

## Important

The current location is never hard-coded. It is obtained from the device through `geolocator`.

The app can still open the map if location permission has not been granted. Press **My Location** to request/access the device location.

## Screenshots for submission

After adding your API key and running the app, take:
1. Google Map screenshot
2. Current location screenshot
3. Favorite markers screenshot
4. Favorite location details dialog screenshot
5. Favorite location list screenshot

Then push the complete project to GitHub and submit the repository link.
