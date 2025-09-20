import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showActions;

  const PaymentCard({
    super.key,
    required this.payment,
    this.onTap,
    this.onLongPress,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(symbol: '৳', decimalDigits: 0);
    final dateFormatter = DateFormat('MMM dd, yyyy \'at\' hh:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormatter.format(payment.amount),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  StatusChip(status: payment.status),
                ],
              ),
              const SizedBox(height: 12),

              // Payment Details
              _buildDetailRow(
                icon: Icons.payment,
                label: 'Method',
                value: payment.methodString.toUpperCase(),
                theme: theme,
              ),
              const SizedBox(height: 8),

              _buildDetailRow(
                icon: Icons.phone,
                label: 'Phone',
                value: payment.phone,
                theme: theme,
              ),
              const SizedBox(height: 8),

              _buildDetailRow(
                icon: Icons.receipt,
                label: 'Transaction ID',
                value: payment.trxId,
                theme: theme,
              ),
              const SizedBox(height: 8),

              _buildDetailRow(
                icon: Icons.card_giftcard,
                label: 'Package',
                value: '${payment.packageTypeString} (Qty: ${payment.quantity})',
                theme: theme,
              ),
              const SizedBox(height: 8),

              _buildDetailRow(
                icon: Icons.access_time,
                label: 'Created',
                value: dateFormatter.format(payment.createdAt),
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  final PaymentStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case PaymentStatus.success:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case PaymentStatus.failed:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.error;
        break;
      case PaymentStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.pending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.name.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
