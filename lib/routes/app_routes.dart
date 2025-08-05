import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/card_edit_screen/card_edit_screen.dart';
import '../presentation/flashcard_study_screen/flashcard_study_screen.dart';
import '../presentation/card_creation_screen/card_creation_screen.dart';
import '../presentation/card_management_screen/card_management_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String cardEditScreen = '/card-edit-screen';
  static const String flashcardStudyScreen = '/flashcard-study-screen';
  static const String cardCreationScreen = '/card-creation-screen';
  static const String cardManagementScreen = '/card-management-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => SplashScreen(),
    splashScreen: (context) => SplashScreen(),
    cardEditScreen: (context) => CardEditScreen(),
    flashcardStudyScreen: (context) => FlashcardStudyScreen(),
    cardCreationScreen: (context) => CardCreationScreen(),
    cardManagementScreen: (context) => CardManagementScreen(),
    // TODO: Add your other routes here
  };
}
