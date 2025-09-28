class AppRoutes {
  // Main Routes
  static const String splash = '/';
  static const String home = '/home';
  static const String todos = '/todos';
  static const String addTodo = '/add-todo';
  static const String editTodo = '/edit-todo';
  static const String todoDetails = '/todo-details';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String categories = '/categories';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String about = '/about';
  
  // Settings Routes
  static const String themeSettings = '/settings/theme';
  static const String notificationSettings = '/settings/notifications';
  static const String languageSettings = '/settings/language';
  static const String backupSettings = '/settings/backup';
  static const String privacySettings = '/settings/privacy';
  static const String aboutSettings = '/settings/about';
  
  // Auth Routes (for future implementation)
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  
  // Error Routes
  static const String notFound = '/404';
  static const String error = '/error';
  
  // Route Names for Navigation
  static const Map<String, String> routeNames = {
    splash: 'Splash',
    home: 'Home',
    todos: 'Todos',
    addTodo: 'Add Todo',
    editTodo: 'Edit Todo',
    todoDetails: 'Todo Details',
    settings: 'Settings',
    profile: 'Profile',
    categories: 'Categories',
    search: 'Search',
    notifications: 'Notifications',
    about: 'About',
    themeSettings: 'Theme Settings',
    notificationSettings: 'Notification Settings',
    languageSettings: 'Language Settings',
    backupSettings: 'Backup Settings',
    privacySettings: 'Privacy Settings',
    aboutSettings: 'About Settings',
    login: 'Login',
    register: 'Register',
    forgotPassword: 'Forgot Password',
    resetPassword: 'Reset Password',
    notFound: 'Not Found',
    error: 'Error',
  };
  
  // Route Parameters
  static const String todoIdParam = 'todoId';
  static const String categoryIdParam = 'categoryId';
  static const String searchQueryParam = 'query';
  static const String filterParam = 'filter';
  static const String sortParam = 'sort';
  
  // Helper Methods
  static String getTodoDetailsRoute(String todoId) {
    return '$todoDetails?$todoIdParam=$todoId';
  }
  
  static String getEditTodoRoute(String todoId) {
    return '$editTodo?$todoIdParam=$todoId';
  }
  
  static String getSearchRoute(String query) {
    return '$search?$searchQueryParam=${Uri.encodeComponent(query)}';
  }
  
  static String getTodosWithFilter(String filter) {
    return '$todos?$filterParam=$filter';
  }
  
  static String getTodosWithSort(String sort) {
    return '$todos?$sortParam=$sort';
  }
  
  static String getTodosWithFilterAndSort(String filter, String sort) {
    return '$todos?$filterParam=$filter&$sortParam=$sort';
  }
  
  // Route Validation
  static bool isValidRoute(String route) {
    return routeNames.containsKey(route);
  }
  
  static String getRouteName(String route) {
    return routeNames[route] ?? 'Unknown Route';
  }
  
  // Deep Link Routes
  static const Map<String, String> deepLinkRoutes = {
    'todo': todoDetails,
    'add': addTodo,
    'settings': settings,
    'search': search,
  };
  
  // Tab Routes (for bottom navigation)
  static const List<String> tabRoutes = [
    home,
    todos,
    search,
    notifications,
    settings,
  ];
  
  // Modal Routes (routes that open as modals)
  static const List<String> modalRoutes = [
    addTodo,
    editTodo,
    todoDetails,
  ];
  
  // Protected Routes (require authentication)
  static const List<String> protectedRoutes = [
    profile,
    backupSettings,
    privacySettings,
  ];
  
  // Public Routes (no authentication required)
  static const List<String> publicRoutes = [
    splash,
    home,
    todos,
    search,
    about,
    login,
    register,
    forgotPassword,
    resetPassword,
    notFound,
    error,
  ];
}
