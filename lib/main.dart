
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator State Lab',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String display = '0';
  String currentInput = '0';
  double? accumulator;
  String? pendingOperator;

  bool awaitingOperand = false;
  bool justCalculated = false;
  bool hasError = false;

  final List<List<String>> buttons = [
    ['7', '8', '9', '÷'],
    ['4', '5', '6', '×'],
    ['1', '2', '3', '−'],
    ['AC', '0', '=', '+'],
  ];

  // Feature 1: Clear all calculator state
  void clearAll() {
    display = '0';
    currentInput = '0';
    accumulator = null;
    pendingOperator = null;
    awaitingOperand = false;
    justCalculated = false;
    hasError = false;
  }

  String formatNumber(double number) {
    if (number == number.truncateToDouble()) {
      return number.toInt().toString();
    }
    return number.toString();
  }

  // Feature 2: Error handling
  void showError(String message) {
    display = message;
    hasError = true;
    accumulator = null;
    pendingOperator = null;
    awaitingOperand = false;
    justCalculated = false;
  }

  double? calculate(
    double first,
    double second,
    String operator,
  ) {
    double result;

    switch (operator) {
      case '+':
        result = first + second;
        break;
      case '−':
        result = first - second;
        break;
      case '×':
        result = first * second;
        break;
      case '÷':
        if (second == 0) {
          showError('Cannot divide by zero');
          return null;
        }
        result = first / second;
        break;
      default:
        return first;
    }

    if (!result.isFinite) {
      showError('Number too large');
      return null;
    }

    return result;
  }

  void enterDigit(String digit) {
    if (hasError || justCalculated) {
      clearAll();
    }

    if (awaitingOperand) {
      currentInput = digit;
      awaitingOperand = false;
    } else if (currentInput == '0') {
      currentInput = digit;
    } else {
      currentInput += digit;
    }

    display = currentInput;
  }

  void selectOperator(String operator) {
    if (hasError) return;

    if (awaitingOperand) {
      // Replace the operator if no new number was entered.
      pendingOperator = operator;
      return;
    }

    final number = double.parse(currentInput);

    if (accumulator == null) {
      accumulator = number;
    } else if (pendingOperator != null) {
      final result = calculate(
        accumulator!,
        number,
        pendingOperator!,
      );

      if (result == null) return;

      accumulator = result;
    } else {
      accumulator = number;
    }

    display = formatNumber(accumulator!);
    currentInput = display;
    pendingOperator = operator;
    awaitingOperand = true;
    justCalculated = false;
  }

  void pressEquals() {
    if (hasError || awaitingOperand) {
      return;
    }

    if (pendingOperator == null || accumulator == null) {
      return;
    }

    final number = double.parse(currentInput);

    final result = calculate(
      accumulator!,
      number,
      pendingOperator!,
    );

    if (result == null) return;

    display = formatNumber(result);
    currentInput = display;
    accumulator = null;
    pendingOperator = null;
    awaitingOperand = false;
    justCalculated = true;
  }

  void buttonPressed(String value) {
    setState(() {
      if (value == 'AC') {
        clearAll();
      } else if (RegExp(r'^[0-9]$').hasMatch(value)) {
        enterDigit(value);
      } else if (value == '=') {
        pressEquals();
      } else {
        selectOperator(value);
      }
    });
  }

  // Feature 3: Animated button feedback using InkWell
  Widget buildButton(String value) {
    final isOperator = ['+', '−', '×', '÷', '='].contains(value);
    final isClear = value == 'AC';

    Color buttonColor;

    if (isClear) {
      buttonColor = Colors.red.shade100;
    } else if (isOperator) {
      buttonColor = Colors.deepPurple.shade200;
    } else {
      buttonColor = Colors.deepPurple.shade50;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: buttonColor,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            splashColor: Colors.deepPurple.withValues(alpha: 0.25),
            highlightColor: Colors.deepPurple.withValues(alpha: 0.12),
            onTap: () => buttonPressed(value),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomRight,
                  child: Text(
                    display,
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: hasError
                          ? Colors.red
                          : Colors.deepPurple.shade900,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                children: buttons.map((row) {
                  return Expanded(
                    child: Row(
                      children: row.map(buildButton).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
