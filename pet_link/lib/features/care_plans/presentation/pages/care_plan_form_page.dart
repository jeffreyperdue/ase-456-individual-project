import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pets/domain/pet.dart';
import '../../domain/care_plan.dart';
import '../../domain/feeding_schedule.dart';
import '../../domain/medication.dart';
import '../widgets/feeding_schedule_widget.dart';
import '../widgets/medication_widget.dart';
import '../widgets/notification_status_widget.dart';
import '../../application/care_plan_form_provider.dart';
import '../../application/care_plan_provider.dart';
import '../../application/providers.dart';
import '../../../auth/presentation/state/auth_provider.dart';
import 'package:petfolio/services/error_handler.dart';
import 'package:petfolio/app/utils/feedback_utils.dart';
import 'package:petfolio/app/widgets/loading_widgets.dart';

/// Page for creating and editing care plans.
class CarePlanFormPage extends ConsumerStatefulWidget {
  final Pet pet;
  final CarePlan? existingCarePlan;

  const CarePlanFormPage({super.key, required this.pet, this.existingCarePlan});

  @override
  ConsumerState<CarePlanFormPage> createState() => _CarePlanFormPageState();
}

class _CarePlanFormPageState extends ConsumerState<CarePlanFormPage> {
  late TextEditingController _dietController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _dietController = TextEditingController(
      text: widget.existingCarePlan?.dietText ?? '',
    );

