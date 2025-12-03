import 'package:flutter/material.dart';
import 'package:integrador/components/add_exercise_dialog.dart';
import 'package:integrador/services/exerciseLog_service.dart';
import 'package:integrador/components/add_exercise_dialog.dart';

class EditExerciseDialog {
  static void show({
    required BuildContext context,
    required ExerciseLogService logService,
    required dynamic log,
  }) {
    final activityController = TextEditingController(text: log.activityName);
    final durationController = TextEditingController(
      text: log.duration.toString(),
    );

    String selectedIntensity = log.intensity.toLowerCase();

    showDialog(
      context: context,
      builder: (context) => AddExerciseDialog.buildDialog(
        context: context,
        title: "Editar Exercício",
        description: "Atualize os detalhes do seu treino",
        icon: Icons.edit_rounded,
        activityController: activityController,
        durationController: durationController,
        selectedIntensity: selectedIntensity,
        onIntensityChanged: (value) => selectedIntensity = value!,
        onCancel: () => Navigator.pop(context),
        onConfirm: () async {
          if (activityController.text.isNotEmpty &&
              durationController.text.isNotEmpty) {
            await logService.updateExerciseLog(
              logId: log.id!,
              activityName: activityController.text,
              intensity: selectedIntensity,
              duration: int.tryParse(durationController.text) ?? 0,
            );
            Navigator.pop(context);
          }
        },
        confirmText: "Atualizar",
      ),
    );
  }
}