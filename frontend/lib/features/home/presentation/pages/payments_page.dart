import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/payment_model.dart';
import '../../../../core/services/payments_service.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PaymentModel> _payments = [];
  PaymentSummary? _summary;
  bool _isLoading = true;
  String? _error;
  int _selectedFilter = 0;

  final List<String> _filters = ['All', 'Pending', 'Paid', 'Overdue'];
  final List<String?> _filterValues = [null, 'PENDING', 'PAID', 'OVERDUE'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        PaymentsService.getMyPayments(status: _filterValues[_selectedFilter]),
        PaymentsService.getPaymentSummary(),
      ]);

      setState(() {
        _payments = results[0] as List<PaymentModel>;
        _summary = results[1] as PaymentSummary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Error fetching payments: $e');
    }
  }

  void _onFilterChanged(int index) {
    setState(() => _selectedFilter = index);
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkGrey, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGrey,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(),
                      const SizedBox(height: 24),
                      _buildFilterChips(),
                      const SizedBox(height: 16),
                      _buildPaymentsList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCards() {
    if (_summary == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSummaryCard(
              label: 'Total',
              amount: _summary!.total,
              count: _summary!.paymentCount,
              color: AppColors.primaryGreen,
              bgColor: const Color(0xFFE8F5E9),
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              label: 'Paid',
              amount: _summary!.paid,
              count: _summary!.paidCount,
              color: AppColors.success,
              bgColor: const Color(0xFFE8F5E9),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSummaryCard(
              label: 'Pending',
              amount: _summary!.pending,
              count: _summary!.pendingCount,
              color: AppColors.gold,
              bgColor: const Color(0xFFFFF8E1),
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              label: 'Overdue',
              amount: _summary!.overdue,
              count: _summary!.overdueCount,
              color: Colors.red,
              bgColor: const Color(0xFFFFEBEE),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required double amount,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.payment, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'AED ${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              '$count payment${count != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.darkGrey.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => _onFilterChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGreen : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryGreen : AppColors.lightGrey,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.white : AppColors.darkGrey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentsList() {
    if (_payments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No payments found',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.lightGrey,
            ),
          ),
        ),
      );
    }

    return Column(
      children: _payments
          .map((payment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPaymentCard(payment),
              ))
          .toList(),
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (payment.status) {
      case PaymentStatus.paid:
        statusColor = AppColors.success;
        statusLabel = 'Paid';
        statusIcon = Icons.check_circle;
        break;
      case PaymentStatus.pending:
        statusColor = AppColors.gold;
        statusLabel = 'Pending';
        statusIcon = Icons.schedule;
        break;
      case PaymentStatus.overdue:
        statusColor = Colors.red;
        statusLabel = 'Overdue';
        statusIcon = Icons.warning;
        break;
      case PaymentStatus.cancelled:
        statusColor = AppColors.lightGrey;
        statusLabel = 'Cancelled';
        statusIcon = Icons.cancel;
        break;
    }

    String typeLabel;
    switch (payment.paymentType) {
      case PaymentType.installment:
        typeLabel = 'Installment';
        break;
      case PaymentType.maintenanceFee:
        typeLabel = 'Maintenance Fee';
        break;
      case PaymentType.serviceCharge:
        typeLabel = 'Service Charge';
        break;
      case PaymentType.addonPayment:
        typeLabel = 'Add-on Payment';
        break;
      case PaymentType.other:
        typeLabel = 'Other';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.description ?? typeLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    if (payment.property != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        payment.property!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkGrey.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.darkGrey.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'AED ${payment.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              if (payment.dueDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      payment.status == PaymentStatus.paid ? 'Paid on' : 'Due date',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkGrey.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${payment.status == PaymentStatus.paid && payment.paidDate != null ? payment.paidDate!.day : payment.dueDate!.day}/${payment.status == PaymentStatus.paid && payment.paidDate != null ? payment.paidDate!.month : payment.dueDate!.month}/${payment.status == PaymentStatus.paid && payment.paidDate != null ? payment.paidDate!.year : payment.dueDate!.year}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Installment details section (for installment payments)
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
          if (payment.invoiceNumber != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 14,
                    color: AppColors.darkGrey.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Invoice: ${payment.invoiceNumber}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGrey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (payment.status == PaymentStatus.pending) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Redirecting to secure payment gateway...'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

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
}
