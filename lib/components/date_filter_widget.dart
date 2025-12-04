import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DateMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }

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
    // tempDate guarda a seleção enquanto o modal está aberto
    DateTime tempDate = widget.selectedDate ?? DateTime.now();

    // controller inicializado com a data atual/selecionada
    final TextEditingController controller = TextEditingController(
      text: DateFormat("dd/MM/yyyy").format(tempDate),
    );

    // Função utilitária para parsear string "DD/MM/YYYY" -> DateTime?
    DateTime? parseMaskedDate(String text) {
      final clean = text.replaceAll(RegExp(r'\D'), '');
      if (clean.length != 8) return null;
      try {
        final d = int.parse(clean.substring(0, 2));
        final m = int.parse(clean.substring(2, 4));
        final y = int.parse(clean.substring(4, 8));
        final candidate = DateTime(y, m, d);
        if (candidate.year == y && candidate.month == m && candidate.day == d) {
          return candidate;
        }
      } catch (_) {}
      return null;
    }

    // Abre um dialog customizado que mantém o visual do calendário Material
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFF111111),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              inputFormatters: [DateMaskFormatter()],
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF1A1A1A),
                                hintText: 'DD/MM/YYYY',
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) {
                                final pd = parseMaskedDate(value);
                                if (pd != null) {
                                  tempDate = pd;
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 173, 71, 71),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                controller.clear();
                                tempDate = DateTime.now();
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Theme(
                        data: Theme.of(context).copyWith(
                          textTheme: const TextTheme(
                            // Dias normais do calendário
                            bodyMedium: TextStyle(color: Colors.white),

                            // Também muda dias fora do mês caso queira
                            bodySmall: TextStyle(color: Colors.white70),
                          ),
                          colorScheme: ColorScheme.dark(
                            primary: Colors.orange, // Cor do dia selecionado
                            onPrimary: Colors
                                .black, // Cor do texto quando o dia está selecionado
                            surface: const Color(
                              0xFF111111,
                            ), // Fundo do calendário
                          ),
                        ),
                        child: CalendarDatePicker(
                          key: ValueKey(
                            tempDate.month,
                          ), // mantém o seu rebuild do mês
                          initialDate: tempDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          onDateChanged: (date) {
                            tempDate = date;
                            final formatted = DateFormat(
                              "dd/MM/yyyy",
                            ).format(date);

                            controller.value = controller.value.copyWith(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                offset: formatted.length,
                              ),
                            );

                            setState(() {});
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              controller.clear();
                              widget.onClearFilter();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Limpar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              final today = DateTime.now();
                              tempDate = DateTime(
                                today.year,
                                today.month,
                                today.day,
                              );
                              final formatted = DateFormat(
                                "dd/MM/yyyy",
                              ).format(tempDate);
                              controller.value = controller.value.copyWith(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: formatted.length,
                                ),
                              );
                              setState(() {});
                            },
                            child: const Text(
                              'Hoje',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: () {
                              // preferimos valor digitado se for válido
                              final fromField = parseMaskedDate(
                                controller.text,
                              );
                              final result = fromField ?? tempDate;
                              widget.onDateSelected(
                                DateTime(result.year, result.month, result.day),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Confirmar',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
              children: [
                Expanded(
                  child: Text(
                    DateFormat(
                      "EEEE, dd 'de' MMMM 'de' yyyy",
                      "pt_BR",
                    ).format(widget.selectedDate!),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 8),
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
