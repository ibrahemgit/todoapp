import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import '../utils/app_router.dart';
import '../constants/app_theme.dart';
import '../constants/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final todoStats = ref.watch(todoStatsProvider);
    final recentTodos = ref.watch(filteredTodoListProvider).take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => AppRouter.goToSearch(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.notifications),
            onSelected: (value) {
              if (value == 'notifications') {
                AppRouter.goToNotifications(context);
              } else if (value == 'settings') {
                AppRouter.goToNotificationSettings(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'notifications',
                child: Row(
                  children: [
                    const Icon(Icons.notifications),
                    const SizedBox(width: 8),
                    Text(l10n.notifications),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings),
                    const SizedBox(width: 8),
                    Text(l10n.notificationSettings),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(todoListProvider.notifier).refreshTodos();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(l10n),
              const SizedBox(height: 24),

              // Recent Todos
              _buildRecentTodosSection(l10n, recentTodos),
              const SizedBox(height: 24),

              // Statistics Cards
              _buildStatsSection(l10n, todoStats),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActionsSection(l10n),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AppRouter.goToAddTodo(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addTodo),
        heroTag: "add_todo",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildWelcomeSection(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.welcomeMessage,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay organized and productive with your smart todo app',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTodosSection(AppLocalizations l10n, List<TodoModel> todos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentTodos,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => AppRouter.goToTodos(context),
              child: Text(l10n.allTodos),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (todos.isEmpty)
          _buildEmptyState(l10n)
        else
          ...todos.map((todo) => _buildTodoItem(l10n, todo)),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTodosFound,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first todo to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(AppLocalizations l10n, TodoModel todo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Checkbox(
          value: todo.status == TodoStatus.completed,
          onChanged: (value) {
            ref.read(todoListProvider.notifier).toggleTodoStatus(todo.id);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: todo.status == TodoStatus.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description != null && todo.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                todo.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPriorityChip(l10n, todo.priority),
                const SizedBox(width: 8),
                _buildStatusChip(l10n, todo.status),
                if (todo.isRepeating && todo.repeatingType != null) ...[
                  const SizedBox(width: 8),
                  _buildRepeatingChip(l10n, todo.repeatingType!),
                ],
              ],
            ),
            if (todo.dueDate != null || todo.reminderTime != null) ...[
              const SizedBox(height: 8),
              _buildTimeInfo(l10n, todo),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTodoAction(l10n, value, todo),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 20, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => AppRouter.goToTodoDetails(context, todo.id),
      ),
    );
  }

  Widget _buildPriorityChip(AppLocalizations l10n, TodoPriority priority) {
    final priorityText = _getPriorityText(l10n, priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getPriorityColor(priority).withOpacity(0.3),
        ),
      ),
      child: Text(
        priorityText,
        style: TextStyle(
          color: AppTheme.getPriorityColor(priority),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(AppLocalizations l10n, TodoStatus status) {
    final statusText = _getStatusText(l10n, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: AppTheme.getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRepeatingChip(AppLocalizations l10n, RepeatingType repeating) {
    final repeatingText = _getRepeatingText(l10n, repeating);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.repeat,
            size: 12,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            repeatingText,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(AppLocalizations l10n, TodoModel todo) {
    final effectiveDateTime = _getEffectiveDateTime(todo);
    final timeStatus = _getTimeStatus(effectiveDateTime);
    final timeStatusText = _getTimeStatusText(l10n, timeStatus);
    final timeStatusColor = _getTimeStatusColor(timeStatus);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: timeStatusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: timeStatusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 12,
            color: timeStatusColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${_formatDateWithTime(effectiveDateTime)} - $timeStatusText',
            style: TextStyle(
              color: timeStatusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AppLocalizations l10n, TodoStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                l10n.totalTodos,
                stats.total.toString(),
                Icons.task_alt,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.completedTodos,
                stats.completed.toString(),
                Icons.check_circle,
                AppTheme.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                l10n.pendingTodos,
                stats.pending.toString(),
                Icons.pending,
                AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.overdueTodos,
                stats.overdue.toString(),
                Icons.warning,
                AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                l10n.addTodo,
                Icons.add,
                AppTheme.primaryColor,
                () => AppRouter.goToAddTodo(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                l10n.todos,
                Icons.list,
                AppTheme.secondaryColor,
                () => AppRouter.goToTodos(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                l10n.search,
                Icons.search,
                AppTheme.infoColor,
                () => AppRouter.goToSearch(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                l10n.settings,
                Icons.settings,
                AppTheme.warningColor,
                () => AppRouter.goToSettings(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  String _getPriorityText(AppLocalizations l10n, TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return l10n.low;
      case TodoPriority.medium:
        return l10n.medium;
      case TodoPriority.high:
        return l10n.high;
      case TodoPriority.urgent:
        return l10n.urgent;
    }
  }

  String _getStatusText(AppLocalizations l10n, TodoStatus status) {
    switch (status) {
      case TodoStatus.pending:
        return l10n.pending;
      case TodoStatus.inProgress:
        return l10n.inProgress;
      case TodoStatus.completed:
        return l10n.completed;
      case TodoStatus.cancelled:
        return l10n.cancelled;
    }
  }

  String _getRepeatingText(AppLocalizations l10n, RepeatingType repeating) {
    switch (repeating) {
      case RepeatingType.daily:
        return l10n.daily;
      case RepeatingType.weekly:
        return l10n.weekly;
      case RepeatingType.monthly:
        return l10n.monthly;
      case RepeatingType.yearly:
        return l10n.yearly;
    }
  }

  DateTime _getEffectiveDateTime(TodoModel todo) {
    if (todo.reminderTime != null) {
      return todo.reminderTime!;
    } else if (todo.dueDate != null) {
      return todo.dueDate!;
    }
    return DateTime.now();
  }

  String _getTimeStatus(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = taskDate.difference(today).inDays;
    
    if (difference < 0) {
      return 'OVERDUE';
    } else if (difference == 0) {
      final timeDiff = dateTime.difference(now).inMinutes;
      if (timeDiff <= 0) {
        return 'DUE_NOW';
      } else {
        return 'DUE_TODAY';
      }
    } else if (difference == 1) {
      return 'DUE_SOON';
    } else if (difference <= 7) {
      return 'DUE_SOON';
    } else {
      return 'UPCOMING';
    }
  }

  String _getTimeStatusText(AppLocalizations l10n, String status) {
    switch (status) {
      case 'OVERDUE':
        return l10n.overdue;
      case 'DUE_NOW':
        return l10n.dueNow;
      case 'DUE_TODAY':
        return l10n.dueToday;
      case 'DUE_SOON':
        return l10n.dueSoon;
      case 'UPCOMING':
        return l10n.upcoming;
      default:
        return '';
    }
  }

  Color _getTimeStatusColor(String status) {
    switch (status) {
      case 'OVERDUE':
        return AppTheme.errorColor;
      case 'DUE_NOW':
        return AppTheme.errorColor;
      case 'DUE_TODAY':
        return AppTheme.warningColor;
      case 'DUE_SOON':
        return AppTheme.infoColor;
      case 'UPCOMING':
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatDateWithTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = taskDate.difference(today).inDays;
    
    String dateText;
    if (difference == 0) {
      dateText = 'Today';
    } else if (difference == 1) {
      dateText = 'Tomorrow';
    } else if (difference == -1) {
      dateText = 'Yesterday';
    } else if (difference > 0) {
      dateText = 'In $difference days';
    } else {
      dateText = '${-difference} days ago';
    }
    
    // Format time as 12-hour with AM/PM
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeText = '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    
    return '$dateText at $timeText';
  }

  void _handleTodoAction(AppLocalizations l10n, String action, TodoModel todo) {
    switch (action) {
      case 'edit':
        AppRouter.goToEditTodo(context, todo.id);
        break;
      case 'delete':
        _showDeleteDialog(l10n, todo);
        break;
    }
  }

  void _showDeleteDialog(AppLocalizations l10n, TodoModel todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.areYouSureDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(todoListProvider.notifier).deleteTodo(todo.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.todoDeletedSuccessfully),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

}
