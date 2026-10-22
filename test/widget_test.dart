import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_investimentos/main.dart';

void main() {
  group('InvestmentResult', () {
    test('calculates monthly compound interest with contributions at month end', () {
      final result = InvestmentResult(
        input: const InvestmentInput(
          name: 'Teste',
          initialCapital: 1000,
          monthlyContribution: 100,
          monthlyRate: 10,
        ),
        months: 2,
      );

      expect(result.balances, [1000, 1200, 1420]);
      expect(result.totalInvested, 1200);
      expect(result.totalReturn, 220);
    });

    test('parses Brazilian decimal and thousands separators', () {
      expect(parseBrazilianNumber('1.234,56'), 1234.56);
      expect(parseBrazilianNumber('1.000'), 1000);
      expect(parseBrazilianNumber('0,8'), 0.8);
      expect(parseBrazilianNumber('12.5'), 12.5);
    });
  });

  testWidgets('opens a side-by-side investment comparison', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const InvestmentSimulatorApp());

    expect(find.text('Simulador de investimentos'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Comparar investimentos'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Comparar investimentos'));
    await tester.pumpAndSettle();

    expect(find.text('Resultado da comparação'), findsOneWidget);
    expect(find.text('Investimento 1'), findsWidgets);
    expect(find.text('Investimento 2'), findsWidgets);
    expect(find.text('Evolução mensal'), findsOneWidget);
    expect(find.text('Mês 12'), findsOneWidget);
  });
}
