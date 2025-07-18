// Este é o "contrato" que a camada de dados deve seguir
abstract class TestRepository {
  Future<String> getGreeting();
}
