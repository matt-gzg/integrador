import 'package:flutter/material.dart';
import 'package:integrador/services/exerciseLog_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LogCardWidget extends StatelessWidget {
  final dynamic log;
  final VoidCallback onTap;

  const LogCardWidget({
    super.key,
    required this.log,
    required this.onTap,
  });

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
        onTap: onTap,
      ),
    );
  }
}