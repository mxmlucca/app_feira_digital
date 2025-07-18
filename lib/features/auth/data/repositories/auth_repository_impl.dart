import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login(String email, String password) async {
    // 1. Faz o login e pega o UID
    final uid = await remoteDataSource.login(email, password);
    // 2. Com o UID, busca o papel do usuário
    final role = await remoteDataSource.getUserRole(uid);
    // 3. Constrói e retorna a nossa entidade User
    return User(uid: uid, email: email, role: role);
  }
}
