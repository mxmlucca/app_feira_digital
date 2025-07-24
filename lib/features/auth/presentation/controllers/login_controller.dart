import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginController extends ChangeNotifier {
  final LoginUseCase _loginUseCase;

  LoginController(this._loginUseCase);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loginUseCase.call(email, password);
      _isLoading = false;
      notifyListeners();
      return true; // Sucesso
    } on FirebaseAuthException catch (e) {
      // Captura a exceção específica do Firebase
      // Imprime o código do erro no console para a gente ver!
      print('FIREBASE AUTH ERROR CODE: ${e.code}');

      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Nenhum usuário encontrado com este email.';
          break;
        case 'wrong-password':
          _errorMessage = 'Senha incorreta. Por favor, tente novamente.';
          break;
        case 'invalid-email':
          _errorMessage = 'O formato do email é inválido.';
          break;
        default:
          _errorMessage = 'Ocorreu um erro inesperado. Tente novamente.';
      }
      _isLoading = false;
      notifyListeners();
      return false; // Falha
    } catch (e) {
      // Captura qualquer outro erro genérico
      print('GENERIC ERROR: $e');
      _errorMessage = 'Ocorreu um erro de conexão. Verifique a internet.';
      _isLoading = false;
      notifyListeners();
      return false; // Falha
    }
  }
}
