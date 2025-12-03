import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';
import 'package:integrador/services/exerciseLog_service.dart';
import 'package:integrador/components/date_filter_widget.dart';
import 'package:integrador/components/log_card_widget.dart';
import 'package:integrador/components/log_skeleton_widget.dart';
import 'package:integrador/components/add_exercise_dialog.dart';
import 'package:integrador/components/edit_exercise_dialog.dart';
import 'package:integrador/components/delete_confirmation_dialog.dart';
import 'package:integrador/components/exercise_options_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  void _setSelectedDate(DateTime? date) {
    setState(() {
      _selectedDate = date;
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
          onPressed: () => AddExerciseDialog.show(
            context: context,
            logService: logService,
            user: widget.user,
          ),
        ),
      ),

      body: Column(
        children: [
          DateFilterWidget(
            selectedDate: _selectedDate,
            onDateSelected: _setSelectedDate,
            onClearFilter: () => _setSelectedDate(null),
          ),

          Expanded(
            child: StreamBuilder(
              stream: logStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return LogSkeletonWidget();
                }

                final allLogs = snapshot.data!;
                final filteredLogs = _filterLogsByDate(allLogs);

                if (filteredLogs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    return LogCardWidget(
                      log: log,
                      onTap: () => ExerciseOptionsDialog.show(
                        context: context,
                        log: log,
                        logService: logService,
                        onEdit: () => EditExerciseDialog.show(
                          context: context,
                          logService: logService,
                          log: log,
                        ),
                        onDelete: () => DeleteConfirmationDialog.show(
                          context: context,
                          logService: logService,
                          log: log,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
}