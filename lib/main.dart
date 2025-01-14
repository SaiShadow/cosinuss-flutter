import 'package:cosinuss/pages/main_page.dart';
import 'package:flutter/material.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// Root widget of the application.
class MyApp extends StatelessWidget {
  /// Constructor for the `MyApp` class.
  const MyApp({Key? key}) : super(key: key);

  /// Builds the `MaterialApp` for the application.
  ///
  /// - Sets the title of the app.
  /// - Configures the theme for consistent styling.
  /// - Specifies the `MainPage` as the home screen.
  /// - Disables the debug banner for production-like appearance.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Configures the primary color theme.
      ),
      home: const MainPage(title: 'Flow State'), // Main page of the app.
      debugShowCheckedModeBanner: false, // Disables the debug banner.
    );
  }
}
