import 'package:flutter/material.dart';

import '../../services/trips_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/trip_widgets.dart';

/// Who is on the trip, who organizes it, and who is sharing their location.
class MembersScreen extends StatelessWidget {
  const MembersScreen({
    super.key,
    required this.tripId,
    TripsRepository? repository,
  }) : _repository = repository;

  final String tripId;
  final TripsRepository? _repository;

  @override
  Widget build(BuildContext context) {
    final repo = _repository ?? TripsRepository.instance;
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final trip = repo.tripById(tripId);
        if (trip == null) {
          return const Scaffold(
            body: Center(child: Text('This trip no longer exists.')),
          );
        }
        final members = trip.group.members;
        final sharing = {for (final l in trip.memberLocations) l.memberId};
        return Scaffold(
          appBar: const TitleBar(title: 'Members'),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(15, 24, 15, 28),
            children: [
              Text(
                '${trip.group.name} · ${members.length} members',
                style: const TextStyle(fontSize: 13, color: AppColors.ink),
              ),
              const SizedBox(height: 16),
              if (members.isEmpty)
                const EmptyCard(message: 'No members in this group yet.')
              else
                for (final m in members) ...[
                  OutlinedCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const MemberAvatar(),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.displayName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sharing.contains(m.id)
                                    ? 'Sharing location'
                                    : 'Not sharing location',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: TripColors.navIdle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (m.id == trip.organizerId)
                          const CategoryChip('Organizer'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
            ],
          ),
        );
      },
    );
  }
}
