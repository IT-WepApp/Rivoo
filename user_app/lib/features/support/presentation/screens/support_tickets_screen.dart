import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:shared_libs/entities/ticket_entity.dart';
import 'package:shared_libs/enums/ticket_status.dart';
import 'package:user_app/features/support/presentation/widgets/ticket_card.dart';

/// شاشة تذاكر الدعم الفني
class SupportTicketsScreen extends StatefulWidget {
  /// إنشاء شاشة تذاكر الدعم الفني
  const SupportTicketsScreen({Key? key}) : super(key: key);

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Ticket> _tickets = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// تحميل تذاكر الدعم الفني
  Future<void> _loadTickets() async {
    // في الواقع، سيتم استدعاء واجهة برمجة التطبيقات لجلب التذاكر
    // هذا مجرد تنفيذ وهمي لأغراض العرض
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      // بيانات وهمية للتذاكر
      _tickets = [
        Ticket(
          id: '1',
          subject: 'مشكلة في الدفع',
          message: 'لا يمكنني إتمام عملية الدفع باستخدام بطاقة الائتمان الخاصة بي. تظهر رسالة خطأ عند محاولة الدفع.',
          category: 'الدفع',
          status: TicketStatus.open,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Ticket(
          id: '2',
          subject: 'استفسار عن المنتج',
          message: 'هل يمكنني معرفة مواصفات المنتج بشكل أكثر تفصيلاً؟ أحتاج إلى معلومات إضافية قبل الشراء.',
          category: 'المنتجات',
          status: TicketStatus.inProgress,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        Ticket(
          id: '3',
          subject: 'تأخير في الشحن',
          message: 'لم يصلني الطلب رغم مرور أسبوع على تأكيد الشحن. هل يمكنكم التحقق من حالة الشحن؟',
          category: 'الشحن',
          status: TicketStatus.closed,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تذاكر الدعم الفني'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'مفتوحة'),
            Tab(text: 'مغلقة'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // جميع التذاكر
                _buildTicketsList(_tickets),
                
                // التذاكر المفتوحة
                _buildTicketsList(_tickets.where((ticket) => 
                  ticket.status == TicketStatus.open || 
                  ticket.status == TicketStatus.inProgress
                ).toList()),
                
                // التذاكر المغلقة
                _buildTicketsList(_tickets.where((ticket) => 
                  ticket.status == TicketStatus.closed
                ).toList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // الانتقال إلى شاشة إنشاء تذكرة جديدة
          Navigator.pushNamed(context, '/create-ticket');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// بناء قائمة التذاكر
  Widget _buildTicketsList(List<Ticket> tickets) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد تذاكر',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'انقر على زر الإضافة لإنشاء تذكرة جديدة',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return TicketCard(
            ticket: ticket,
            onTap: () {
              // الانتقال إلى شاشة تفاصيل التذكرة
              Navigator.pushNamed(
                context,
                '/ticket-details',
                arguments: ticket,
              );
            },
          );
        },
      ),
    );
  }
}

/// شاشة تفاصيل التذكرة
class TicketDetailsScreen extends StatelessWidget {
  /// التذكرة المعروضة
  final Ticket ticket;

  /// إنشاء شاشة تفاصيل التذكرة
  const TicketDetailsScreen({
    Key? key,
    required this.ticket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل التذكرة'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات التذكرة
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان التذكرة
                  Text(
                    ticket.subject,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // معلومات إضافية
                  Row(
                    children: [
                      // فئة التذكرة
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ticket.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // حالة التذكرة
                      _buildStatusChip(ticket.status),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // تاريخ التذكرة
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'تم الإنشاء: ${_formatDate(ticket.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.update,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'آخر تحديث: ${_formatDate(ticket.updatedAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // رسالة التذكرة
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الرسالة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(ticket.message),
                ],
              ),
            ),
            
            const Divider(),
            
            // المحادثة
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'المحادثة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // هنا ستكون قائمة الرسائل
                  // في التطبيق الفعلي، ستكون هناك قائمة من الرسائل
                  // لكن هنا سنعرض رسالة بسيطة
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.chat,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'لا توجد رسائل بعد',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'سيتم الرد على استفسارك في أقرب وقت ممكن',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالتك هنا...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: () {
                  // إرسال الرسالة
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء شريحة حالة التذكرة
  Widget _buildStatusChip(TicketStatus status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String statusText;
    
    switch (status) {
      case TicketStatus.open:
        backgroundColor = AppTheme.infoColor;
        statusText = 'مفتوحة';
        break;
      case TicketStatus.inProgress:
        backgroundColor = AppTheme.warningColor;
        statusText = 'قيد التنفيذ';
        break;
      case TicketStatus.closed:
        backgroundColor = AppTheme.successColor;
        statusText = 'مغلقة';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// شاشة إنشاء تذكرة جديدة
class CreateTicketScreen extends StatefulWidget {
  /// إنشاء شاشة إنشاء تذكرة جديدة
  const CreateTicketScreen({Key? key}) : super(key: key);

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'المنتجات';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'المنتجات',
    'الطلبات',
    'الدفع',
    'الشحن',
    'الحساب',
    'أخرى',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// إرسال التذكرة
  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      // في الواقع، سيتم استدعاء واجهة برمجة التطبيقات لإنشاء التذكرة
      // هذا مجرد تنفيذ وهمي لأغراض العرض
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isSubmitting = false;
      });
      
      // إظهار رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء التذكرة بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        // العودة إلى شاشة التذاكر
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء تذكرة جديدة'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان التذكرة
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان التذكرة',
                    hintText: 'أدخل عنوانًا موجزًا للتذكرة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال عنوان للتذكرة';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // فئة التذكرة
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'فئة التذكرة',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // رسالة التذكرة
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'رسالة التذكرة',
                    hintText: 'اشرح مشكلتك أو استفسارك بالتفصيل',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رسالة للتذكرة';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // زر إرفاق ملف
                OutlinedButton.icon(
                  onPressed: () {
                    // إرفاق ملف
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text('إرفاق ملف'),
                ),
                
                const SizedBox(height: 24),
                
                // زر إرسال التذكرة
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitTicket,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('إرسال التذكرة'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
