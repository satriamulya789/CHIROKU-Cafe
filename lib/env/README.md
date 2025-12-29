# Environment Configuration

## Setup

1. **Buat file `.env`** di root project dengan konten:

```env
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

2. **Generate file `env.g.dart`** dengan command:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

atau untuk watch mode (auto-regenerate saat ada perubahan):

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Usage

Import dan gunakan `Env` class:

```dart
import 'package:chiroku_cafe/configs/env/env.dart';

// Access environment variables
final url = Env.supabaseUrl;
final key = Env.supabaseAnonKey;
```

## Security

- File `env.g.dart` **TIDAK** di-commit ke Git (sudah ada di `.gitignore`)
- Credentials di-obfuscate menggunakan `envied` package
- File `.env` juga **TIDAK** di-commit (sudah ada di `.gitignore`)

## Regenerate

Jika ada perubahan di file `.env` atau `env.dart`, jalankan lagi:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
