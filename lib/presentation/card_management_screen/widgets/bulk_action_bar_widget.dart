import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BulkActionBarWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onDeleteSelected;
  final VoidCallback onExportSelected;
  final VoidCallback onClearSelection;

  const BulkActionBarWidget({
    super.key,
    required this.selectedCount,
    required this.onDeleteSelected,
    required this.onExportSelected,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: onClearSelection,
              icon: CustomIconWidget(
                iconName: 'close',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              constraints: BoxConstraints(
                minWidth: 10.w,
                minHeight: 6.h,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                '$selectedCount selected',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: onExportSelected,
                    icon: CustomIconWidget(
                      iconName: 'file_download',
                      size: 20,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    tooltip: 'Export Selected',
                    constraints: BoxConstraints(
                      minWidth: 10.w,
                      minHeight: 6.h,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _showDeleteConfirmation(context),
                    icon: CustomIconWidget(
                      iconName: 'delete',
                      size: 20,
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                    tooltip: 'Delete Selected',
                    constraints: BoxConstraints(
                      minWidth: 10.w,
                      minHeight: 6.h,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
              SizedBox(width: 2.w),
              Text(
                'Delete Flashcards',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete $selectedCount flashcard${selectedCount > 1 ? 's' : ''}? This action cannot be undone.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onDeleteSelected();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
