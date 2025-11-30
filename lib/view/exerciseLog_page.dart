import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';
import 'package:integrador/services/exerciseLog_service.dart';

class ExerciseLogPage extends StatelessWidget {
  final AppUser user;

  const ExerciseLogPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final logService = ExerciseLogService(user.clanId!);
    final logStream = logService.getUserLogs(user.id!);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Log de Exercícios"),
        backgroundColor: Colors.deepPurple,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () => _openAddExerciseDialog(context, logService),
      ),

      body: StreamBuilder(
        stream: logStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data!;
          if (logs.isEmpty) {
            return const Center(child: Text("Nenhuma atividade registrada."));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(log.activityName),
                  subtitle: Text(
                    "${log.intensity.toUpperCase()} • ${log.duration} min\n"
                    "Registrado em ${log.timestamp}",
                  ),
                  trailing: Text(
                    "+${log.points}",
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Modal para registrar atividade
  void _openAddExerciseDialog(BuildContext context, ExerciseLogService logService) {
    final activityController = TextEditingController();
    final durationController = TextEditingController();

    String selectedIntensity = "baixa"; // valor padrão

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registrar Exercício"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: activityController,
              decoration: const InputDecoration(labelText: "Nome da atividade"),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedIntensity,
              decoration: const InputDecoration(labelText: "Intensidade"),
              items: const [
                DropdownMenuItem(value: "baixa", child: Text("Baixa")),
                DropdownMenuItem(value: "media", child: Text("Média")),
                DropdownMenuItem(value: "alta", child: Text("Alta")),
              ],
              onChanged: (value) {
                selectedIntensity = value!;
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Duração (minutos)"),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),

          ElevatedButton(
            onPressed: () async {
              await logService.addExerciseLog(
                userId: user.id!,
                userName: user.name,
                activityName: activityController.text,
                intensity: selectedIntensity,
                duration: int.tryParse(durationController.text) ?? 0,
              );

              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }
}
