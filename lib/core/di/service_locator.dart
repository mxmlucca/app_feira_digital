import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

// ADICIONE ESTAS 5 LINHAS:
import '../../features/test_flow/data/datasources/test_remote_datasource.dart';
import '../../features/test_flow/data/repositories/test_repository_impl.dart';
import '../../features/test_flow/domain/repositories/test_repository.dart';
import '../../features/test_flow/domain/usecases/get_greeting_usecase.dart';
import '../../features/test_flow/presentation/controllers/test_page_controller.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // DATA
  getIt.registerLazySingleton<TestRemoteDataSource>(
    () => TestRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<TestRepository>(
    () => TestRepositoryImpl(remoteDataSource: getIt()),
  );

  // DOMAIN
  getIt.registerLazySingleton(() => GetGreetingUseCase(getIt()));

  // PRESENTATION
  getIt.registerFactory(() => TestPageController(getGreetingUseCase: getIt()));
}
