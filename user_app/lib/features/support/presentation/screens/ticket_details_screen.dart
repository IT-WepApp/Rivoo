import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:user_app/core/widgets/app_button.dart';
import 'package:user_app/core/widgets/app_text_field.dart';
import 'package:shared_libs/entities/ticket_entity.dart';
import 'package:shared_libs/enums/ticket_status.dart';
import 'package:user_app/flutter_gen/gen_l10n/app_localizations.dart';

/// شاشة تفاصيل تذكرة الدعم
class TicketDetailsScreen extends StatefulWidget {
  /// معرف التذكرة
  final String ticketId;

  /// إنشاء شاشة تفاصيل تذكرة الدعم
  const TicketDetailsScreen({
    Key? key,
    required this.ticketId,
  }) : super(key: key);

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  final _messageController = TextEditingController();
  bool _isLoading = true;
  bool _isSending = false;
  Ticket? _ticket;
  List<TicketMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadTicketDetails();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// تحميل تفاصيل التذكرة
  Future<void> _loadTicketDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // استدعاء واجهة برمجة التطبيقات للحصول على تفاصيل التذكرة
      await Future.delayed(const Duration(seconds: 1));
      
      // بيانات وهمية للعرض
      setState(() {
        _ticket = Ticket(
          id: widget.ticketId,
          subject: 'مشكلة في الدفع',
          category: 'payment',
          priority: 'high',
          message: 'لم أتمكن من إتمام عملية الدفع، وتم خصم المبلغ من حسابي دون إتمام الطلب.',
          status: 'open',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        
        _messages = [
          TicketMessage(
            id: 'msg_1',
            ticketId: widget.ticketId,
            message: 'لم أتمكن من إتمام عملية الدفع، وتم خصم المبلغ من حسابي دون إتمام الطلب.',
            sender: MessageSender.user,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            attachments: [],
          ),
          TicketMessage(
            id: 'msg_2',
            ticketId: widget.ticketId,
            message: 'شكرًا لتواصلك معنا. نأسف للإزعاج الذي تعرضت له. هل يمكنك تزويدنا برقم الطلب ورقم المعاملة المالية لنتمكن من التحقق من المشكلة؟',
            sender: MessageSender.support,
            createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 23)),
            attachments: [],
          ),
          TicketMessage(
            id: 'msg_3',
            ticketId: widget.ticketId,
            message: 'رقم الطلب هو #ORD12345 ورقم المعاملة المالية هو TRX98765.',
            sender: MessageSender.user,
            createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 20)),
            attachments: [],
          ),
          TicketMessage(
            id: 'msg_4',
            ticketId: widget.ticketId,
            message: 'شكرًا لتزويدنا بالمعلومات. لقد تحققنا من المعاملة ووجدنا أن هناك مشكلة في معالجة الطلب. تم إعادة المبلغ إلى حسابك وسيظهر خلال 3-5 أيام عمل. هل ترغب في إعادة محاولة الطلب؟',
            sender: MessageSender.support,
            createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 18)),
            attachments: [],
          ),
        ];
      });
    } catch (e) {
      // معالجة الخطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.ticketDetails),
        actions: [
          if (_ticket != null)
            PopupMenuButton<String>(
              onSelected: _handleMenuItemSelected,
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'close',
                  child: Text(_ticket!.status == 'closed'
                      ? localizations.reopenTicket
                      : localizations.closeTicket),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ticket == null
              ? Center(
                  child: Text(localizations.ticketNotFound),
                )
              : Column(
                  children: [
                    // تفاصيل التذكرة
                    _buildTicketDetails(localizations),
                    
                    // قائمة الرسائل
                    Expanded(
                      child: _buildMessagesList(),
                    ),
                    
                    // حقل إدخال الرسالة
                    _buildMessageInput(localizations),
                  ],
                ),
    );
  }

  /// بناء تفاصيل التذكرة
  Widget _buildTicketDetails(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الموضوع
          Text(
            _ticket!.subject,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // معلومات التذكرة
          Row(
            children: [
              // المعرف
              _buildInfoChip(
                label: localizations.ticketId,
                value: '#${_ticket!.id}',
              ),
              
              const SizedBox(width: 8),
              
              // الحالة
              _buildStatusChip(
                status: _ticket!.status,
                localizations: localizations,
              ),
              
              const SizedBox(width: 8),
              
              // الأولوية
              _buildPriorityChip(
                priority: _ticket!.priority,
                localizations: localizations,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // التاريخ
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${localizations.created}: ${_formatDate(_ticket!.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.update,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${localizations.updated}: ${_formatDate(_ticket!.updatedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء شريحة معلومات
  Widget _buildInfoChip({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }

  /// بناء شريحة الحالة
  Widget _buildStatusChip({
    required String status,
    required AppLocalizations localizations,
  }) {
    Color color;
    String text;
    
    switch (status) {
      case 'open':
        color = Colors.green;
        text = localizations.open;
        break;
      case 'closed':
        color = Colors.red;
        text = localizations.closed;
        break;
      case 'pending':
        color = Colors.orange;
        text = localizations.pending;
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// بناء شريحة الأولوية
  Widget _buildPriorityChip({
    required String priority,
    required AppLocalizations localizations,
  }) {
    Color color;
    String text;
    
    switch (priority) {
      case 'low':
        color = Colors.blue;
        text = localizations.low;
        break;
      case 'medium':
        color = Colors.orange;
        text = localizations.medium;
        break;
      case 'high':
        color = Colors.red;
        text = localizations.high;
        break;
      default:
        color = Colors.grey;
        text = priority;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// بناء قائمة الرسائل
  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      reverse: true,
      itemBuilder: (context, index) {
        final reversedIndex = _messages.length - 1 - index;
        final message = _messages[reversedIndex];
        final isUser = message.sender == MessageSender.user;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) _buildAvatar(isUser),
              
              const SizedBox(width: 8),
              
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // فقاعة الرسالة
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? AppTheme.primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message.message,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // الوقت
                    Text(
                      _formatDateTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    
                    // المرفقات (إن وجدت)
                    if (message.attachments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: message.attachments.map((attachment) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.attach_file,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  attachment,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              if (isUser) _buildAvatar(isUser),
            ],
          ),
        );
      },
    );
  }

  /// بناء الصورة الرمزية
  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser ? AppTheme.primaryColor : Colors.grey[300],
      child: Icon(
        isUser ? Icons.person : Icons.support_agent,
        size: 16,
        color: isUser ? Colors.white : Colors.grey[700],
      ),
    );
  }

  /// بناء حقل إدخال الرسالة
  Widget _buildMessageInput(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر إضافة مرفق
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _ticket!.status == 'closed' ? null : _addAttachment,
            color: AppTheme.primaryColor,
          ),
          
          // حقل إدخال الرسالة
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: _ticket!.status == 'closed'
                    ? localizations.ticketClosed
                    : localizations.typeMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                enabled: _ticket!.status != 'closed',
              ),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // زر الإرسال
          CircleAvatar(
            radius: 20,
            backgroundColor: _ticket!.status == 'closed'
                ? Colors.grey
                : AppTheme.primaryColor,
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
              onPressed: _ticket!.status == 'closed' ? null : _sendMessage,
              color: Colors.white,
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// إضافة مرفق
  void _addAttachment() {
    // تنفيذ إضافة مرفق
  }

  /// إرسال رسالة
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }
    
    setState(() {
      _isSending = true;
    });
    
    try {
      // إرسال الرسالة إلى الخادم
      await Future.delayed(const Duration(seconds: 1));
      
      // إضافة الرسالة إلى القائمة
      setState(() {
        _messages.add(
          TicketMessage(
            id: 'msg_${_messages.length + 1}',
            ticketId: widget.ticketId,
            message: message,
            sender: MessageSender.user,
            createdAt: DateTime.now(),
            attachments: [],
          ),
        );
        
        // تحديث وقت آخر تحديث للتذكرة
        _ticket = _ticket!.copyWith(
          updatedAt: DateTime.now(),
        );
        
        // مسح حقل الإدخال
        _messageController.clear();
      });
    } catch (e) {
      // عرض رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  /// معالجة اختيار عنصر القائمة
  void _handleMenuItemSelected(String value) {
    switch (value) {
      case 'close':
        _toggleTicketStatus();
        break;
    }
  }

  /// تبديل حالة التذكرة
  Future<void> _toggleTicketStatus() async {
    final newStatus = _ticket!.status == 'closed' ? 'open' : 'closed';
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // تحديث حالة التذكرة في الخادم
      await Future.delayed(const Duration(seconds: 1));
      
      // تحديث حالة التذكرة محليًا
      setState(() {
        _ticket = _ticket!.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      });
      
      // عرض رسالة نجاح
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'closed'
                  ? localizations.ticketClosed
                  : localizations.ticketReopened,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // عرض رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// تنسيق التاريخ والوقت
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// نوع مرسل الرسالة
enum MessageSender {
  /// المستخدم
  user,
  
  /// فريق الدعم
  support,
}

/// رسالة التذكرة
class TicketMessage {
  /// معرف الرسالة
  final String id;
  
  /// معرف التذكرة
  final String ticketId;
  
  /// نص الرسالة
  final String message;
  
  /// مرسل الرسالة
  final MessageSender sender;
  
  /// وقت إنشاء الرسالة
  final DateTime createdAt;
  
  /// المرفقات
  final List<String> attachments;

  /// إنشاء رسالة تذكرة
  const TicketMessage({
    required this.id,
    required this.ticketId,
    required this.message,
    required this.sender,
    required this.createdAt,
    required this.attachments,
  });
}
