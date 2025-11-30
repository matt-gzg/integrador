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
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(
          "Exercícios",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Color(0xFF111111),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.orange),
        centerTitle: true,
      ),

      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade600,
              Colors.orange.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, color: Colors.white, size: 28),
          onPressed: () => _openAddExerciseDialog(context, logService),
        ),
      ),

      body: StreamBuilder(
        stream: logStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _buildLogSkeleton();
          }

          final logs = snapshot.data!;
          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[800]!.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: Colors.grey[600],
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Nenhuma atividade registrada",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Clique no + para adicionar seu primeiro exercício",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return _buildLogCard(log, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildLogCard(log, int index) {
    Color intensityColor;
    String intensityLabel;
    
    switch (log.intensity.toLowerCase()) {
      case "alta":
        intensityColor = Colors.red.shade400;
        intensityLabel = "ALTA";
        break;
      case "media":
        intensityColor = Colors.orange.shade400;
        intensityLabel = "MÉDIA";
        break;
      case "baixa":
      default:
        intensityColor = Colors.green.shade400;
        intensityLabel = "BAIXA";
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF111111),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade600,
                Colors.orange.shade800,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          log.activityName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: intensityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: intensityColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    intensityLabel,
                    style: TextStyle(
                      color: intensityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "${log.duration}min",
                    style: TextStyle(
                      color: Colors.blue.shade400,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              "Registrado em ${log.timestamp}",
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade600,
                Colors.orange.shade800,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            "+${log.points}",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogSkeleton() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: List.generate(5, (index) => Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        )),
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
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header do modal
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade600,
                      Colors.orange.shade800,
                    ],
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
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(height: 16),
              
              Text(
                "Registrar Exercício",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              
              Text(
                "Adicione os detalhes do seu treino",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 24),

              // Campos do formulário
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: activityController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Nome da atividade",
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),

              SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
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
                  value: selectedIntensity,
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
                  onChanged: (value) {
                    selectedIntensity = value!;
                  },
                ),
              ),

              SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: durationController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Duração (minutos)",
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[600]!,
                          width: 1,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                            color: Colors.grey[400],
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
                          colors: [
                            Colors.orange.shade600,
                            Colors.orange.shade800,
                          ],
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
                        onPressed: () async {
                          if (activityController.text.isNotEmpty && durationController.text.isNotEmpty) {
                            await logService.addExerciseLog(
                              userId: user.id!,
                              userName: user.name,
                              activityName: activityController.text,
                              intensity: selectedIntensity,
                              duration: int.tryParse(durationController.text) ?? 0,
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Salvar",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}