    // Load existing care plan data into form
    if (widget.existingCarePlan != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(carePlanFormProvider.notifier)
            .loadFromCarePlan(widget.existingCarePlan!);
      });
    }
  }

  @override
  void dispose() {
    _dietController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(carePlanFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingCarePlan != null
              ? 'Edit Care Plan'
              : 'Create Care Plan',
        ),
        actions: [
          if (widget.existingCarePlan != null)
            IconButton(
              onPressed: _showDeleteDialog,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete care plan',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet info card
              _buildPetInfoCard(),

              const SizedBox(height: 24),

              // Diet section
              _buildDietSection(),

              const SizedBox(height: 24),

              // Feeding schedules section
              _buildFeedingSchedulesSection(),

              const SizedBox(height: 24),

              // Medications section
              _buildMedicationsSection(),

              const SizedBox(height: 24),

              // Notifications status
              const NotificationStatusWidget(),

              const SizedBox(height: 24),

              // Validation errors
              if (formState.validationErrors.isNotEmpty)
                _buildValidationErrors(),

              const SizedBox(height: 24),

              // Save button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  widget.pet.photoUrl != null
                      ? NetworkImage(widget.pet.photoUrl!)
                      : null,
              child:
                  widget.pet.photoUrl == null
                      ? Text(
                        widget.pet.name.isNotEmpty
                            ? widget.pet.name[0].toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.headlineSmall,
                      )
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pet.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${widget.pet.species}${widget.pet.breed != null ? ' • ${widget.pet.breed}' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diet Information',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Provide details about your pet\'s diet, feeding preferences, and any dietary restrictions.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dietController,
          decoration: const InputDecoration(
            labelText: 'Diet Details',
            hintText:
                'Describe your pet\'s diet, food preferences, allergies, etc.',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          onChanged: (value) {
            ref.read(carePlanFormProvider.notifier).updateDietText(value);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Diet information is required';
            }
            if (value.length > 2000) {
              return 'Diet information must be less than 2000 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFeedingSchedulesSection() {
    final formState = ref.watch(carePlanFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Feeding Schedules',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton.icon(
              onPressed: _addFeedingSchedule,
              icon: const Icon(Icons.add),
              label: const Text('Add Schedule'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Set up regular feeding times for your pet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // Feeding schedules
        if (formState.feedingSchedules.isEmpty)
          _buildEmptyState(
            icon: Icons.restaurant,
            title: 'No Feeding Schedules',
            subtitle: 'Add your first feeding schedule to get started',
            actionText: 'Add Schedule',
            onAction: _addFeedingSchedule,
          )
        else
          ...formState.feedingSchedules.asMap().entries.map((entry) {
            final index = entry.key;
            final schedule = entry.value;

            return FeedingScheduleWidget(
              key: ValueKey(schedule.id),
              initialSchedule: schedule,
              onScheduleChanged: (updatedSchedule) {
                ref
                    .read(carePlanFormProvider.notifier)
                    .updateFeedingSchedule(index, updatedSchedule);
              },
              onRemove:
                  formState.feedingSchedules.length > 1
                      ? () {
                        ref
                            .read(carePlanFormProvider.notifier)
                            .removeFeedingSchedule(index);
                      }
                      : null,
            );
          }).toList(),
      ],
    );
  }

  Widget _buildMedicationsSection() {
    final formState = ref.watch(carePlanFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Medications',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton.icon(
              onPressed: _addMedication,
              icon: const Icon(Icons.medication),
              label: const Text('Add Medication'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Track your pet\'s medications and dosing schedules.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // Medications
        if (formState.medications.isEmpty)
          _buildEmptyState(
            icon: Icons.medication_outlined,
            title: 'No Medications',
            subtitle: 'Add medications if your pet takes any regularly',
            actionText: 'Add Medication',
            onAction: _addMedication,
          )
        else
          ...formState.medications.asMap().entries.map((entry) {
            final index = entry.key;
            final medication = entry.value;

            return MedicationWidget(
              key: ValueKey(medication.id),
              initialMedication: medication,
              onMedicationChanged: (updatedMedication) {
                ref
                    .read(carePlanFormProvider.notifier)
                    .updateMedication(index, updatedMedication);
              },
              onRemove: () {
                ref.read(carePlanFormProvider.notifier).removeMedication(index);
              },
            );
          }).toList(),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(icon),
              label: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationErrors() {
    final formState = ref.watch(carePlanFormProvider);

    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Please fix the following issues:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...formState.validationErrors.map(
              (error) => Padding(
                padding: const EdgeInsets.only(left: 24, top: 4),
                child: Text(
                  '• $error',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final formState = ref.watch(carePlanFormProvider);

    return SizedBox(
      width: double.infinity,
      child: LoadingWidgets.loadingButton(
        text: widget.existingCarePlan != null
            ? 'Update Care Plan'
            : 'Create Care Plan',
        onPressed: formState.isValid && !formState.isSubmitting ? _saveCarePlan : null,
        isLoading: formState.isSubmitting,
      ),
    );
  }

  void _addFeedingSchedule() {
    final schedule = FeedingSchedule(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      times: [],
      active: true,
    );

    ref.read(carePlanFormProvider.notifier).addFeedingSchedule(schedule);
  }

  void _addMedication() {
    final medication = Medication(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: '',
      dosage: '',
      times: [],
      active: true,
    );

    ref.read(carePlanFormProvider.notifier).addMedication(medication);
  }

  Future<void> _saveCarePlan() async {
    if (!_formKey.currentState!.validate()) return;

    final formNotifier = ref.read(carePlanFormProvider.notifier);
    final carePlanNotifier = ref.read(
      carePlanForPetProvider(widget.pet.id).notifier,
    );
    final currentUser = ref.read(currentUserDataProvider);

    if (currentUser == null) {
      FeedbackUtils.showError(context, 'You must be signed in to save care plans', customMessage: 'You must be signed in to save care plans');
      return;
    }

    formNotifier.setSubmitting(true);

    try {
      final formState = ref.read(carePlanFormProvider);
      final carePlan = formState.toCarePlan(
        id: widget.existingCarePlan?.id ?? '${widget.pet.id}_care_plan',
        petId: widget.pet.id,
        ownerId: currentUser.id,
      );

      if (widget.existingCarePlan != null) {
        await carePlanNotifier.updateCarePlan(carePlan);
        FeedbackUtils.showSuccess(context, 'Care plan updated successfully!');
      } else {
        await carePlanNotifier.createCarePlan(carePlan);
        FeedbackUtils.showSuccess(context, 'Care plan created successfully!');
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ErrorHandler.handleError(context, e);
    } finally {
      formNotifier.setSubmitting(false);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Care Plan'),
            content: const Text(
              'Are you sure you want to delete this care plan? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteCarePlan();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteCarePlan() async {
    if (widget.existingCarePlan == null) return;

    final carePlanNotifier = ref.read(
      carePlanForPetProvider(widget.pet.id).notifier,
    );

    try {
      await carePlanNotifier.deleteCarePlan(widget.existingCarePlan!.id);
      FeedbackUtils.showSuccess(context, 'Care plan deleted successfully');

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ErrorHandler.handleError(context, e);
    }
  }

}
