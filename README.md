# PaySync - Payment Tracking & SMS Monitoring App

PaySync হলো একটি Flutter অ্যাপ যা payment tracking এবং SMS monitoring এর জন্য তৈরি করা হয়েছে। এটি বাংলাদেশের bKash এবং Nagad এর SMS automatically detect করে Firebase এ store করে।

## Features

### 🔐 Permission Management
- অ্যাপ শুরুতে সব required permissions check করে
- SMS এবং Phone permissions না দিলে main screen access করতে পারবেন না

### 📱 Navigation Tabs

#### 1. Request Tab
- Firebase এর `payments` collection থেকে pending status এর payments show করে
- Date অনুযায়ী সর্ট হয় (latest উপরে)
- Card এ long press করলে status change করার option আসে:
  - Make as Success
  - Make as Failed

#### 2. Pending Tab
- SMS monitoring status দেখায়
- `unmatched_payments` collection এর data show করে
- Real-time SMS monitoring (mock implementation)
- Bkash ও Nagad এর SMS parse করে automatically data add করে

#### 3. History Tab
দুইটা sub-tab আছে:
- **Success**: Successful payments (20টা করে pagination)
- **Failed**: Failed payments (20টা করে pagination)
- Long press করে delete করার option

## Firebase Collections

### payments
```json
{
  "user_id": "xyz",
  "package_type": "monthly",
  "quantity": 3,
  "amount": 300,
  "trx_id": "ABC123",
  "status": "pending|success|failed",
  "method": "bkash|nagad",
  "created_at": "timestamp"
}
```

### unmatched_payments
```json
{
  "sender_number": "0195xxxxxxx",
  "amount": 735,
  "trx_id": "CHI8MADSNW",
  "method": "bkash|nagad",
  "received_at": "timestamp"
}
```

## SMS Parsing

### Bkash SMS Format
```
You have received Tk 735.00 from 01954880349.Ref wifi. Fee Tk 0.00. Balance Tk 762.57. TrxID CHI8MADSNW at 18/08/2025 23:47
```

### Nagad SMS Format
```
Money Received.
Amount: Tk 500.00
Sender: 01737067174
Ref: N/A
TxnID: 747FUXJZ
Balance: Tk 500.78
30/07/2025 11:54
```

## Architecture

Clean Architecture অনুসরণ করা হয়েছে:

```
lib/
├── core/
│   ├── constants/     # App constants
│   ├── errors/        # Error handling
│   └── utils/         # Utility functions
├── data/
│   ├── datasources/   # Firebase & Local data sources
│   ├── models/        # Data models
│   └── repositories/  # Repository implementations
├── domain/
│   ├── entities/      # Business entities
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Business logic
├── presentation/
│   ├── bloc/          # State management (BLoC)
│   ├── pages/         # UI screens
│   └── widgets/       # Reusable widgets
└── injection/         # Dependency injection
```

## Getting Started

### Prerequisites
- Flutter SDK
- Firebase project setup
- Android device (for SMS testing)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd pay_sync
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Add `google-services.json` to `android/app/`
- Update Firebase configuration in `lib/firebase_options.dart`

4. Build and run
```bash
flutter run
```

### Firebase Setup

1. Create collections in Firestore:
   - `payments`
   - `unmatched_payments`

2. Add some sample data to `payments` collection for testing

## Permissions Required

- `android.permission.RECEIVE_SMS`
- `android.permission.READ_SMS`
- `android.permission.READ_PHONE_STATE`
- `android.permission.INTERNET`

## Technology Stack

- **Framework**: Flutter
- **State Management**: BLoC/Cubit
- **Backend**: Firebase Firestore
- **Architecture**: Clean Architecture
- **Dependency Injection**: GetIt
- **Error Handling**: Dartz (Either)

## Future Enhancements

1. **Real SMS Monitoring**: Currently using mock implementation
2. **Push Notifications**: For new payments
3. **Analytics Dashboard**: Payment statistics
4. **Multiple Payment Methods**: Support for more mobile banking services
5. **Offline Support**: Local database with sync

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## Notes

- SMS monitoring currently uses mock implementation
- Real SMS integration needs proper native Android integration
- Firebase Security Rules should be configured properly in production
- App requires proper testing with actual payment SMS

## Support

For any issues or questions, please create an issue in the repository.

---

**PaySync** - Making payment tracking simple and automated! 🚀
