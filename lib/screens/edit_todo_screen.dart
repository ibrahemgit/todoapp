import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import '../utils/app_router.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';

class EditTodoScreen extends ConsumerStatefulWidget {
  final String todoId;

  const EditTodoScreen({
    super.key,
    required this.todoId,
  });

  @override
  ConsumerState<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends ConsumerState<EditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TodoPriority _selectedPriority = TodoPriority.medium;
  TodoStatus _selectedStatus = TodoStatus.pending;
  DateTime? _selectedDueDate;
  DateTime? _selectedReminderTime;
  bool _isRepeating = false;
  RepeatingType? _selectedRepeatingType;

  @override
  void initState() {
    super.initState();
    _loadTodo();
  }

  void _loadTodo() {
    final todos = ref.read(todoListProvider);
    final todo = todos.firstWhere((t) => t.id == widget.todoId);
    
    _titleController.text = todo.title;
    _descriptionController.text = todo.description ?? '';
    _selectedPriority = todo.priority;
    _selectedStatus = todo.status;
    _selectedDueDate = todo.dueDate;
    _selectedReminderTime = todo.reminderTime;
    _isRepeating = todo.isRepeating;
    _selectedRepeatingType = todo.repeatingType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Todo'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goToHome(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveTodo,
            child: const Text('Save'),
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

              // Status Selection
              _buildStatusSelection(),
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
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Title *',
        hintText: 'Enter todo title',
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Title is required';
        }
        if (value.length > AppConstants.maxTodoTitleLength) {
          return 'Title must be less than ${AppConstants.maxTodoTitleLength} characters';
        }
        return null;
      },
      maxLength: AppConstants.maxTodoTitleLength,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Enter todo description (optional)',
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      maxLength: AppConstants.maxTodoDescriptionLength,
      validator: (value) {
        if (value != null && value.length > AppConstants.maxTodoDescriptionLength) {
          return 'Description must be less than ${AppConstants.maxTodoDescriptionLength} characters';
        }
        return null;
      },
    );
  }


  Widget _buildPrioritySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TodoPriority.values.map((priority) {
            final isSelected = _selectedPriority == priority;
            return FilterChip(
              label: Text(priority.toString().split('.').last.toUpperCase()),
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

  Widget _buildStatusSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TodoStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            return FilterChip(
              label: Text(status.toString().split('.').last.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = status;
                });
              },
              selectedColor: AppTheme.getStatusColor(status).withOpacity(0.2),
              checkmarkColor: AppTheme.getStatusColor(status),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDueDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
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
                      : 'Select due date (optional)',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Time',
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
                      : 'Select reminder time (optional)',
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
              'Repeating Todo',
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
              return FilterChip(
                label: Text(type.toString().split('.').last.toUpperCase()),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTodo,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Update Todo'),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
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
      initialTime: _selectedReminderTime != null 
          ? TimeOfDay.fromDateTime(_selectedReminderTime!)
          : TimeOfDay.now(),
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

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
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
        id: widget.todoId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _selectedPriority,
        status: _selectedStatus,
        dueDate: finalDueDate,
        reminderTime: finalReminderTime,
        isRepeating: _isRepeating,
        repeatingType: _selectedRepeatingType,
      );

      ref.read(todoListProvider.notifier).updateTodo(todo);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todo updated successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      AppRouter.goToHome(context);
    }
  }
}
