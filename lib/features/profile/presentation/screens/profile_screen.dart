import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app_routes.dart';
import '../../../../components/organisms/app_bottom_navigation.dart';
import '../../../../components/organisms/app_main_top_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_preference_icons.dart';
import '../../../../models/member_preferences.dart';
import '../../../../screens/onboarding/onboarding_steps.dart' show formatPeso;
import '../../data/profile_repository.dart';
import '../widgets/preference_category.dart';
import '../widgets/profile_widgets.dart';
import 'preference_detail_screens.dart';
import 'preference_screens.dart';

/// 12.01 — avatar, stats, current plan and the preferences list.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.repository});

  final ProfileRepository? repository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileRepository _repo =
      widget.repository ?? ProfileRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.load();
  }

  void _openCategory(PreferenceCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PreferenceViewScreen(category: category, repository: _repo),
      ),
    );
  }

  void _openDetail(PreferenceDetail detail) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PreferenceDetailViewScreen(detail: detail, repository: _repo),
      ),
    );
  }

  String _list(List<String> values) =>
      values.isEmpty ? 'None selected' : values.join(', ');

  List<ProfilePreferenceItem> _items(MemberPreferences p) {
    final pace = p.travelPace;
    return [
      ProfilePreferenceItem(
        title: PreferenceCategory.activities.title,
        value: _list(p.activities),
        icon: Iconsax.sun_15,
        onTap: () => _openCategory(PreferenceCategory.activities),
      ),
      ProfilePreferenceItem(
        title: PreferenceCategory.dietary.title,
        value: _list(p.dietaryPreferences),
        svgAsset: AppPreferenceIcons.assets['Food Trips'],
        onTap: () => _openCategory(PreferenceCategory.dietary),
      ),
      ProfilePreferenceItem(
        title: PreferenceCategory.allergies.title,
        value: _list(p.allergies),
        svgAsset: AppPreferenceIcons.assets['Seafood'],
        onTap: () => _openCategory(PreferenceCategory.allergies),
      ),
      ProfilePreferenceItem(
        title: PreferenceDetail.budget.title,
        value: formatPeso(p.budget),
        icon: Iconsax.wallet_25,
        onTap: () => _openDetail(PreferenceDetail.budget),
      ),
      ProfilePreferenceItem(
        title: PreferenceDetail.pace.title,
        value: pace == null || pace.isEmpty
            ? 'Not set'
            : '${pace[0].toUpperCase()}${pace.substring(1)}',
        icon: Iconsax.wind_25,
        onTap: () => _openDetail(PreferenceDetail.pace),
      ),
      ProfilePreferenceItem(
        title: PreferenceDetail.notes.title,
        value: p.notes.isEmpty ? 'No notes yet' : p.notes,
        icon: Iconsax.note_25,
        onTap: () => _openDetail(PreferenceDetail.notes),
      ),
    ];
  }

  void _onTab(int index) {
    if (index == 4) return;
    if (index == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    const names = ['Home', 'Trips', 'Create trip', 'Groups', 'Profile'];
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${names[index]} tapped')));
  }

  @override
  Widget build(BuildContext context) {
    final summary = _repo.summary;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppMainTopBar(
        onProfileTap: () {},
        onNotificationTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.notifications),
      ),
      body: ValueListenableBuilder<MemberPreferences>(
        valueListenable: _repo.preferences,
        builder: (context, prefs, _) => ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            ProfileHeader(
              summary: summary,
              onEditAvatar: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo editing is coming soon.')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileStatsCard(summary: summary),
                  const SizedBox(height: 28),
                  const ProfileSectionTitle('Current Plan'),
                  const SizedBox(height: 14),
                  CurrentPlanCard(
                    summary: summary,
                    onManageSubscription: () =>
                        Navigator.of(context).pushNamed(AppRoutes.subscription),
                  ),
                  const SizedBox(height: 34),
                  const ProfileSectionTitle('Preferences'),
                  const SizedBox(height: 14),
                  ProfilePreferencesCard(items: _items(prefs)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 4,
        onTabSelected: _onTab,
      ),
    );
  }
}
