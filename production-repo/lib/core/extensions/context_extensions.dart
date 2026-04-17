import 'package:flutter/material.dart';

/// Extension methods for BuildContext
/// 
/// Provides convenient access to common properties like theme,
/// navigator, and media query from any widget context.
extension ContextExtensions on BuildContext {
  /// Access the current theme
  ThemeData get theme => Theme.of(this);
  
  /// Access the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Access the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Access the current media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  /// Access the screen size
  Size get screenSize => MediaQuery.sizeOf(this);
  
  /// Access the screen width
  double get screenWidth => MediaQuery.sizeOf(this).width;
  
  /// Access the screen height
  double get screenHeight => MediaQuery.sizeOf(this).height;
  
  /// Check if the device is in landscape mode
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
  
  /// Check if the device is in portrait mode
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;
  
  /// Check if the device is a tablet (width >= 600)
  bool get isTablet => screenWidth >= 600;
  
  /// Check if the device is a desktop (width >= 1200)
  bool get isDesktop => screenWidth >= 1200;
  
  /// Check if dark mode is enabled
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  /// Access the current navigator
  NavigatorState get navigator => Navigator.of(this);
  
  /// Access the current scaffold messenger
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
  
  /// Access the bottom safe area padding
  double get bottomPadding => mediaQuery.padding.bottom;
  
  /// Access the top safe area padding
  double get topPadding => mediaQuery.padding.top;
  
  /// Show a snackbar
  void showSnackBar(String message, {bool isError = false}) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
