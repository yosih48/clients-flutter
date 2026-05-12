import 'package:clientsf/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:clientsf/l10n/app_localizations.dart';
import '../Constants/AppString.dart';

void showAlertDialog(BuildContext context, String title, {String? subtitle}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: subtitle != null ? Text(subtitle) : null,
      actions: [
        TextButton(
          child: const Text(AppStrings.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

void showToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: AppColors.ink,
    textColor: Colors.white,
    fontSize: 15.0,
  );
}

/// Soft confirm dialog used before destructive actions (delete client, delete
/// call, etc).
void showDialogw(BuildContext context, {required VoidCallback onConfirm}) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      final loc = AppLocalizations.of(context)!;
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.dangerSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.warning_amber_rounded,
                    color: AppColors.danger, size: 28),
              ),
              const SizedBox(height: 18),
              Text(
                'האם אתה בטוח שברצונך למחוק?',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: Text(loc.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                      ),
                      onPressed: () {
                        onConfirm();
                        Navigator.pop(context, 'OK');
                      },
                      child: Text(loc.yes),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
