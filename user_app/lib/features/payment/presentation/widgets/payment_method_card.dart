import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/payment/domain/payment_entity.dart';
import 'package:user_app/features/payment/presentation/viewmodels/payment_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';

class PaymentMethodCard extends ConsumerWidget {
  final PaymentMethodEntity paymentMethod;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const PaymentMethodCard({
    Key? key,
    required this.paymentMethod,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
    this.onSetDefault,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return ResponsiveBuilder(
      mobile: _buildMobileCard(context, theme, localizations),
      tablet: _buildTabletCard(context, theme, localizations),
      desktop: _buildDesktopCard(context, theme, localizations),
    );
  }

  Widget _buildMobileCard(BuildContext context, ThemeData theme, AppLocalizations localizations) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPaymentMethodIcon(),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _getPaymentMethodName(localizations),
                style: theme.textTheme.titleMedium,
              ),
              if (paymentMethod.card != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${_getCardBrandName(paymentMethod.card!.brand)} •••• ${paymentMethod.card!.last4}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${localizations.expiresOn} ${paymentMethod.card!.expiryMonth}/${paymentMethod.card!.expiryYear}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (paymentMethod.isDefault) ...[
                const SizedBox(height: 8),
                Chip(
                  label: Text(localizations.default_),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
              if (onDelete != null || onSetDefault != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onSetDefault != null && !paymentMethod.isDefault)
                      TextButton(
                        onPressed: onSetDefault,
                        child: Text(localizations.setAsDefault),
                      ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        tooltip: localizations.delete,
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletCard(BuildContext context, ThemeData theme, AppLocalizations localizations) {
    // تحسين التصميم للأجهزة اللوحية
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _buildPaymentMethodIcon(size: 48),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPaymentMethodName(localizations),
                      style: theme.textTheme.titleMedium,
                    ),
                    if (paymentMethod.card != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${_getCardBrandName(paymentMethod.card!.brand)} •••• ${paymentMethod.card!.last4}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${localizations.expiresOn} ${paymentMethod.card!.expiryMonth}/${paymentMethod.card!.expiryYear}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (paymentMethod.isDefault) ...[
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(localizations.default_),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  const SizedBox(height: 16),
                  if (onSetDefault != null && !paymentMethod.isDefault)
                    TextButton(
                      onPressed: onSetDefault,
                      child: Text(localizations.setAsDefault),
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: localizations.delete,
                      color: theme.colorScheme.error,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCard(BuildContext context, ThemeData theme, AppLocalizations localizations) {
    // تحسين التصميم لأجهزة سطح المكتب
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              _buildPaymentMethodIcon(size: 64),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getPaymentMethodName(localizations),
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(width: 12),
                        if (paymentMethod.isDefault)
                          Chip(
                            label: Text(localizations.default_),
                            backgroundColor: theme.colorScheme.primaryContainer,
                            labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                    if (paymentMethod.card != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${_getCardBrandName(paymentMethod.card!.brand)} •••• ${paymentMethod.card!.last4}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${localizations.expiresOn} ${paymentMethod.card!.expiryMonth}/${paymentMethod.card!.expiryYear}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (onSetDefault != null && !paymentMethod.isDefault)
                        ElevatedButton.icon(
                          onPressed: onSetDefault,
                          icon: const Icon(Icons.star_outline),
                          label: Text(localizations.setAsDefault),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      if (onDelete != null) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          tooltip: localizations.delete,
                          color: theme.colorScheme.error,
                          iconSize: 28,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodIcon({double size = 32}) {
    IconData iconData;
    Color iconColor;

    switch (paymentMethod.type) {
      case PaymentMethodType.card:
        if (paymentMethod.card != null) {
          switch (paymentMethod.card!.brand.toLowerCase()) {
            case 'visa':
              iconData = Icons.credit_card;
              iconColor = Colors.blue;
              break;
            case 'mastercard':
              iconData = Icons.credit_card;
              iconColor = Colors.deepOrange;
              break;
            case 'amex':
              iconData = Icons.credit_card;
              iconColor = Colors.indigo;
              break;
            default:
              iconData = Icons.credit_card;
              iconColor = Colors.grey;
          }
        } else {
          iconData = Icons.credit_card;
          iconColor = Colors.grey;
        }
        break;
      case PaymentMethodType.paypal:
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.blue;
        break;
      case PaymentMethodType.applePay:
        iconData = Icons.apple;
        iconColor = Colors.black;
        break;
      case PaymentMethodType.googlePay:
        iconData = Icons.g_mobiledata;
        iconColor = Colors.green;
        break;
      case PaymentMethodType.bankTransfer:
        iconData = Icons.account_balance;
        iconColor = Colors.teal;
        break;
    }

    return Icon(
      iconData,
      size: size,
      color: iconColor,
    );
  }

  String _getPaymentMethodName(AppLocalizations localizations) {
    switch (paymentMethod.type) {
      case PaymentMethodType.card:
        return localizations.creditCard;
      case PaymentMethodType.paypal:
        return 'PayPal';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.bankTransfer:
        return localizations.bankTransfer;
    }
  }

  String _getCardBrandName(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'MasterCard';
      case 'amex':
        return 'American Express';
      case 'discover':
        return 'Discover';
      case 'jcb':
        return 'JCB';
      case 'diners':
        return 'Diners Club';
      default:
        return brand;
    }
  }
}
