# pokemondex

Pokedex project

## Testing Coverage

You can see the coverage of the testing by using below commands

flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

## How to Run and Install

**Install Prerequisites**
1. Flutter SDK (≥ 3.22.0) https://docs.flutter.dev/get-started/install
2. Dart https://dart.dev/get-dart
3. Android Studio or VS Code
4. Android SDK + Emulator (for Android builds)
5. Xcode (for iOS builds, macOS only)
6. You can check your flutter setup with command **flutter doctor** and make sure all green checkmarks
**Clone Repository**
1. git clone https://github.com/YudithOcto/pokedex-graphql
2. cd pokemondex
3. Flutter pub get
4. Open Android Studio → Tools → Device Manager → Start an emulator
5. Run flutter app using **flutter run** command. Make sure the emulator is turned on