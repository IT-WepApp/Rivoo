import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/features/profile/presentation/pages/shipping_address_list_page.dart';
import 'package:user_app/features/profile/domain/models/shipping_address.dart';
import 'package:user_app/features/profile/application/shipping_address_notifier.dart';
import 'package:shared_libs/widgets/widgets .dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  bool _isLoading = false;
  String _paymentMethod = 'cash_on_delivery'; // Default payment method
  ShippingAddress? _selectedAddress;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultAddress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(shippingAddressProvider.notifier).loadAddresses();
      // Default address will be automatically selected via the provider
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

  Future<void> _selectShippingAddress() async {
    final address = await Navigator.of(context).push<ShippingAddress>(
      MaterialPageRoute(
        builder: (context) => const ShippingAddressListPage(selectMode: true),
      ),
    );

    if (address != null) {
      setState(() {
        _selectedAddress = address;
      });
    }
  }

  Future<void> _addNewAddress() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const ShippingAddressFormPage(),
      ),
    );

    if (result == true) {
      // Address added successfully, refresh addresses
      await _loadDefaultAddress();
    }
  }

  Future<void> _placeOrder() async {
    // Validate that we have a shipping address
    if (_selectedAddress == null && ref.read(defaultAddressProvider) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إضافة عنوان للشحن أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, we would create the order in the database here
      // For now, we'll just simulate a delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Navigate to order confirmation page
        context.goNamed('order-confirmation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء إنشاء الطلب: ${e.toString()}'),
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
    // Get cart items and total from provider
    // final cartItems = ref.watch(cartProvider);
    // final cartTotal = ref.watch(cartTotalProvider);

    // For now, we'll use dummy data
    const cartTotal = 150.0;

    // Get default address if no address is selected
    final defaultAddress = ref.watch(defaultAddressProvider);
    final addressToUse = _selectedAddress ?? defaultAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الطلب'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shipping Address Section
                  const Text(
                    'عنوان الشحن',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (addressToUse != null)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addressToUse.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${addressToUse.street}, ${addressToUse.city}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              '${addressToUse.state}, ${addressToUse.postalCode}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              addressToUse.country,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'هاتف: ${addressToUse.phoneNumber}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: _selectShippingAddress,
                                  icon: const Icon(Icons.edit_location),
                                  label: const Text('تغيير'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'لا يوجد عنوان شحن محدد',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  onPressed: _selectShippingAddress,
                                  icon: const Icon(Icons.location_on),
                                  label: const Text('اختيار عنوان'),
                                ),
                                TextButton.icon(
                                  onPressed: _addNewAddress,
                                  icon: const Icon(Icons.add_location_alt),
                                  label: const Text('إضافة عنوان'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Payment Method Section
                  const Text(
                    'طريقة الدفع',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Row(
                              children: [
                                Icon(Icons.money),
                                SizedBox(width: 8),
                                Text('الدفع عند الاستلام'),
                              ],
                            ),
                            value: 'cash_on_delivery',
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                          ),
                          // Additional payment methods can be added here
                          // RadioListTile<String>(
                          //   title: const Row(
                          //     children: [
                          //       Icon(Icons.credit_card),
                          //       SizedBox(width: 8),
                          //       Text('بطاقة ائتمان'),
                          //     ],
                          //   ),
                          //   value: 'credit_card',
                          //   groupValue: _paymentMethod,
                          //   onChanged: (value) {
                          //     setState(() {
                          //       _paymentMethod = value!;
                          //     });
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Order Notes Section
                  const Text(
                    'ملاحظات الطلب (اختياري)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  AppTextField(
                    controller: _notesController,
                    hintText: 'أضف أي ملاحظات خاصة بالطلب هنا...',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  // Order Summary Section
                  const Text(
                    'ملخص الطلب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('إجمالي المنتجات'),
                              Text('150.00 ريال'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('رسوم الشحن'),
                              Text('15.00 ريال'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('الضريبة'),
                              Text('24.75 ريال'),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'الإجمالي',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${cartTotal + 15.0 + 24.75} ريال',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      onPressed: _placeOrder,
                      text: 'تأكيد الطلب',
                      icon: Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
