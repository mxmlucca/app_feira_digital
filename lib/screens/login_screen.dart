import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Supondo que as suas cores kCorPrimaria e kCorSecundaria estão definidas no main.dart
// e são acessíveis aqui via Theme.of(context) ou importadas de um ficheiro de constantes.
// Para este exemplo, vou usar cores diretas baseadas na sua imagem.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _message = '';
  bool _isLoading = false;
  bool _obscurePassword = true; // Para controlar a visibilidade da senha

  // Cores baseadas na sua imagem de referência
  final Color corDeFundo = const Color(0xFFFFEB3B); // Amarelo forte
  final Color corDoBotao = const Color(0xFFC2185B); // Um magenta/rosa escuro
  final Color corDoCampo = const Color.fromARGB(255, 31, 37, 47);
  final Color corTextoLink = const Color.fromARGB(
    255,
    48,
    63,
    159,
  ); // Mesma cor dos campos para os links

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _message = 'A autenticar...';
      });
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        print('Login bem-sucedido na LoginScreen: ${userCredential.user?.uid}');
        if (mounted)
          setState(() {
            _message = '';
          });
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Ocorreu um erro.';
        if (e.code == 'user-not-found' || e.code == 'invalid-email') {
          errorMessage = 'Email não encontrado ou inválido.';
        } else if (e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          errorMessage = 'Senha incorreta.';
        } else {
          errorMessage = e.message ?? errorMessage;
        }
        setState(() {
          _message = errorMessage;
        });
      } catch (e) {
        setState(() {
          _message = 'Ocorreu um erro inesperado.';
        });
      } finally {
        if (mounted)
          setState(() {
            _isLoading = false;
            if (_message == 'A autenticar...') _message = '';
          });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usar o tema global para consistência, mas permitir sobrescrever cores específicas
    // final theme = Theme.of(context);

    return Scaffold(
      // Não teremos AppBar para seguir o design do Figma
      // appBar: AppBar(
      //   title: const Text('Login'),
      //   automaticallyImplyLeading: false,
      // ),
      body: SafeArea(
        // Garante que o conteúdo não fica sob as áreas do sistema (notch, etc)
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 1. Imagem do Logo
                  Image.asset(
                    'assets/images/logoTrilhos.png', // SUBSTITUA PELO CAMINHO DO SEU LOGO
                    height: 120, // Ajuste a altura conforme necessário
                    // width: 200, // Ajuste a largura se precisar
                  ),
                  const SizedBox(height: 48.0), // Espaço maior após o logo
                  // 2. Campo de Email
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(
                      color: Colors.white,
                    ), // Cor do texto dentro do campo
                    decoration: InputDecoration(
                      hintText: 'Email', // Usar hintText para o placeholder
                      hintStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: corDoCampo, // Cor de fundo do campo
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide.none, // Sem borda visível inicialmente
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Insira o seu email';
                      if (!value.contains('@') || !value.contains('.'))
                        return 'Insira um email válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // 3. Campo de Senha
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      hintStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: corDoCampo,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Insira a sua senha';
                      if (value.length < 6)
                        return 'A senha deve ter pelo menos 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28.0), // Espaço maior antes do botão
                  // 4. Botão Entrar
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corDoBotao,
                      foregroundColor: Colors.white, // Cor do texto
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3.0,
                              ),
                            )
                            : const Text('Entrar'),
                  ),
                  const SizedBox(height: 16.0),

                  // Mensagem de erro
                  if (_message.isNotEmpty &&
                      !_message.contains('A autenticar...'))
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        _message,
                        // Usar uma cor que contraste com o amarelo de fundo para o erro
                        style: TextStyle(
                          color: corDoBotao,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // 5. Links Adicionais
                  TextButton(
                    onPressed: () {
                      // TODO: Implementar lógica de recuperar senha
                      print('Botão Recuperar Senha pressionado');
                    },
                    child: Text(
                      'Recuperar Senha',
                      style: TextStyle(color: corTextoLink),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implementar lógica de cadastrar com vendedor
                      print('Botão Cadastrar com Vendedor pressionado');
                    },
                    child: Text(
                      'Cadastrar como Vendedor',
                      style: TextStyle(color: corTextoLink),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
