import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/app_theme.dart';

/// Displays a circular group photo placeholder (or selected image) alongside
/// an "Add photo" button.
///
/// When [imageFile] is null, a yellow circle with a user icon is shown.
/// When [imageFile] is set, it is displayed as a cropped circle using
/// [ClipOval] + [BoxFit.cover].
class GroupPhotoPicker extends StatelessWidget {
  const GroupPhotoPicker({
    super.key,
    this.imageFile,
    this.onAddPhoto,
    this.onRemovePhoto,
  });

  /// The currently selected image. Null when no photo has been chosen.
  final File? imageFile;

  /// Called when the user taps "Add photo" or the circular placeholder.
  final VoidCallback? onAddPhoto;

  /// Called when the user wants to remove the current photo.
  final VoidCallback? onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Circular photo display ──────────────────────────────────────
        GestureDetector(
          onTap: onAddPhoto,
          child: SizedBox(
            width: AppTokens.groupPhotoSize,
            height: AppTokens.groupPhotoSize,
            child: ClipOval(
              child: imageFile != null
                  ? Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                      width: AppTokens.groupPhotoSize,
                      height: AppTokens.groupPhotoSize,
                    )
                  : Container(
                      color: AppColors.yellow,
                      child: const Icon(
                        Iconsax.profile_2user,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // ── Add photo button ────────────────────────────────────────────
        GestureDetector(
          onTap: onAddPhoto,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryDark,
                width: AppTokens.cardBorderWidth,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.primaryDark,
                  offset: Offset(0, AppTokens.cardShadowOffset),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Iconsax.camera,
                  size: 18,
                  color: AppColors.primaryText,
                ),
                SizedBox(width: 6),
                Text(
                  'Add photo',
                  style: TextStyle(
                    fontFamily: AppFonts.urbanist,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
