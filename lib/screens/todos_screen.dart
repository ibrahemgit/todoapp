import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import '../utils/app_router.dart';
import '../constants/app_theme.dart';

class TodosScreen extends ConsumerStatefulWidget {
  final String filter;
  final String sort;

  const TodosScreen({
    super.key,
    required this.filter,
    required this.sort,
  });

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen> {
  @override
  void initState() {
    super.initState();
    // Set initial filter and sort
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todoFilterProvider.notifier).state = _getFilterFromString(widget.filter);
      ref.read(todoSortProvider.notifier).state = _getSortFromString(widget.sort);
    });
  }

  TodoFilter _getFilterFromString(String filter) {
    switch (filter.toLowerCase()) {
      case 'pending':
        return TodoFilter.pending;
      case 'inprogress':
        return TodoFilter.inProgress;
      case 'completed':
        return TodoFilter.completed;
      case 'cancelled':
        return TodoFilter.cancelled;
      case 'overdue':
        return TodoFilter.overdue;
      case 'today':
        return TodoFilter.today;
      case 'thisweek':
        return TodoFilter.thisWeek;
      default:
        return TodoFilter.all;
    }
  }

  TodoSort _getSortFromString(String sort) {
    switch (sort.toLowerCase()) {
      case 'title':
        return TodoSort.title;
      case 'duedate':
        return TodoSort.dueDate;
      case 'priority':
        return TodoSort.priority;
      case 'createddate':
        return TodoSort.createdDate;
      case 'status':
        return TodoSort.status;
      default:
        return TodoSort.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(filteredTodoListProvider);
    final filter = ref.watch(todoFilterProvider);
    final priorityFilter = ref.watch(todoPriorityFilterProvider);
    // Note: sort is handled by the filteredTodoListProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Todos'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goToHome(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => AppRouter.goToSearch(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              ref.read(todoFilterProvider.notifier).state = _getFilterFromString(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Todos'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: 'inprogress',
                child: Text('In Progress'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Completed'),
              ),
              const PopupMenuItem(
                value: 'overdue',
                child: Text('Overdue'),
              ),
              const PopupMenuItem(
                value: 'today',
                child: Text('Today'),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              ref.read(todoSortProvider.notifier).state = _getSortFromString(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duedate',
                child: Text('Due Date'),
              ),
              const PopupMenuItem(
                value: 'priority',
                child: Text('Priority'),
              ),
              const PopupMenuItem(
                value: 'title',
                child: Text('Title'),
              ),
              const PopupMenuItem(
                value: 'createddate',
                child: Text('Created Date'),
              ),
              const PopupMenuItem(
                value: 'status',
                child: Text('Status'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter and Sort Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Status Filters
                Row(
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', TodoFilter.all, filter),
                            const SizedBox(width: 8),
                            _buildFilterChip('Pending', TodoFilter.pending, filter),
                            const SizedBox(width: 8),
                            _buildFilterChip('In Progress', TodoFilter.inProgress, filter),
                            const SizedBox(width: 8),
                            _buildFilterChip('Completed', TodoFilter.completed, filter),
                            const SizedBox(width: 8),
                            _buildFilterChip('Overdue', TodoFilter.overdue, filter),
                            const SizedBox(width: 8),
                            _buildFilterChip('Today', TodoFilter.today, filter),
                            const SizedBox(width: 8),
                            _buildFilterChip('This Week', TodoFilter.thisWeek, filter),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Priority Filters
                Row(
                  children: [
                    Text(
                      'Priority:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPriorityFilterChip('All', null, priorityFilter),
                            const SizedBox(width: 8),
                            _buildPriorityFilterChip('Low', TodoPriority.low, priorityFilter),
                            const SizedBox(width: 8),
                            _buildPriorityFilterChip('Medium', TodoPriority.medium, priorityFilter),
                            const SizedBox(width: 8),
                            _buildPriorityFilterChip('High', TodoPriority.high, priorityFilter),
                            const SizedBox(width: 8),
                            _buildPriorityFilterChip('Urgent', TodoPriority.urgent, priorityFilter),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Todos List
          Expanded(
            child: todos.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(todoListProvider.notifier).refreshTodos();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return _buildTodoItem(todo);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppRouter.goToAddTodo(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, TodoFilter filterValue, TodoFilter currentFilter) {
    final isSelected = currentFilter == filterValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(todoFilterProvider.notifier).state = filterValue;
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildPriorityFilterChip(String label, TodoPriority? priority, TodoPriority? currentPriorityFilter) {
    final isSelected = currentPriorityFilter == priority;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(todoPriorityFilterProvider.notifier).state = selected ? priority : null;
      },
      selectedColor: priority != null ? AppTheme.getPriorityColor(priority).withOpacity(0.2) : AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: priority != null ? AppTheme.getPriorityColor(priority) : AppTheme.primaryColor,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_rtl,
              size: 64,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No todos found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or create a new todo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => AppRouter.goToAddTodo(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Todo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoItem(TodoModel todo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          onTap: () => AppRouter.goToTodoDetails(context, todo.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Checkbox(
                  value: todo.status == TodoStatus.completed,
                  onChanged: (value) {
                    ref.read(todoListProvider.notifier).toggleTodoStatus(todo.id);
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: todo.status == TodoStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (todo.description != null && todo.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatusChip(todo.status),
                          const SizedBox(width: 8),
                          _buildPriorityChip(todo.priority),
                          if (todo.category != null) ...[
                            const SizedBox(width: 8),
                            _buildCategoryChip(todo.category!),
                          ],
                        ],
                      ),
                      if (todo.dueDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: AppTheme.textHint,
                            ),
                            const SizedBox(width: 4),
                        Text(
                          _formatDate(todo.dueDate!),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textHint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        AppRouter.goToEditTodo(context, todo.id);
                        break;
                      case 'delete':
                        _showDeleteDialog(todo);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TodoStatus status) {
    final color = AppTheme.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TodoPriority priority) {
    final color = AppTheme.getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.toString().split('.').last.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.secondaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    
    // Compare dates only (without time) for accurate day calculation
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    final difference = taskDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${-difference} days ago';
    }
  }

  void _showDeleteDialog(TodoModel todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(todoListProvider.notifier).deleteTodo(todo.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
