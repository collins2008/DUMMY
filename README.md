
Habit Garden - Android APK build instructions
===========================================

What I created for you:
- A ready Flutter app source in `lib/main.dart` (single-file MVP UI).
- pubspec.yaml and placeholder asset files listed under `assets/lottie/`.
- This package does NOT include Lottie JSON animations (you must add them manually).
- I cannot build the APK here, but you can build it on your PC and install on your Samsung device.

Steps to build APK (on your computer):
1. Install Flutter SDK: https://flutter.dev/docs/get-started/install
2. Install Android Studio and Android SDK & set up an Android emulator OR enable USB debugging on your Samsung phone.
3. Clone or unzip this project folder to your machine.
4. From the project root, run:
   flutter pub get
5. Add Lottie animation files into `assets/lottie/` or replace the Lottie references in lib/main.dart.
   If you don't add Lottie files, the app will show placeholder avatars instead.
6. Build the APK:
   flutter build apk --release
   The APK will be under build/app/outputs/flutter-apk/app-release.apk
7. Install the APK on your Samsung device (via USB or transfer):
   adb install -r build/app/outputs/flutter-apk/app-release.apk

Notes on widgets:
- Android home-screen widgets require native code. I can provide a sample Kotlin AppWidgetProvider and instructions to connect it to the app storage (SharedPreferences or a file).

If you'd like, next I can:
- Add local persistence (Hive) so your habits are saved between sessions.
- Create the Android native widget sample (Kotlin) that reads from the app storage and displays simple static icons & streak counts.
- Help you pick and add free Lottie files for the streak styles and show you exactly where to place them.



## What's new (updated)
- Added Hive persistence and SharedPreferences mirroring so habits persist and native widgets can read a JSON snapshot.
- Included a sample Android AppWidgetProvider (Kotlin) and widget layout XML under `android/app/src/main/...`.

## How the widget works
- The Flutter app stores habits in Hive and mirrors a JSON string to SharedPreferences key `habit_garden_widget_data` (in FlutterSharedPreferences).
- The native Kotlin widget reads that key and displays the first habit (you can expand it to show multiple items).

## Suggested free Lottie animations to download (place into assets/lottie/):
1. Fire: https://lottiefiles.com/24634-fire-animation (save as fire.json)
2. Plant growth: https://lottiefiles.com/9363-plant-growing (save as plant.json)
3. Book fill: https://lottiefiles.com/1123-book (save as book.json)
4. Gem sparkle: https://lottiefiles.com/3898-gem (save as gem.json)
5. Moon phases: https://lottiefiles.com/5123-moon (save as moon.json)

After downloading, replace the placeholder JSON files in `assets/lottie/` and run `flutter pub get`.

## Next steps I can do for you
- Adjust the widget to show a list/grid of top 3 habits with small icons (requires RemoteViewsList or collection support).
- Provide a signed APK build script (you'll still need to run it locally).
