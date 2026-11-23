/// Invitation response status for a trip participant.
enum TripResponseStatus {
  going,
  notGoing,
  pending,
}

extension TripResponseStatusLabel on TripResponseStatus {
  String get label {
    switch (this) {
      case TripResponseStatus.going:
        return 'Going';
      case TripResponseStatus.notGoing:
        return 'Not Going';
      case TripResponseStatus.pending:
        return 'Pending';
    }
  }
}

/// Filter options for the Invitation Responses list.
enum TripResponseFilter {
  all,
  going,
  notGoing,
  pending,
}

extension TripResponseFilterLabel on TripResponseFilter {
  String get label {
    switch (this) {
      case TripResponseFilter.all:
        return 'All';
      case TripResponseFilter.going:
        return 'Going';
      case TripResponseFilter.notGoing:
        return 'Not Going';
      case TripResponseFilter.pending:
        return 'Pending';
    }
  }

  bool matches(TripResponseStatus status) {
    switch (this) {
      case TripResponseFilter.all:
        return true;
      case TripResponseFilter.going:
        return status == TripResponseStatus.going;
      case TripResponseFilter.notGoing:
        return status == TripResponseStatus.notGoing;
      case TripResponseFilter.pending:
        return status == TripResponseStatus.pending;
    }
  }
}

/// Model representing a participant in a trip and their invitation response state.
class TripParticipant {
  final String id;
  final String name;
  final String username;
  final TripResponseStatus status;
  final bool isNudged;
  final bool isOrganizer;

  const TripParticipant({
    required this.id,
    required this.name,
    required this.username,
    required this.status,
    this.isNudged = false,
    this.isOrganizer = false,
  });

  String get handle => username.startsWith('@') ? username : '@$username';

  TripParticipant copyWith({
    String? id,
    String? name,
    String? username,
    TripResponseStatus? status,
    bool? isNudged,
    bool? isOrganizer,
  }) {
    return TripParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      status: status ?? this.status,
      isNudged: isNudged ?? this.isNudged,
      isOrganizer: isOrganizer ?? this.isOrganizer,
    );
  }
}

/// Default seed participants matching Figma screens 07.07 and 07.09.
const List<TripParticipant> defaultTripParticipants = [
  TripParticipant(
    id: 'p-1',
    name: 'Louielyn Abella',
    username: 'blackxswann',
    status: TripResponseStatus.going,
  ),
  TripParticipant(
    id: 'p-2',
    name: 'Hannah S. Labandero',
    username: 'hannah.l',
    status: TripResponseStatus.going,
  ),
  TripParticipant(
    id: 'p-3',
    name: 'Carla Santos',
    username: 'carla.s',
    status: TripResponseStatus.notGoing,
  ),
  TripParticipant(
    id: 'p-4',
    name: 'Jessa',
    username: 'jessa.c',
    status: TripResponseStatus.pending,
    isNudged: true,
  ),
  TripParticipant(
    id: 'p-5',
    name: 'Nico',
    username: 'nico.t',
    status: TripResponseStatus.pending,
  ),
  TripParticipant(
    id: 'p-6',
    name: 'Ana',
    username: 'ana.p',
    status: TripResponseStatus.pending,
  ),
  TripParticipant(
    id: 'p-7',
    name: 'Mika',
    username: 'mika.s',
    status: TripResponseStatus.pending,
  ),
  TripParticipant(
    id: 'p-8',
    name: 'Paolo',
    username: 'paolo.r',
    status: TripResponseStatus.pending,
  ),
  TripParticipant(
    id: 'p-9',
    name: 'Ella',
    username: 'ella.b',
    status: TripResponseStatus.pending,
  ),
  TripParticipant(
    id: 'p-10',
    name: 'John',
    username: 'john.m',
    status: TripResponseStatus.pending,
  ),
];
