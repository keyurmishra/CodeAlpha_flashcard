import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EditFormWidget extends StatefulWidget {
  final Map<String, dynamic> flashcard;
  final Function(String question, String answer) onUpdate;
  final VoidCallback onCancel;

  const EditFormWidget({
    super.key,
    required this.flashcard,
    required this.onUpdate,
    required this.onCancel,
  });

  @override
  State<EditFormWidget> createState() => _EditFormWidgetState();
}

class _EditFormWidgetState extends State<EditFormWidget>
    with TickerProviderStateMixin {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late AnimationController _previewAnimationController;
  late Animation<double> _previewAnimation;
  bool _hasUnsavedChanges = false;
  bool _isPreviewVisible = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.flashcard['question'] as String? ?? '',
    );
    _answerController = TextEditingController(
      text: widget.flashcard['answer'] as String? ?? '',
    );

    _previewAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _previewAnimation = CurvedAnimation(
      parent: _previewAnimationController,
      curve: Curves.easeInOut,
    );

    _questionController.addListener(_onTextChanged);
    _answerController.addListener(_onTextChanged);

    // Position cursor at end of text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _questionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _questionController.text.length),
      );
    });
  }

  void _onTextChanged() {
    final hasChanges =
        _questionController.text != widget.flashcard['question'] ||
            _answerController.text != widget.flashcard['answer'];

    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  void _togglePreview() {
    setState(() {
      _isPreviewVisible = !_isPreviewVisible;
    });

    if (_isPreviewVisible) {
      _previewAnimationController.forward();
    } else {
      _previewAnimationController.reverse();
    }
  }

  void _handleUpdate() {
    if (_questionController.text.trim().isEmpty ||
        _answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Both question and answer are required',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    widget.onUpdate(
      _questionController.text.trim(),
      _answerController.text.trim(),
    );
  }

  Future<bool> _handleBackPress() async {
    if (!_hasUnsavedChanges) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unsaved Changes',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'You have unsaved changes. Do you want to discard them?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Keep Editing',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Discard',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _previewAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _handleBackPress();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question Input
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                TextField(
                  controller: _questionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter your question here...',
                    contentPadding: EdgeInsets.all(3.w),
                  ),
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          // Answer Input
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Answer',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                TextField(
                  controller: _answerController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter your answer here...',
                    contentPadding: EdgeInsets.all(3.w),
                  ),
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          // Preview Toggle Button
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: OutlinedButton.icon(
              onPressed: _togglePreview,
              icon: CustomIconWidget(
                iconName: _isPreviewVisible ? 'visibility_off' : 'visibility',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              label: Text(_isPreviewVisible ? 'Hide Preview' : 'Show Preview'),
            ),
          ),

          // Live Preview Card
          AnimatedBuilder(
            animation: _previewAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _previewAnimation,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Card(
                    elevation: 2,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      constraints: BoxConstraints(minHeight: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Q: ${_questionController.text.isEmpty ? 'Enter your question...' : _questionController.text}',
                            style: AppTheme.lightTheme.textTheme.bodyLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'A: ${_answerController.text.isEmpty ? 'Enter your answer...' : _answerController.text}',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Action Buttons
          Container(
            margin: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final shouldCancel = await _handleBackPress();
                      if (shouldCancel) {
                        widget.onCancel();
                      }
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _hasUnsavedChanges ? _handleUpdate : null,
                    child: const Text('Update Card'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
