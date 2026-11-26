import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/trip_repository.dart';

/// Dedicated Edit Trip screen navigated to from Trip Actions -> Edit Trip.
class EditTripScreen extends StatefulWidget {
  final TripModel trip;

  const EditTripScreen({
    super.key,
    required this.trip,
  });

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _destinationController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _meetingPlaceController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.trip.name);
    _destinationController =
        TextEditingController(text: widget.trip.destination);
    _startDateController = TextEditingController(text: widget.trip.startDate);
    _endDateController = TextEditingController(text: widget.trip.endDate);
    _meetingPlaceController =
        TextEditingController(text: widget.trip.meetingPlace);
    _descriptionController =
        TextEditingController(text: widget.trip.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _meetingPlaceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final destination = _destinationController.text.trim();
    final startDate = _startDateController.text.trim();
    final endDate = _endDateController.text.trim();
    final meetingPlace = _meetingPlaceController.text.trim();
    final description = _descriptionController.text.trim();

    final updated = widget.trip.copyWith(
      name: name,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      fullDateRange: '$startDate - $endDate',
      meetingPlace: meetingPlace,
      description: description,
    );

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(57),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Iconsax.arrow_left,
                  color: AppColors.secondaryDark,
                  size: 22,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                splashRadius: 22,
              ),
              titleSpacing: 0,
              title: Text(
                'Edit Trip',
                style: AppTypography.h4.copyWith(
                  color: AppColors.secondaryDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.ann,
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 44).clamp(0.0, double.infinity),
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set up your trip essentials',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.secondaryDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Give your trip a name and fill in a few key details to get started.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.carla,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildField(
                          label: 'Trip Name',
                          isRequired: true,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Destination',
                          isRequired: true,
                          controller: _destinationController,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildField(
                                label: 'Start Date',
                                isRequired: true,
                                controller: _startDateController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: 'End Date',
                                isRequired: true,
                                controller: _endDateController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Meeting Place',
                          isRequired: true,
                          controller: _meetingPlaceController,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Description',
                          isRequired: false,
                          controller: _descriptionController,
                          minLines: 1,
                          maxLines: 3,
                        ),
                        const Spacer(),
                        const SizedBox(height: 28),
                        AppButton(
                          text: 'Save Changes',
                          variant: AppButtonVariant.primaryNavy,
                          customHeight: 52,
                          borderRadius: 18,
                          onPressed: _saveChanges,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Cancel',
                          variant: AppButtonVariant.secondary,
                          customHeight: 52,
                          borderRadius: 18,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required bool isRequired,
    required TextEditingController controller,
    int minLines = 1,
    int maxLines = 1,
  }) {
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: AppColors.secondaryDark,
        width: 2.0,
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: AppColors.primaryOrange,
        width: 2.0,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: AppTypography.inputLabel.copyWith(
              color: AppColors.secondaryDark,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: '*',
                  style: AppTypography.inputLabel.copyWith(
                    color: AppColors.primaryOrange,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.secondaryDark,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: AppColors.secondaryDark,
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.secondaryLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: defaultBorder,
            enabledBorder: defaultBorder,
            focusedBorder: defaultBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
            errorStyle: AppTypography.bodySmall.copyWith(
              color: AppColors.primaryOrange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
