import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//
// import '../../features/test_flow/data/datasources/test_remote_datasource.dart';
// import '../../features/test_flow/data/repositories/test_repository_impl.dart';
// import '../../features/test_flow/domain/repositories/test_repository.dart';
// import '../../features/test_flow/domain/usecases/get_greeting_usecase.dart';
// import '../../features/test_flow/presentation/controllers/test_page_controller.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/controllers/login_controller.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // ---- AUTH ---- //

  // External
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  // Data
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: getIt(), firestore: getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt()),
  );

  // Domain
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));

  // Presentation
  // Usamos registerFactory para o Controller, pois ele pode ser criado
  // e descartado várias vezes junto com a página.
  getIt.registerFactory(() => LoginController(getIt()));
}
