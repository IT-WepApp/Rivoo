// 📁 seller_panel/lib/features/promotions/presentation/pages/promotion_management_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_libs/lib/models/src/models/promotion.dart';
import 'package:shared_widgets/shared_widgets.dart';
import '../../application/promotion_notifier.dart';

class PromotionManagementPage extends ConsumerStatefulWidget {
  final String productId;
  const PromotionManagementPage({Key? key, required this.productId})
      : super(key: key);

  @override
  ConsumerState<PromotionManagementPage> createState() =>
      _PromotionManagementPageState();
}

class _PromotionManagementPageState
    extends ConsumerState<PromotionManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  PromotionType _selectedType = PromotionType.percentageDiscount;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existingPromotion =
        ref.read(promotionProvider(widget.productId)).promotion;
    if (existingPromotion != null) {
      _initializeForm(existingPromotion);
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _initializeForm(Promotion promotion) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isEditing = true;
          _selectedType = promotion.type;
          _valueController.text = promotion.value.toString();
          _startDate = promotion.startDate;
          _endDate = promotion.endDate;
        });
      }
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _isEditing = false;
      _selectedType = PromotionType.percentageDiscount;
      _valueController.clear();
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _savePromotion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final promotion = Promotion(
      type: _selectedType,
      value: double.tryParse(_valueController.text) ?? 0,
      startDate: _startDate,
      endDate: _endDate,
    );

    final success = await ref
        .read(promotionProvider(widget.productId).notifier)
        .savePromotion(promotion);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('تم ${_isEditing ? 'تحديث' : 'إنشاء'} العرض بنجاح.'),
            backgroundColor: Colors.green),
      );
      _initializeForm(promotion);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('فشل في حفظ العرض.'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isSaving = false);
  }

  Future<void> _deletePromotion() async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: const Text('هل أنت متأكد من رغبتك في حذف هذا العرض؟'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('حذف', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      setState(() => _isSaving = true);
      final success = await ref
          .read(promotionProvider(widget.productId).notifier)
          .deletePromotion();
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم حذف العرض.'), backgroundColor: Colors.green),
        );
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('فشل في حذف العرض.'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initial = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final first = isStartDate
        ? DateTime.now().subtract(const Duration(days: 1))
        : (_startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العروض'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'حذف العرض',
              onPressed: _isSaving ? null : _deletePromotion,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('معرف المنتج: ${widget.productId}',
                  style: theme.textTheme.labelSmall),
              const SizedBox(height: 16),
              DropdownButtonFormField<PromotionType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'نوع العرض',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: PromotionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == PromotionType.percentageDiscount
                        ? 'خصم بالنسبة المئوية'
                        : 'خصم بمبلغ ثابت'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _valueController,
                label: _selectedType == PromotionType.percentageDiscount
                    ? 'النسبة المئوية (%)'
                    : 'مبلغ الخصم (ر.س)',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: _selectedType == PromotionType.percentageDiscount
                    ? Icons.percent
                    : Icons.attach_money,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال قيمة.';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'أدخل رقمًا موجبًا صالحًا.';
                  }
                  if (_selectedType == PromotionType.percentageDiscount &&
                      parsed > 100) {
                    return 'لا يمكن أن تتجاوز النسبة المئوية 100%';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_startDate == null
                    ? 'تاريخ البدء (اختياري)'
                    : 'البدء: ${DateFormat.yMd().format(_startDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_endDate == null
                    ? 'تاريخ الانتهاء (اختياري)'
                    : 'الانتهاء: ${DateFormat.yMd().format(_endDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: _isSaving
                    ? 'جاري الحفظ...'
                    : (_isEditing ? 'تحديث العرض' : 'إنشاء عرض جديد'),
                onPressed: _isSaving
                    ? () {}
                    : () {
                        _savePromotion();
                      },
              ),
              if (_isEditing)
                TextButton(
                  onPressed: _resetForm,
                  child: const Text('مسح/إنشاء جديد'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
