enum GroupRole { organizer, member }

extension GroupRoleX on GroupRole {
  bool get isOrganizer => this == GroupRole.organizer;
  String get label => isOrganizer ? 'Organizer' : 'Member';
}

class GroupDetailArgs {
  final String groupName;
  final GroupRole role;
  const GroupDetailArgs(this.groupName, this.role);
}
