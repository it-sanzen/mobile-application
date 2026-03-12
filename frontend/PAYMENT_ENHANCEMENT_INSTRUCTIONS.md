# Payment Enhancement Instructions

## 📋 What Needs to Be Done:

### 1. Run SQL Migration
Execute the file: `backend/payment-installment-fields.sql`

This will add these new columns to the payment table:
- `installmentNumber` (e.g., 1, 2, 3, 4)
- `totalInstallments` (e.g., 10)
- `percentage` (e.g., 10.0%)

### 2. Backend Changes - Already Done ✅
- ✅ Schema updated with new fields in `backend/prisma/schema.prisma`
- ✅ Backend will automatically return these fields in API responses

### 3. Flutter Changes - Already Done ✅
- ✅ PaymentModel updated with new fields in `lib/core/models/payment_model.dart`

### 4. UI Enhancement Needed

Add this helper method to `payments_page.dart` after the `_buildPaymentCard` method (around line 510):

```dart
Widget _buildInstallmentDetail(String label, String value, IconData icon) {
  return Expanded(
    child: Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primaryGreen.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.darkGrey.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    ),
  );
}
```

Then, in the `_buildPaymentCard` method, find this section (around line 477):

```dart
          ],
          if (payment.invoiceNumber != null) ...[
```

And add BEFORE it:

```dart
          // Installment details section
          if (payment.paymentType == PaymentType.installment && payment.installmentNumber != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInstallmentDetail(
                        'Installment',
                        '${payment.installmentNumber}/${payment.totalInstallments}',
                        Icons.format_list_numbered,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      ),
                      _buildInstallmentDetail(
                        'Percentage',
                        '${payment.percentage?.toStringAsFixed(1)}%',
                        Icons.pie_chart_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInstallmentDetail(
                        'Date',
                        payment.dueDate != null
                            ? '${payment.dueDate!.day}/${payment.dueDate!.month}/${payment.dueDate!.year}'
                            : 'TBD',
                        Icons.calendar_today,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      ),
                      _buildInstallmentDetail(
                        'Amount',
                        'AED ${payment.amount.toStringAsFixed(0)}',
                        Icons.attach_money,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
```

## 🎨 What This Will Show:

For INSTALLMENT payments only, a beautiful green-bordered box will display:

**Top Row:**
- Installment: 1/10 (with number icon)
- | (divider)
- Percentage: 10.0% (with pie chart icon)

**Divider line**

**Bottom Row:**
- Date: 15/1/2024 (with calendar icon)
- | (divider)
- Amount: AED 45000 (with money icon)

## ✅ After Running SQL:
The payment cards will show:
- Installment number/total
- Percentage of payment plan
- Due date
- Amount

All in a nice organized layout!
