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
    // Esta lógica agora está dentro de um método que pode ser reutilizado
    await _loadUserData(firebaseUser);
  }

  // NOVO MÉTODO PÚBLICO PARA ATUALIZAÇÃO MANUAL
  Future<void> refreshUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    await _loadUserData(currentUser);
  }

  // MÉTODO PRIVADO PARA CONCENTRAR A LÓGICA DE CARREGAMENTO
  Future<void> _loadUserData(User? firebaseUser) async {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    if (firebaseUser == null) {
      _usuario = null;
      _expositorProfile = null;
      print("UserProvider: Utilizador deslogado.");
    } else {
      print(
        "UserProvider: Verificando dados para o UID ${firebaseUser.uid}...",
      );
      _usuario = await _firestoreService.getUsuario(firebaseUser.uid);

      if (_usuario?.papel == 'expositor') {
        _expositorProfile = await _firestoreService.getExpositorPorId(
          firebaseUser.uid,
        );
        print(
          "UserProvider: Perfil de expositor carregado com status: ${_expositorProfile?.status}",
        );
      } else {
        _expositorProfile = null; // Garante que está limpo para outros papéis
        print(
          "UserProvider: Utilizador carregado com papel: ${_usuario?.papel}",
        );
      }
    }

    _isLoading = false;
    notifyListeners(); // Notifica os widgets que os dados mudaram (ou não) e o loading acabou
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
