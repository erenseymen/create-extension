# Tarayıcı Eklentisi Projesi Oluşturucu

Bu proje, Chrome ve Firefox için modern (Manifest V3) tarayıcı eklentisi projeleri oluşturmanızı sağlayan bir bash script'idir.

## Özellikler

- 🚀 **Hızlı Başlangıç:** Tek komutla tam proje yapısı oluşturur.
- 🌐 **Çoklu Tarayıcı:** Hem Chrome (Manifest V3) hem Firefox (Gecko) uyumlu manifest dosyaları hazırlar.
- 📁 **Hazır Yapı:**
  - `src/`: Popup, Options ve Content scriptleri.
  - `icons/`: İkon yönetimi.
  - `package.sh`: Tek tıkla .zip paketleme (Chrome ve Firefox için ayrı ayrı).
  - `generate-icons.sh`: Tek bir görselden tüm ikon boyutlarını oluşturma.
- 🤖 **AI Dostu:** Oluşturulan proje, AI asistanlarının (Cursor, Copilot vb.) projeyi anlamasını kolaylaştıran `AI_CONTEXT.md` ve `.cursorrules` dosyalarını içerir.

## Kullanım

Script'i çalıştırılabilir yapın (ilk seferde):

```bash
chmod +x create-extension.sh
```

### Yeni Proje Oluşturma

Otomatik isimle (tarih-saat bazlı):
```bash
./create-extension.sh
```

İsim belirterek:
```bash
./create-extension.sh "My Awesome Extension"
```

İsim ve konum belirterek:
```bash
./create-extension.sh "My Awesome Extension" ~/projects/
```

### Masaüstü Kısayolu (Linux)

Uygulama başlatıcısından hızlıca proje oluşturmak için `create-extension.desktop` dosyasını kullanabilirsiniz:

1. Dosyayı `~/.local/share/applications/` klasörüne kopyalayın.
2. `Exec` satırını scriptin tam yolunu içerecek şekilde düzenleyin.
3. Varsayılan editör ve klasör için parametreleri özelleştirebilirsiniz:
   ```ini
   Exec=/path/to/create-extension.sh -k /home/user/projects -e cursor
   ```

## Oluşturulan Proje İçeriği

Script çalıştıktan sonra oluşturulan klasörde şunlar bulunur:

- **manifest.json**: Chrome için yapılandırma.
- **manifest.firefox.json**: Firefox için yapılandırma.
- **package.sh**: Eklentiyi `.zip` olarak paketleyen araç.
- **generate-icons.sh**: İkon setlerini oluşturan araç.
- **src/**: Temel HTML/JS/CSS dosyaları (Popup ve Options sayfaları dahil).

