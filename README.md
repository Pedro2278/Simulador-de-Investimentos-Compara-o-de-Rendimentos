# Simulador de Investimentos: Comparação de Rendimentos

Aplicativo desenvolvido em Flutter para simular e comparar a evolução de dois investimentos com capital inicial, aportes mensais e taxas de juros compostos diferentes. A simulação apresenta os resultados finais e a evolução de cada opção ao longo de um período compartilhado.

## Identificação

| Campo | Informação |
|---|---|
| **Matéria** | Programação para dispositivos moveis |
| **Professor** | Felipe Gonçalves |
| **Autor** | Pedro Henrique Vogado Maia |
| **Projeto** | Simulador de Investimentos: Comparação de Rendimentos |
| **Tecnologia** | Flutter e Dart |

## Objetivo

O objetivo do projeto é aplicar conceitos de desenvolvimento de aplicativos móveis, incluindo construção de formulários, validação de dados, gerenciamento de estado com `setState`, navegação entre telas, listas e cálculos financeiros. O usuário informa os dados de dois investimentos e visualiza uma comparação detalhada dos resultados.

## Funcionalidades

- Cadastro de um nome para cada investimento.
- Entrada de capital inicial, aplicação mensal e taxa de juros mensal para cada opção.
- Definição de um prazo compartilhado entre **1 e 600 meses**.
- Validação dos campos: valores financeiros não negativos e limitados a R$ 1 trilhão, e taxa mensal limitada a 100%.
- Aceitação de números decimais com vírgula ou ponto, como `0,8` ou `0.8`.
- Tela de resultados com montante final, rendimento total, total investido e taxa mensal de cada investimento.
- Destaque da opção com maior montante final e diferença entre os resultados.
- Gráfico simples de barras para comparação dos montantes finais.
- Lista comparativa com os saldos no início e em cada mês, acompanhada por barras de evolução opcionais.
- Navegação de retorno ao formulário para editar os dados e realizar outra simulação.
- Restauração dos valores de exemplo pelo botão de reinício na tela inicial.
- Interface adaptável a diferentes tamanhos de tela.

## Como usar

1. Abra o aplicativo e confira os campos dos dois investimentos.
2. Informe o nome, o capital inicial, o aporte mensal e a taxa mensal de cada opção.
3. Defina o período comum da simulação, em meses.
4. Toque em **Comparar investimentos**. Se algum campo estiver inválido, o formulário exibirá uma mensagem para correção.
5. Analise os montantes finais, rendimentos totais, valores investidos, gráfico e evolução mensal.
6. Use **Editar valores e comparar novamente** para retornar ao formulário. O botão de reinício restaura os valores de exemplo.

## Cálculo financeiro

A taxa deve ser informada como percentual mensal. Por exemplo, `0,8` significa uma taxa de **0,8% ao mês**. O programa converte esse percentual para decimal dividindo-o por 100.

O saldo inicial é exibido como **Inicial**. Para cada mês, primeiro são calculados os juros sobre o saldo existente e, em seguida, o aporte mensal é adicionado:

```text
taxa decimal = taxa mensal percentual / 100
saldo do mês = saldo anterior × (1 + taxa decimal) + aporte mensal
```

O rendimento total é calculado descontando do montante final o capital inicial e todos os aportes:

```text
total investido = capital inicial + (aporte mensal × número de meses)
rendimento total = montante final − total investido
```

**Convenção da simulação:** o aporte é realizado no fim de cada mês; portanto, ele não recebe juros naquele mesmo mês. Os valores são apresentados em reais, formatados para duas casas decimais. O cálculo é uma estimativa e não considera impostos, tarifas, inflação ou variação de taxas ao longo do tempo.

## Tecnologias e conceitos

- **Flutter:** framework para desenvolvimento da interface multiplataforma.
- **Dart:** linguagem utilizada na implementação.
- **Material 3:** componentes e tema visual.
- **`Form` e `TextFormField`:** coleta e validação das entradas.
- **`StatefulWidget` e `setState`:** atualização da interface, incluindo o controle das barras de evolução.
- **`Navigator` e `MaterialPageRoute`:** navegação da tela de entrada para os resultados e retorno para uma nova simulação.
- **Listas:** armazenamento e exibição dos saldos de cada mês.
- **Testes Flutter:** verificação do cálculo financeiro, da interpretação de números brasileiros e do fluxo da interface.

## Organização do projeto

```text
.
├── lib/
│   └── main.dart              # Aplicativo, modelos, cálculos e telas
├── test/
│   └── widget_test.dart       # Testes de cálculo e navegação
├── pubspec.yaml               # Configuração e dependências Flutter
└── README.md                  # Documentação do projeto
```

As classes `InvestmentInput`, `InvestmentResult` e `InvestmentComparison` representam, respectivamente, os dados de entrada, o resultado de uma opção e a comparação entre as duas. `InvestmentFormPage` contém o formulário; `InvestmentResultsPage` apresenta o resumo e a evolução mensal.

## Requisitos

- Flutter SDK instalado e configurado.
- Dart SDK compatível com a versão declarada no `pubspec.yaml` (Dart `^3.13.3`).
- Um dispositivo ou emulador configurado, ou um navegador para executar a versão web.

Confira a instalação do Flutter com:

```bash
flutter doctor
```

## Executar o aplicativo

Na pasta raiz do projeto, instale as dependências e inicie o app:

```bash
flutter pub get
flutter run
```

Para executar em um navegador compatível:

```bash
flutter run -d chrome
```

Para gerar a versão web de produção:

```bash
flutter build web
```

Os arquivos gerados ficam em `build/web`.

## Testes e análise estática

Execute os testes automatizados:

```bash
flutter test
```

Verifique problemas de estilo e análise estática:

```bash
flutter analyze
```

Os testes do projeto cobrem o cálculo de juros compostos com aportes no fim do mês, a leitura de valores no formato brasileiro e a navegação até a tela de comparação.

## Roteiro sugerido para o vídeo de apresentação

1. Apresente o objetivo do simulador e os dados que podem ser informados.
2. Preencha dois investimentos com taxas ou aportes diferentes e escolha um prazo.
3. Inicie a comparação e explique os montantes finais, o total investido e o rendimento de cada opção.
4. Mostre o gráfico e percorra a evolução dos saldos mês a mês.
5. Retorne ao formulário, altere um dos valores e execute uma nova simulação.
6. Explique a fórmula, a convenção de aporte no fim do mês e as limitações da estimativa.

> O vídeo é uma apresentação a ser gravada pelo autor; ele não está incluído nos arquivos do projeto.
