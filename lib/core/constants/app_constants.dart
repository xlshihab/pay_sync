class AppConstants {
  static const String appName = 'PaySync';

  // Firebase Collections
  static const String paymentsCollection = 'payments';
  static const String unmatchedPaymentsCollection = 'unmatched_payments';

  // Payment Status
  static const String statusPending = 'pending';
  static const String statusSuccess = 'success';
  static const String statusFailed = 'failed';

  // Payment Methods
  static const String methodBkash = 'bkash';
  static const String methodNagad = 'nagad';

  // Pagination
  static const int paginationLimit = 20;

  // SMS Keywords
  static const List<String> bkashKeywords = ['bkash', 'received', 'tk'];
  static const List<String> nagadKeywords = ['nagad', 'money received', 'amount'];
}

