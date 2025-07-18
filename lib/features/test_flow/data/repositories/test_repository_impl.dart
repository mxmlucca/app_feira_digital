import '../../domain/repositories/test_repository.dart';
import '../datasources/test_remote_datasource.dart';

class TestRepositoryImpl implements TestRepository {
  final TestRemoteDataSource remoteDataSource;

  TestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> getGreeting() {
    return remoteDataSource.getGreetingMessage();
  }
}
