import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/todos_screen.dart';
import '../screens/add_todo_screen.dart';
import '../screens/edit_todo_screen.dart';
import '../screens/todo_details_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/search_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/about_screen.dart';
import '../screens/theme_settings_screen.dart';
import '../screens/language_settings_screen.dart';
import '../screens/notification_settings_screen.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Route
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.routeNames[AppRoutes.splash]!,
        builder: (context, state) => const SplashScreen(),
      ),

      // Main Routes
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.routeNames[AppRoutes.home]!,
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: AppRoutes.todos,
        name: AppRoutes.routeNames[AppRoutes.todos]!,
        builder: (context, state) {
          final filter = state.uri.queryParameters['filter'] ?? 'all';
          final sort = state.uri.queryParameters['sort'] ?? 'dueDate';
          return TodosScreen(filter: filter, sort: sort);
        },
      ),

      GoRoute(
        path: AppRoutes.addTodo,
        name: AppRoutes.routeNames[AppRoutes.addTodo]!,
        builder: (context, state) => const AddTodoScreen(),
      ),

      GoRoute(
        path: AppRoutes.editTodo,
        name: AppRoutes.routeNames[AppRoutes.editTodo]!,
        builder: (context, state) {
          final todoId = state.uri.queryParameters[AppRoutes.todoIdParam];
          if (todoId == null) {
            return const ErrorScreen(message: 'Todo ID is required');
          }
          return EditTodoScreen(todoId: todoId);
        },
      ),

      GoRoute(
        path: AppRoutes.todoDetails,
        name: AppRoutes.routeNames[AppRoutes.todoDetails]!,
        builder: (context, state) {
          final todoId = state.uri.queryParameters[AppRoutes.todoIdParam];
          if (todoId == null) {
            return const ErrorScreen(message: 'Todo ID is required');
          }
          return TodoDetailsScreen(todoId: todoId);
        },
      ),

      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.routeNames[AppRoutes.settings]!,
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: AppRoutes.search,
        name: AppRoutes.routeNames[AppRoutes.search]!,
        builder: (context, state) {
          final query = state.uri.queryParameters[AppRoutes.searchQueryParam] ?? '';
          return SearchScreen(query: query);
        },
      ),

      GoRoute(
        path: AppRoutes.notifications,
        name: AppRoutes.routeNames[AppRoutes.notifications]!,
        builder: (context, state) => const NotificationsScreen(),
      ),

      GoRoute(
        path: AppRoutes.about,
        name: AppRoutes.routeNames[AppRoutes.about]!,
        builder: (context, state) => const AboutScreen(),
      ),

      // Settings Sub-routes
      GoRoute(
        path: '/settings/theme',
        name: 'theme-settings',
        builder: (context, state) => const ThemeSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/language',
        name: 'language-settings',
        builder: (context, state) => const LanguageSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        name: 'notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),

      // Error Routes
      GoRoute(
        path: AppRoutes.notFound,
        name: AppRoutes.routeNames[AppRoutes.notFound]!,
        builder: (context, state) => const ErrorScreen(message: 'Page not found'),
      ),

      GoRoute(
        path: AppRoutes.error,
        name: AppRoutes.routeNames[AppRoutes.error]!,
        builder: (context, state) {
          final message = state.uri.queryParameters['message'] ?? 'An error occurred';
          return ErrorScreen(message: message);
        },
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(
      message: 'Navigation error: ${state.error}',
    ),
  );

  static GoRouter get router => _router;

  // Navigation Helper Methods
  static void goToSplash(BuildContext context) {
    context.go(AppRoutes.splash);
  }

  static void goToHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  static void goToTodos(BuildContext context, {String? filter, String? sort}) {
    String path = AppRoutes.todos;
    final queryParams = <String, String>{};
    
    if (filter != null) queryParams['filter'] = filter;
    if (sort != null) queryParams['sort'] = sort;
    
    if (queryParams.isNotEmpty) {
      path += '?${Uri(queryParameters: queryParams).query}';
    }
    
    context.go(path);
  }

  static void goToAddTodo(BuildContext context) {
    context.go(AppRoutes.addTodo);
  }

  static void goToEditTodo(BuildContext context, String todoId) {
    context.go(AppRoutes.getEditTodoRoute(todoId));
  }

  static void goToTodoDetails(BuildContext context, String todoId) {
    context.go(AppRoutes.getTodoDetailsRoute(todoId));
  }

  static void goToSettings(BuildContext context) {
    context.go(AppRoutes.settings);
  }

  static void goToSearch(BuildContext context, {String? query}) {
    if (query != null && query.isNotEmpty) {
      context.go(AppRoutes.getSearchRoute(query));
    } else {
      context.go(AppRoutes.search);
    }
  }

  static void goToNotifications(BuildContext context) {
    context.go(AppRoutes.notifications);
  }

  static void goToAbout(BuildContext context) {
    context.go(AppRoutes.about);
  }

  // Settings Navigation Methods
  static void goToThemeSettings(BuildContext context) {
    context.go('/settings/theme');
  }

  static void goToLanguageSettings(BuildContext context) {
    context.go('/settings/language');
  }

  static void goToNotificationSettings(BuildContext context) {
    context.go('/settings/notifications');
  }


  // Push Methods (for modals)
  static Future<void> pushAddTodo(BuildContext context) async {
    await context.push(AppRoutes.addTodo);
  }

  static Future<void> pushEditTodo(BuildContext context, String todoId) async {
    await context.push(AppRoutes.getEditTodoRoute(todoId));
  }

  static Future<void> pushTodoDetails(BuildContext context, String todoId) async {
    await context.push(AppRoutes.getTodoDetailsRoute(todoId));
  }

  static Future<void> pushSearch(BuildContext context, {String? query}) async {
    if (query != null && query.isNotEmpty) {
      await context.push(AppRoutes.getSearchRoute(query));
    } else {
      await context.push(AppRoutes.search);
    }
  }

  // Pop Methods
  static void pop(BuildContext context) {
    context.pop();
  }

  static void popUntil(BuildContext context, String route) {
    // Note: popUntil is not available in GoRouter, using alternative approach
    // This would need to be implemented based on specific navigation requirements
    context.go(route);
  }

  // Can Pop Check
  static bool canPop(BuildContext context) {
    return context.canPop();
  }

  // Get Current Route
  static String getCurrentRoute(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  // Get Current Route Name
  static String getCurrentRouteName(BuildContext context) {
    return GoRouterState.of(context).name ?? 'Unknown';
  }

  // Get Route Parameters
  static Map<String, String> getRouteParameters(BuildContext context) {
    return GoRouterState.of(context).uri.queryParameters;
  }

  // Get Route Parameter
  static String? getRouteParameter(BuildContext context, String key) {
    return GoRouterState.of(context).uri.queryParameters[key];
  }
}

// Error Screen Widget
class ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (onRetry != null) ...[
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 8),
              ],
              TextButton(
                onPressed: () => AppRouter.goToHome(context),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
