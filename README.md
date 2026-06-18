# DisNetFin

DisNetFin is a Flutter finance app that:

- reads transactions from your PocketBase `transactions` collection (read-only)
- shows monthly totals and budget usage
- lets users set a monthly budget and track spending against it

## Authentication

- The app now requires PocketBase authentication.
- Sign in using email and password (PocketBase auth collection: `users`).
- The app only reads transactions after successful login.
- Auth sessions are persisted locally and restored on app restart.
- Auth session refresh runs silently on app start and when app resumes.
- Budget values are still stored locally on-device.

## Configure PocketBase URL

PocketBase is configured to:

- `https://disnetfin-db.disnetdev.co.za`

Update the base URL in this file if needed:

- `lib/core/config/app_config.dart`

Example:

```dart
static const String pocketBaseUrl = 'http://127.0.0.1:8090';
```

If you run on a physical device, use your machine's LAN IP instead of `127.0.0.1`.

## Data Source

The app reads from this collection:

- `transactions`

Current schema mapping:

- amount: `amount` (number)
- currency: `currency` (text)
- merchant name: `merchant_name` (text)
- account name: `account_name` (text)
- transaction type: `type` (text)
- available balance: `available` (number)
- transaction date: `created` (date)

## Run

```bash
flutter pub get
flutter run
```
