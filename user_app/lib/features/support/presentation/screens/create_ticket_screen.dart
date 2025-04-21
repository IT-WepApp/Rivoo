import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/utils/responsive_utils.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';
import 'package:user_app/features/support/application/support_notifier.dart';
import 'package:user_app/features/support/domain/ticket.dart';
import 'package:user_app/features/support/presentation/screens/ticket_details_screen.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  final String? orderId;

  const CreateTicketScreen({
    Key? key,
    this.orderId,
  }) : super(key: key);

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  TicketType _selectedType = TicketType.general;
  TicketPriority _selectedPriority = TicketPriority.medium;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createNewTicket),
      ),
      body: ResponsiveBuilder(
        // تنفيذ واجهة الهاتف
        mobileBuilder: (context) => _buildMobileLayout(context, l10n),

        // تنفيذ واجهة الجهاز اللوحي والأكبر
        smallTabletBuilder: (context) => _buildTabletLayout(context, l10n),
      ),
    );
  }

  // بناء تخطيط الهاتف
  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildForm(context, l10n),
      ),
    );
  }

  // بناء تخطيط الجهاز اللوحي
  Widget _buildTabletLayout(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: context.screenWidth * 0.7,
            maxHeight: context.screenHeight * 0.8,
          ),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildForm(context, l10n),
            ),
          ),
        ),
      ),
    );
  }

  // بناء نموذج إنشاء التذكرة
  Widget _buildForm(BuildContext context, AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Text(
            l10n.howCanWeHelpYou,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'يرجى تقديم تفاصيل كافية حتى نتمكن من مساعدتك بشكل أفضل.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),

          // حقل الموضوع
          TextFormField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: l10n.subject,
              hintText: 'أدخل موضوع التذكرة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال موضوع للتذكرة';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // حقل الوصف
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.description,
              hintText: 'اشرح مشكلتك بالتفصيل',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال وصف للتذكرة';
              }
              if (value.trim().length < 20) {
                return 'يرجى تقديم وصف أكثر تفصيلاً (20 حرف على الأقل)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // اختيار نوع التذكرة
          Text(
            l10n.ticketType,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildTicketTypeSelector(context),
          const SizedBox(height: 16),

          // اختيار أولوية التذكرة
          Text(
            l10n.priority,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildPrioritySelector(context),
          const SizedBox(height: 24),

          // زر الإرسال
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitTicket,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : Text(l10n.submitTicket),
            ),
          ),
        ],
      ),
    );
  }

  // بناء محدد نوع التذكرة
  Widget _buildTicketTypeSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTypeChip(context, TicketType.general, 'استفسار عام'),
        _buildTypeChip(context, TicketType.orderIssue, 'مشكلة في الطلب'),
        _buildTypeChip(context, TicketType.paymentIssue, 'مشكلة في الدفع'),
        _buildTypeChip(context, TicketType.accountIssue, 'مشكلة في الحساب'),
        _buildTypeChip(context, TicketType.appIssue, 'مشكلة في التطبيق'),
        _buildTypeChip(context, TicketType.suggestion, 'اقتراح'),
        _buildTypeChip(context, TicketType.other, 'أخرى'),
      ],
    );
  }

  // بناء شريحة نوع التذكرة
  Widget _buildTypeChip(BuildContext context, TicketType type, String label) {
    final isSelected = _selectedType == type;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedType = type;
          });
        }
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  // بناء محدد الأولوية
  Widget _buildPrioritySelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPriorityChip(context, TicketPriority.low, 'منخفضة', Colors.green),
        _buildPriorityChip(
            context, TicketPriority.medium, 'متوسطة', Colors.blue),
        _buildPriorityChip(
            context, TicketPriority.high, 'عالية', Colors.orange),
        _buildPriorityChip(context, TicketPriority.urgent, 'عاجلة', Colors.red),
      ],
    );
  }

  // بناء شريحة الأولوية
  Widget _buildPriorityChip(
    BuildContext context,
    TicketPriority priority,
    String label,
    Color color,
  ) {
    final isSelected = _selectedPriority == priority;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPriority = priority;
          });
        }
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  // إرسال التذكرة
  Future<void> _submitTicket() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final supportNotifier = ref.read(supportNotifierProvider.notifier);

      await supportNotifier.createTicket(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        priority: _selectedPriority,
        orderId: widget.orderId,
      );

      final selectedTicket = ref.read(supportNotifierProvider).selectedTicket;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء التذكرة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // الانتقال إلى صفحة تفاصيل التذكرة
      if (selectedTicket != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TicketDetailsScreen(ticketId: selectedTicket.id),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
