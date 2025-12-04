import 'package:flutter/material.dart';
import 'package:integrador/components/add_exercise_dialog.dart';
import 'package:integrador/services/exercise_service.dart';

class EditExerciseDialog {
  static void show({
    required BuildContext context,
    required ExerciseService logService,
    required dynamic log,
  }) {
    final activityController = TextEditingController(text: log.activityName);
    final durationController = TextEditingController(
      text: log.duration.toString(),
    );

    String selectedIntensity = log.intensity.toLowerCase();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AddExerciseDialog.buildDialog(
          context: context,
          title: "Editar Exercício",
          description: "Atualize os detalhes do seu treino",
          formKey: GlobalKey<FormState>(),
          icon: Icons.edit_rounded,
          activityController: activityController,
          durationController: durationController,
          selectedIntensity: selectedIntensity,
          onIntensityChanged: (value) => selectedIntensity = value!,
          onCancel: () => !isLoading ? Navigator.pop(context) : null,
          onConfirm: () async {
            final durationText = durationController.text;

            if (activityController.text.isEmpty ||
                activityController.text.trim().isEmpty) {
              return _showError(
                context,
                "O campo de nome precisa estar preenchido",
              );
            }

            if (durationText.isEmpty) {
              return _showError(
                context,
                "O campo de minutos não pode ficar vazio.",
              );
            }

            final minutes = int.tryParse(durationText);
            if (minutes == null) {
              return _showError(
                context,
                "Digite um número válido para minutos.",
              );
            }

            if (minutes < 1) {
              return _showError(context, "O mínimo permitido é 1 minuto.");
            }

            if (minutes > 300) {
              return _showError(context, "O máximo permitido é 300 minutos.");
            }

            // Se estiver tudo certo, continua:
            setState(() => isLoading = true);
            try {
              await logService.updateExerciseLog(
                logId: log.id!,
                activityName: activityController.text,
                intensity: selectedIntensity,
                duration: minutes,
              );
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao atualizar: $e'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() => isLoading = false);
            }
          },
          confirmText: "Atualizar",
          isLoading: isLoading,
        ),
      ),
    );
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
