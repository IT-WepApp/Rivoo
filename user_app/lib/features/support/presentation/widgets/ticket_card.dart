import 'package:flutter/material.dart';
import 'package:user_app/features/support/domain/ticket.dart';
import 'package:intl/intl.dart';

class TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const TicketCard({
    Key? key,
    required this.ticket,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة
              Row(
                children: [
                  // رمز نوع التذكرة
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTicketTypeIcon(ticket.type),
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // معلومات التذكرة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.subject,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تذكرة #${ticket.id.substring(0, 8)} • ${_formatDate(ticket.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // حالة التذكرة
                  _buildStatusChip(context, ticket.status),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // وصف التذكرة
              Text(
                ticket.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // معلومات إضافية
              Row(
                children: [
                  // الأولوية
                  _buildPriorityChip(context, ticket.priority),
                  
                  const Spacer(),
                  
                  // عدد الرسائل غير المقروءة
                  if (ticket.unreadMessages > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mark_email_unread,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ticket.unreadMessages}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(width: 8),
                  
                  // زر الإجراءات
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء شريحة الحالة
  Widget _buildStatusChip(BuildContext context, TicketStatus status) {
    String label;
    Color color;
    
    switch (status) {
      case TicketStatus.open:
        label = 'مفتوحة';
        color = Colors.blue;
        break;
      case TicketStatus.pending:
        label = 'قيد الانتظار';
        color = Colors.orange;
        break;
      case TicketStatus.resolved:
        label = 'تم الحل';
        color = Colors.green;
        break;
      case TicketStatus.closed:
        label = 'مغلقة';
        color = Colors.grey;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // بناء شريحة الأولوية
  Widget _buildPriorityChip(BuildContext context, TicketPriority priority) {
    String label;
    Color color;
    
    switch (priority) {
      case TicketPriority.low:
        label = 'منخفضة';
        color = Colors.green;
        break;
      case TicketPriority.medium:
        label = 'متوسطة';
        color = Colors.blue;
        break;
      case TicketPriority.high:
        label = 'عالية';
        color = Colors.orange;
        break;
      case TicketPriority.urgent:
        label = 'عاجلة';
        color = Colors.red;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // الحصول على أيقونة نوع التذكرة
  IconData _getTicketTypeIcon(TicketType type) {
    switch (type) {
      case TicketType.general:
        return Icons.help_outline;
      case TicketType.orderIssue:
        return Icons.shopping_bag;
      case TicketType.paymentIssue:
        return Icons.payment;
      case TicketType.accountIssue:
        return Icons.person;
      case TicketType.appIssue:
        return Icons.smartphone;
      case TicketType.suggestion:
        return Icons.lightbulb_outline;
      case TicketType.other:
        return Icons.more_horiz;
    }
  }

  // تنسيق التاريخ
  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }
}
