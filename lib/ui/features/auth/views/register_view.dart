import 'package:flutter/material.dart';
import 'package:barberblack/ui/core/theme/app_theme.dart';
import 'package:barberblack/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barberblack/ui/features/auth/models/account_type.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.accountType});

  final AccountType accountType;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.signUpWithEmail(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        accountType: widget.accountType.name,
      );

      if (!mounted) return;

      final precisaConfirmarEmail = response.session == null;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            precisaConfirmarEmail
                ? 'Se este e-mail ainda não estiver cadastrado, você receberá uma mensagem para confirmar sua conta. Se já possuir uma conta, faça login.'
                : 'Conta criada com sucesso!',
          ),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      final erro = error.message.toLowerCase();

      String mensagem;

      if (erro.contains('already registered')) {
        mensagem = 'Este e-mail já possui uma conta.';
      } else if (erro.contains('password')) {
        mensagem = 'A senha não atende aos requisitos de segurança.';
      } else {
        mensagem = 'Não foi possível criar a conta. Verifique os dados e tente novamente.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensagem)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível criar a conta. Tente novamente.'),
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Voltar',
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppTheme.navy,
                            ),
                          ),
                        ],
                      ),

                      Image.asset(
                        'assets/images/barberblack_logo.png',
                        width: compact ? 150 : 170,
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
                                'Crie sua conta',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Comece agora no BarberBlack',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),

                              SizedBox(height: compact ? 16 : 20),

                              TextFormField(
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  hintText: 'Nome completo',
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 14,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe seu nome';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  hintText: 'E-mail',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
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
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
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
                                    return 'Informe uma senha';
                                  }

                                  if (value.length < 6) {
                                    return 'Use pelo menos 6 caracteres';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _hideConfirmPassword,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  hintText: 'Confirmar senha',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock_reset_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    tooltip: _hideConfirmPassword
                                        ? 'Mostrar senha'
                                        : 'Ocultar senha',
                                    onPressed: () {
                                      setState(() {
                                        _hideConfirmPassword =
                                            !_hideConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _hideConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirme sua senha';
                                  }

                                  if (value != _passwordController.text) {
                                    return 'As senhas não coincidem';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Criar conta'),
                                    SizedBox(width: 10),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 6),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Já tenho uma conta'),
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
            );
          },
        ),
      ),
    );
  }
}
