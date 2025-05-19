# Dependency Injection pada Aplikasi CBO

## Pengantar

Dependency Injection (DI) adalah pola desain yang digunakan untuk mengurangi ketergantungan langsung antar komponen dalam aplikasi. Pada aplikasi CBO ini, kami menggunakan library `get_it` sebagai service locator untuk mengelola dependency injection.

## Struktur Dependency Injection

Dependency injection pada aplikasi ini diorganisir sebagai berikut:

```
lib/
├── core/
│   └── di/
│       ├── injection_container.dart   # Container utama dan inisialisasi
│       └── README.md                  # Dokumentasi ini
│
└── features/
    ├── auth/
    │   └── di/
    │       └── auth_injection.dart    # DI untuk fitur auth
    │
    ├── schedule/
    │   └── di/
    │       └── schedule_injection.dart # DI untuk fitur schedule
    │
    └── approval/
        └── di/
            └── approval_injection.dart # DI untuk fitur approval
```

## Jenis Registrasi Dependency

Dalam aplikasi ini, kami menggunakan beberapa jenis registrasi:

1. **Factory**: Membuat instance baru setiap kali dipanggil

   ```dart
   sl.registerFactory(() => AuthBloc(...));
   ```

2. **Lazy Singleton**: Membuat instance saat pertama kali dipanggil dan menggunakan instance yang sama untuk panggilan berikutnya
   ```dart
   sl.registerLazySingleton(() => LoginUseCase(sl()));
   ```

## Hirarki Dependency

Dependency diorganisir dalam hirarki sebagai berikut:

1. **External Dependencies**:

   - SharedPreferences
   - Dio
   - InternetConnectionChecker
   - dll.

2. **Core Dependencies**:

   - Database
   - NetworkInfo
   - dll.

3. **Feature Dependencies**:
   - BLoC
   - Use Cases
   - Repositories
   - Data Sources

## Cara Penggunaan

Untuk menggunakan dependency yang telah didaftarkan:

```dart
// Menggunakan dependency langsung
final authBloc = sl<AuthBloc>();

// Atau melalui BlocProvider
BlocProvider(
  create: (_) => sl<AuthBloc>(),
  child: MyWidget(),
),
```

## Manfaat Dependency Injection

1. **Testability**: Memudahkan pengujian dengan mock objects
2. **Loose Coupling**: Mengurangi ketergantungan langsung antar komponen
3. **Maintainability**: Memudahkan pemeliharaan kode
4. **Scalability**: Memudahkan penambahan fitur baru

## Implementasi Clean Architecture

Dependency injection ini mendukung implementasi Clean Architecture dengan memisahkan:

- **Presentation Layer**: BLoC, UI
- **Domain Layer**: Use Cases, Entities, Repository Interfaces
- **Data Layer**: Repository Implementations, Data Sources

Dengan struktur ini, aliran dependency mengikuti prinsip "Dependency Rule" di mana lapisan dalam tidak bergantung pada lapisan luar.
