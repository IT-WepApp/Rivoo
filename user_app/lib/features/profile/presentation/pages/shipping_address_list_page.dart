import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_libs/widgets/widgets .dart';
import 'package:user_app/features/profile/domain/models/shipping_address.dart';
import 'package:user_app/features/profile/application/shipping_address_notifier.dart';
import 'package:user_app/features/profile/presentation/pages/shipping_address_form_page.dart';

class ShippingAddressListPage extends ConsumerStatefulWidget {
  final bool selectMode;

  const ShippingAddressListPage({
    super.key,
    this.selectMode = false,
  });

  @override
  ConsumerState<ShippingAddressListPage> createState() =>
      _ShippingAddressListPageState();
}

class _ShippingAddressListPageState
    extends ConsumerState<ShippingAddressListPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(shippingAddressProvider.notifier).loadAddresses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل العناوين: ${e.toString()}'),
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

  Future<void> _addNewAddress() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const ShippingAddressFormPage(),
      ),
    );

    if (result == true) {
      // Address added successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة العنوان بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _editAddress(ShippingAddress address) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ShippingAddressFormPage(address: address),
      ),
    );

    if (result == true) {
      // Address updated successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث العنوان بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteAddress(ShippingAddress address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العنوان'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا العنوان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref
            .read(shippingAddressProvider.notifier)
            .deleteAddress(address.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف العنوان بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء حذف العنوان: ${e.toString()}'),
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

  Future<void> _setDefaultAddress(ShippingAddress address) async {
    if (address.isDefault) return; // Already default

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(shippingAddressProvider.notifier)
          .setDefaultAddress(address.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تعيين العنوان الافتراضي بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('حدث خطأ أثناء تعيين العنوان الافتراضي: ${e.toString()}'),
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

  void _selectAddress(ShippingAddress address) {
    if (widget.selectMode) {
      Navigator.of(context).pop(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(shippingAddressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectMode ? 'اختر عنوان الشحن' : 'عناوين الشحن'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد عناوين شحن محفوظة',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        onPressed: _addNewAddress,
                        text: 'إضافة عنوان جديد',
                        icon: Icons.add_location_alt,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAddresses,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: addresses.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return _AddressCard(
                        address: address,
                        onEdit: () => _editAddress(address),
                        onDelete: () => _deleteAddress(address),
                        onSetDefault: () => _setDefaultAddress(address),
                        onSelect: widget.selectMode
                            ? () => _selectAddress(address)
                            : null,
                      );
                    },
                  ),
                ),
      floatingActionButton: addresses.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _addNewAddress,
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final ShippingAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final VoidCallback? onSelect;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: address.isDefault
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      address.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'افتراضي',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${address.street}, ${address.city}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '${address.state}, ${address.postalCode}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                address.country,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'هاتف: ${address.phoneNumber}',
                style: const TextStyle(fontSize: 14),
              ),
              if (address.additionalInfo != null &&
                  address.additionalInfo!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'معلومات إضافية: ${address.additionalInfo}',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!address.isDefault)
                    TextButton.icon(
                      onPressed: onSetDefault,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('تعيين كافتراضي'),
                    ),
                  const Spacer(),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    tooltip: 'تعديل',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    tooltip: 'حذف',
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
