import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barberblack/ui/core/theme/app_theme.dart';
import 'package:barberblack/ui/core/widgets/bb_empty_state.dart';
import 'package:barberblack/ui/features/client/view_models/client_home_view_model.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({
    super.key,
    required this.onOpenSearch,
    required this.onOpenAppointments,
  });

  final VoidCallback onOpenSearch;
  final VoidCallback onOpenAppointments;

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  late final ClientHomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = ClientHomeViewModel();
    _viewModel.addListener(_onChanged);
    _viewModel.load();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.errorMessage != null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: BBEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Não foi possível carregar a Home',
              message: _viewModel.errorMessage!,
              actionLabel: 'Tentar novamente',
              onAction: _viewModel.load,
            ),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: AppTheme.navy,
        child: SafeArea(
          bottom: false,
          child: ColoredBox(
            color: const Color(0xFFF6F7F9),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth >= 600
                    ? 32.0
                    : 20.0;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _Header(
                        userName: _viewModel.userName,
                        horizontalPadding: horizontalPadding,
                        onSearch: widget.onOpenSearch,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        20,
                        horizontalPadding,
                        28,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _SectionTitle(
                            title: 'Próximo agendamento',
                            actionLabel: 'Ver todos',
                            onAction: widget.onOpenAppointments,
                          ),
                          const SizedBox(height: 10),
                          BBEmptyState(
                            compact: true,
                            icon: Icons.calendar_month_outlined,
                            title: 'Nenhum agendamento marcado',
                            message: 'Quando você agendar um serviço, ele aparecerá aqui.',
                            actionLabel: 'Agendar agora',
                            onAction: widget.onOpenSearch,
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle(title: 'Serviços populares'),
                          const SizedBox(height: 10),
                          const _ServicesRow(),
                          const SizedBox(height: 24),
                          const _SectionTitle(title: 'Barbeiros em destaque'),
                          const SizedBox(height: 10),
                          const BBEmptyState(
                            icon: Icons.content_cut_rounded,
                            title: 'Nenhum barbeiro disponível',
                            message: 'Os profissionais cadastrados no BarberBlack aparecerão aqui.',
                          ),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.userName,
    required this.horizontalPadding,
    required this.onSearch,
  });

  final String userName;
  final double horizontalPadding;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final firstName = userName.split(' ').first;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        14,
        horizontalPadding,
        24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SizedBox(
                      width: 118,
                      height: 48,
                      child: Image.asset(
                        'assets/images/barberblack_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: IconButton(
                      tooltip: 'Notificações',
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Olá, $firstName 👋',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Encontre seu próximo corte',
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.76)),
              ),
              const SizedBox(height: 18),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: onSearch,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppTheme.navy),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Buscar barbeiro ou serviço...',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                        Icon(Icons.tune_rounded, color: AppTheme.navy),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.4),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _ServicesRow extends StatelessWidget {
  const _ServicesRow();

  @override
  Widget build(BuildContext context) {
    const services = [
      (icon: Icons.content_cut_rounded, label: 'Corte'),
      (icon: Icons.face_retouching_natural_rounded, label: 'Barba'),
      (icon: Icons.auto_awesome_rounded, label: 'Completo'),
    ];

    return Row(
      children: [
        for (var i = 0; i < services.length; i++) ...[
          Expanded(
            child: _ServiceTile(
              icon: services[i].icon,
              label: services[i].label,
            ),
          ),
          if (i != services.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.navy, size: 26),
          const SizedBox(height: 9),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
