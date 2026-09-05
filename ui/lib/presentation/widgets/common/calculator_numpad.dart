import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable on-screen numerical keypad and expression calculator.
class CalculatorNumpad extends StatefulWidget {
  final int initialAmountCents;
  final ValueChanged<int> onAmountChanged;
  final VoidCallback? onDone;

  const CalculatorNumpad({
    super.key,
    this.initialAmountCents = 0,
    required this.onAmountChanged,
    this.onDone,
  });

  @override
  State<CalculatorNumpad> createState() => _CalculatorNumpadState();
}

class _CalculatorNumpadState extends State<CalculatorNumpad> {
  String _input = '';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetOnNextDigit = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmountCents > 0) {
      final double val = widget.initialAmountCents / 100.0;
      _input = val % 1 == 0 ? val.toInt().toString() : val.toString();
    }
  }

  void _onDigit(String digit) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_shouldResetOnNextDigit) {
        _input = digit;
        _shouldResetOnNextDigit = false;
      } else {
        if (_input == '0' && digit != '.') {
          _input = digit;
        } else {
          // Limit decimal places to 2
          if (_input.contains('.')) {
            final parts = _input.split('.');
            if (parts.length > 1 && parts[1].length >= 2) {
              return; // Max 2 decimal digits
            }
          }
          if (_input.length < 12) {
            _input += digit;
          }
        }
      }
    });
    _notifyAmount();
  }

  void _onDecimal() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_shouldResetOnNextDigit) {
        _input = '0.';
        _shouldResetOnNextDigit = false;
      } else if (!_input.contains('.')) {
        _input = _input.isEmpty ? '0.' : '$_input.';
      }
    });
  }

  void _onDoubleZero() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_shouldResetOnNextDigit) {
        _input = '0';
        _shouldResetOnNextDigit = false;
      } else if (_input.isNotEmpty && _input != '0') {
        if (!_input.contains('.')) {
          _input += '00';
        } else {
          final parts = _input.split('.');
          if (parts[1].isEmpty) {
            _input += '00';
          } else if (parts[1].length == 1) {
            _input += '0';
          }
        }
      }
    });
    _notifyAmount();
  }

  void _onBackspace() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_input.isNotEmpty) {
        _input = _input.substring(0, _input.length - 1);
      }
    });
    _notifyAmount();
  }

  void _onClear() {
    HapticFeedback.mediumImpact();
    setState(() {
      _input = '';
      _firstOperand = null;
      _operator = null;
      _shouldResetOnNextDigit = false;
    });
    _notifyAmount();
  }

  void _onOperator(String op) {
    HapticFeedback.selectionClick();
    setState(() {
      final double? currentVal = double.tryParse(_input);
      if (currentVal != null) {
        if (_firstOperand != null && _operator != null) {
          _calculateResult();
        } else {
          _firstOperand = currentVal;
        }
      }
      _operator = op;
      _shouldResetOnNextDigit = true;
    });
  }

  void _onEquals() {
    HapticFeedback.mediumImpact();
    setState(() {
      _calculateResult();
      _operator = null;
      _firstOperand = null;
      _shouldResetOnNextDigit = true;
    });
    _notifyAmount();
  }

  void _calculateResult() {
    if (_firstOperand == null || _operator == null) return;
    final double? secondOperand = double.tryParse(_input);
    if (secondOperand == null) return;

    double result = 0;
    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = (_firstOperand! - secondOperand).clamp(0, double.infinity);
        break;
      case '×':
      case '*':
        result = _firstOperand! * secondOperand;
        break;
      case '÷':
      case '/':
        result = secondOperand != 0 ? _firstOperand! / secondOperand : 0;
        break;
    }

    // Format result to at most 2 decimals
    result = (result * 100).round() / 100.0;
    _input = result % 1 == 0
        ? result.toInt().toString()
        : result.toStringAsFixed(2);
    _firstOperand = result;
  }

  void _notifyAmount() {
    final double? val = double.tryParse(_input);
    final int cents = val != null ? (val * 100).round() : 0;
    widget.onAmountChanged(cents);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow([
            _buildKey('C', isAction: true, onPressed: _onClear),
            _buildKey('÷', isOperator: true, onPressed: () => _onOperator('÷')),
            _buildKey('×', isOperator: true, onPressed: () => _onOperator('×')),
            _buildKey(
              '⌫',
              isAction: true,
              icon: Icons.backspace_outlined,
              onPressed: _onBackspace,
            ),
          ]),
          _buildRow([
            _buildKey('7', onPressed: () => _onDigit('7')),
            _buildKey('8', onPressed: () => _onDigit('8')),
            _buildKey('9', onPressed: () => _onDigit('9')),
            _buildKey('-', isOperator: true, onPressed: () => _onOperator('-')),
          ]),
          _buildRow([
            _buildKey('4', onPressed: () => _onDigit('4')),
            _buildKey('5', onPressed: () => _onDigit('5')),
            _buildKey('6', onPressed: () => _onDigit('6')),
            _buildKey('+', isOperator: true, onPressed: () => _onOperator('+')),
          ]),
          _buildRow([
            _buildKey('1', onPressed: () => _onDigit('1')),
            _buildKey('2', onPressed: () => _onDigit('2')),
            _buildKey('3', onPressed: () => _onDigit('3')),
            _buildKey('=', isOperator: true, onPressed: _onEquals),
          ]),
          _buildRow([
            _buildKey('00', onPressed: _onDoubleZero),
            _buildKey('0', onPressed: () => _onDigit('0')),
            _buildKey('.', onPressed: _onDecimal),
            _buildKey(
              '✓',
              isDone: true,
              icon: Icons.check,
              onPressed: widget.onDone ?? _onEquals,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children
            .map(
              (child) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: child,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildKey(
    String label, {
    IconData? icon,
    bool isOperator = false,
    bool isAction = false,
    bool isDone = false,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor;

    if (isDone) {
      backgroundColor = colorScheme.primary;
      foregroundColor = colorScheme.onPrimary;
    } else if (isOperator) {
      backgroundColor = colorScheme.primaryContainer;
      foregroundColor = colorScheme.onPrimaryContainer;
    } else if (isAction) {
      backgroundColor = colorScheme.errorContainer.withValues(alpha: 0.7);
      foregroundColor = colorScheme.onErrorContainer;
    } else {
      backgroundColor = colorScheme.surface;
      foregroundColor = colorScheme.onSurface;
    }

    return SizedBox(
      height: 48,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        elevation: 0.5,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: icon != null
                ? Icon(icon, size: 20, color: foregroundColor)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: foregroundColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
