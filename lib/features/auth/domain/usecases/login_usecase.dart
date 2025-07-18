import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> call(String email, String password) async {
    // Validações de email/senha podem ser adicionadas aqui
    return await repository.login(email, password);
  }
}
