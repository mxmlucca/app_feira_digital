import 'package:flutter/material.dart';
// ADICIONE ESTA LINHA:
import '../../domain/usecases/get_greeting_usecase.dart';

class TestPageController extends ChangeNotifier {
  final GetGreetingUseCase getGreetingUseCase;

  TestPageController({required this.getGreetingUseCase});

  String _message = 'Press the button to get a greeting.';
  String get message => _message;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchGreeting() async {
    _isLoading = true;
    notifyListeners();

    _message = await getGreetingUseCase();

    _isLoading = false;
    notifyListeners();
  }
}
