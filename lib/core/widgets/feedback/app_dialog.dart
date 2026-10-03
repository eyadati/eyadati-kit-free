import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_radius.dart';
import '../../constants/app_spacing.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDanger;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDanger = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDanger: isDanger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.dialogRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: AppSpacing.md),
              content!,
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                if (cancelText != null) ...[
                  Expanded(
                    child: SecondaryButton(
                      label: cancelText!,
                      onPressed: () {
                        onCancel?.call();
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                if (confirmText != null)
                  Expanded(
                    child: isDanger
                        ? ElevatedButton(
                            onPressed: () {
                              onConfirm?.call();
                              Navigator.of(context).pop(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            child: Text(confirmText!),
                          )
                        : PrimaryButton(
                            label: confirmText!,
                            isFullWidth: false,
                            onPressed: () {
                              onConfirm?.call();
                              Navigator.of(context).pop(true);
                            },
                          ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}