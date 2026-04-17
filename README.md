# FluxPDF - Professional PDF Reader & Manager

FluxPDF is a comprehensive Flutter application for viewing and managing PDF documents on Android devices. It provides an intuitive interface for document organization with features like text selection, copying, and sharing.

## Project Purpose

FluxPDF aims to deliver a mobile-first PDF experience for viewing and basic management. It enables users to:
- View and navigate PDFs with smooth performance
- Select and copy text from documents
- Organize documents with favorites and tags
- Share PDFs with other applications
- Switch between light and dark themes (red accent)

## Installation and Setup

### Prerequisites
Before building and running the app, ensure you have the following installed:

1. **Flutter SDK** (Version 3.10.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH
   - Verify installation: `flutter doctor`

2. **Android Studio** (Latest stable version)
   - Includes Android SDK (API 21+), JDK 17, and Android Emulator
   - Download from: https://developer.android.com/studio
   - Install Android SDK components via SDK Manager

3. **Git** (For cloning the repository)
   - Download from: https://git-scm.com/downloads

4. **Optional for iOS**: Xcode (if building for iOS devices)
   - Available on macOS via App Store

### Step-by-Step Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```
   This downloads all required packages defined in `pubspec.yaml`.

3. **Verify Environment Setup**
   ```bash
   flutter doctor
   ```
   Ensure all components are installed and configured correctly. Fix any issues reported.

4. **Set Up Android Device/Emulator**
   - **Physical Device**: Enable Developer Options and USB Debugging on your Android device, then connect via USB.
   - **Emulator**: Open Android Studio > Tools > Device Manager > Create Virtual Device.

5. **Run the App in Development Mode**
   ```bash
   flutter run
   ```
   - Select your target device (emulator or connected Android device).
   - The app will build and install automatically.

6. **Build Release APK for Distribution**
   ```bash
   flutter build apk --release
   ```
   - The APK file will be generated at `build/app/outputs/flutter-apk/app-release.apk`.
   - Transfer the APK to your Android device and install it manually.

   **Optional: Build with Size Analysis**
   ```bash
   flutter build apk --release --analyze-size
   ```
   This provides a breakdown of the APK size.

### Additional Setup Notes
- **Syncfusion License**: This app uses Syncfusion PDF controls. For production use, obtain a license from https://www.syncfusion.com/products/flutter/pdf and add it to your app.
- **Permissions**: The app requires storage permissions to access PDF files on your device.
- **iOS Build**: To build for iOS, run `flutter build ios` on a macOS machine with Xcode installed.
- **Troubleshooting**: If builds fail, run `flutter clean` then `flutter pub get` again.

## Detailed Usage Instructions

### Getting Started
1. Launch the app and grant storage permissions
2. Tap "Import PDF" to load documents from your device
3. Use the document manager to organize your PDFs

### Viewing PDFs
- **Navigation**: Swipe or use page indicators to navigate
- **Zoom**: Pinch to zoom in/out
- **Night Mode**: Toggle dark theme for comfortable reading

### Text Selection and Copy
1. Long press on text in a PDF to select it
2. Selected text is automatically copied to clipboard with confirmation

### Document Management

#### Organizing Documents
- **Long Press** any document to access context menu:
  - **Rename**: Change document name
  - **Favorite/Star**: Add/remove from favorites
  - **Share**: Share PDF with other apps
  - **Delete**: Remove document with confirmation

#### Document Views
- Switch between grid and list views
- Use folder view organized by tags
- Search documents by name
- Filter by favorites or tags

#### PDF Viewing Features
- **Navigation**: Swipe or use page indicators
- **Zoom**: Pinch to zoom in/out
- **Themes**: Toggle between light/dark modes (red accent)
- **Share**: Share button in PDF viewer top bar
## Supported Features

### Core Features
- ✅ PDF viewing with smooth scrolling and navigation
- ✅ Text selection and automatic copying to clipboard
- ✅ Document management (rename, favorite, delete, share)
- ✅ Grid/List view toggle with folder organization
- ✅ Search and filter documents
- ✅ Light/Dark theme support (red accent theme)
- ✅ PDF sharing with external applications
- ✅ Local storage with Hive database

### PDF Processing Tools (UI Ready)
- 📋 Merge PDFs (screen implemented)
- ✂️ Split PDFs (screen implemented)
- 🖼️ Image to PDF conversion (screen implemented)

### Limitations
- **Platform**: Android only (iOS support possible with modifications)
- **File Formats**: PDF input only; images supported for conversion
- **OCR**: Not included; text selection works with searchable PDFs
- **Cloud Sync**: Local storage only
- **Privacy**: 100% Offline processing; no data leaves the device
- **Maximum File Size**: Limited by device memory (tested up to 100MB)
- **Advanced Editing**: Basic text selection only (no annotations, signatures, or advanced editing)

## Current Implementation Status

### ✅ Fully Working Features
- **PDF Viewing**: Smooth scrolling, zoom, page navigation
- **Text Selection**: Long press to select and auto-copy text
- **Document Management**: Import, organize, search, tag documents
- **Context Menu**: Long press for rename/favorite/share/delete
- **Themes**: Light/dark mode with red accent theme
- **Local Storage**: Hive database for document metadata

### 🚧 Partially Implemented
- **PDF Processing Tools**: UI screens exist but backend logic limited
- **Merge PDFs**: Screen available, processing not fully implemented
- **Split PDFs**: Screen available, processing not fully implemented
- **Image to PDF**: Screen available, processing not fully implemented

### 📋 Planned Features (Not Implemented)
- Advanced PDF editing (annotations, signatures)
- Sensitive data scanning and redaction
- OCR text recognition
- Cloud synchronization

## Architecture Overview

FluxPDF follows Clean Architecture principles:

### Domain Layer
- **Entities**: Document models with metadata
- **Use Cases**: Business logic for PDF operations
- **Services**: PDF processing interfaces

### Data Layer
- **Repositories**: Data access implementations
- **Services**: Basic PDF viewing with Syncfusion
- **Datasources**: Local file system integration with Hive

### Presentation Layer
- **Screens**: UI components with Riverpod state management
- **Widgets**: Reusable UI elements
- **Providers**: State management and dependency injection

## Build System

The app uses Flutter's build system with Gradle for Android:
- **Dart AOT Compilation**: Optimized native code generation
- **Asset Bundling**: Fonts and resources packaged
- **Plugin Integration**: Native Android APIs bridged
- **APK Assembly**: Signed release builds for distribution

## Troubleshooting

### Build Issues
- Ensure Flutter and Android SDK paths are correct in `local.properties`
- Run `flutter doctor` to check environment
- Clean build: `flutter clean && flutter pub get`

### Runtime Issues
- Grant storage permissions in Android settings
- Ensure PDFs are not corrupted
- For large files, increase device memory if possible
- If PDF shows blank screen, check file path and permissions

### Feature Limitations
- Basic text selection only (no advanced annotations)
- No collaborative editing
- Limited to local device storage
- PDF processing tools (merge/split) have UI but limited backend implementation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with proper testing
4. Submit a pull request

## License

This project is licensed under the MIT License.
