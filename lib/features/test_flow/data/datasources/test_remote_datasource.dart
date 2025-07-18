// Interface
abstract class TestRemoteDataSource {
  Future<String> getGreetingMessage();
}

// Implementação
class TestRemoteDataSourceImpl implements TestRemoteDataSource {
  @override
  Future<String> getGreetingMessage() async {
    // Simula uma chamada de rede com 2 segundos de atraso
    await Future.delayed(const Duration(seconds: 2));
    return 'Teste!';
  }
}
