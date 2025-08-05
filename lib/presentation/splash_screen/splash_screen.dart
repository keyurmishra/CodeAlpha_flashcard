import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/gradient_background_widget.dart';
import './widgets/loading_indicator_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isInitialized = false;
  String _loadingText = 'Initializing flashcards...';

  // Mock flashcard data for initialization
  final List<Map<String, dynamic>> _mockFlashcards = [
    {
      "id": 1,
      "question": "What is the capital of France?",
      "answer": "Paris is the capital and most populous city of France.",
      "category": "Geography",
      "difficulty": "Easy",
      "created_at": "2025-01-15T10:30:00Z",
      "last_reviewed": null,
      "review_count": 0,
    },
    {
      "id": 2,
      "question": "What is photosynthesis?",
      "answer":
          "Photosynthesis is the process by which plants use sunlight, water, and carbon dioxide to create oxygen and energy in the form of sugar.",
      "category": "Biology",
      "difficulty": "Medium",
      "created_at": "2025-01-16T14:20:00Z",
      "last_reviewed": null,
      "review_count": 0,
    },
    {
      "id": 3,
      "question": "Who wrote Romeo and Juliet?",
      "answer":
          "William Shakespeare wrote Romeo and Juliet, one of his most famous tragic plays.",
      "category": "Literature",
      "difficulty": "Easy",
      "created_at": "2025-01-17T09:15:00Z",
      "last_reviewed": null,
      "review_count": 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setSystemUIOverlay();
    _initializeApp();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate loading local flashcard database
      await _loadFlashcardDatabase();

      // Check data integrity
      await _checkDataIntegrity();

      // Prepare animation controllers
      await _prepareAnimationControllers();

      // Initialize Flutter widgets
      await _initializeWidgets();

      setState(() {
        _isInitialized = true;
        _loadingText = 'Ready to learn!';
      });

      // Wait for animations to complete
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // Handle initialization errors gracefully
      await _handleInitializationError();
    }
  }

  Future<void> _loadFlashcardDatabase() async {
    setState(() {
      _loadingText = 'Loading flashcard database...';
    });

    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate database loading with SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final hasExistingCards = prefs.getBool('has_flashcards') ?? false;

    if (!hasExistingCards) {
      // Initialize with mock data for first-time users
      await prefs.setBool('has_flashcards', true);
      await prefs.setInt('flashcard_count', _mockFlashcards.length);
    }
  }

  Future<void> _checkDataIntegrity() async {
    setState(() {
      _loadingText = 'Checking data integrity...';
    });

    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate data integrity check
    final prefs = await SharedPreferences.getInstance();
    final cardCount = prefs.getInt('flashcard_count') ?? 0;

    if (cardCount < 0) {
      // Repair corrupted data
      await prefs.setInt('flashcard_count', _mockFlashcards.length);
    }
  }

  Future<void> _prepareAnimationControllers() async {
    setState(() {
      _loadingText = 'Preparing animations...';
    });

    await Future.delayed(const Duration(milliseconds: 400));

    // Simulate animation controller preparation
    // This would typically involve initializing complex animation sequences
  }

  Future<void> _initializeWidgets() async {
    setState(() {
      _loadingText = 'Initializing interface...';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate widget initialization
    // This would typically involve preparing complex UI components
  }

  Future<void> _handleInitializationError() async {
    setState(() {
      _loadingText = 'Preparing fallback mode...';
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    // Set up minimal working state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_flashcards', false);
    await prefs.setInt('flashcard_count', 0);

    setState(() {
      _isInitialized = true;
      _loadingText = 'Ready to start!';
    });
  }

  void _onLogoAnimationComplete() {
    if (_isInitialized) {
      _navigateToNextScreen();
    }
  }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final hasFlashcards = prefs.getBool('has_flashcards') ?? false;
    final cardCount = prefs.getInt('flashcard_count') ?? 0;

    // Start fade out animation
    await _fadeController.forward();

    if (mounted) {
      // Navigate based on user state
      if (hasFlashcards && cardCount > 0) {
        Navigator.pushReplacementNamed(context, '/flashcard-study-screen');
      } else {
        Navigator.pushReplacementNamed(context, '/card-creation-screen');
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: 1.0 - _fadeAnimation.value,
            child: SafeArea(
              child: GradientBackgroundWidget(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Spacer to push content to center
                      const Spacer(flex: 2),

                      // Animated logo section
                      AnimatedLogoWidget(
                        onAnimationComplete: _onLogoAnimationComplete,
                      ),

                      // Spacer between logo and loading indicator
                      const Spacer(flex: 1),

                      // Loading indicator section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: LoadingIndicatorWidget(
                          loadingText: _loadingText,
                        ),
                      ),

                      // Bottom spacer
                      const Spacer(flex: 2),

                      // App version info
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Text(
                          'Version 1.0.0',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 2.5.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
