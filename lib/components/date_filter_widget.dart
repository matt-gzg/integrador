import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilterWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;
  final VoidCallback onClearFilter;

  const DateFilterWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onClearFilter,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
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
      onDateSelected(DateTime(picked.year, picked.month, picked.day));
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
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
                SizedBox(height: 4),
                Text(
                  selectedDate == null
                      ? "Mostrando todos os registros"
                      : DateFormat("EEEE, dd 'de' MMMM 'de' yyyy").format(selectedDate!),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              if (selectedDate != null)
                _buildIconButton(
                  icon: Icons.close,
                  tooltip: "Limpar filtro",
                  onPressed: onClearFilter,
                  color: Colors.grey[700]!.withOpacity(0.3),
                ),
              if (selectedDate != null) SizedBox(width: 8),

              if (selectedDate != null)
                _buildIconButton(
                  icon: Icons.chevron_left,
                  tooltip: "Dia anterior",
                  onPressed: () {
                    onDateSelected(selectedDate!.subtract(Duration(days: 1)));
                  },
                  color: Colors.grey[800]!.withOpacity(0.3),
                ),
              if (selectedDate != null) SizedBox(width: 8),

              _buildIconButton(
                icon: Icons.calendar_today,
                tooltip: selectedDate == null ? "Selecionar data" : "Alterar data",
                onPressed: () => _selectDate(context),
                isGradient: true,
              ),

              if (selectedDate != null) SizedBox(width: 8),
              if (selectedDate != null)
                _buildIconButton(
                  icon: Icons.chevron_right,
                  tooltip: "Próximo dia",
                  onPressed: selectedDate!.isAtSameMomentAs(DateTime.now()) ||
                          selectedDate!.isAfter(DateTime.now())
                      ? null
                      : () {
                          onDateSelected(selectedDate!.add(Duration(days: 1)));
                        },
                  color: Colors.grey[800]!.withOpacity(0.3),
                ),
            ],
          ),
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