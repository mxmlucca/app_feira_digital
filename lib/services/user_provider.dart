import 'dart:async'; // Para StreamSubscription
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario.dart';
import '../models/expositor.dart'; // Importar o model Expositor
import 'firestore_service.dart';

class UserProvider with ChangeNotifier {
  Usuario? _usuario;
  Expositor? _expositorProfile;
  bool _isLoading = true;

  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription? _authStateSubscription;

  Usuario? get usuario => _usuario;
  Expositor? get expositorProfile => _expositorProfile;
  bool get isLoading => _isLoading;

  UserProvider() {
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    // Começa a carregar
    if (_isLoading == false) {
      _isLoading = true;
      notifyListeners(); // Notifica que o carregamento começou
    }

    if (firebaseUser == null) {
      _usuario = null;
      _expositorProfile = null;
      print("UserProvider: Utilizador deslogado.");
    } else {
      print("UserProvider: Utilizador logado, buscando dados no Firestore...");
      _usuario = await _firestoreService.getUsuario(firebaseUser.uid);

      // Se o utilizador é um expositor, busca também o perfil de expositor
      if (_usuario?.papel == 'expositor') {
        _expositorProfile = await _firestoreService.getExpositorPorId(
          firebaseUser.uid,
        );
        if (_expositorProfile != null) {
          print(
            "UserProvider: Perfil de expositor carregado. Status: ${_expositorProfile!.status}",
          );
        } else {
          print(
            "UserProvider: Perfil de expositor NÃO encontrado para o UID ${firebaseUser.uid}.",
          );
        }
      } else {
        _expositorProfile =
            null; // Garante que o perfil de expositor está limpo se for admin
        if (_usuario != null) {
          print(
            "UserProvider: Dados do utilizador carregados. Papel: ${_usuario!.papel}",
          );
        }
      }
    }

    _isLoading = false; // Terminou de carregar
    notifyListeners(); // Notifica todos os widgets que os dados mudaram
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
