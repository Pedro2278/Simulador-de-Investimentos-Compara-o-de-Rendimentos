import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const InvestmentSimulatorApp());
}

class InvestmentSimulatorApp extends StatelessWidget {
  const InvestmentSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF147D64);
    return MaterialApp(
      title: 'Comparador de investimentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          surface: const Color(0xFFF6F8F6),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8F6),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E8E3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: seedColor, width: 1.5),
          ),
        ),
      ),
      home: const InvestmentFormPage(),
    );
  }
}

/// Dados de entrada de um investimento individual.
class InvestmentInput {
  const InvestmentInput({
    required this.name,
    required this.initialCapital,
    required this.monthlyContribution,
    required this.monthlyRate,
  });

  final String name;
  final double initialCapital;
  final double monthlyContribution;
  final double monthlyRate;
}

/// Resultado de um investimento, incluindo o saldo no mês zero e nos meses seguintes.
class InvestmentResult {
  InvestmentResult({
    required this.input,
    required this.months,
  }) : balances = _calculateBalances(input, months);

  final InvestmentInput input;
  final int months;
  final List<double> balances;

  double get finalAmount => balances.last;

  double get totalInvested =>
      input.initialCapital + input.monthlyContribution * months;

  double get totalReturn => finalAmount - totalInvested;

  static List<double> _calculateBalances(InvestmentInput input, int months) {
    final values = <double>[input.initialCapital];
    var balance = input.initialCapital;
    final monthlyRate = input.monthlyRate / 100;

    // O aporte é feito no fim do mês: primeiro rende, depois recebe o novo aporte.
    for (var month = 1; month <= months; month++) {
      balance = balance * (1 + monthlyRate) + input.monthlyContribution;
      values.add(balance);
    }
    return List.unmodifiable(values);
  }
}

class InvestmentComparison {
  InvestmentComparison({
    required InvestmentInput first,
    required InvestmentInput second,
    required this.months,
  }) : first = InvestmentResult(input: first, months: months),
       second = InvestmentResult(input: second, months: months);

  final InvestmentResult first;
  final InvestmentResult second;
  final int months;

  InvestmentResult get winner =>
      first.finalAmount >= second.finalAmount ? first : second;

  double get difference => (first.finalAmount - second.finalAmount).abs();
}

class InvestmentFormPage extends StatefulWidget {
  const InvestmentFormPage({super.key});

  @override
  State<InvestmentFormPage> createState() => _InvestmentFormPageState();
}

class _InvestmentFormPageState extends State<InvestmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{
    'name1': TextEditingController(text: 'Investimento 1'),
    'capital1': TextEditingController(text: '1.000'),
    'contribution1': TextEditingController(text: '200'),
    'rate1': TextEditingController(text: '0,8'),
    'name2': TextEditingController(text: 'Investimento 2'),
    'capital2': TextEditingController(text: '1.000'),
    'contribution2': TextEditingController(text: '200'),
    'rate2': TextEditingController(text: '1'),
    'months': TextEditingController(text: '12'),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _resetForm() {
    const defaults = {
      'name1': 'Investimento 1',
      'capital1': '1.000',
      'contribution1': '200',
      'rate1': '0,8',
      'name2': 'Investimento 2',
      'capital2': '1.000',
      'contribution2': '200',
      'rate2': '1',
      'months': '12',
    };
    setState(() {
      for (final entry in defaults.entries) {
        _controllers[entry.key]!.text = entry.value;
      }
      _formKey.currentState?.reset();
    });
  }

