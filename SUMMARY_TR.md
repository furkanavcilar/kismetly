# Güncel Değişiklik Özeti

- Uygulamanın tamamında Türkçe ve İngilizce locale desteği sağlandı; tüm metinler ARB dosyalarından yükleniyor ve menüdeki dil anahtarları tercihleri kalıcı biçimde saklıyor.
- Ana ekran günlük & yükselen burç içgörüleri, uyumluluk ön izlemesi ve hızlı aksiyon kartlarıyla yenilendi; seçilen burçlar ve tarih bazlı mesajlar yerel bellekte tutuluyor.
- Rüya yorumlama ve kahve falı ekranları yapay zekâ desteğiyle eklendi; OpenAI anahtarı yoksa kültüre duyarlı deterministik yanıtlar üretiliyor ve son kahve falı sonuçları cihazda saklanıyor.
- Zodyak uyumu ekranı aşk/aile/iş sekmelerine ayrıldı, puanlar locale duyarlı sıralanan burçlarla hesaplanıyor ve sezgisel öneriler sunuyor.
- Burç detay sayfasına Firebase kullanılabilirken Firestore’a, değilken bellekte çalışan yorum bölümü entegre edildi; yorumlar için kötü dil filtresi ve karakter sınırı var.
- `pubspec.yaml` bağımlılıkları güncellendi, yeni çekirdek dosyalar (locale sağlayıcı, locale sıralayıcı, yapay zekâ servisi) ile README lokalizasyon ve AI yapılandırmasını açıklıyor.
