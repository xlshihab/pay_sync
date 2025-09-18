# Pay Sync - Payment SMS Tracker

একটি Flutter অ্যাপ যা payment SMS automatically track করে এবং Firebase এ sync করে।

## Features

### 📱 Main Navigation
- **Request Page**: Firebase payments collection থেকে সব payment data
- **Pending Page**: Unmatched payments যেগুলো SMS থেকে এসেছে
- **History Page**: Success এবং Failed payments আলাদা tab এ
- **Inbox Page**: SMS monitoring এবং real-time processing

### 🔄 Real-time SMS Processing
- Automatic SMS monitoring (background এ চলে)
- ২টি SMS format support:
  - Format 1: "Money Received. Amount: Tk X.XX Sender: XXXXXXX TxnID: XXXXX"
  - Format 2: "You have received Tk X.XX from XXXXXXX TrxID XXXXX"
- Auto-parsing এবং data extraction
- Local SQLite storage
- Auto-sync to Firebase when internet available

### 🏗️ Architecture
- **Clean Architecture** pattern
- **Repository Pattern** for data layer
- **BLoC** for state management
- **Dependency Injection** with GetIt
- **Background Services** for SMS monitoring

## Firebase Collections

### payments/{paymentId}
```json
{
  "amount": 300,
  "created_at": "2025-09-17T18:00:06Z",
  "method": "bkash",
  "package_type": "monthly",
  "phone": "01324002899",
  "quantity": 3,
  "status": "success|pending|failed",
  "trx_id": "ABC123",
  "user_id": "user123"
}
```

### unmatched_payments/{id}
```json
{
  "amount": 800,
  "received_at": "2025-09-17T20:10:11Z",
  "sender_number": "01521798452",
  "trx_id": "KHDIAKDH"
}
```

## Permissions Required
- SMS read permission
- SMS receive permission
- Internet permission
- Background task permission

## Installation

1. Clone repository
2. Run `flutter pub get`
3. Configure Firebase project
4. Update `firebase_options.dart` with your Firebase config
5. Run `flutter run`

## Usage

1. **SMS Monitoring**: Inbox page এ background service start করুন
2. **Real-time Updates**: সব page automatically update হবে
3. **Offline Support**: Internet না থাকলে locally store হবে, পরে sync হবে
4. **Background Processing**: App বন্ধ থাকলেও SMS monitor করবে

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants
│   ├── database/        # SQLite database
│   ├── errors/          # Error handling
│   ├── network/         # Network connectivity
│   ├── services/        # Background services
│   └── utils/           # Utility functions
├── features/
│   ├── request/         # Payment requests
│   ├── pending/         # Unmatched payments
│   ├── history/         # Payment history
│   └── inbox/           # SMS monitoring
├── injection/           # Dependency injection
└── shared/              # Shared widgets/navigation
```

## Development

### Adding New Features
1. Create feature folder in `features/`
2. Implement clean architecture layers
3. Add to dependency injection
4. Update navigation if needed

### Testing
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for full workflows

## Dependencies

- firebase_core, cloud_firestore
- flutter_bloc, get_it, injectable
- another_telephony, permission_handler
- sqflite, connectivity_plus
- flutter_foreground_task, workmanager

## License

MIT License
