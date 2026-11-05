import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../atoms/app_button.dart';
import '../atoms/app_input_field.dart';

/// Password confirmation UI. The caller supplies the secure deletion operation.
class DeleteAccountModal extends StatefulWidget {
  const DeleteAccountModal({super.key, required this.onDelete});
  final Future<void> Function(String password) onDelete;

  @override
  State<DeleteAccountModal> createState() => _DeleteAccountModalState();
}

class _DeleteAccountModalState extends State<DeleteAccountModal> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_password.text.isEmpty) {
      setState(() => _error = 'Enter your password to continue.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onDelete(_password.text);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'Unable to delete your account. Please try again or contact support.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.secondaryDark, width: 2),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton.outlined(
                  tooltip: 'Close',
                  onPressed: _busy ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
              const Icon(
                Icons.report_rounded,
                color: AppColors.primaryOrange,
                size: 80,
              ),
              const Text(
                'Delete your account?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'This action is permanent. Your account and its associated data will be deleted.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.carla),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),
              AppInputField(
                label: 'CONFIRM YOUR PASSWORD',
                hint: 'Enter your password',
                controller: _password,
                isPassword: true,
                isEnabled: !_busy,
                errorText: _error,
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Delete Account',
                variant: AppButtonVariant.destructive,
                isLoading: _busy,
                onPressed: _delete,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );
}
