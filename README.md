# Kismetly

Kismetly, astroloji temalı mobil deneyimi Türkçe ve İngilizce olarak sunan bir Flutter uygulamasıdır. Uygulama, günlük ve yükselen içgörüleri, yapay zekâ destekli rüya yorumlama ve kahve falı, burç uyumluluk analizleri ve kullanıcı yorumlarını tek bir koyu temada birleştirir.

## Özellikler
- 🇹🇷/🇬🇧 dil anahtarları ile anında locale değişimi ve kalıcı tercih.
- Günlük ve yükselen burç içgörüleri; burç seçicileri yerel olarak saklanır.
- Yapay zekâ destekli rüya yorumlama ve kahve falı (OpenAI anahtarı bulunmadığında çevrimdışı senaryolar).
- Zodyak uyumluluk ekranında aşk/aile/iş sekmeleri ve puanlamalar.
- Firebase etkinse Firestore üzerinde, değilse bellekte çalışan burç yorumları bölümü.

## Yapay Zekâ servislerini etkinleştirme
1. `lib/services/ai_service.dart` dosyasında OpenAI API anahtarı `OPENAI_API_KEY` derleme parametresi veya ortam değişkeni olarak okunur. Çalıştırırken:
   ```bash
   flutter run --dart-define=OPENAI_API_KEY=sk-xxx --dart-define=OPENAI_MODEL=gpt-4o-mini
   ```
2. Anahtar sağlanmazsa uygulama tutarlı, deterministik Türkçe/İngilizce yanıtlar üretir.

## Firebase ile yorumlar
- `firebase_core`, `firebase_auth` ve `cloud_firestore` eklenmiştir. `firebase_options.dart` dosyasını doğru yapılandırdıktan sonra kullanıcı girişiyle yorumlar Firestore’da saklanır.
- Firebase başlatılamazsa uygulama otomatik olarak bellekte tutulan mock depo ile çalışır.

## Lokalizasyon
- Tüm metinler `lib/l10n` klasöründeki ARB dosyalarından yüklenir.
- Desteklenen diller: Türkçe (varsayılan) ve İngilizce.
- Yeni çeviriler eklemek için ilgili `.arb` dosyasına anahtar ekleyip uygulamayı yeniden derleyin.

## Testler
Widget duman testleri `flutter test` komutu ile çalıştırılabilir. Bu ortamda Flutter SDK mevcut olmadığından CI üzerinde veya yerel makinenizde çalıştırmanız önerilir.

## Geliştirme
- `lib/core/localization/locale_provider.dart` uygulamanın locale durumunu ve kalıcılığını yönetir.
- `lib/core/utils/locale_collator.dart` menüleri ve burç listelerini dil kurallarına göre sıralar.
- `lib/features` altındaki modüller (rüyalar, kahve, yorumlar) ayrı özellik klasörlerinde tutulur.
