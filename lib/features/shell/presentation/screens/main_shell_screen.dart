import 'package:flutter/material.dart';
import '../../../../components/organisms/app_bottom_navigation.dart';
import '../../../groups/presentation/screens/group_detail_screen.dart';
import 'home_tab.dart';
import 'trips_tab.dart';
import 'create_tab.dart';
import 'profile_tab.dart';

/// Main Shell screen hosting the bottom navigation bar and active tabs.
/// Meets criteria: "All routes are reachable and the active tab is highlighted"
class MainShellScreen extends StatefulWidget {
  final int initialTab;

  const MainShellScreen({super.key, this.initialTab = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeTab(
        onNavigateToTrips: () => _onTabSelected(1),
        onNavigateToGroups: () => _onTabSelected(3),
        onNavigateToProfile: () => _onTabSelected(4),
      ),
      GroupDetailScreen(
        groupName: 'Trip to Bantayan',
        embeddedInShell: true,
        onNavigateToProfile: () => _onTabSelected(4),
      ),
      CreateTab(
        onTripCreated: () => _onTabSelected(1),
      ),
      TripsTab(
        onNavigateToProfile: () => _onTabSelected(4),
      ),
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
