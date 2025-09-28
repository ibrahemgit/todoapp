import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_localizations.dart';
import '../utils/app_router.dart';
import '../models/notification_log_model.dart';
import '../services/notification_log_service.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  NotificationLogType? _selectedFilter;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goToHome(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Text('تحديد الكل كمقروء'),
              ),
              const PopupMenuItem(
                value: 'delete_old',
                child: Text('حذف السجلات القديمة'),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Text('حذف جميع السجلات'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => AppRouter.goToNotificationSettings(context),
            tooltip: 'Notification Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الكل', icon: Icon(Icons.list)),
            Tab(text: 'اليوم', icon: Icon(Icons.today)),
            Tab(text: 'هذا الأسبوع', icon: Icon(Icons.date_range)),
            Tab(text: 'الإحصائيات', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllLogsTab(),
          _buildTodayLogsTab(),
          _buildWeekLogsTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  /// تبويب جميع السجلات
  Widget _buildAllLogsTab() {
    final logs = _getFilteredLogs(NotificationLogService.getAllLogs());
    
    if (logs.isEmpty) {
      return _buildEmptyState('لا توجد سجلات إشعارات');
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return _buildLogCard(log);
        },
      ),
    );
  }

  /// تبويب سجلات اليوم
  Widget _buildTodayLogsTab() {
    final logs = _getFilteredLogs(NotificationLogService.getTodayLogs());
    
    if (logs.isEmpty) {
      return _buildEmptyState('لا توجد سجلات لليوم');
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return _buildLogCard(log);
        },
      ),
    );
  }

  /// تبويب سجلات هذا الأسبوع
  Widget _buildWeekLogsTab() {
    final logs = _getFilteredLogs(NotificationLogService.getThisWeekLogs());
    
    if (logs.isEmpty) {
      return _buildEmptyState('لا توجد سجلات لهذا الأسبوع');
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return _buildLogCard(log);
        },
      ),
    );
  }

  /// تبويب الإحصائيات
  Widget _buildStatisticsTab() {
    final stats = NotificationLogService.getLogStatistics();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard('إجمالي السجلات', stats['إجمالي السجلات'] ?? 0, Icons.list),
          const SizedBox(height: 16),
          _buildStatsCard('السجلات غير المقروءة', stats['السجلات غير المقروءة'] ?? 0, Icons.mark_email_unread),
          const SizedBox(height: 16),
          _buildStatsCard('سجلات اليوم', stats['سجلات اليوم'] ?? 0, Icons.today),
          const SizedBox(height: 16),
          _buildStatsCard('سجلات هذا الأسبوع', stats['سجلات هذا الأسبوع'] ?? 0, Icons.date_range),
          const SizedBox(height: 24),
          const Text(
            'السجلات حسب النوع:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...stats.entries
              .where((entry) => !['إجمالي السجلات', 'السجلات غير المقروءة', 'سجلات اليوم', 'سجلات هذا الأسبوع'].contains(entry.key))
              .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildTypeStatsItem(entry.key, entry.value),
                  )),
        ],
      ),
    );
  }

  /// بناء بطاقة السجل
  Widget _buildLogCard(NotificationLogModel log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: log.isRead ? 2 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: log.isRead ? null : Theme.of(context).primaryColor.withOpacity(0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleLogTap(log),
        onLongPress: () => _handleLogAction('mark_read', log),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getTypeColor(log.type),
                  _getTypeColor(log.type).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _getTypeColor(log.type).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getTypeIcon(log.type),
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            log.title,
            style: TextStyle(
              fontWeight: log.isRead ? FontWeight.normal : FontWeight.bold,
              color: log.isRead ? null : Theme.of(context).primaryColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                log.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    log.type.arabicLabel,
                    style: TextStyle(
                      color: _getTypeColor(log.type),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTimestamp(log.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (log.taskTitle != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• ${log.taskTitle}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!log.isRead)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) => _handleLogAction(value, log),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        Icon(log.isRead ? Icons.mark_email_unread : Icons.mark_email_read),
                        const SizedBox(width: 8),
                        Text(log.isRead ? 'تحديد كمقروء' : 'تحديد كمقروء'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف السجل', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء بطاقة الإحصائيات
  Widget _buildStatsCard(String title, int count, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء عنصر إحصائيات النوع
  Widget _buildTypeStatsItem(String type, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(type),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// بناء حالة فارغة
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'لا توجد إشعارات لعرضها حالياً',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// الحصول على السجلات المفلترة
  List<NotificationLogModel> _getFilteredLogs(List<NotificationLogModel> logs) {
    var filteredLogs = logs;

    // فلترة حسب النوع
    if (_selectedFilter != null) {
      filteredLogs = filteredLogs.where((log) => log.type == _selectedFilter).toList();
    }

    // فلترة حسب القراءة
    if (_showUnreadOnly) {
      filteredLogs = filteredLogs.where((log) => !log.isRead).toList();
    }

    // فلترة حسب البحث
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredLogs = filteredLogs.where((log) =>
          log.title.toLowerCase().contains(query) ||
          log.description.toLowerCase().contains(query) ||
          (log.taskTitle?.toLowerCase().contains(query) ?? false)).toList();
    }

    return filteredLogs;
  }

  /// الحصول على لون النوع
  Color _getTypeColor(NotificationLogType type) {
    return Color(int.parse(type.colorHex.replaceFirst('#', '0xFF')));
  }

  /// الحصول على أيقونة Material Design للنوع
  IconData _getTypeIcon(NotificationLogType type) {
    switch (type) {
      case NotificationLogType.taskCreated:
        return Icons.add_task;
      case NotificationLogType.taskCompleted:
        return Icons.check_circle;
      case NotificationLogType.taskUpdated:
        return Icons.edit;
      case NotificationLogType.taskDeleted:
        return Icons.delete;
      case NotificationLogType.notificationScheduled:
        return Icons.schedule;
      case NotificationLogType.error:
        return Icons.error;
      case NotificationLogType.info:
        return Icons.info;
      case NotificationLogType.warning:
        return Icons.warning;
    }
  }

  /// التعامل مع إجراءات السجل
  void _handleLogAction(String action, NotificationLogModel log) {
    switch (action) {
      case 'mark_read':
        NotificationLogService.markAsRead(log.id);
        setState(() {});
        break;
      case 'delete':
        _showDeleteConfirmation(log);
        break;
    }
  }

  /// إظهار تأكيد الحذف
  void _showDeleteConfirmation(NotificationLogModel log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            const SizedBox(width: 8),
            const Text('حذف السجل'),
          ],
        ),
        content: const Text('هل أنت متأكد من حذف هذا السجل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              NotificationLogService.deleteLog(log.id);
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم حذف السجل'),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  /// تنسيق الطابع الزمني
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  /// التعامل مع النقر على السجل
  void _handleLogTap(NotificationLogModel log) {
    if (!log.isRead) {
      NotificationLogService.markAsRead(log.id);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم تحديد السجل كمقروء'),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// إظهار مربع البحث
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.search, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('البحث في السجلات'),
          ],
        ),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'ابحث في السجلات...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('مسح'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  /// إظهار مربع الفلترة
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('فلترة السجلات'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: CheckboxListTile(
                title: const Text('السجلات غير المقروءة فقط'),
                value: _showUnreadOnly,
                onChanged: (value) {
                  setState(() {
                    _showUnreadOnly = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'فلترة حسب النوع:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<NotificationLogType?>(
                value: _selectedFilter,
                hint: const Text('جميع الأنواع'),
                isExpanded: true,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem<NotificationLogType?>(
                    value: null,
                    child: Text('جميع الأنواع'),
                  ),
                  ...NotificationLogType.values.map((type) => DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getTypeColor(type),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(type.arabicLabel),
                          ],
                        ),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = null;
                _showUnreadOnly = false;
              });
              Navigator.pop(context);
            },
            child: const Text('مسح الفلاتر'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  /// التعامل مع إجراءات القائمة
  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_all_read':
        NotificationLogService.markAllAsRead();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث جميع السجلات كمقروءة')),
        );
        break;
      case 'delete_old':
        NotificationLogService.deleteOldLogs();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف السجلات القديمة')),
        );
        break;
      case 'delete_all':
        _showDeleteAllConfirmation();
        break;
    }
  }

  /// إظهار تأكيد حذف جميع السجلات
  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('حذف جميع السجلات'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_forever,
              size: 48,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'هل أنت متأكد من حذف جميع السجلات؟',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'لا يمكن التراجع عن هذا الإجراء.',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              NotificationLogService.deleteAllLogs();
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم حذف جميع السجلات'),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
  }
}
