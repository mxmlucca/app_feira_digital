import '../repositories/test_repository.dart';

// O UseCase representa uma única regra de negócio [cite: 59]
class GetGreetingUseCase {
  final TestRepository repository;

  GetGreetingUseCase(this.repository);

  Future<String> call() async {
    return await repository.getGreeting();
  }
}
