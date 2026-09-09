import 'package:flutter_test/flutter_test.dart';
import 'package:barberblack/main.dart';

void main() {
  testWidgets('BarberBlack abre na tela de login', (tester) async {
    await tester.pumpWidget(const BarberBlackApp());

    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Entrar com Google'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });
}
