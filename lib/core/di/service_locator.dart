import 'package:get_it/get_it.dart';

// Service Locator instance
final getIt = GetIt.instance;

// Function to initialize all dependencies
Future<void> setupLocator() async {
  // At this moment, it's empty.
  // As we create controllers, use cases, and repositories,
  // we will register them here.
  // Ex: getIt.registerLazySingleton(() => AuthController());
}
