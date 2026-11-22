import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../trips/data/trip_repository.dart';
import '../../data/ai_itinerary_service.dart';
import '../widgets/itinerary_widgets.dart';

/// What the user chose on the "AI Suggestions Added" screen.
enum AiItineraryFlowAction { viewItinerary, backToTrip }

/// Result popped by [AiItineraryFlowScreen]. `null` means the user cancelled
/// and nothing was saved.
class AiItineraryFlowResult {
  final AiItineraryFlowAction action;
  final List<ItineraryItemModel> savedItems;

  const AiItineraryFlowResult({required this.action, required this.savedItems});
}

enum _FlowStage { generating, failed, review, success }

/// Full-screen AI itinerary flow:
/// 08.05 generating → (failure + retry) → 08.06 review → 08.07 success.
///
/// Push it after [showGenerateWithAiSheet] returns a scope:
/// ```dart
/// final result = await Navigator.of(context).push<AiItineraryFlowResult>(
///   MaterialPageRoute(builder: (_) => AiItineraryFlowScreen(request: req)),
/// );
/// ```
class AiItineraryFlowScreen extends StatefulWidget {
  final AiItineraryRequest request;

  /// Calendar dates for Day 1…N, used for the "Saturday, November 14" label.
  final List<DateTime> tripDays;

  /// Defaults to [defaultAiItineraryService].
  final AiItineraryService? service;

  /// Defaults to [TripRepository.instance.saveItineraryItems].
  final Future<List<ItineraryItemModel>> Function(List<ItineraryItemModel>)?
      saveItems;

  /// Delay between checklist steps on the loading screen.
  final Duration stepInterval;

  const AiItineraryFlowScreen({
    super.key,
    required this.request,
    this.tripDays = const [],
    this.service,
    this.saveItems,
    this.stepInterval = const Duration(milliseconds: 900),
  });

  @override
  State<AiItineraryFlowScreen> createState() => _AiItineraryFlowScreenState();
}

class _AiItineraryFlowScreenState extends State<AiItineraryFlowScreen> {
  static const _steps = [
    ('Checking group preferences', 'Looking at everyone\'s travel style'),
    ('Checking availability', 'Working around your existing plans'),
    ('Finding places to go', 'Picking spots around your destination'),
    ('Planning activities', 'Matching ideas to your group\'s interests'),
    ('Building your schedule', 'Putting everything in order'),
  ];

  _FlowStage _stage = _FlowStage.generating;
  int _completedSteps = 0;
  Timer? _stepTimer;
  int _attempt = 0;
  String _errorMessage = '';

  List<AiItinerarySuggestion> _suggestions = [];
  int _dayIndex = 0;
  bool _isSaving = false;
  List<ItineraryItemModel> _savedItems = const [];

