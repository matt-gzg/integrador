import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Formatador de máscara para data brasileira (DD/MM/YYYY)
class DateMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Se o texto está vazio, retorna como está
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove caracteres não numéricos
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limita a 8 dígitos (DDMMYYYY)
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }

    // Aplica a máscara
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class DateFilterWidget extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;
  final VoidCallback onClearFilter;

  const DateFilterWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onClearFilter,
  });

  @override
  State<DateFilterWidget> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterWidget> {
  late TextEditingController _dateInputController;

  @override
  void initState() {
    super.initState();
    _dateInputController = TextEditingController(
      text: widget.selectedDate != null
          ? DateFormat("dd/MM/yyyy").format(widget.selectedDate!)
          : "",
    );
  }

  @override
  void didUpdateWidget(DateFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _dateInputController.text = widget.selectedDate != null
          ? DateFormat("dd/MM/yyyy").format(widget.selectedDate!)
          : "";
    }
  }

  @override
  void dispose() {
    _dateInputController.dispose();
    super.dispose();
  }

  void _parseAndSetDate(String input) {
    if (input.isEmpty) {
      widget.onClearFilter();
      return;
    }

    try {
      // Remove caracteres não-numéricos
      String cleanInput = input.replaceAll(RegExp(r'\D'), '');

      if (cleanInput.length == 8) {
        int day = int.parse(cleanInput.substring(0, 2));
        int month = int.parse(cleanInput.substring(2, 4));
        int year = int.parse(cleanInput.substring(4, 8));

        // Validações básicas
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          final parsedDate = DateTime(year, month, day);
          widget.onDateSelected(parsedDate);
        }
      }
    } catch (e) {
      // Ignora erros de parsing
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Color(0xFF111111),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color(0xFF111111),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDateSelected(DateTime(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Filtrar por data",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[800]!, width: 1),
                  ),
                  child: TextField(
                    controller: _dateInputController,
                    style: TextStyle(color: Colors.white),
                    inputFormatters: [DateMaskFormatter()],
                    keyboardType: TextInputType.number,
                    onChanged: _parseAndSetDate,
                    decoration: InputDecoration(
                      hintText: "DD/MM/YYYY",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.calendar_today,
                tooltip: widget.selectedDate == null
                    ? "Selecionar data"
                    : "Alterar data",
                onPressed: () => _selectDate(context),
                isGradient: true,
              ),
            ],
          ),
          if (widget.selectedDate != null) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat(
                    "EEEE, dd 'de' MMMM 'de' yyyy",
                    "pt_BR",
                  ).format(widget.selectedDate!),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    _buildIconButton(
                      icon: Icons.chevron_left,
                      tooltip: "Dia anterior",
                      onPressed: () {
                        widget.onDateSelected(
                          widget.selectedDate!.subtract(Duration(days: 1)),
                        );
                      },
                      color: Colors.grey[800]!.withOpacity(0.3),
                    ),
                    SizedBox(width: 4),
                    _buildIconButton(
                      icon: Icons.close,
                      tooltip: "Limpar filtro",
                      onPressed: widget.onClearFilter,
                      color: Colors.grey[700]!.withOpacity(0.3),
                    ),
                    SizedBox(width: 4),
                    _buildIconButton(
                      icon: Icons.chevron_right,
                      tooltip: "Próximo dia",
                      onPressed:
                          widget.selectedDate!.isAtSameMomentAs(
                                DateTime.now(),
                              ) ||
                              widget.selectedDate!.isAfter(DateTime.now())
                          ? null
                          : () {
                              widget.onDateSelected(
                                widget.selectedDate!.add(Duration(days: 1)),
                              );
                            },
                      color: Colors.grey[800]!.withOpacity(0.3),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    Color? color,
    bool isGradient = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isGradient ? null : color,
        gradient: isGradient
            ? LinearGradient(
                colors: [Colors.orange.shade600, Colors.orange.shade800],
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isGradient
            ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip: tooltip,
      ),
    );
  }
}
