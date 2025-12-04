import 'package:flutter/material.dart';
import 'package:integrador/services/exerciseLog_service.dart';

class ExerciseOptionsDialog {
  static void show({
    required BuildContext context,
    required dynamic log,
    required ExerciseLogService logService,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
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

              _buildActionButton(
                icon: Icons.edit_rounded,
                label: "Editar Exercício",
                color: Colors.orange,
                onPressed: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),

              SizedBox(height: 12),

              _buildActionButton(
                icon: Icons.delete_rounded,
                label: "Excluir Exercício",
                color: Colors.red,
                onPressed: () {
                  Navigator.pop(context);
                  onDelete();
                },
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

  static Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}