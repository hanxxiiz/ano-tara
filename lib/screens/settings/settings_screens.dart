import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../components/atoms/app_avatar.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_input_field.dart';
import '../../components/molecules/settings_card.dart';
import '../../components/organisms/app_top_bar.dart';
import '../../components/organisms/delete_account_modal.dart';

void _message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.title,
    required this.children,
    this.footer,
  });
  final String title;
  final List<Widget> children;
  final Widget? footer;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppTopBar(title: title),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 72).clamp(0, double.infinity),
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...children,
                  if (footer != null) ...[
                    const SizedBox(height: 32),
                    const Spacer(),
                    footer!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _heading(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: Text(
    text,
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  ),
);
Widget _intro(String title, String subtitle) => Padding(
  padding: const EdgeInsets.only(bottom: 30),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      Text(subtitle, style: const TextStyle(fontSize: 13)),
    ],
  ),
);
Widget _link(
  BuildContext context,
  String title,
  String subtitle,
  String route,
) => Padding(
  padding: const EdgeInsets.only(bottom: 20),
  child: SettingsCard(
    onTap: () => Navigator.pushNamed(context, route),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, size: 22),
      ],
    ),
  ),
);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => SettingsPage(
    title: 'Settings',
    children: [
      _heading('ACCOUNT'),
      _link(
        context,
        'Personal Information',
        'Edit name, username and photo',
        AppRoutes.personalInformation,
      ),
      _link(
        context,
        'Account & Security',
        'Email, password and account deletion',
        AppRoutes.accountSecurity,
      ),
      _link(
        context,
        'Manage Subscription',
        'Plan and billing options',
        AppRoutes.subscription,
      ),
      const SizedBox(height: 12),
      _heading('GENERAL'),
      const SizedBox(height: 6),
      _link(
        context,
        'Help & Support',
        'Get help and contact support',
        AppRoutes.helpSupport,
      ),
    ],
    footer: AppButton(
      text: 'Log Out',
      variant: AppButtonVariant.destructive,
      iconTrailing: const Icon(Icons.logout, color: Colors.white),
      onPressed: () async {
        try {
          await Supabase.instance.client.auth.signOut();
          if (context.mounted)
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.welcome,
              (_) => false,
            );
        } catch (_) {
          if (context.mounted)
            _message(context, 'Unable to log out. Please try again.');
        }
      },
    ),
  );
}

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});
  @override
  Widget build(BuildContext context) => SettingsPage(
    title: 'Account and Security',
    children: [
      _heading('ACCOUNT MANAGEMENT'),
      _link(
        context,
        'Change Email Address',
        'Update your email address.',
        AppRoutes.changeEmail,
      ),
      _link(
        context,
        'Change Password',
        'Update your account password.',
        AppRoutes.changePassword,
      ),
      SettingsCard(
        color: AppColors.primaryOrange,
        onTap: () => showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => DeleteAccountModal(
            onDelete: (_) async {
              // Requires a server-side endpoint that verifies the password and deletes
              // the authenticated user and associated data. Never use an admin key here.
              throw UnsupportedError(
                'Account deletion endpoint is not configured.',
              );
            },
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Permanently remove your account',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  );
}

enum SettingsFormType { personal, email, password }

class SettingsFormScreen extends StatefulWidget {
  const SettingsFormScreen({super.key, required this.type});
  final SettingsFormType type;
  @override
  State<SettingsFormScreen> createState() => _SettingsFormScreenState();
}

class _SettingsFormScreenState extends State<SettingsFormScreen> {
  final _form = GlobalKey<FormState>();
  final _fields = List.generate(3, (_) => TextEditingController());
  bool _busy = false;
  final _visible = [false, false, false];
  String? _avatar;
  User? get _user {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  bool get _personal => widget.type == SettingsFormType.personal;
  bool get _email => widget.type == SettingsFormType.email;
  @override
  void initState() {
    super.initState();
    final user = _user;
    if (_personal) {
      final data = user?.userMetadata;
      _fields[0].text = data?['first_name'] as String? ?? '';
      _fields[1].text = data?['last_name'] as String? ?? '';
      _fields[2].text = data?['username'] as String? ?? '';
      _avatar = data?['avatar_url'] as String?;
    } else if (_email) {
      _fields[0].text = user?.email ?? '';
    }
  }

  @override
  void dispose() {
    for (final field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> _editPhoto() async {
    final controller = TextEditingController(text: _avatar);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profile photo'),
        content: AppInputField(
          label: 'Photo URL',
          hint: 'https://…',
          controller: controller,
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              final uri = Uri.tryParse(value);
              if (value.isNotEmpty &&
                  (uri == null || uri.scheme != 'https' || uri.host.isEmpty)) {
                _message(context, 'Enter a valid HTTPS photo URL.');
                return;
              }
              Navigator.pop(context, value);
            },
            child: const Text('Use photo'),
          ),
        ],
      ),
    );
    // The dialog route finishes its closing animation before its field is disposed.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (result != null && mounted)
      setState(() => _avatar = result.isEmpty ? null : result);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_user == null) throw StateError('Not signed in');
      if (_personal) {
        await auth.updateUser(
          UserAttributes(
            data: {
              'first_name': _fields[0].text.trim(),
              'last_name': _fields[1].text.trim(),
              'username': _fields[2].text.trim(),
              'avatar_url': _avatar,
            },
          ),
        );
      } else if (_email) {
        await auth.updateUser(UserAttributes(email: _fields[1].text.trim()));
      } else {
        await auth.signInWithPassword(
          email: _user!.email!,
          password: _fields[0].text,
        );
        await auth.updateUser(UserAttributes(password: _fields[1].text));
      }
      if (mounted) {
        _message(
          context,
          _email
              ? 'Check your email to confirm the address change.'
              : 'Changes saved.',
        );
        if (!_personal && !_email) {
          for (final field in _fields) {
            field.clear();
          }
        }
      }
    } catch (_) {
      if (mounted)
        _message(
          context,
          'Unable to save changes. Check your details and try again.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = _personal
        ? ['First Name', 'Last Name', 'Username']
        : _email
        ? ['Current Email', 'New Email']
        : ['Current Password', 'New Password', 'Confirm New Password'];
    return SettingsPage(
      title: _personal ? 'Personal Information' : 'Account and Security',
      children: [
        _intro(
          _personal
              ? 'Edit Personal Information'
              : _email
              ? 'Edit Email Address'
              : 'Change Password',
          _personal
              ? 'Update your name, username, and profile photo.'
              : _email
              ? 'Update your email address and confirm the new one.'
              : 'Enter your current password and choose a new one.',
        ),
        if (_personal) ...[
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AppAvatar(
                  size: 106,
                  imageUrl: _avatar,
                  hasBorder: true,
                  backgroundColor: AppColors.secondaryLight,
                ),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: IconButton.filled(
                    onPressed: _busy ? null : _editPhoto,
                    tooltip: 'Edit profile photo',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      side: const BorderSide(
                        color: AppColors.secondaryDark,
                        width: 2,
                      ),
                    ),
                    icon: const Icon(Icons.edit, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
        Form(
          key: _form,
          child: Column(
            children: List.generate(
              labels.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: AppInputField(
                  label: labels[i],
                  controller: _fields[i],
                  isEnabled: !_busy,
                  isReadOnly: _email && i == 0,
                  keyboardType: _email
                      ? TextInputType.emailAddress
                      : TextInputType.text,
                  isPassword: !_personal && !_email && !_visible[i],
                  suffixIcon: !_personal && !_email
                      ? IconButton(
                          tooltip: _visible[i]
                              ? 'Hide password'
                              : 'Show password',
                          onPressed: () =>
                              setState(() => _visible[i] = !_visible[i]),
                          icon: Icon(
                            _visible[i]
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        )
                      : null,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty)
                      return 'This field is required.';
                    if (_email &&
                        !RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(value!.trim()))
                      return 'Enter a valid email address.';
                    if (_email &&
                        i == 1 &&
                        value!.trim() == _fields[0].text.trim())
                      return 'Enter a different email address.';
                    if (!_personal && !_email && i == 1 && value!.length < 8)
                      return 'Use at least 8 characters.';
                    if (!_personal &&
                        !_email &&
                        i == 2 &&
                        value != _fields[1].text)
                      return 'Passwords do not match.';
                    return null;
                  },
                ),
              ),
            ),
          ),
        ),
      ],
      footer: AppButton(
        text: 'Save Changes',
        isLoading: _busy,
        onPressed: _save,
      ),
    );
  }
}

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});
  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expanded = 0;
  static const _questions = [
    'How do I reset my password?',
    'Why is my payment still pending?',
    'How do I upgrade my subscription?',
    'How do I add members to my group?',
  ];
  static const _answers = [
    'Go to Settings → Account & Security → Change Password, then follow the instructions to update it.',
    'Payment confirmation may take time. Check with your payment provider before attempting another payment.',
    'Open Settings → Manage Subscription to check plan and billing availability.',
    'Open your group and use its invitation option to invite new members.',
  ];
  @override
  Widget build(BuildContext context) => SettingsPage(
    title: 'Help & Support',
    children: [
      _intro('How can we help?', 'Tap a question to view the answer.'),
      _heading('FREQUENTLY ASKED QUESTIONS'),
      ...List.generate(
        _questions.length,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: SettingsCard(
            onTap: () => setState(() => _expanded = _expanded == i ? null : i),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _questions[i],
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Icon(
                      _expanded == i
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
                if (_expanded == i) ...[
                  const Divider(height: 28),
                  Text(
                    _answers[i],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.carla,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      SettingsCard(
        color: const Color(0xFFE8F2F9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Still need a hand?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Have a question we missed? Reach out to our team.',
              style: TextStyle(fontSize: 13),
            ),
            const Divider(height: 28),
            AppButton(
              text: 'Contact Support',
              size: AppButtonSize.small,
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Contact Support'),
                  content: Text(
                    'Support contact details are not available yet. Please check back later.',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ],
  );
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});
  @override
  Widget build(BuildContext context) => SettingsPage(
    title: 'Manage Subscription',
    children: [
      _intro(
        'Plan and billing',
        'Manage your subscription and payment details.',
      ),
      const SettingsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription information unavailable',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text('Plan and billing management has not been connected yet.'),
          ],
        ),
      ),
    ],
  );
}
