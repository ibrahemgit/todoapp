class AppConstants {
  // App Information
  static const String appName = 'Smart TodoApp';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A smart and practical todo app with intelligent reminders';
  
  // Storage Keys
  static const String todoBoxName = 'todos';
  static const String settingsBoxName = 'settings';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String firstLaunchKey = 'first_launch';
  
  // Notification Keys
  static const String notificationChannelId = 'todo_reminders';
  static const String notificationChannelName = 'Todo Reminders';
  static const String notificationChannelDescription = 'Notifications for todo reminders and alerts';
  
  // Default Values
  static const int defaultReminderMinutes = 5;
  static const int maxTodoTitleLength = 100;
  static const int maxTodoDescriptionLength = 500;
  static const int maxTagsPerTodo = 5;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Pagination
  static const int todosPerPage = 20;
  static const int maxRecentTodos = 10;
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'h:mm a';
  static const String displayDateTimeFormat = 'MMM dd, yyyy h:mm a';
  
  // Validation
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  
  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String unknownErrorMessage = 'An unknown error occurred. Please try again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  static const String permissionDeniedMessage = 'Permission denied. Please enable the required permissions.';
  
  // Success Messages
  static const String todoCreatedMessage = 'Todo created successfully!';
  static const String todoUpdatedMessage = 'Todo updated successfully!';
  static const String todoDeletedMessage = 'Todo deleted successfully!';
  static const String todoCompletedMessage = 'Todo completed!';
  
  // Categories
  static const List<String> defaultCategories = [
    'Personal',
    'Work',
    'Health',
    'Shopping',
    'Education',
    'Travel',
    'Finance',
    'Other',
  ];
  
  // Tags
  static const List<String> defaultTags = [
    'urgent',
    'important',
    'meeting',
    'deadline',
    'review',
    'follow-up',
    'idea',
    'project',
  ];
  
  // Repeating Types
  static const List<String> repeatingTypes = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];
  
  // Priority Levels
  static const List<String> priorityLevels = [
    'Low',
    'Medium',
    'High',
    'Urgent',
  ];
  
  // Status Options
  static const List<String> statusOptions = [
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled',
  ];
  
  // API Endpoints (for future cloud sync)
  static const String baseUrl = 'https://api.todoapp.com';
  static const String todosEndpoint = '/todos';
  static const String categoriesEndpoint = '/categories';
  static const String settingsEndpoint = '/settings';
  
  // Local Database
  static const int databaseVersion = 1;
  static const String databaseName = 'todoapp.db';
  
  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB
  
  // File Upload
  static const int maxFileSize = 10; // MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
  
  // Security
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const int passwordMinLength = 8;
  
  // Performance
  static const int maxConcurrentOperations = 5;
  static const Duration operationTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
}
