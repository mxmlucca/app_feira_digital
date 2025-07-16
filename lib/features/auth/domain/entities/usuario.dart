/// Representa os dados de um utilizador guardados no Firestore,
/// para além das informações do Firebase Auth.
class Usuario {
  final String uid; // Corresponde ao UID do Firebase Auth
  final String email;
  final String nome;
  final String papel; // 'admin' ou 'expositor'

  Usuario({
    required this.uid,
    required this.email,
    required this.nome,
    required this.papel,
  });

  factory Usuario.fromMap(Map<String, dynamic> data, String documentId) {
    return Usuario(
      uid: documentId,
      email: data['email'] ?? '',
      nome: data['nome'] ?? '',
      papel: data['papel'] ?? 'expositor', // Padrão é 'expositor'
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'nome': nome, 'papel': papel};
  }
}
