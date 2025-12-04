import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';
import 'package:integrador/services/exercise_service.dart';

class AddExerciseDialog {
  static void show({
    required BuildContext context,
    required ExerciseService logService,
    required AppUser user,
  }) {
    final activityController = TextEditingController();
    final durationController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String selectedIntensity = "baixa";

    showDialog(
      context: context,
      builder: (context) => buildDialog(
        context: context,
        formKey: formKey,
        title: "Registrar Exercício",
        description: "Adicione os detalhes do seu treino",
        icon: Icons.fitness_center_rounded,
        activityController: activityController,
        durationController: durationController,
        selectedIntensity: selectedIntensity,
        onIntensityChanged: (value) => selectedIntensity = value!,
        onCancel: () => Navigator.pop(context),
        onConfirm: () async {
          await logService.addExerciseLog(
            userId: user.id!,
            userName: user.name,
            activityName: activityController.text,
            intensity: selectedIntensity,
            duration: int.parse(durationController.text),
          );
          Navigator.pop(context);
        },
        confirmText: "Salvar",
      ),
    );
  }
  static Widget buildDialog({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required TextEditingController activityController,
    required TextEditingController durationController,
    required String selectedIntensity,
    required ValueChanged<String?> onIntensityChanged,
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
    required String confirmText,
    required GlobalKey<FormState> formKey,
    bool isLoading = false,
  }) {
    return Dialog(
      backgroundColor: Color(0xFF111111),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey[800]!, width: 1),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade600, Colors.orange.shade800],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                SizedBox(height: 16),

                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[800]!, width: 1),
                  ),
                  child: TextFormField(
                    controller: activityController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Nome da atividade",
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.trim().isEmpty) {
                        return "Informe o nome da atividade.";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16),

                _buildIntensityDropdown(
                  selectedIntensity: selectedIntensity,
                  onChanged: onIntensityChanged,
                ),
                SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[800]!, width: 1),
                  ),
                  child: TextFormField(
                    controller: durationController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Duração (minutos)",
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Informe a duração em minutos.";
                      }

                      final minutes = int.tryParse(value);
                      if (minutes == null) {
                        return "Digite um número válido.";
                      }

                      if (minutes < 1) {
                        return "A duração mínima é 1 minuto.";
                      }

                      if (minutes > 300) {
                        return "A duração máxima é 300 minutos.";
                      }

                      return null;
                    },
                  ),
                ),

                SizedBox(height: 24),

                _buildDialogButtons(
                  onCancel: onCancel,
                  onConfirm: () {
                    if (formKey.currentState?.validate() == true) {
                      onConfirm(); // chama o callback normal
                    }
                  },

                  confirmText: confirmText,
                  isLoading: isLoading,
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

  static Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  static Widget _buildIntensityDropdown({
    required String selectedIntensity,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: Color(0xFF1A1A1A),
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: "Intensidade",
          labelStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
        initialValue: selectedIntensity,
        items: const [
          DropdownMenuItem(
            value: "baixa",
            child: Text("Baixa", style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: "media",
            child: Text("Média", style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: "alta",
            child: Text("Alta", style: TextStyle(color: Colors.white)),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  static Widget _buildDialogButtons({
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
    required String confirmText,
    bool isLoading = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[600]!, width: 1),
            ),
            child: TextButton(
              onPressed: isLoading ? null : onCancel,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Cancelar",
                style: TextStyle(
                  color: isLoading ? Colors.grey[600] : Colors.grey[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),

        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.orange.shade800],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: isLoading ? null : onConfirm,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      confirmText,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
