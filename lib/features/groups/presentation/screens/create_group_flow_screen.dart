import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../widgets/shield_check_icon.dart';

class CreateGroupFlowScreen extends StatefulWidget {
  const CreateGroupFlowScreen({super.key});

  @override
  State<CreateGroupFlowScreen> createState() => _CreateGroupFlowScreenState();
}

class _CreateGroupFlowScreenState extends State<CreateGroupFlowScreen> {
  int _currentStep = 1; // 1: Details, 2: Invite, 3: Review, 4: Created/Confirmed

  // Step 1 Controllers
  final _nameController = TextEditingController(text: 'Weekend Wanderers');
  final _descriptionController = TextEditingController(
    text: 'For our weekend escapes and spontaneous trips.',
  );

  // Step 2 Search & Member Selection
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allMembers = [
    {'name': 'Louielyn Abella', 'email': 'louielyn@gmail.com', 'selected': true},
    {'name': 'Ellle Bernante', 'email': 'ellle@gmail.com', 'selected': true},
    {'name': 'Hannah S. Labandero', 'email': 'hannah@gmail.com', 'selected': false},
    {'name': 'Carla Santos', 'email': 'carla@gmail.com', 'selected': false},
    {'name': 'Mark Lim', 'email': 'mark@gmail.com', 'selected': false},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name.'),
          backgroundColor: AppColors.semanticRed,
        ),
      );
      return;
    }
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  List<Map<String, dynamic>> get _invitedMembers =>
      _allMembers.where((m) => m['selected'] == true).toList();

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 4) {
      return _buildConfirmationScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top Bar with Back Arrow and 3-Pill Capsule Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Iconsax.arrow_left,
                        color: AppColors.secondaryDark,
                        size: 24,
                      ),
                      onPressed: _previousStep,
                      splashRadius: 24,
                    ),
                  ),
                  _buildProgressIndicator(),
                ],
              ),
            ),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _buildCurrentStepBody(),
              ),
            ),

            // Sticky Bottom Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: _buildBottomActions(),
            ),
          ],
        ),
      ),
    );
  }

  // 3-Pill Capsule Indicator matching Figma: active step solid #0F0331, inactive outlined
  Widget _buildProgressIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final stepNum = index + 1;
            final isActive = _currentStep == stepNum;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 32,
              height: 7,
              decoration: BoxDecoration(
                color: isActive ? AppColors.secondaryDark : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.secondaryDark,
                  width: 1.5,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          '$_currentStep/3',
          style: AppTypography.caption.copyWith(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepBody() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Details();
      case 2:
        return _buildStep2Invite();
      case 3:
        return _buildStep3Review();
      default:
        return const SizedBox.shrink();
    }
  }

  // ================= STEP 1: GROUP DETAILS =================
  Widget _buildStep1Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Give your group a name',
          style: AppTypography.h3.copyWith(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bring your travel buddies together in one place.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.secondaryDark,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 24),

        // Group photo section
        Text(
          'Group photo (optional)',
          style: AppTypography.caption.copyWith(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: AppIcon(
                  Iconsax.profile_2user5,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image picker opened (optional)'),
                        backgroundColor: AppColors.primaryNavy,
                        duration: Duration(milliseconds: 1200),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.secondaryDark, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.secondaryDark,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Add photo',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Group Name Field - uses clean atom without double-border
        AppInputField(
          label: 'Group Name*',
          hint: 'e.g. Weekend Wanderers',
          controller: _nameController,
        ),
        const SizedBox(height: 16),

        // Description Field - uses clean atom without double-border
        AppInputField(
          label: 'Description (optional)',
          hint: 'What brings your group together?',
          controller: _descriptionController,
          minLines: 3,
          maxLines: 4,
        ),
        const SizedBox(height: 16),

        Text(
          'You’ll be the group organizer. You can invite members next.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.secondaryDark,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ================= STEP 2: INVITE MEMBERS =================
  Widget _buildStep2Invite() {
    final filteredMembers = _allMembers.where((m) {
      if (_searchQuery.isEmpty) return true;
      return (m['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (m['email'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final selectedCount = _allMembers.where((m) => m['selected'] == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who’s in your travel crew?',
          style: AppTypography.h3.copyWith(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Search by name or email and select the people you want to invite.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.secondaryDark,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 20),

        // Clean Search Bar without inner double-border
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(
                Iconsax.search_normal,
                color: AppColors.secondaryDark,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryDark),
                  decoration: const InputDecoration(
                    hintText: 'Search name or email...',
                    hintStyle: TextStyle(color: AppColors.carla, fontSize: 13.5),
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Count label
        Text(
          '$selectedCount people selected',
          style: AppTypography.caption.copyWith(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 12),

        // Member Selection Cards
        for (final member in filteredMembers) ...[
          _buildMemberSelectTile(member),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildMemberSelectTile(Map<String, dynamic> member) {
    final bool isSelected = member['selected'] == true;
    final String name = member['name'] as String;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            member['selected'] = !isSelected;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.semanticYellow,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: AppIcon(
                    Iconsax.user5,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
              ),
              Text(
                isSelected ? 'Selected' : 'Select',
                style: AppTypography.caption.copyWith(
                  color: isSelected ? AppColors.primaryNavy : AppColors.shayne,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= STEP 3: REVIEW =================
  Widget _buildStep3Review() {
    final groupName = _nameController.text.trim().isEmpty
        ? 'Weekend Wanderers'
        : _nameController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? 'For our weekend escapes and spontaneous trips.'
        : _descriptionController.text.trim();
    final invited = _invitedMembers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ready to make it official?',
          style: AppTypography.h3.copyWith(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Check your group details before creating it.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.secondaryDark,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 20),

        // Yellow Group Card matching Figma
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.semanticYellow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondaryDark, width: 2.0),
                    ),
                    child: const Center(
                      child: AppIcon(
                        Iconsax.profile_2user5,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'You · Organizer',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondaryDark,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Edit group details button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _currentStep = 1),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondaryDark, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.secondaryDark,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Edit group details',
                  style: AppTypography.buttonMedium.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Invited members card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${invited.length} people to invite',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              if (invited.isEmpty)
                Text(
                  'No members selected yet.',
                  style: AppTypography.caption.copyWith(color: AppColors.shayne),
                )
              else
                for (final m in invited) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      m['name'] as String,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.secondaryDark,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              const SizedBox(height: 10),
              Text(
                'They’ll join once they accept your invitation.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondaryDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Bottom action buttons depending on step
  Widget _buildBottomActions() {
    if (_currentStep == 1) {
      return _buildNeobrutalistButton(
        text: 'Continue',
        backgroundColor: AppColors.primaryNavy,
        textColor: AppColors.white,
        onTap: _nextStep,
      );
    } else if (_currentStep == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNeobrutalistButton(
            text: 'Continue',
            backgroundColor: AppColors.primaryNavy,
            textColor: AppColors.white,
            onTap: _nextStep,
          ),
          const SizedBox(height: 12),
          _buildNeobrutalistButton(
            text: 'Skip for now',
            backgroundColor: AppColors.secondaryLight,
            textColor: AppColors.secondaryDark,
            onTap: _nextStep,
          ),
        ],
      );
    } else if (_currentStep == 3) {
      return _buildNeobrutalistButton(
        text: 'Create Group',
        icon: Iconsax.profile_2user5,
        backgroundColor: AppColors.primaryNavy,
        textColor: AppColors.white,
        onTap: () {
          setState(() {
            _currentStep = 4;
          });
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildNeobrutalistButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                AppIcon(icon, color: textColor, size: 22),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AppTypography.buttonLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= STEP 4: CONFIRMATION / CREATED =================
  Widget _buildConfirmationScreen() {
    final groupName = _nameController.text.trim().isEmpty
        ? 'Weekend Wanderers'
        : _nameController.text.trim();
    final invitedCount = _invitedMembers.length;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 155,
                height: 155,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: ShieldCheckIcon(size: 78),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Your group is ready!',
                textAlign: TextAlign.center,
                style: AppTypography.h2.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$groupName has been created. Invitations were sent to $invitedCount people.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryDark,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              _buildNeobrutalistButton(
                text: 'View Group',
                backgroundColor: AppColors.primaryNavy,
                textColor: AppColors.white,
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    AppRoutes.groupOverview,
                    arguments: groupName,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
