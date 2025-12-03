import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';
import 'package:integrador/services/exerciseLog_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseLogPage extends StatefulWidget {
  final AppUser user;

  const ExerciseLogPage({super.key, required this.user});

  @override
  State<ExerciseLogPage> createState() => _ExerciseLogPageState();
}

class _ExerciseLogPageState extends State<ExerciseLogPage> {
  DateTime? _selectedDate;
  late ExerciseLogService logService;
  late Stream<List<dynamic>> logStream;

  @override
  void initState() {
    super.initState();
    logService = ExerciseLogService(widget.user.clanId!);
    logStream = logService.getUserLogs(widget.user.id!);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
  }

  List<dynamic> _filterLogsByDate(List<dynamic> allLogs) {
    if (_selectedDate == null) {
      return allLogs;
    }
    
    return allLogs.where((log) {
      try {
        DateTime logDate;
        if (log.timestamp is String) {
          logDate = DateTime.parse(log.timestamp);
        } else if (log.timestamp is Timestamp) {
          logDate = (log.timestamp as Timestamp).toDate();
        } else if (log.timestamp is DateTime) {
          logDate = log.timestamp;
        } else {
          return false;
        }

        return logDate.year == _selectedDate!.year &&
            logDate.month == _selectedDate!.month &&
            logDate.day == _selectedDate!.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  String _formatarDataBrasileira(dynamic timestamp) {
    if (timestamp == null) return "Data não disponível";

    try {
      DateTime dateTime;

      if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else {
        return "Formato inválido";
      }

      return DateFormat("dd/MM/yyyy 'às' HH:mm").format(dateTime);
    } catch (e) {
      return "Erro na data";
    }
  }

  @override
  Widget build(BuildContext context) {
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
            colors: [Colors.orange.shade600, Colors.orange.shade800],
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

      body: Column(
        children: [
          _buildDateFilter(context),

          Expanded(
            child: StreamBuilder(
              stream: logStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _buildLogSkeleton();
                }

                final allLogs = snapshot.data!;
                final filteredLogs = _filterLogsByDate(allLogs);

                if (filteredLogs.isEmpty) {
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
                          _selectedDate == null
                              ? "Nenhuma atividade registrada"
                              : _selectedDate!.day == DateTime.now().day &&
                                      _selectedDate!.month == DateTime.now().month &&
                                      _selectedDate!.year == DateTime.now().year
                                  ? "Nenhuma atividade registrada hoje"
                                  : "Nenhuma atividade registrada em ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Clique no + para adicionar um exercício",
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
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    return _buildLogCard(log, index, context, logService);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
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
                  _selectedDate == null
                      ? "Mostrando todos os registros"
                      : DateFormat("EEEE, dd 'de' MMMM 'de' yyyy").format(_selectedDate!),
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
              if (_selectedDate != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[700]!.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: _clearDateFilter,
                    padding: EdgeInsets.zero,
                    tooltip: "Limpar filtro",
                  ),
                ),
              if (_selectedDate != null) SizedBox(width: 8),

              if (_selectedDate != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[800]!.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.chevron_left, color: Colors.white, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate!.subtract(Duration(days: 1));
                      });
                    },
                    padding: EdgeInsets.zero,
                    tooltip: "Dia anterior",
                  ),
                ),
              if (_selectedDate != null) SizedBox(width: 8),

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade600, Colors.orange.shade800],
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
                child: IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _selectDate(context),
                  padding: EdgeInsets.zero,
                  tooltip: _selectedDate == null ? "Selecionar data" : "Alterar data",
                ),
              ),

              if (_selectedDate != null) SizedBox(width: 8),
              if (_selectedDate != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[800]!.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _selectedDate!.isAtSameMomentAs(DateTime.now()) ||
                            _selectedDate!.isAfter(DateTime.now())
                        ? null
                        : () {
                            setState(() {
                              _selectedDate = _selectedDate!.add(Duration(days: 1));
                            });
                          },
                    padding: EdgeInsets.zero,
                    tooltip: "Próximo dia",
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(
    log,
    int index,
    BuildContext context,
    ExerciseLogService logService,
  ) {
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
          colors: [Color(0xFF1A1A1A), Color(0xFF111111)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 1),
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
              colors: [Colors.orange.shade600, Colors.orange.shade800],
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
              "Registrado em ${_formatarDataBrasileira(log.timestamp)}",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade600, Colors.orange.shade800],
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
        onTap: () => _showExerciseOptions(context, logService, log),
      ),
    );
  }

  void _showExerciseOptions(
    BuildContext context,
    ExerciseLogService logService,
    log,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade600, Colors.orange.shade800],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(height: 12),

              Text(
                log.activityName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),

              Text(
                "${log.duration}min • ${log.intensity}",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              SizedBox(height: 20),

              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fecha o popup atual
                    _openEditExerciseDialog(context, logService, log);
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_rounded, color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Editar Exercício",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12),

              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fecha o popup atual
                    _showDeleteConfirmationDialog(context, logService, log);
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Excluir Exercício",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[600]!, width: 1),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogSkeleton() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
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
          ),
        ),
      ),
    );
  }

  void _openAddExerciseDialog(
    BuildContext context,
    ExerciseLogService logService,
  ) {
    final activityController = TextEditingController();
    final durationController = TextEditingController();

    String selectedIntensity = "baixa"; // valor padrão

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
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
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!, width: 1),
                ),
                child: TextField(
                  controller: activityController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Nome da atividade",
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              Container(
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
                  value: selectedIntensity,
                  items: const [
                    DropdownMenuItem(
                      value: "baixa",
                      child: Text(
                        "Baixa",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "media",
                      child: Text(
                        "Média",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "alta",
                      child: Text(
                        "Alta",
                        style: TextStyle(color: Colors.white),
                      ),
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
                  border: Border.all(color: Colors.grey[800]!, width: 1),
                ),
                child: TextField(
                  controller: durationController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Duração (minutos)",
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
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
                        border: Border.all(color: Colors.grey[600]!, width: 1),
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
                          if (activityController.text.isNotEmpty &&
                              durationController.text.isNotEmpty) {
                            await logService.addExerciseLog(
                              userId: widget.user.id!,
                              userName: widget.user.name,
                              activityName: activityController.text,
                              intensity: selectedIntensity,
                              duration:
                                  int.tryParse(durationController.text) ?? 0,
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

  void _openEditExerciseDialog(
    BuildContext context,
    ExerciseLogService logService,
    log,
  ) {
    final activityController = TextEditingController(text: log.activityName);
    final durationController = TextEditingController(
      text: log.duration.toString(),
    );

    String selectedIntensity = log.intensity.toLowerCase();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
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
                child: Icon(Icons.edit_rounded, color: Colors.white, size: 28),
              ),
              SizedBox(height: 16),

              Text(
                "Editar Exercício",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),

              Text(
                "Atualize os detalhes do seu treino",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!, width: 1),
                ),
                child: TextField(
                  controller: activityController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Nome da atividade",
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              Container(
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
                  value: selectedIntensity,
                  items: const [
                    DropdownMenuItem(
                      value: "baixa",
                      child: Text(
                        "Baixa",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "media",
                      child: Text(
                        "Média",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "alta",
                      child: Text(
                        "Alta",
                        style: TextStyle(color: Colors.white),
                      ),
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
                  border: Border.all(color: Colors.grey[800]!, width: 1),
                ),
                child: TextField(
                  controller: durationController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Duração (minutos)",
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              Row(
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
                          if (activityController.text.isNotEmpty &&
                              durationController.text.isNotEmpty) {
                            await logService.updateExerciseLog(
                              logId: log.id!,
                              activityName: activityController.text,
                              intensity: selectedIntensity,
                              duration:
                                  int.tryParse(durationController.text) ?? 0,
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
                          "Atualizar",
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

  void _showDeleteConfirmationDialog(
    BuildContext context,
    ExerciseLogService logService,
    log,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(Icons.warning_rounded, color: Colors.red, size: 30),
              ),
              SizedBox(height: 20),

              Text(
                "Excluir Exercício",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              Text(
                "Tem certeza que deseja excluir '${log.activityName}'? Esta ação não pode ser desfeita.",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              Row(
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
                          colors: [Colors.red.shade600, Colors.red.shade800],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () async {
                          await logService.deleteExerciseLog(log.id!);
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Excluir",
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