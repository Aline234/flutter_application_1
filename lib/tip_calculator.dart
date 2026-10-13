import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necessário para os Formatters
import 'package:intl/intl.dart';

// Formatter personalizado para simular entrada de banco (centavos automáticos)
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove tudo que não for dígito
    String numbersOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbersOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Converte para double dividindo por 100 para considerar os centavos
    double value = double.parse(numbersOnly) / 100;

    // Formata usando o padrão brasileiro (R$ 0,00)
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String newText = formatter.format(value);

    // Retorna o novo valor ajustando o cursor para o final do texto
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class TipCalculator extends StatefulWidget {
  const TipCalculator({super.key});

  @override
  State<TipCalculator> createState() => _TipCalculatorState();
}

class _TipCalculatorState extends State<TipCalculator> {
  double _currentSliderValue = 15;
  double _valor = 0.0;
  double _gorjeta = 0.0;
  double _valorTotal = 0.0;

  final TextEditingController _controller1 = TextEditingController();

  // Função para recalcular os valores com base no valor atual e slider
  void _calcular(double valorBase) {
    setState(() {
      _valor = valorBase;
      _gorjeta = (_valor * _currentSliderValue / 100);
      _valorTotal = _valor + _gorjeta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Gorjeta'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Esta é a calculadora de gorjeta!',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _controller1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  onChanged: (value) {
                    // Remove símbolos e formatação para extrair apenas o número puro
                    String cleanValue = value
                        .replaceAll('R\$', '')
                        .replaceAll('.', '')
                        .replaceAll(',', '')
                        .trim();

                    double doubleVal = double.tryParse(cleanValue) ?? 0.0;
                    doubleVal /= 100.0; // Transforma os centavos em reais

                    _calcular(doubleVal);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Digite o valor',
                    hintText: 'RS 0,00',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Valor: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_valor)}',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Gorjeta: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_gorjeta)}',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_valorTotal)}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Slider(
                  value: _currentSliderValue,
                  max: 30,
                  divisions: 30,
                  label: '${_currentSliderValue.round()}%',
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value.round().toDouble();
                    });
                    _calcular(_valor);
                  },
                ),
                Text(
                  'Porcentagem: ${_currentSliderValue.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Voltar para a Tela Principal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}