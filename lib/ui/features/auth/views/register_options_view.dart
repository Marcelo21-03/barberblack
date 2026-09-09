import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:barberblack/data/services/auth_service.dart';
import 'package:barberblack/ui/core/theme/app_theme.dart';
import 'package:barberblack/ui/features/auth/models/account_type.dart';
import 'package:barberblack/ui/features/auth/views/register_view.dart';

class RegisterOptionsView extends StatefulWidget {
  const RegisterOptionsView({super.key});

  @override
  State<RegisterOptionsView> createState() => _RegisterOptionsViewState();
}

class _RegisterOptionsViewState extends State<RegisterOptionsView> {
  AccountType? _accountType;

  final AuthService _authService = AuthService();
  bool _isGoogleLoading = false;

  Future<void> _continueWithGoogle() async {
    final type = _accountType;

    if (type == null || _isGoogleLoading) {
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      await _authService.signInWithGoogle(accountType: type.name);

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta Google autenticada com sucesso.')),
      );
    } on GoogleSignInException catch (error) {
      if (!mounted) return;

      if (error.code == GoogleSignInExceptionCode.canceled) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível entrar com o Google.')),
      );
    } on AuthException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível concluir a autenticação com o Google.',
          ),
        ),
      );
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

  void _openEmailRegister() {
    final type = _accountType;

    if (type == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => RegisterView(accountType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _accountType;

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
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppTheme.navy,
                            ),
                          ),
                        ],
                      ),

                      Image.asset(
                        'assets/images/barberblack_logo.png',
                        width: compact ? 155 : 175,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Crie sua conta',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Escolha o tipo da sua conta',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),

                            const SizedBox(height: 22),

                            _AccountCard(
                              title: 'Cliente',
                              description:
                                  'Agende serviços e acompanhe seus horários',
                              icon: Icons.person_outline_rounded,
                              selected: selected == AccountType.cliente,
                              onTap: () {
                                setState(() {
                                  _accountType = AccountType.cliente;
                                });
                              },
                            ),

                            const SizedBox(height: 12),

                            _AccountCard(
                              title: 'Barbeiro',
                              description:
                                  'Gerencie sua agenda, clientes e serviços',
                              icon: Icons.content_cut_rounded,
                              selected: selected == AccountType.barbeiro,
                              onTap: () {
                                setState(() {
                                  _accountType = AccountType.barbeiro;
                                });
                              },
                            ),

                            const SizedBox(height: 22),

                            Text(
                              'Como deseja continuar?',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),

                            const SizedBox(height: 14),

                            OutlinedButton.icon(
                              onPressed: selected == null || _isGoogleLoading
                                  ? null
                                  : _continueWithGoogle,
                              icon: Image.asset(
                                'assets/images/google_g_logo.png',
                                width: 20,
                                height: 20,
                              ),
                              label: const Text('Continuar com Google'),
                            ),

                            const SizedBox(height: 14),

                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
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

                            const SizedBox(height: 14),

                            ElevatedButton(
                              onPressed: selected == null
                                  ? null
                                  : _openEmailRegister,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.mail_outline_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text('Criar conta com e-mail'),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Já tenho uma conta'),
                            ),
                          ],
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

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.navy.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppTheme.gold : AppTheme.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? AppTheme.navy : AppTheme.textSecondary,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: AppTheme.gold),
            ],
          ),
        ),
      ),
    );
  }
}
