import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:barberblack/ui/core/theme/app_theme.dart';
import 'package:barberblack/ui/features/auth/views/register_options_view.dart';
import 'package:barberblack/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barberblack/ui/features/client/views/client_main_shell.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso.')),
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      final mensagem =
          error.message.toLowerCase().contains('email not confirmed')
          ? 'Confirme seu e-mail antes de entrar.'
          : 'E-mail ou senha inválidos. Se ainda não tiver uma conta, toque em Criar conta.';

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensagem)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível entrar. Tente novamente.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isGoogleLoading) {
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final profile = await _authService.signInExistingWithGoogle();

      if (!mounted) return;

      final accountType = profile['tipo_conta']?.toString();

      if (accountType == 'cliente') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => const ClientMainShell(),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A área do barbeiro será conectada na próxima etapa.'),
        ),
      );
    } on GoogleSignInException catch (error) {
      if (!mounted) return;

      if (error.code == GoogleSignInExceptionCode.canceled) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível entrar com o Google.')),
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      final mensagem = error.message.contains('Nenhum perfil BarberBlack')
          ? 'Esta conta Google ainda não possui cadastro no BarberBlack. Toque em Criar conta.'
          : 'Não foi possível concluir o login com o Google.';

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensagem)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível entrar com o Google.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 820;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: compact ? 8 : 12,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (compact ? 16 : 24),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/barberblack_logo.png',
                          width: compact ? 175 : 195,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: compact ? 8 : 12),

                        Container(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            compact ? 18 : 22,
                            20,
                            compact ? 18 : 22,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 30,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Bem-vindo de volta!',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  'Acesse sua conta para continuar',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),

                                SizedBox(height: compact ? 16 : 20),

                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: const InputDecoration(
                                    hintText: 'E-mail',
                                    prefixIcon: Icon(
                                      Icons.mail_outline_rounded,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (value) {
                                    final email = value?.trim() ?? '';

                                    if (email.isEmpty) {
                                      return 'Informe seu e-mail';
                                    }

                                    if (!email.contains('@')) {
                                      return 'Informe um e-mail válido';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 12),

                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _hidePassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  onFieldSubmitted: (_) => _signIn(),
                                  decoration: InputDecoration(
                                    hintText: 'Senha',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 14,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                    ),
                                    suffixIcon: IconButton(
                                      tooltip: _hidePassword
                                          ? 'Mostrar senha'
                                          : 'Ocultar senha',
                                      onPressed: () {
                                        setState(() {
                                          _hidePassword = !_hidePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _hidePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Informe sua senha';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 14),

                                ElevatedButton(
                                  onPressed: _isLoading ? null : _signIn,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Entrar'),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 4),

                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Esqueci minha senha'),
                                ),

                                const SizedBox(height: 4),

                                const Row(
                                  children: [
                                    Expanded(child: Divider()),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Text(
                                        'ou',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider()),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                OutlinedButton.icon(
                                  onPressed: _isGoogleLoading
                                      ? null
                                      : _signInWithGoogle,
                                  icon: Image.asset(
                                    'assets/images/google_g_logo.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  label: const Text('Entrar com Google'),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  'Ainda não tem uma conta?',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),

                                const SizedBox(height: 6),

                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (context) =>
                                            const RegisterOptionsView(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.navy,
                                    side: const BorderSide(
                                      color: AppTheme.gold,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Criar conta'),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 19,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'BARBEARIA MAIS ORGANIZADA • RESULTADOS REAIS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
