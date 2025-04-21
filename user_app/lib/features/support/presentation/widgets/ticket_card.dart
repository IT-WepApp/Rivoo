import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:user_app/features/support/domain/entities/ticket.dart';

/// بطاقة التذكرة
class TicketCard extends StatelessWidget {
  /// التذكرة
  final Ticket ticket;
  
  /// دالة تنفذ عند النقر على البطاقة
  final VoidCallback? onTap;

  /// إنشاء بطاقة تذكرة
  const TicketCard({
    Key? key,
    required this.ticket,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رقم التذكرة والحالة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // رقم التذكرة
                  Text(
                    'تذكرة #${ticket.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  
                  // حالة التذكرة
                  _buildStatusChip(),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // عنوان التذكرة
              Text(
                ticket.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // وصف التذكرة
              Text(
                ticket.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // التاريخ والأولوية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // تاريخ الإنشاء
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(ticket.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  // الأولوية
                  _buildPriorityChip(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء شريحة حالة التذكرة
  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String statusText;
    
    switch (ticket.status) {
      case TicketStatus.new_:
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        statusText = 'جديدة';
        break;
      case TicketStatus.inProgress:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        statusText = 'قيد المعالجة';
        break;
      case TicketStatus.waitingForUserResponse:
        backgroundColor = Colors.purple.withOpacity(0.2);
        textColor = Colors.purple;
        statusText = 'بانتظار الرد';
        break;
      case TicketStatus.closed:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        statusText = 'مغلقة';
        break;
      case TicketStatus.cancelled:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        statusText = 'ملغاة';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  /// بناء شريحة أولوية التذكرة
  Widget _buildPriorityChip() {
    Color backgroundColor;
    Color textColor;
    String priorityText;
    
    switch (ticket.priority) {
      case TicketPriority.low:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        priorityText = 'منخفضة';
        break;
      case TicketPriority.medium:
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        priorityText = 'متوسطة';
        break;
      case TicketPriority.high:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        priorityText = 'عالية';
        break;
      case TicketPriority.critical:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        priorityText = 'حرجة';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priorityText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
