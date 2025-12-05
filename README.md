# Tarayıcı Eklentisi Oluşturucu

Chrome (Manifest V3) ve Firefox için modern eklenti projeleri oluşturan, AI dostu bash scripti.

## Özellikler
- 🚀 **Hızlı & Hazır:** Tek komutla tam proje yapısı (`src/`, `icons/`, `package.sh` vb.).
- 🌐 **Multi-Browser:** Chrome ve Firefox manifestleri.
- 🤖 **AI Uyumlu:** `AI_CONTEXT.md` ve `.cursorrules` ile gelir.

## Kullanım
```bash
chmod +x create-extension.sh

# Otomatik isimle (tarih-saat)
./create-extension.sh

# İsim belirterek
./create-extension.sh "My Extension"

# Konum belirterek
./create-extension.sh "My Extension" ~/projects/

# Otomatik isim, hedef klasör ve editör ile
./create-extension.sh -k ~/projects -e cursor
```

## Masaüstü Kısayolu (Linux)
`create-extension.desktop` dosyasını `~/.local/share/applications/` içine kopyalayın ve `Exec` yolunu düzenleyin.

## Çıktı
Oluşturulan proje; `manifest.json` (Chrome), `manifest.firefox.json`, `package.sh` (zipleyici), `generate-icons.sh` ve temel `src/` dosyalarını içerir.