  void _compare() {
    if (!_formKey.currentState!.validate()) return;

    String nameFor(String key, String fallback) {
      final value = _controllers[key]!.text.trim();
      return value.isEmpty ? fallback : value;
    }

    final comparison = InvestmentComparison(
      first: InvestmentInput(
        name: nameFor('name1', 'Investimento 1'),
        initialCapital: _readNumber('capital1'),
        monthlyContribution: _readNumber('contribution1'),
        monthlyRate: _readNumber('rate1'),
      ),
      second: InvestmentInput(
        name: nameFor('name2', 'Investimento 2'),
        initialCapital: _readNumber('capital2'),
        monthlyContribution: _readNumber('contribution2'),
        monthlyRate: _readNumber('rate2'),
      ),
      months: int.parse(_controllers['months']!.text),
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InvestmentResultsPage(comparison: comparison),
      ),
    );
  }

  double _readNumber(String key) => parseBrazilianNumber(_controllers[key]!.text);

  String? _validateAmount(String? value, {bool isRate = false}) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe um valor.';
    }
    final number = parseBrazilianNumber(value);
    if (!number.isFinite || number < 0) {
      return 'Informe um número válido e não negativo.';
    }
    if (isRate && number > 100) {
      return 'Use uma taxa mensal de até 100%.';
    }
    if (!isRate && number > 1000000000000) {
      return 'Informe um valor de até R\$ 1 trilhão.';
    }
    return null;
  }

  String? _validateMonths(String? value) {
    final months = int.tryParse(value ?? '');
    if (months == null || months < 1 || months > 600) {
      return 'Informe um período entre 1 e 600 meses.';
    }
    return null;
  }

  Widget _moneyField(String key, String label, {bool isRate = false}) {
    return TextFormField(
      controller: _controllers[key],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      validator: (value) => _validateAmount(value, isRate: isRate),
      decoration: InputDecoration(
        labelText: label,
        prefixText: isRate ? null : 'R\$ ',
        suffixText: isRate ? '% a.m.' : null,
      ),
    );
  }

  Widget _investmentFields({
    required String title,
    required String subtitle,
    required String nameKey,
    required String capitalKey,
    required String contributionKey,
    required String rateKey,
    required Color accent,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE7ECE8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.savings_outlined, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF69766F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _controllers[nameKey],
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome do investimento',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 14),
            _moneyField(capitalKey, 'Capital inicial'),
            const SizedBox(height: 14),
            _moneyField(contributionKey, 'Aplicação mensal'),
            const SizedBox(height: 14),
            _moneyField(rateKey, 'Taxa de juros mensal', isRate: true),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de investimentos'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Restaurar valores de exemplo',
            onPressed: _resetForm,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Text(
                    'Qual investimento rende mais?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF18352B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preencha os dados de cada opção e compare a evolução do patrimônio mês a mês.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF65736B),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _investmentFields(
                    title: 'Investimento 1',
                    subtitle: 'Primeira opção da comparação',
                    nameKey: 'name1',
                    capitalKey: 'capital1',
                    contributionKey: 'contribution1',
                    rateKey: 'rate1',
                    accent: colors.primary,
                  ),
                  const SizedBox(height: 14),
                  _investmentFields(
                    title: 'Investimento 2',
                    subtitle: 'Segunda opção da comparação',
                    nameKey: 'name2',
                    capitalKey: 'capital2',
                    contributionKey: 'contribution2',
                    rateKey: 'rate2',
                    accent: const Color(0xFF6873C8),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: const BorderSide(color: Color(0xFFE7ECE8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Período da simulação',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'O mesmo prazo será aplicado às duas opções.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFF69766F)),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _controllers['months'],
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: _validateMonths,
                            decoration: const InputDecoration(
                              labelText: 'Duração',
                              prefixIcon: Icon(Icons.calendar_month_outlined),
                              suffixText: 'meses',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Estimativa matemática, sem considerar impostos, taxas ou inflação. Os aportes são considerados no fim de cada mês.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF69766F),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _compare,
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('Comparar investimentos'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

class InvestmentResultsPage extends StatefulWidget {
  const InvestmentResultsPage({super.key, required this.comparison});

  final InvestmentComparison comparison;

  @override
  State<InvestmentResultsPage> createState() => _InvestmentResultsPageState();
}

class _InvestmentResultsPageState extends State<InvestmentResultsPage> {
  bool _showBalances = true;

  InvestmentComparison get comparison => widget.comparison;

  @override
  Widget build(BuildContext context) {
    final first = comparison.first;
    final second = comparison.second;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado da comparação'),
        actions: [
          IconButton(
            tooltip: 'Fazer nova simulação',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.insights_outlined, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${comparison.months} meses de simulação',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${comparison.winner.input.name} termina com ${formatCurrency(comparison.difference)} a mais.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cards = [
                      _summaryCard(context, first, const Color(0xFF147D64)),
                      _summaryCard(context, second, const Color(0xFF6873C8)),
                    ];
                    if (constraints.maxWidth >= 620) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 14),
                          Expanded(child: cards[1]),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 12),
                        cards[1],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                _comparisonChart(context, first, second),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Evolução mensal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showBalances = !_showBalances),
                      icon: Icon(
                        _showBalances
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      label: Text(
                        _showBalances
                            ? 'Ocultar barras da evolução'
                            : 'Mostrar barras da evolução',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _monthlyTable(context, first, second),
                const SizedBox(height: 16),
                Text(
                  'O rendimento total é o montante final menos o capital inicial e a soma dos aportes mensais.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF69766F),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar valores e comparar novamente'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    InvestmentResult result,
    Color accent,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE7ECE8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.input.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Montante final',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF69766F),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatCurrency(result.finalAmount),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _summaryLine(
              context,
              'Rendimento total',
              formatCurrency(result.totalReturn),
            ),
            const SizedBox(height: 8),
            _summaryLine(
              context,
              'Total investido',
              formatCurrency(result.totalInvested),
            ),
            const SizedBox(height: 8),
            _summaryLine(
              context,
              'Taxa mensal',
              '${formatDecimal(result.input.monthlyRate)}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryLine(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF69766F),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _comparisonChart(
    BuildContext context,
    InvestmentResult first,
    InvestmentResult second,
  ) {
    final maximum = first.finalAmount > second.finalAmount
        ? first.finalAmount
        : second.finalAmount;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE7ECE8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Montantes finais',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            _barRow(
              context,
              first.input.name,
              first.finalAmount,
              maximum,
              const Color(0xFF147D64),
            ),
            const SizedBox(height: 14),
            _barRow(
              context,
              second.input.name,
              second.finalAmount,
              maximum,
              const Color(0xFF6873C8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barRow(
    BuildContext context,
    String label,
    double amount,
    double maximum,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatCurrency(amount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: maximum == 0 ? 0 : amount / maximum,
            minHeight: 10,
            color: color,
            backgroundColor: const Color(0xFFEDF1EE),
          ),
        ),
      ],
    );
  }

  Widget _monthlyTable(
    BuildContext context,
    InvestmentResult first,
    InvestmentResult second,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE7ECE8)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: _tableHeader(
                    context,
                    first.input.name,
                    const Color(0xFF147D64),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _tableHeader(
                    context,
                    second.input.name,
                    const Color(0xFF6873C8),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: first.balances.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
            itemBuilder: (context, index) {
              final firstBalance = first.balances[index];
              final secondBalance = second.balances[index];
              final firstShare = _showBalances && first.finalAmount > 0
                  ? (firstBalance / first.finalAmount).clamp(0.0, 1.0)
                  : 0.0;
              final secondShare = _showBalances && second.finalAmount > 0
                  ? (secondBalance / second.finalAmount).clamp(0.0, 1.0)
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        index == 0 ? 'Inicial' : 'Mês $index',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF69766F),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _balanceCell(
                        context,
                        firstBalance,
                        firstShare,
                        const Color(0xFF147D64),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _balanceCell(
                        context,
                        secondBalance,
                        secondShare,
                        const Color(0xFF6873C8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(BuildContext context, String name, Color color) {
    return Text(
      name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _balanceCell(
    BuildContext context,
    double balance,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatCurrency(balance),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_showBalances) ...[
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              color: color,
              backgroundColor: const Color(0xFFEDF1EE),
            ),
          ),
        ],
      ],
    );
  }
}

/// Aceita tanto números decimais com vírgula quanto valores formatados em pt-BR.
double parseBrazilianNumber(String value) {
  var normalized = value.trim().replaceAll(' ', '');
  if (normalized.contains(',')) {
    normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
  } else if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(normalized)) {
    normalized = normalized.replaceAll('.', '');
  }
  return double.tryParse(normalized) ?? double.nan;
}

String formatCurrency(double value) {
  final negative = value < 0;
  final fixed = value.abs().toStringAsFixed(2).split('.');
  final integer = fixed.first;
  final grouped = integer.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (match) => '${match[1]}.',
  );
  return '${negative ? '-' : ''}R\$ $grouped,${fixed.last}';
}

String formatDecimal(double value) {
  final fixed = value.toStringAsFixed(2);
  return fixed.replaceAll('.', ',');
}
