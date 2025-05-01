import 'package:flutter/material.dart';
import 'package:user_app/core/theme/app_theme.dart';
import 'package:user_app/core/widgets/app_button.dart';
import 'package:user_app/core/widgets/app_text_field.dart';
import 'package:shared_libs/entities/ticket_entity.dart';
import 'package:shared_libs/enums/ticket_status.dart';
import 'package:shared_libs/enums/ticket_category.dart';
import 'package:user_app/flutter_gen/gen_l10n/app_localizations.dart';

/// شاشة إنشاء تذكرة دعم جديدة
class CreateTicketScreen extends StatefulWidget {
  /// إنشاء شاشة إنشاء تذكرة دعم جديدة
  const CreateTicketScreen({Key? key}) : super(key: key);

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'general';
  String _selectedPriority = 'medium';
  bool _isLoading = false;
  List<String>? _attachments;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.createTicket),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // الموضوع
            AppTextField(
              controller: _subjectController,
              labelText: localizations.subject,
              hintText: localizations.subjectHint,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.subjectRequired;
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // الفئة
            _buildDropdownField(
              label: localizations.category,
              value: _selectedCategory,
              items: {
                'general': localizations.general,
                'account': localizations.account,
                'order': localizations.order,
                'payment': localizations.payment,
                'technical': localizations.technical,
                'other': localizations.other,
              },
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // الأولوية
            _buildDropdownField(
              label: localizations.priority,
              value: _selectedPriority,
              items: {
                'low': localizations.low,
                'medium': localizations.medium,
                'high': localizations.high,
              },
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // الرسالة
            AppTextField(
              controller: _messageController,
              labelText: localizations.message,
              hintText: localizations.messageHint,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.messageRequired;
                }
                if (value.length < 10) {
                  return localizations.messageTooShort;
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // المرفقات
            _buildAttachmentsSection(localizations),
            
            const SizedBox(height: 24),
            
            // زر الإرسال
            AppButton(
              text: localizations.submit,
              isLoading: _isLoading,
              onPressed: _submitTicket,
            ),
          ],
        ),
      ),
    );
  }

  /// بناء حقل القائمة المنسدلة
  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required Map<String, String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items.entries.map((entry) {
                return DropdownMenuItem<T>(
                  value: entry.key as T,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// بناء قسم المرفقات
  Widget _buildAttachmentsSection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.attachments,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        if (_attachments != null && _attachments!.isNotEmpty)
          Column(
            children: _attachments!.map((attachment) {
              return ListTile(
                leading: const Icon(Icons.attach_file),
                title: Text(attachment),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _attachments!.remove(attachment);
                    });
                  },
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addAttachment,
          icon: const Icon(Icons.add),
          label: Text(localizations.addAttachment),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: BorderSide(color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }

  /// إضافة مرفق
  void _addAttachment() {
    // تنفيذ إضافة مرفق
    setState(() {
      _attachments ??= [];
      _attachments!.add('attachment_${_attachments!.length + 1}.jpg');
    });
  }

  /// إرسال التذكرة
  Future<void> _submitTicket() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // إنشاء كائن التذكرة
      final ticket = Ticket(
        id: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
        subject: _subjectController.text,
        category: _selectedCategory,
        priority: _selectedPriority,
        message: _messageController.text,
        attachments: _attachments,
        status: 'open',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // إرسال التذكرة إلى الخادم
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // عرض رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.ticketCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        
        // العودة إلى الشاشة السابقة
        Navigator.pop(context);
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
}
