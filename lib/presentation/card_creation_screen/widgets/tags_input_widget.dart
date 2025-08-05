import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TagsInputWidget extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onTagsChanged;

  const TagsInputWidget({
    super.key,
    required this.tags,
    required this.onTagsChanged,
  });

  @override
  State<TagsInputWidget> createState() => _TagsInputWidgetState();
}

class _TagsInputWidgetState extends State<TagsInputWidget> {
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _tagController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag() {
    final tagText = _tagController.text.trim();
    if (tagText.isNotEmpty &&
        !widget.tags.contains(tagText) &&
        widget.tags.length < 5) {
      final updatedTags = List<String>.from(widget.tags)..add(tagText);
      widget.onTagsChanged(updatedTags);
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    final updatedTags = List<String>.from(widget.tags)..remove(tag);
    widget.onTagsChanged(updatedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags (Optional)',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          if (widget.tags.isNotEmpty) ...[
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: widget.tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: CustomIconWidget(
                          iconName: 'close',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 4.w,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 1.h),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagController,
                  focusNode: _focusNode,
                  maxLength: 20,
                  onSubmitted: (_) => _addTag(),
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: widget.tags.length >= 5
                        ? 'Maximum 5 tags allowed'
                        : 'Add a tag...',
                    hintStyle:
                        AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                    ),
                    counterText: '',
                    enabled: widget.tags.length < 5,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: widget.tags.length < 5 &&
                        _tagController.text.trim().isNotEmpty
                    ? _addTag
                    : null,
                child: Container(
                  width: 12.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: widget.tags.length < 5 &&
                            _tagController.text.trim().isNotEmpty
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: widget.tags.length < 5 &&
                              _tagController.text.trim().isNotEmpty
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                      size: 5.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.tags.length >= 5) ...[
            SizedBox(height: 1.h),
            Text(
              'Maximum 5 tags allowed',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
