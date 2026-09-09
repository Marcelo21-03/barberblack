import 'package:flutter/material.dart';
import 'package:barberblack/ui/core/theme/app_theme.dart';
import 'package:barberblack/ui/features/client/views/client_home_view.dart';

class ClientMainShell extends StatefulWidget {
  const ClientMainShell({super.key});

  @override
  State<ClientMainShell> createState() => _ClientMainShellState();
}

class _ClientMainShellState extends State<ClientMainShell> {
  int _currentIndex = 0;

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ClientHomeView(
        onOpenSearch: () => _selectTab(1),
        onOpenAppointments: () => _selectTab(2),
      ),
      const _PlaceholderPage(
        icon: Icons.search_rounded,
        title: 'Buscar',
        message: 'A busca de barbeiros será desenvolvida na próxima etapa.',
      ),
      const _PlaceholderPage(
        icon: Icons.calendar_month_rounded,
        title: 'Agenda',
        message: 'Seus agendamentos aparecerão aqui.',
      ),
      const _PlaceholderPage(
        icon: Icons.person_outline_rounded,
        title: 'Perfil',
        message: 'As configurações do seu perfil aparecerão aqui.',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: ColoredBox(
        color: AppTheme.navy,
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: AppTheme.navy,
              indicatorColor: AppTheme.gold.withValues(alpha: 0.16),
              elevation: 0,
              height: 72,
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((
                states,
              ) {
                final selected = states.contains(WidgetState.selected);

                return IconThemeData(
                  color: selected
                      ? AppTheme.gold
                      : Colors.white.withValues(alpha: 0.68),
                  size: 24,
                );
              }),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((
                states,
              ) {
                final selected = states.contains(WidgetState.selected);

                return TextStyle(
                  color: selected
                      ? AppTheme.gold
                      : Colors.white.withValues(alpha: 0.68),
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _selectTab,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Início',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  label: 'Buscar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Agenda',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF6F7F9),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: AppTheme.navy),
                  const SizedBox(height: 16),
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.textSecondary),
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