  AiItineraryService get _service =>
      widget.service ?? defaultAiItineraryService;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  Future<void> _generate() async {
    final attempt = ++_attempt;
    setState(() {
      _stage = _FlowStage.generating;
      _completedSteps = 0;
    });

    _stepTimer?.cancel();
    _stepTimer = Timer.periodic(widget.stepInterval, (_) {
      // The final step only completes once the AI has actually answered.
      if (_completedSteps < _steps.length - 1) {
        setState(() => _completedSteps++);
      }
    });

    try {
      final suggestions = await _service.generate(widget.request);
      if (!mounted || attempt != _attempt) return;
      _stepTimer?.cancel();
      setState(() => _completedSteps = _steps.length);
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted || attempt != _attempt) return;
      setState(() {
        _suggestions = List.of(suggestions)
          ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
        _dayIndex = 0;
        _stage = _FlowStage.review;
      });
    } catch (e) {
      if (!mounted || attempt != _attempt) return;
      _stepTimer?.cancel();
      setState(() {
        _errorMessage = e is AiItineraryException
            ? e.message
            : 'Something went wrong while creating your itinerary. '
                'Please try again.';
        _stage = _FlowStage.failed;
      });
    }
  }

  // ---------------------------------------------------------------- review

  List<int> get _reviewDays => widget.request.targetDays;

  int get _currentDay => _reviewDays[_dayIndex];

  List<AiItinerarySuggestion> get _currentDaySuggestions =>
      _suggestions.where((s) => s.dayNumber == _currentDay).toList();

  DateTime? _dateFor(int day) =>
      day - 1 < widget.tripDays.length ? widget.tripDays[day - 1] : null;

  void _remove(AiItinerarySuggestion suggestion) {
    final index = _suggestions.indexOf(suggestion);
    setState(() => _suggestions.removeAt(index));

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Removed "${suggestion.title}"'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            if (!mounted) return;
            setState(() => _suggestions.insert(
                  index.clamp(0, _suggestions.length),
                  suggestion,
                ));
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_suggestions.isEmpty || _isSaving) return;
    setState(() => _isSaving = true);
    final items = _suggestions
        .map((s) => s.toItineraryItem(tripId: widget.request.tripId))
        .toList();
    try {
      final save =
          widget.saveItems ?? TripRepository.instance.saveItineraryItems;
      final saved = await save(items);
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        _savedItems = saved;
        _isSaving = false;
        _stage = _FlowStage.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t save these suggestions. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _finish(AiItineraryFlowAction action) {
    Navigator.of(context).pop(
      AiItineraryFlowResult(action: action, savedItems: _savedItems),
    );
  }

  // ----------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (_stage) {
      case _FlowStage.generating:
        body = _buildGenerating();
        break;
      case _FlowStage.failed:
        body = _buildFailed();
        break;
      case _FlowStage.review:
        body = _buildReview();
        break;
      case _FlowStage.success:
        body = _buildSuccess();
        break;
    }

    return PopScope(
      // After saving, leaving goes through the result buttons so the caller
      // always learns that items were added.
      canPop: _stage != _FlowStage.success,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _stage == _FlowStage.success) {
          _finish(AiItineraryFlowAction.backToTrip);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: KeyedSubtree(key: ValueKey(_stage), child: body),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerating() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(36, 72, 36, 32),
      child: Column(
        children: [
          const ItineraryHeroCircle(
            icon: Iconsax.map5,
            color: AppColors.primaryNavy,
          ),
          const SizedBox(height: 26),
          Text(
            'Creating your itinerary...',
            textAlign: TextAlign.center,
            style: AppTypography.h3.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI is putting together the best options for your group.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.secondaryDark,
            ),
          ),
          const SizedBox(height: 30),
          for (var i = 0; i < _steps.length; i++) ...[
            _ChecklistRow(
              title: _steps[i].$1,
              subtitle: _steps[i].$2,
              done: i < _completedSteps,
              active: i == _completedSteps,
            ),
            if (i < _steps.length - 1) const SizedBox(height: 22),
          ],
        ],
      ),
    );
  }

  Widget _buildFailed() {
    return _CenteredStatus(
      illustration: const ItineraryHeroCircle(icon: Iconsax.warning_25),
      title: 'We couldn\'t create your itinerary',
      message: _errorMessage,
      primary: AppButton(
        text: 'Try Again',
        customHeight: 51,
        borderRadius: 16,
        iconLeading: const AppIcon(
          Iconsax.refresh5,
          size: 20,
          color: AppColors.white,
        ),
        onPressed: _generate,
      ),
      secondary: AppButton(
        text: 'Cancel',
        variant: AppButtonVariant.secondary,
        customHeight: 51,
        borderRadius: 16,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildReview() {
    final daySuggestions = _currentDaySuggestions;
    final day = _currentDay;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 0),
          child: ItineraryDayHeader(
            dayNumber: day,
            dayCount: widget.request.dayCount,
            date: _dateFor(day),
            onPrevious:
                _dayIndex > 0 ? () => setState(() => _dayIndex--) : null,
            onNext: _dayIndex < _reviewDays.length - 1
                ? () => setState(() => _dayIndex++)
                : null,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(17, 24, 17, 24),
            children: [
              const AiNoticeBox(
                title: 'AI-generated itinerary',
                message: 'Review these recommendations before adding them '
                    'to your trip. Remove any you don\'t want, then save the '
                    'rest to your itinerary.',
              ),
              const SizedBox(height: 23),
              if (daySuggestions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    _suggestions.isEmpty
                        ? 'You removed every suggestion. Cancel to go back, '
                            'or undo a removal to keep it.'
                        : 'No suggestions left for Day $day.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium,
                  ),
                )
              else
                for (final s in daySuggestions) ...[
                  AiSuggestionCard(
                    key: ValueKey(s.id),
                    suggestion: s,
                    onRemove: () => _remove(s),
                  ),
                  const SizedBox(height: 24),
                ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            children: [
              AppButton(
                text: 'Save',
                customHeight: 50,
                borderRadius: 16,
                isLoading: _isSaving,
                isDisabled: _suggestions.isEmpty,
                onPressed: _save,
              ),
              const SizedBox(height: 14),
              AppButton(
                text: 'Cancel',
                variant: AppButtonVariant.secondary,
                customHeight: 54,
                borderRadius: 16,
                isDisabled: _isSaving,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return _CenteredStatus(
      illustration: const AppIcon(
        Iconsax.verify5,
        size: 150,
        color: AppColors.primaryOrange,
      ),
      title: 'AI Suggestions Added',
      message: 'Your selected recommendations have been added to your trip '
          'itinerary.',
      primary: AppButton(
        text: 'View Itinerary',
        customHeight: 51,
        borderRadius: 16,
        onPressed: () => _finish(AiItineraryFlowAction.viewItinerary),
      ),
      secondary: AppButton(
        text: 'Back to Trip',
        variant: AppButtonVariant.secondary,
        customHeight: 51,
        borderRadius: 16,
        onPressed: () => _finish(AiItineraryFlowAction.backToTrip),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final bool active;

  const _ChecklistRow({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.primaryNavy : kItineraryMutedBlue;
    return Row(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: active
              ? const Padding(
                  padding: EdgeInsets.all(5),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: kItineraryMutedBlue,
                  ),
                )
              : AppIcon(Iconsax.tick_circle5, size: 32, color: color),
        ),
        const SizedBox(width: 21),
        Expanded(
          child: Opacity(
            opacity: done || active ? 1 : 0.55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.black,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Illustration + title + message + two stacked buttons (success / failure).
class _CenteredStatus extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String message;
  final Widget primary;
  final Widget secondary;

  const _CenteredStatus({
    required this.illustration,
    required this.title,
    required this.message,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    illustration,
                    const SizedBox(height: 40),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.h1.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          primary,
          const SizedBox(height: 16),
          secondary,
        ],
      ),
    );
  }
}
