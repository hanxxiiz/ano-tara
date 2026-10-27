import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_checkbox.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../components/organisms/app_top_bar.dart';

class CreateTab extends StatefulWidget {
  final VoidCallback? onTripCreated;

  const CreateTab({super.key, this.onTripCreated});

  @override
  State<CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _splitEqually = true;
  bool _notifyMembers = true;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _handleCreate() async {
    setState(() => _isCreating = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isCreating = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip plan created and synced with your group!'),
        backgroundColor: AppColors.primaryNavy,
      ),
    );

    widget.onTripCreated?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        showBackButton: false,
        title: 'Plan New Adventure',
        subtitle: 'Fill details to propose to your squad',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInputField(
                label: 'Trip / Hangout Title',
                hint: 'e.g. Bantayan Island Weekend Getaway',
                controller: _titleController,
                prefixIcon: const Icon(Iconsax.map_1, color: AppColors.shayne, size: 20),
              ),
              const SizedBox(height: 16),

              AppInputField(
                label: 'Destination / Location',
                hint: 'e.g. Santa Fe, Cebu',
                controller: _locationController,
                prefixIcon: const Icon(Iconsax.location, color: AppColors.shayne, size: 20),
              ),
              const SizedBox(height: 16),

              AppInputField(
                label: 'Estimated Target Budget (₱)',
                hint: 'e.g. 5000',
                controller: _budgetController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Iconsax.money_send, color: AppColors.shayne, size: 20),
              ),
              const SizedBox(height: 20),

              // Split equally checkbox atom
              AppCheckbox(
                value: _splitEqually,
                onChanged: (val) => setState(() => _splitEqually = val),
                label: 'Auto-split expense equally across members',
                activeColor: AppColors.primaryNavy,
              ),
              const SizedBox(height: 8),

              // Notify members checkbox atom
              AppCheckbox(
                value: _notifyMembers,
                onChanged: (val) => setState(() => _notifyMembers = val),
                label: 'Notify group members instantly via push notification',
                activeColor: AppColors.primaryOrange,
              ),
              const SizedBox(height: 32),

              AppButton(
                text: 'Create & Propose Trip',
                variant: AppButtonVariant.primaryNavy,
                isLoading: _isCreating,
                iconLeading: const Icon(Iconsax.add_circle, color: AppColors.white, size: 18),
                onPressed: _handleCreate,
              ),
              const SizedBox(height: 14),

              AppButton(
                text: 'Auto-fill with AI Assistant',
                variant: AppButtonVariant.outline,
                iconLeading: const Icon(Iconsax.magicpen, color: AppColors.primaryNavy, size: 18),
                onPressed: () {
                  setState(() {
                    _titleController.text = 'Siargao Cloud 9 Surf & Sunset';
                    _locationController.text = 'General Luna, Surigao del Norte';
                    _budgetController.text = '7500';
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
