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
          icon: Icons.edit_rounded,
          activityController: activityController,
          durationController: durationController,
          selectedIntensity: selectedIntensity,
          onIntensityChanged: (value) => selectedIntensity = value!,
          onCancel: () => !isLoading ? Navigator.pop(context) : null,
          onConfirm: () async {
            if (activityController.text.isNotEmpty &&
                durationController.text.isNotEmpty) {
              setState(() => isLoading = true);
              try {
                await logService.updateExerciseLog(
                  logId: log.id!,
                  activityName: activityController.text,
                  intensity: selectedIntensity,
                  duration: int.tryParse(durationController.text) ?? 0,
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
            }
          },
          confirmText: "Atualizar",
          isLoading: isLoading,
        ),
      ),
    );
  }
}
