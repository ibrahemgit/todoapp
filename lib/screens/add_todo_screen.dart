import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import '../utils/app_router.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';
import '../constants/app_localizations.dart';

class AddTodoScreen extends ConsumerStatefulWidget {
  const AddTodoScreen({super.key});

  @override
  ConsumerState<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends ConsumerState<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TodoPriority _selectedPriority = TodoPriority.medium;
  DateTime? _selectedDueDate;
  DateTime? _selectedReminderTime;
  bool _isRepeating = false;
  RepeatingType? _selectedRepeatingType;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addTodo),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goToHome(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveTodo,
            child: Text(l10n.save),
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
              // Title Field
              _buildTitleField(),
              const SizedBox(height: 16),

              // Description Field
              _buildDescriptionField(),
              const SizedBox(height: 16),

              // Priority Selection
              _buildPrioritySelection(),
              const SizedBox(height: 16),

              // Due Date Selection
              _buildDueDateSelection(),
              const SizedBox(height: 16),

              // Reminder Time Selection
              _buildReminderTimeSelection(),
              const SizedBox(height: 16),

              // Repeating Options
              _buildRepeatingOptions(),
              const SizedBox(height: 32),

              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    final l10n = AppLocalizations.of(context);
    
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: '${l10n.todoTitle} *',
        hintText: l10n.todoTitle,
        prefixIcon: const Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '${l10n.todoTitle} ${l10n.required}';
        }
        if (value.length > AppConstants.maxTodoTitleLength) {
          return '${l10n.todoTitle} ${l10n.mustBeLessThan} ${AppConstants.maxTodoTitleLength} ${l10n.characters}';
        }
        return null;
      },
      maxLength: AppConstants.maxTodoTitleLength,
    );
  }

  Widget _buildDescriptionField() {
    final l10n = AppLocalizations.of(context);
    
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: l10n.todoDescription,
        hintText: '${l10n.todoDescription} (${l10n.optional})',
        prefixIcon: const Icon(Icons.description),
      ),
      maxLines: 3,
      maxLength: AppConstants.maxTodoDescriptionLength,
      validator: (value) {
        if (value != null && value.length > AppConstants.maxTodoDescriptionLength) {
          return '${l10n.todoDescription} ${l10n.mustBeLessThan} ${AppConstants.maxTodoDescriptionLength} ${l10n.characters}';
        }
        return null;
      },
    );
  }


  Widget _buildPrioritySelection() {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.priority,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TodoPriority.values.map((priority) {
            final isSelected = _selectedPriority == priority;
            String priorityText;
            switch (priority) {
              case TodoPriority.low:
                priorityText = l10n.low;
                break;
              case TodoPriority.medium:
                priorityText = l10n.medium;
                break;
              case TodoPriority.high:
                priorityText = l10n.high;
                break;
              case TodoPriority.urgent:
                priorityText = l10n.urgent;
                break;
            }
            return FilterChip(
              label: Text(priorityText),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPriority = priority;
                });
              },
              selectedColor: AppTheme.getPriorityColor(priority).withOpacity(0.2),
              checkmarkColor: AppTheme.getPriorityColor(priority),
            );
          }).toList(),
        ),
      ],
    );
  }


  Widget _buildDueDateSelection() {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dueDate,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDueDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  _selectedDueDate != null
                      ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                      : '${l10n.selectDate} (${l10n.optional})',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _selectedDueDate != null
                        ? AppTheme.textPrimary
                        : AppTheme.textHint,
                  ),
                ),
                const Spacer(),
                if (_selectedDueDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedDueDate = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderTimeSelection() {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reminderTime,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectReminderTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: 12),
                Text(
                  _selectedReminderTime != null
                      ? '${_selectedReminderTime!.hour}:${_selectedReminderTime!.minute.toString().padLeft(2, '0')}'
                      : '${l10n.selectTime} (${l10n.optional})',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _selectedReminderTime != null
                        ? AppTheme.textPrimary
                        : AppTheme.textHint,
                  ),
                ),
                const Spacer(),
                if (_selectedReminderTime != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedReminderTime = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatingOptions() {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isRepeating,
              onChanged: (value) {
                setState(() {
                  _isRepeating = value ?? false;
                  if (!_isRepeating) {
                    _selectedRepeatingType = null;
                  } else {
                    _selectedRepeatingType = RepeatingType.daily;
                  }
                });
              },
            ),
            Text(
              '${l10n.repeating} ${l10n.todos}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (_isRepeating) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: RepeatingType.values.map((type) {
              final isSelected = _selectedRepeatingType == type;
              String typeText;
              switch (type) {
                case RepeatingType.daily:
                  typeText = l10n.daily;
                  break;
                case RepeatingType.weekly:
                  typeText = l10n.weekly;
                  break;
                case RepeatingType.monthly:
                  typeText = l10n.monthly;
                  break;
                case RepeatingType.yearly:
                  typeText = l10n.yearly;
                  break;
              }
              return FilterChip(
                label: Text(typeText),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedRepeatingType = type;
                  });
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }


  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTodo,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text('${l10n.save} ${l10n.todos}'),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
        
        // If reminder time is already selected, update it with the new date
        if (_selectedReminderTime != null) {
          _selectedReminderTime = DateTime(
            date.year,
            date.month,
            date.day,
            _selectedReminderTime!.hour,
            _selectedReminderTime!.minute,
          );
        }
      });
    }
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        // If no due date is selected, automatically set it to today
        if (_selectedDueDate == null) {
          _selectedDueDate = DateTime.now();
        }
        
        // Create the reminder time with the selected due date
        _selectedReminderTime = DateTime(
          _selectedDueDate!.year,
          _selectedDueDate!.month,
          _selectedDueDate!.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _saveTodo() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Determine the final due date and reminder time
        DateTime? finalDueDate = _selectedDueDate;
        DateTime? finalReminderTime = _selectedReminderTime;
        
        // If only reminder time is selected, set due date to today
        if (_selectedReminderTime != null && _selectedDueDate == null) {
          finalDueDate = DateTime.now();
          finalReminderTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            _selectedReminderTime!.hour,
            _selectedReminderTime!.minute,
          );
        }
        // If only due date is selected, set reminder time to 12:00 AM
        else if (_selectedDueDate != null && _selectedReminderTime == null) {
          finalReminderTime = DateTime(
            _selectedDueDate!.year,
            _selectedDueDate!.month,
            _selectedDueDate!.day,
            0, // 12:00 AM
            0,
          );
        }
        // If both are selected, ensure they're properly linked
        else if (_selectedDueDate != null && _selectedReminderTime != null) {
          finalReminderTime = DateTime(
            _selectedDueDate!.year,
            _selectedDueDate!.month,
            _selectedDueDate!.day,
            _selectedReminderTime!.hour,
            _selectedReminderTime!.minute,
          );
        }
        
        final todo = TodoModel(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          priority: _selectedPriority,
          status: TodoStatus.pending, // Default status
          dueDate: finalDueDate,
          reminderTime: finalReminderTime,
          isRepeating: _isRepeating,
          repeatingType: _selectedRepeatingType,
        );

        await ref.read(todoListProvider.notifier).addTodo(todo);
        
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.todoAddedSuccessfully),
              backgroundColor: AppTheme.successColor,
            ),
          );

          // Navigate back to home screen
          AppRouter.goToHome(context);
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.error} ${l10n.addTodo}: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }
}
