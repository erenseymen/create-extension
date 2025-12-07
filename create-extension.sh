#!/bin/bash

# ============================================
# Tarayıcı Eklentisi Projesi Oluşturucu
# ============================================
# Bu script, yeni bir tarayıcı eklentisi projesi oluşturur.
# Chrome ve Firefox için temel dosya yapısını hazırlar.
#
# Kullanım:
#   ./create-extension.sh                           # Otomatik isim (new-extension-TIMESTAMP)
#   ./create-extension.sh "Eklenti Adı"            # Doğrudan isim ile
#   ./create-extension.sh "Eklenti Adı" /path/to   # İsim ve hedef klasör ile
#   ./create-extension.sh -k /path/to              # Hedef klasörde otomatik isim ile
#   ./create-extension.sh -e cursor "Eklenti Adı" # Belirtilen editör ile aç
#   ./create-extension.sh -e code -k /path/to     # VS Code ile aç, otomatik isim
#
# Parametreler:
#   -e <editor>  Projeyi belirtilen editör ile aç (cursor, code, vim, vb.)
#   -k <path>    Hedef klasörde otomatik isim ile oluştur
#
# ============================================

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

show_banner() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}       ${BOLD}Tarayıcı Eklentisi Projesi Oluşturucu${NC}                ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_help() {
    show_banner
    echo -e "${BOLD}Kullanım:${NC}"
    echo "  $0 [SEÇENEKLER] [EKLENTİ ADI] [HEDEF KLASÖR]"
    echo ""
    echo -e "${BOLD}Açıklama:${NC}"
    echo "  Bu script, yeni bir tarayıcı eklentisi (Chrome & Firefox) projesi oluşturur."
    echo "  Manifest V3 uyumlu temel dosya yapısını, ikonları ve paketleme scriptlerini hazırlar."
    echo ""
    echo -e "${BOLD}Seçenekler:${NC}"
    echo -e "  ${GREEN}-h, --help${NC}      Bu yardım mesajını gösterir"
    echo -e "  ${GREEN}-e <editor>${NC}     Projeyi belirtilen editör ile açar (örn: cursor, code, vim)"
    echo -e "  ${GREEN}-k <path>${NC}       Belirtilen hedef klasörde otomatik isim ile oluşturur"
    echo ""
    echo -e "${BOLD}Örnekler:${NC}"
    echo "  $0                                    # Otomatik isim (new-extension-TIMESTAMP)"
    echo "  $0 \"My Extension\"                     # İsim ile oluştur"
    echo "  $0 \"My Extension\" ~/projects          # İsim ve hedef klasör ile"
    echo "  $0 -k ~/projects                      # Hedefte otomatik isimle"
    echo "  $0 -e cursor \"My Extension\"           # Oluştur ve Cursor ile aç"
    echo ""
}

# Yardım parametresi kontrolü
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

show_banner

# Parametreleri al
EXTENSION_NAME=""
TARGET_DIR=""
EDITOR_CMD=""
AUTO_NAME=false

# Parametreleri parse et
while getopts "e:k:" opt; do
    case $opt in
        e)
            EDITOR_CMD="$OPTARG"
            ;;
        k)
            TARGET_DIR="$OPTARG"
            AUTO_NAME=true
            ;;
        \?)
            echo -e "${RED}Geçersiz parametre: -$OPTARG${NC}" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

# Kalan argümanları al
if [ "$AUTO_NAME" = true ]; then
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    EXTENSION_NAME="new-extension-$TIMESTAMP"
    echo -e "${YELLOW}Otomatik isim oluşturuldu: ${EXTENSION_NAME}${NC}"
else
    EXTENSION_NAME="$1"
    TARGET_DIR="${2:-$TARGET_DIR}"
    
    # Eğer eklenti adı verilmediyse, otomatik isim oluştur
    if [ -z "$EXTENSION_NAME" ]; then
        TIMESTAMP=$(date +%Y%m%d-%H%M%S)
        EXTENSION_NAME="new-extension-$TIMESTAMP"
        echo -e "${YELLOW}Otomatik isim oluşturuldu: ${EXTENSION_NAME}${NC}"
    fi
fi

# Klasör adını oluştur (küçük harf, tire ile)
FOLDER_NAME=$(echo "$EXTENSION_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g')

# Hedef dizin belirtilmediyse, mevcut dizini kullan
if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="$(pwd)"
fi

PROJECT_PATH="$TARGET_DIR/$FOLDER_NAME"

# Eğer klasör zaten varsa hata ver
if [ -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Hata: '$PROJECT_PATH' klasörü zaten mevcut!${NC}"
    exit 1
fi

echo -e "${GREEN}Eklenti Adı:${NC} $EXTENSION_NAME"
echo -e "${GREEN}Klasör Adı:${NC} $FOLDER_NAME"
echo -e "${GREEN}Proje Yolu:${NC} $PROJECT_PATH"
echo ""
echo -e "${CYAN}Proje oluşturuluyor...${NC}"
echo ""

# Proje klasörünü oluştur
mkdir -p "$PROJECT_PATH"
cd "$PROJECT_PATH" || exit 1

# Alt klasörleri oluştur
mkdir -p src
mkdir -p icons
mkdir -p images

# ============================================
# manifest.json (Chrome)
# ============================================
cat > manifest.json << 'MANIFEST_EOF'
{
    "manifest_version": 3,
    "name": "EXTENSION_NAME_PLACEHOLDER",
    "version": "1.0",
    "description": "Eklenti açıklaması buraya yazılacak.",
    "author": "Yazar Adı",
    "homepage_url": "https://github.com/kullanici/FOLDER_NAME_PLACEHOLDER",
    "permissions": [
        "storage"
    ],
    "host_permissions": [
        "https://example.com/*"
    ],
    "action": {
        "default_popup": "src/popup.html"
    },
    "options_page": "src/options.html",
    "content_scripts": [
        {
            "matches": [
                "https://example.com/*"
            ],
            "js": [
                "src/content.js"
            ],
            "css": [
                "src/styles.css"
            ]
        }
    ],
    "icons": {
        "16": "icons/icon16.png",
        "48": "icons/icon48.png",
        "128": "icons/icon128.png"
    },
    "web_accessible_resources": [
        {
            "resources": [
                "src/options.html"
            ],
            "matches": [
                "https://example.com/*"
            ]
        }
    ]
}
MANIFEST_EOF

# Placeholder'ları değiştir
sed -i "s/EXTENSION_NAME_PLACEHOLDER/$EXTENSION_NAME/g" manifest.json
sed -i "s/FOLDER_NAME_PLACEHOLDER/$FOLDER_NAME/g" manifest.json

# ============================================
# manifest.firefox.json
# ============================================
cat > manifest.firefox.json << 'MANIFEST_FF_EOF'
{
    "manifest_version": 3,
    "name": "EXTENSION_NAME_PLACEHOLDER",
    "version": "1.0",
    "description": "Eklenti açıklaması buraya yazılacak.",
    "author": "Yazar Adı",
    "homepage_url": "https://github.com/kullanici/FOLDER_NAME_PLACEHOLDER",
    "browser_specific_settings": {
        "gecko": {
            "id": "FOLDER_NAME_PLACEHOLDER@example.com",
            "strict_min_version": "109.0",
            "data_collection_permissions": {
                "required": ["none"],
                "optional": []
            }
        },
        "gecko_android": {
            "strict_min_version": "120.0"
        }
    },
    "permissions": [
        "storage"
    ],
    "host_permissions": [
        "https://example.com/*"
    ],
    "action": {
        "default_popup": "src/popup.html"
    },
    "options_ui": {
        "page": "src/options.html",
        "open_in_tab": true
    },
    "content_scripts": [
        {
            "matches": [
                "https://example.com/*"
            ],
            "js": [
                "src/content.js"
            ],
            "css": [
                "src/styles.css"
            ]
        }
    ],
    "icons": {
        "16": "icons/icon16.png",
        "48": "icons/icon48.png",
        "128": "icons/icon128.png"
    },
    "web_accessible_resources": [
        {
            "resources": [
                "src/options.html"
            ],
            "matches": [
                "https://example.com/*"
            ]
        }
    ]
}
MANIFEST_FF_EOF

# Placeholder'ları değiştir
sed -i "s/EXTENSION_NAME_PLACEHOLDER/$EXTENSION_NAME/g" manifest.firefox.json
sed -i "s/FOLDER_NAME_PLACEHOLDER/$FOLDER_NAME/g" manifest.firefox.json

# ============================================
# src/content.js
# ============================================
cat > src/content.js << 'CONTENT_EOF'
// Content Script - Ana işlevsellik buraya yazılacak
// Bu script, hedef web sayfasında çalışır

// Sayfa yüklendiğinde çalışacak init fonksiyonu
const init = () => {
    console.log('Extension initialized!');
    
    // Sayfa türünü tespit et
    const pageType = detectPageType();
    console.log('Page type:', pageType);
    
    // Sayfa türüne göre işlem yap
    switch (pageType) {
        case 'main':
            initMainPage();
            break;
        default:
            break;
    }
};

// Sayfa türünü tespit et
const detectPageType = () => {
    const path = window.location.pathname;
    
    if (path === '/' || path === '') {
        return 'main';
    }
    
    return 'unknown';
};

// Ana sayfa için başlatma
const initMainPage = () => {
    // Ana sayfa işlemleri
};

// Ayarları getir
const getSettings = async () => {
    return new Promise((resolve) => {
        chrome.storage.sync.get({
            // Varsayılan değerler
            setting1: '',
            setting2: true
        }, (items) => {
            resolve(items);
        });
    });
};

// Helper: HTML escape (XSS önleme)
const escapeHtml = (str) => {
    if (!str) return '';
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
};

// Tema tespiti (dark/light mode)
const detectTheme = () => {
    const bodyBg = window.getComputedStyle(document.body).backgroundColor;
    const rgb = bodyBg.match(/\d+/g);
    if (rgb) {
        const brightness = (parseInt(rgb[0]) * 299 + parseInt(rgb[1]) * 587 + parseInt(rgb[2]) * 114) / 1000;
        return brightness < 128 ? 'dark' : 'light';
    }
    return 'light';
};

// Init çalıştır
init();
CONTENT_EOF

# ============================================
# src/styles.css
# ============================================
cat > src/styles.css << 'STYLES_EOF'
/* Extension Styles */

:root {
    --ext-bg: #f9f9f9;
    --ext-text: #333;
    --ext-border: #ddd;
    --ext-primary: #4a90d9;
    --ext-primary-hover: #3a7bc8;
    --ext-btn-text: white;
    --ext-secondary-bg: #555;
    --ext-secondary-hover: #333;
    --ext-warning-bg: #f8d7da;
    --ext-warning-text: #721c24;
    --ext-success-bg: #d4edda;
    --ext-success-text: #155724;
}

/* Dark Mode */
.ext-dark {
    --ext-bg: #2d2d2d;
    --ext-text: #ccc;
    --ext-border: #444;
    --ext-primary: #5a9de9;
    --ext-primary-hover: #4a8bd8;
    --ext-secondary-bg: #444;
    --ext-secondary-hover: #222;
    --ext-warning-bg: #4c2f32;
    --ext-warning-text: #ffb3b3;
    --ext-success-bg: #2a4d35;
    --ext-success-text: #b3ffb3;
}

/* Container */
.ext-container {
    margin: 15px 0;
    padding: 15px;
    background-color: var(--ext-bg);
    border: 1px solid var(--ext-border);
    border-radius: 8px;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    color: var(--ext-text);
}

/* Button */
.ext-btn {
    background-color: var(--ext-primary);
    color: var(--ext-btn-text);
    border: none;
    padding: 10px 18px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 600;
    transition: background-color 0.2s ease;
}

.ext-btn:hover {
    background-color: var(--ext-primary-hover);
}

.ext-btn:disabled {
    background-color: #ccc;
    cursor: not-allowed;
    opacity: 0.7;
}

.ext-btn.secondary {
    background-color: var(--ext-secondary-bg);
}

.ext-btn.secondary:hover {
    background-color: var(--ext-secondary-hover);
}

/* Loading */
.ext-loading {
    display: inline-block;
    font-style: italic;
    color: var(--ext-text);
    opacity: 0.8;
}

/* Warning */
.ext-warning {
    color: var(--ext-warning-text);
    background-color: var(--ext-warning-bg);
    padding: 12px;
    border-radius: 6px;
    margin-top: 10px;
}

/* Success */
.ext-success {
    color: var(--ext-success-text);
    background-color: var(--ext-success-bg);
    padding: 12px;
    border-radius: 6px;
    margin-top: 10px;
}
STYLES_EOF

# ============================================
# src/popup.html
# ============================================
cat > src/popup.html << 'POPUP_EOF'
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Popup</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 15px;
            min-width: 280px;
            background-color: #f4f4f4;
            color: #333;
        }

        h2 {
            margin: 0 0 15px 0;
            color: #4a90d9;
            font-size: 18px;
        }

        .info {
            font-size: 14px;
            color: #666;
            margin-bottom: 15px;
        }

        button {
            background-color: #4a90d9;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            width: 100%;
            margin-bottom: 10px;
        }

        button:hover {
            background-color: #3a7bc8;
        }

        #settingsLink {
            background-color: #666;
            text-decoration: none;
            display: block;
            text-align: center;
            color: white;
            padding: 10px 20px;
            border-radius: 4px;
        }

        #settingsLink:hover {
            background-color: #555;
        }

        .status {
            margin-top: 10px;
            padding: 8px;
            border-radius: 4px;
            display: none;
            font-size: 13px;
        }

        .status.success {
            background-color: #d4edda;
            color: #155724;
            display: block;
        }

        .status.error {
            background-color: #f8d7da;
            color: #721c24;
            display: block;
        }
    </style>
</head>
<body>
    <h2>EXTENSION_NAME_PLACEHOLDER</h2>
    
    <p class="info">Eklenti bilgileri burada görüntülenecek.</p>

    <a href="#" id="settingsLink">Ayarlar</a>
    
    <div id="status" class="status"></div>

    <script src="popup.js"></script>
</body>
</html>
POPUP_EOF

# Placeholder'ları değiştir
sed -i "s/EXTENSION_NAME_PLACEHOLDER/$EXTENSION_NAME/g" src/popup.html

# ============================================
# src/popup.js
# ============================================
cat > src/popup.js << 'POPUP_JS_EOF'
// Popup Script

// Ayarlar sayfasını aç
document.getElementById('settingsLink').addEventListener('click', (e) => {
    e.preventDefault();
    chrome.runtime.openOptionsPage();
});

// Status göster
const showStatus = (message, type = 'success') => {
    const status = document.getElementById('status');
    status.textContent = message;
    status.className = `status ${type}`;
    
    setTimeout(() => {
        status.textContent = '';
        status.className = 'status';
    }, 3000);
};

// Sayfa yüklendiğinde
document.addEventListener('DOMContentLoaded', () => {
    // Mevcut ayarları yükle
    chrome.storage.sync.get({
        setting1: '',
        setting2: true
    }, (items) => {
        console.log('Settings loaded:', items);
    });
});
POPUP_JS_EOF

# ============================================
# src/options.html
# ============================================
cat > src/options.html << 'OPTIONS_EOF'
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EXTENSION_NAME_PLACEHOLDER - Ayarlar</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f4f4;
            color: #333;
            padding: 20px;
            max-width: 600px;
            margin: 0 auto;
        }

        h1 {
            color: #4a90d9;
            border-bottom: 2px solid #ddd;
            padding-bottom: 10px;
        }

        .container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
        }

        input[type="text"],
        input[type="url"],
        input[type="email"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            margin-bottom: 15px;
            font-size: 14px;
        }

        input[type="checkbox"] {
            margin-right: 8px;
        }

        .checkbox-group {
            margin-bottom: 15px;
        }

        button {
            background-color: #4a90d9;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.2s;
        }

        button:hover {
            background-color: #3a7bc8;
        }

        .status {
            margin-top: 10px;
            padding: 10px;
            border-radius: 4px;
            display: none;
        }

        .status.success {
            background-color: #d4edda;
            color: #155724;
            display: block;
        }

        .status.error {
            background-color: #f8d7da;
            color: #721c24;
            display: block;
        }

        .info {
            margin-top: 20px;
            font-size: 14px;
            color: #666;
            line-height: 1.6;
        }

        a {
            color: #4a90d9;
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Ayarlar</h1>

        <label for="setting1">Ayar 1</label>
        <input type="text" id="setting1" placeholder="Değer girin">

        <div class="checkbox-group">
            <label>
                <input type="checkbox" id="setting2">
                Ayar 2 - Özellik etkinleştir
            </label>
        </div>

        <button id="saveBtn">Kaydet</button>

        <div id="status" class="status"></div>

        <div class="info">
            <h3>Hakkında</h3>
            <p>Bu eklenti hakkında bilgiler buraya yazılacak.</p>
        </div>
    </div>

    <script src="options.js"></script>
</body>
</html>
OPTIONS_EOF

# Placeholder'ları değiştir
sed -i "s/EXTENSION_NAME_PLACEHOLDER/$EXTENSION_NAME/g" src/options.html

# ============================================
# src/options.js
# ============================================
cat > src/options.js << 'OPTIONS_JS_EOF'
// Options Page Script

// Ayarları kaydet
const saveOptions = () => {
    const setting1 = document.getElementById('setting1').value;
    const setting2 = document.getElementById('setting2').checked;
    const status = document.getElementById('status');

    const settings = {
        setting1: setting1,
        setting2: setting2
    };

    chrome.storage.sync.set(settings, () => {
        status.textContent = 'Ayarlar kaydedildi.';
        status.className = 'status success';
        
        setTimeout(() => {
            status.textContent = '';
            status.className = 'status';
        }, 3000);
    });
};

// Ayarları yükle
const restoreOptions = () => {
    chrome.storage.sync.get({
        setting1: '',
        setting2: true
    }, (items) => {
        document.getElementById('setting1').value = items.setting1;
        document.getElementById('setting2').checked = items.setting2;
    });
};

// Sayfa yüklendiğinde ayarları geri yükle
document.addEventListener('DOMContentLoaded', restoreOptions);

// Kaydet butonuna tıklandığında
document.getElementById('saveBtn').addEventListener('click', saveOptions);

// Enter tuşuna basıldığında kaydet
document.getElementById('setting1').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
        saveOptions();
    }
});
OPTIONS_JS_EOF

# ============================================
# package.sh
# ============================================
cat > package.sh << 'PACKAGE_EOF'
#!/bin/bash

# Chrome Web Store ve Firefox Add-ons için eklenti paketleme scripti

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}EXTENSION_NAME_PLACEHOLDER - Paketleme Scripti${NC}"
echo "=========================================="

# Kullanım bilgisi
show_usage() {
    echo -e "${CYAN}Kullanım:${NC}"
    echo "  ./package.sh          # Hem Chrome hem Firefox paketler"
    echo "  ./package.sh chrome   # Sadece Chrome paketi"
    echo "  ./package.sh firefox  # Sadece Firefox paketi"
    echo ""
}

# Versiyonu manifest.json'dan oku
VERSION=$(grep -o '"version": "[^"]*"' manifest.json | cut -d'"' -f4)
if [ -z "$VERSION" ]; then
    echo -e "${RED}Hata: manifest.json'dan versiyon okunamadı!${NC}"
    exit 1
fi

echo -e "${GREEN}Versiyon: ${VERSION}${NC}"
echo ""

# Chrome paketi oluştur
package_chrome() {
    local ZIP_NAME="FOLDER_NAME_PLACEHOLDER-v${VERSION}-chrome.zip"
    local TEMP_DIR=".package_temp_chrome"

    echo -e "${CYAN}Chrome paketi hazırlanıyor...${NC}"

    # Eski paketleri temizle
    [ -f "$ZIP_NAME" ] && rm "$ZIP_NAME"
    [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"

    # Geçici dizin oluştur
    mkdir -p "$TEMP_DIR"

    # Gerekli dosyaları kopyala
    cp manifest.json "$TEMP_DIR/"
    cp -r icons "$TEMP_DIR/"
    cp -r src "$TEMP_DIR/"

    # ZIP oluştur
    cd "$TEMP_DIR" || exit 1
    zip -r "../$ZIP_NAME" . -q
    cd ..

    # Geçici dizini temizle
    rm -rf "$TEMP_DIR"

    # Dosya boyutunu göster
    FILE_SIZE=$(du -h "$ZIP_NAME" | cut -f1)
    echo -e "${GREEN}✓ Chrome paketi: ${ZIP_NAME} (${FILE_SIZE})${NC}"
}

# Firefox paketi oluştur
package_firefox() {
    local ZIP_NAME="FOLDER_NAME_PLACEHOLDER-v${VERSION}-firefox.zip"
    local TEMP_DIR=".package_temp_firefox"

    echo -e "${CYAN}Firefox paketi hazırlanıyor...${NC}"

    # Firefox manifest kontrolü
    if [ ! -f "manifest.firefox.json" ]; then
        echo -e "${RED}Hata: manifest.firefox.json bulunamadı!${NC}"
        exit 1
    fi

    # Eski paketleri temizle
    [ -f "$ZIP_NAME" ] && rm "$ZIP_NAME"
    [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"

    # Geçici dizin oluştur
    mkdir -p "$TEMP_DIR"

    # Gerekli dosyaları kopyala (Firefox manifest'i ana manifest olarak)
    cp manifest.firefox.json "$TEMP_DIR/manifest.json"
    cp -r icons "$TEMP_DIR/"
    cp -r src "$TEMP_DIR/"

    # ZIP oluştur
    cd "$TEMP_DIR" || exit 1
    zip -r "../$ZIP_NAME" . -q
    cd ..

    # Geçici dizini temizle
    rm -rf "$TEMP_DIR"

    # Dosya boyutunu göster
    FILE_SIZE=$(du -h "$ZIP_NAME" | cut -f1)
    echo -e "${GREEN}✓ Firefox paketi: ${ZIP_NAME} (${FILE_SIZE})${NC}"
}

# Parametre kontrolü
case "$1" in
    chrome)
        package_chrome
        echo ""
        echo -e "${GREEN}✓ Chrome paketleme tamamlandı!${NC}"
        ;;
    firefox)
        package_firefox
        echo ""
        echo -e "${GREEN}✓ Firefox paketleme tamamlandı!${NC}"
        ;;
    ""|all)
        package_chrome
        echo ""
        package_firefox
        echo ""
        echo -e "${GREEN}✓ Tüm paketleme tamamlandı!${NC}"
        echo ""
        echo -e "${YELLOW}Yükleme linkleri:${NC}"
        echo -e "  Chrome: https://chrome.google.com/webstore/devconsole"
        echo -e "  Firefox: https://addons.mozilla.org/developers/"
        ;;
    -h|--help)
        show_usage
        ;;
    *)
        echo -e "${RED}Geçersiz parametre: $1${NC}"
        show_usage
        exit 1
        ;;
esac

echo ""
PACKAGE_EOF

# Placeholder'ları değiştir
sed -i "s/EXTENSION_NAME_PLACEHOLDER/$EXTENSION_NAME/g" package.sh
sed -i "s/FOLDER_NAME_PLACEHOLDER/$FOLDER_NAME/g" package.sh
chmod +x package.sh

# ============================================
# generate-icons.sh
# ============================================
cat > generate-icons.sh << 'ICONS_EOF'
#!/bin/bash

# Icon generation script
# Generates different icon sizes from the source 128x128 icon
# Requires: ImageMagick (install with: sudo apt install imagemagick)

SOURCE_ICON="icons/icon128.png"
OUTPUT_DIR="icons"

# Icon sizes to generate
SIZES=(16 32 48 64 128)

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed."
    echo "Install it with: sudo apt install imagemagick"
    exit 1
fi

# Check if source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo "Error: Source icon not found at $SOURCE_ICON"
    echo "Please add a 128x128 PNG icon as icons/icon128.png first."
    exit 1
fi

echo "Generating icons from $SOURCE_ICON..."

for size in "${SIZES[@]}"; do
    output_file="$OUTPUT_DIR/icon${size}.png"
    echo "  Creating ${size}x${size} -> $output_file"
    convert "$SOURCE_ICON" -resize "${size}x${size}" "$output_file"
done

echo ""
echo "Done! Generated icons:"
ls -la "$OUTPUT_DIR"/icon*.png
ICONS_EOF

chmod +x generate-icons.sh

# ============================================
# .gitignore
# ============================================
cat > .gitignore << 'GITIGNORE_EOF'
# Packages
*.zip
.package_temp_*

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Node (if you add node modules later)
node_modules/
npm-debug.log
yarn-error.log

# Build outputs
dist/
build/

# Environment files
.env
.env.local
.env.*.local

# Temporary files
*.tmp
*.temp
*.log
GITIGNORE_EOF

# ============================================
# README.md
# ============================================
cat > README.md << 'README_EOF'
# EXTENSION_NAME_PLACEHOLDER

Eklenti açıklaması buraya yazılacak. Store listing bilgileri için `STORE_LISTING.md` dosyasına bakın.

## Özellikler

- Özellik 1
- Özellik 2
- Özellik 3

## Kurulum

### Chrome

1. `chrome://extensions` adresine gidin
2. "Geliştirici modu"nu aktif edin
3. "Paketlenmemiş öğe yükle" butonuna tıklayın
4. Bu klasörü seçin

### Firefox

1. `about:debugging#/runtime/this-firefox` adresine gidin
2. "Geçici Eklenti Yükle" butonuna tıklayın
3. `manifest.firefox.json` dosyasını seçin

## Geliştirme

### Dosya Yapısı

```
FOLDER_NAME_PLACEHOLDER/
├── manifest.json           # Chrome manifest
├── manifest.firefox.json   # Firefox manifest
├── src/
│   ├── content.js         # Content script
│   ├── styles.css         # Stiller
│   ├── popup.html         # Popup sayfası
│   ├── popup.js           # Popup scripti
│   ├── options.html       # Ayarlar sayfası
│   └── options.js         # Ayarlar scripti
├── icons/
│   ├── icon16.png
│   ├── icon48.png
│   └── icon128.png
├── package.sh             # Paketleme scripti
├── generate-icons.sh      # İkon oluşturma scripti
├── README.md
├── STORE_LISTING.md       # Mağaza listeleme bilgileri
└── CHROME_WEB_STORE_GUIDE.md / FIREFOX_ADDON_GUIDE.md
```

### Paketleme

```bash
# Hem Chrome hem Firefox paketlerini oluştur
./package.sh

# Sadece Chrome paketi
./package.sh chrome

# Sadece Firefox paketi
./package.sh firefox
```

## Lisans

MIT License

## İletişim

- GitHub: [kullanici/FOLDER_NAME_PLACEHOLDER](https://github.com/kullanici/FOLDER_NAME_PLACEHOLDER)
README_EOF

# Placeholder'ları değiştir
sed -i "s/EXTENSION_NAME_PLACEHOLDER/$EXTENSION_NAME/g" README.md
sed -i "s/FOLDER_NAME_PLACEHOLDER/$FOLDER_NAME/g" README.md

# ============================================
# CHROME_WEB_STORE_GUIDE.md
# ============================================
cat > CHROME_WEB_STORE_GUIDE.md << 'CHROME_GUIDE_EOF'
# Chrome Web Store Yayınlama Rehberi

Bu rehber, **EXTENSION_NAME_PLACEHOLDER** eklentisini Chrome Web Store'a yayınlamak için gereken adımları içerir.

## Ön Hazırlık

### 1. Gerekli Dosyalar Kontrolü

✅ **Tamamlanması Gerekenler:**
- [x] `manifest.json` - Manifest V3 formatında
- [x] İkonlar (16x16, 48x48, 128x128) - Mevcut
- [ ] Gizlilik Politikası - Hazırlanmalı
- [ ] Store listing için ekran görüntüleri (1280x800 veya 640x400)
- [ ] Promosyon görseli (440x280) - Opsiyonel ama önerilir
- [ ] Küçük promosyon görseli (920x680) - Opsiyonel ama önerilir

### 2. Manifest.json Kontrolü

Manifest dosyanız Chrome Web Store gereksinimlerini karşılıyor:
- ✅ Manifest V3
- ✅ İsim, versiyon, açıklama mevcut
- ✅ İkonlar tanımlı
- ✅ Permissions ve host_permissions tanımlı

**Önerilen İyileştirmeler:**
- `homepage_url` eklenebilir (GitHub repository linki)
- `author` alanı eklenebilir

## Adım 1: Chrome Web Store Developer Dashboard'a Erişim

1. [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole) adresine gidin
2. Google hesabınızla giriş yapın
3. **$5 tek seferlik kayıt ücreti** ödemeniz gerekecek (henüz ödemediyseniz)

## Adım 2: Yeni Eklenti Oluşturma

1. Dashboard'da **"Yeni öğe"** (New Item) butonuna tıklayın
2. ZIP dosyanızı yükleyin (aşağıdaki "Paketleme" bölümüne bakın)
3. Eklenti yüklendikten sonra store listing bilgilerini doldurun

## Adım 3: Store Listing Bilgileri

### Zorunlu Alanlar:

#### 1. **Dil ve Bölge**
- **Varsayılan Dil:** Türkçe (tr) veya İngilizce (en)
- **Bölgeler:** Hedef bölgeler (veya "Tüm bölgeler")

#### 2. **Açıklama**
Eklentinizin ne yaptığını net bir şekilde açıklayın. `STORE_LISTING.md` dosyasındaki "Description" bölümünü kullanabilirsiniz.

```
EXTENSION_NAME_PLACEHOLDER açıklaması...

Özellikler:
- Özellik 1
- Özellik 2
- Özellik 3
```

**Not:** `STORE_LISTING.md` dosyasını düzenleyerek store listing bilgilerinizi hazırlayabilirsiniz.

#### 3. **Kategori**
- **Birincil Kategori:** Eklentinize uygun kategoriyi seçin (örn: Productivity, Developer Tools)

#### 4. **Görseller**
- **Ekran Görüntüleri:** En az 1, en fazla 5 adet
  - Boyut: 1280x800 veya 640x400 piksel
  - Format: PNG veya JPEG
  - İçerik: Eklentinin kullanımını gösteren ekran görüntüleri

#### 5. **Gizlilik Politikası**
- Gizlilik politikası URL'si gerekli
- GitHub Pages veya benzeri bir serviste yayınlayın
- `PRIVACY_POLICY.md` dosyasını oluşturup kullanabilirsiniz

#### 6. **Promosyon Görselleri** (Opsiyonel ama önerilir)
- Küçük: 440x280 piksel
- Büyük: 920x680 piksel

## Adım 4: Gizlilik ve Güvenlik

### Veri Kullanımı Bildirimi

Chrome Web Store, eklentinizin veri kullanımını soracak.

**Kullanıcı verileri topluyor musunuz?**
- Eğer uzak sunucuya veri gönderiyorsanız veya local storage kullanıyorsanız durumu belirtin.

### İnceleme Sürecinde Sorulacak Sorular

**1. Single Purpose Description**
Eklentinin tek bir amacı olduğunu açıklayın.

**2. Permission Justification**
Manifest dosyasındaki her izin için (storage, host_permissions vb.) neden gerekli olduğunu açıklayın.

Örnek:
- `storage`: Kullanıcı ayarlarını kaydetmek için.
- `host_permissions`: Hedef sitede çalışmak için.

## Adım 5: Paketleme

### ZIP Dosyası Oluşturma

Terminal'de proje dizininde şu komutu çalıştırın veya `package.sh` scriptini kullanın:

```bash
./package.sh chrome
```

Bu komut `FOLDER_NAME_PLACEHOLDER-vX.X-chrome.zip` dosyasını oluşturacaktır.

## Adım 6: İnceleme Süreci

1. Tüm bilgileri doldurduktan sonra **"Değişiklikleri Kaydet"** butonuna tıklayın
2. **"İncelemeye Gönder"** butonuna tıklayın
3. İnceleme süreci genellikle **1-3 iş günü** sürer

## Yararlı Linkler

- [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole)
- [Program Policies](https://developer.chrome.com/docs/webstore/program-policies/)
- [Manifest V3 Guide](https://developer.chrome.com/docs/extensions/mv3/intro/)
CHROME_GUIDE_EOF

sed -i "s/EXTENSION_NAME_PLACEHOLDER/$EXTENSION_NAME/g" CHROME_WEB_STORE_GUIDE.md
sed -i "s/FOLDER_NAME_PLACEHOLDER/$FOLDER_NAME/g" CHROME_WEB_STORE_GUIDE.md

# ============================================
# FIREFOX_ADDON_GUIDE.md
# ============================================
cat > FIREFOX_ADDON_GUIDE.md << 'FIREFOX_GUIDE_EOF'
# Firefox Add-ons Yayınlama Rehberi

Bu rehber, **EXTENSION_NAME_PLACEHOLDER** eklentisini Firefox Add-ons'a (AMO) yayınlamak için adım adım talimatları içerir.

## Ön Hazırlık

### 1. Firefox Developer Hub Hesabı

1. [Firefox Add-on Developer Hub](https://addons.mozilla.org/developers/)'a gidin
2. Firefox hesabınızla giriş yapın veya yeni hesap oluşturun
3. Geliştirici sözleşmesini kabul edin

### 2. Paket Oluşturma

Terminal'de proje dizininde şu komutu çalıştırın:

```bash
./package.sh firefox
```

Bu komut `FOLDER_NAME_PLACEHOLDER-vX.X-firefox.zip` dosyasını oluşturacaktır.

## Add-on Gönderimi

### Adım 1: Yeni Add-on Başlatma

1. [Submit a New Add-on](https://addons.mozilla.org/developers/addon/submit/distribution) sayfasına gidin
2. **"On this site"** seçeneğini seçin (AMO'da dağıtım için)
3. **"Continue"** butonuna tıklayın

### Adım 2: Dosya Yükleme

1. Oluşturduğunuz ZIP dosyasını yükleyin
2. Kaynak kod (source code) istenmesi durumunda:
   - Eğer kodunuz obfuscate edilmemişse (okunabilirse) kaynak kod yüklemek zorunda değilsiniz
   - Eğer minified/obfuscated kod varsa kaynak kodu ZIP olarak yüklemelisiniz

### Adım 3: Add-on Detayları

#### Temel Bilgiler
- **Name:** EXTENSION_NAME_PLACEHOLDER
- **Summary:** `STORE_LISTING.md` dosyasındaki "Summary" bölümünü kullanın
- **Categories:** Uygun kategorileri seçin

#### Açıklama (Description)
`STORE_LISTING.md` dosyasındaki "Description" bölümünü kullanın. Eklentinin detaylı açıklaması, özellikleri ve kullanım talimatları burada yer almalı.

#### İkon ve Görseller
- **İkon:** 128x128 PNG (Mevcut: `icons/icon128.png`)
- **Ekran Görüntüleri:** En az 1 adet (Önerilen: 1280x800)

### Adım 4: Teknik Bilgiler

#### İzinler Açıklaması
Firefox bazen izinlerin neden gerekli olduğunu sorabilir.
- `storage`: Ayarlar için
- `host_permissions`: Site içeriğine erişim için

### Adım 5: Gönderim

1. Bilgileri kontrol edin
2. **"Submit Version"** butonuna tıklayın

## İnceleme Süreci

- İlk inceleme: 1-5 iş günü
- Güncellemeler: Genellikle 24 saat içinde

## Güncelleme Yayınlama

1. `manifest.json` ve `manifest.firefox.json` içinde versiyonu artırın
2. `./package.sh firefox` ile yeni paket oluşturun
3. [My Add-ons](https://addons.mozilla.org/developers/addons) sayfasından "Upload New Version" deyin

## Faydalı Linkler

- [Firefox Extension Workshop](https://extensionworkshop.com/)
- [Add-on Policies](https://extensionworkshop.com/documentation/publish/add-on-policies/)
FIREFOX_GUIDE_EOF

sed -i "s/EXTENSION_NAME_PLACEHOLDER/$EXTENSION_NAME/g" FIREFOX_ADDON_GUIDE.md
sed -i "s/FOLDER_NAME_PLACEHOLDER/$FOLDER_NAME/g" FIREFOX_ADDON_GUIDE.md

# ============================================
# STORE_LISTING.md - Mağaza listeleme bilgileri
# ============================================
cat > STORE_LISTING.md << 'STORE_LISTING_EOF'
# Title:

EXTENSION_NAME_PLACEHOLDER

# Summary (Kısa Açıklama):

Eklentinizin kısa açıklaması buraya yazılacak (132 karakter sınırı - Chrome Web Store).

# Description (Tam Açıklama):

Eklentinizin detaylı açıklaması buraya yazılacak. Chrome Web Store ve Firefox Add-ons için kullanılacak.

Özellikler:
- Özellik 1
- Özellik 2
- Özellik 3

## Nasıl Kullanılır

1. Adım 1
2. Adım 2
3. Adım 3

## Gereksinimler

- Gereksinim 1 (varsa)
- Gereksinim 2 (varsa)

## Notlar

- Önemli notlar buraya yazılabilir
STORE_LISTING_EOF

# Placeholder'ları değiştir
sed -i "s/EXTENSION_NAME_PLACEHOLDER/$EXTENSION_NAME/g" STORE_LISTING.md

# ============================================
# SUBMISSION_CHECKLIST.md
# ============================================
cat > SUBMISSION_CHECKLIST.md << 'CHECKLIST_EOF'
# Yayınlama Kontrol Listesi

## ✅ Hazır Olanlar

- [x] Manifest dosyaları (Chrome & Firefox)
- [x] Temel ikonlar (16, 48, 128 px)
- [x] Paketleme scripti (`package.sh`)

## ⚠️ Yapılması Gerekenler

### 1. Dokümantasyon ve Politika
- [ ] **Gizlilik Politikası**: `PRIVACY_POLICY.md` dosyasını oluşturun ve bir URL'de yayınlayın (GitHub Pages vb.)
- [ ] **Lisans**: Projenize uygun bir lisans dosyası ekleyin (MIT, Apache vb.)

### 2. Görsel Varlıklar
- [ ] **Ekran Görüntüleri**:
  - Boyut: 1280x800px veya 640x400px
  - Format: PNG/JPEG
  - En az 1 adet, eklentiyi tanıtan görsel
- [ ] **Promosyon Görselleri** (Chrome Store için önerilir):
  - Küçük: 440x280px
  - Büyük: 920x680px

### 3. Mağaza Bilgileri
- [ ] `STORE_LISTING.md` dosyasını düzenleyin (Title, Summary, Description)
- [ ] Eklenti **Açıklaması** (Kısa ve Uzun) - `STORE_LISTING.md`'den kopyalayın
- [ ] **Kategori** seçimi
- [ ] **Dil** ayarları

### 4. Hesaplar
- [ ] **Chrome Web Store**: Developer hesabı ($5)
- [ ] **Firefox Add-ons**: Developer hesabı (Ücretsiz)

### 5. Son Kontroller
- [ ] Tüm `console.log`'ları temizleyin veya development moduna alın
- [ ] Manifest versiyon numarasını kontrol edin
- [ ] Eklentiyi "Load Unpacked" ile son kez test edin
- [ ] `./package.sh` ile temiz paket oluşturun

## 🚀 Yayınlama Adımları

1. **Paketle**: `./package.sh` komutunu çalıştır
2. **Chrome**: `CHROME_WEB_STORE_GUIDE.md` adımlarını izle
3. **Firefox**: `FIREFOX_ADDON_GUIDE.md` adımlarını izle
CHECKLIST_EOF

# ============================================
# Placeholder icon oluştur (basit bir metin dosyası)
# ============================================
echo -e "${YELLOW}Not: icons/ klasörüne 128x128 PNG icon eklemeyi unutmayın!${NC}"
echo "Placeholder icon dosyası oluşturuluyor..."

# Basit bir placeholder SVG oluştur ve PNG'ye çevirmeyi öner
cat > icons/placeholder.txt << 'PLACEHOLDER_EOF'
Bu klasöre aşağıdaki dosyaları eklemelisiniz:
- icon128.png (128x128 px)
- icon48.png (48x48 px)
- icon16.png (16x16 px)

128x128 icon'u ekledikten sonra generate-icons.sh çalıştırarak
diğer boyutları otomatik oluşturabilirsiniz.
PLACEHOLDER_EOF

# ============================================
# AI_CONTEXT.md - AI için proje bağlamı
# ============================================
cat > AI_CONTEXT.md << 'AI_CONTEXT_EOF'
# AI Context - Browser Extension Development Guide

Bu dosya, AI asistanların (Claude, GPT, Cursor vb.) bu projeyi daha iyi anlaması için hazırlanmıştır.

## 🎯 Proje Özeti

Bu bir **browser extension** (tarayıcı eklentisi) projesidir. Hem Chrome hem Firefox'ta çalışacak şekilde tasarlanmıştır.

## 📁 Dosya Yapısı ve Amaçları

```
project/
├── manifest.json           # Chrome için ana manifest dosyası (Manifest V3)
├── manifest.firefox.json   # Firefox için manifest (gecko ayarları içerir)
├── src/
│   ├── content.js         # Hedef web sayfasında çalışan ana script
│   ├── styles.css         # Content script'in eklediği stiller
│   ├── popup.html         # Toolbar'daki ikon tıklandığında açılan popup
│   ├── popup.js           # Popup'ın JavaScript'i
│   ├── options.html       # Ayarlar sayfası (chrome://extensions'dan erişilir)
│   └── options.js         # Ayarlar sayfasının JavaScript'i
├── icons/                 # Extension ikonları (16, 48, 128 px)
└── images/                # Promosyon görselleri, ekran görüntüleri
```

## 🔧 Manifest V3 Özellikleri

### Permissions (İzinler)
```json
{
    "permissions": [
        "storage",        // chrome.storage API - ayarları saklamak için
        "tabs",           // Tab bilgilerine erişim (isteğe bağlı)
        "activeTab"       // Aktif tab'a erişim (isteğe bağlı)
    ],
    "host_permissions": [
        "https://example.com/*"   // Hangi sitelerde çalışacak
    ]
}
```

### Content Scripts
Content script'ler belirtilen URL pattern'leriyle eşleşen sayfalarda otomatik çalışır:
```json
{
    "content_scripts": [{
        "matches": ["https://example.com/*"],
        "js": ["src/content.js"],
        "css": ["src/styles.css"]
    }]
}
```

### Action (Popup)
Toolbar'daki ikon için popup tanımı:
```json
{
    "action": {
        "default_popup": "src/popup.html",
        "default_icon": {
            "16": "icons/icon16.png",
            "48": "icons/icon48.png"
        }
    }
}
```

## 💾 Chrome Storage API

Ayarları kaydetmek ve okumak için `chrome.storage.sync` kullanılır:

```javascript
// Kaydetme
chrome.storage.sync.set({
    apiKey: 'xxx',
    enabled: true
}, () => {
    console.log('Kaydedildi');
});

// Okuma (varsayılan değerlerle)
chrome.storage.sync.get({
    apiKey: '',
    enabled: true
}, (items) => {
    console.log(items.apiKey);
    console.log(items.enabled);
});
```

## 🌐 Chrome vs Firefox Farkları

### Firefox Özel Ayarları
Firefox'un `manifest.firefox.json` dosyasında ek ayarlar gerekir:
```json
{
    "browser_specific_settings": {
        "gecko": {
            "id": "extension-name@example.com",
            "strict_min_version": "109.0"
        }
    },
    "options_ui": {
        "page": "src/options.html",
        "open_in_tab": true
    }
}
```

### API Farkları
- Chrome: `chrome.runtime`, `chrome.storage`
- Firefox: Aynı API'ler çalışır (Chrome uyumlu)

## 🎨 CSS Best Practices

### CSS Variables ile Tema Desteği
```css
:root {
    --ext-bg: #ffffff;
    --ext-text: #333333;
    --ext-primary: #4a90d9;
}

.ext-dark {
    --ext-bg: #2d2d2d;
    --ext-text: #cccccc;
}
```

### Specificity Sorunlarını Önleme
Host sayfanın CSS'i ile çakışmayı önlemek için:
```css
/* Prefix kullan */
.my-extension-container { }
.my-extension-btn { }

/* !important dikkatli kullan */
.my-extension-btn {
    background-color: var(--ext-primary) !important;
}
```

## 🔌 External API Çağrıları

Content script'ten API çağrısı yapmak için `host_permissions` gerekir:

```javascript
// manifest.json'da
"host_permissions": [
    "https://api.example.com/*"
]

// content.js'de
const response = await fetch('https://api.example.com/data', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
    },
    body: JSON.stringify({ data: 'value' })
});
```

## 🐛 Debug İpuçları

### Content Script Debug
1. Hedef sayfada F12 → Console
2. Extension hataları burada görünür

### Popup Debug
1. Extension ikonuna sağ tık → "Inspect popup"
2. Ayrı DevTools penceresi açılır

### Background/Service Worker Debug
1. `chrome://extensions` → Extension detayları
2. "Service worker" linkine tıkla

## 📦 Paketleme

```bash
# Tüm platformlar için
./package.sh

# Sadece Chrome
./package.sh chrome

# Sadece Firefox
./package.sh firefox
```

## 🚀 Yaygın Kullanım Senaryoları

### 1. Sayfaya Buton Ekleme
```javascript
const button = document.createElement('button');
button.className = 'my-ext-btn';
button.textContent = 'Analiz Et';
button.onclick = handleClick;
document.querySelector('.target-element').appendChild(button);
```

### 2. Sayfa İçeriğini Okuma
```javascript
const entries = document.querySelectorAll('.entry');
const data = Array.from(entries).map(entry => ({
    id: entry.dataset.id,
    content: entry.querySelector('.content').textContent,
    author: entry.querySelector('.author').textContent
}));
```

### 3. DOM Değişikliklerini İzleme
```javascript
const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
        if (mutation.addedNodes.length) {
            // Yeni elementler eklendi
            handleNewContent(mutation.addedNodes);
        }
    });
});

observer.observe(document.body, {
    childList: true,
    subtree: true
});
```

### 4. Popup'tan Content Script'e Mesaj Gönderme
```javascript
// popup.js
chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
    chrome.tabs.sendMessage(tabs[0].id, { action: 'getData' }, (response) => {
        console.log(response);
    });
});

// content.js
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'getData') {
        sendResponse({ data: collectedData });
    }
    return true; // Async response için
});
```

## ⚠️ Önemli Notlar

1. **CORS**: Content script'ler host sayfanın context'inde çalışır, API çağrıları için `host_permissions` gerekir
2. **CSP**: Bazı siteler Content Security Policy ile inline script'leri engeller
3. **Rate Limiting**: External API'lere çok sık istek atmaktan kaçının
4. **Storage Limits**: `chrome.storage.sync` max 100KB, `chrome.storage.local` max 5MB
5. **Manifest V3**: Service worker'lar persistent değil, state'i storage'da tutun

## 📝 Geliştirme Checklist

- [ ] manifest.json'da doğru permissions tanımlandı
- [ ] host_permissions hedef siteleri içeriyor
- [ ] Content script doğru URL pattern'leriyle eşleşiyor
- [ ] CSS class'ları prefix ile unique
- [ ] API key'ler güvenli şekilde saklanıyor
- [ ] Hata mesajları kullanıcı dostu
- [ ] Dark/light mode desteği var
- [ ] Firefox uyumluluğu test edildi
AI_CONTEXT_EOF

# ============================================
# TECH_STACK.md - Kullanılan teknolojiler
# ============================================
cat > TECH_STACK.md << 'TECH_STACK_EOF'
# Technology Stack

## Core Technologies

| Teknoloji | Versiyon | Amaç |
|-----------|----------|------|
| Manifest | V3 | Chrome Extension API |
| JavaScript | ES2020+ | Ana programlama dili |
| CSS3 | - | Stil ve tema |
| HTML5 | - | UI yapısı |

## Browser APIs

### Chrome Extension APIs
- `chrome.storage.sync` - Ayarları senkronize kaydetme
- `chrome.storage.local` - Büyük verileri lokal kaydetme
- `chrome.runtime` - Extension lifecycle yönetimi
- `chrome.tabs` - Tab yönetimi
- `chrome.action` - Toolbar action (popup)

### Web APIs
- `fetch` - HTTP istekleri
- `MutationObserver` - DOM değişiklik izleme
- `IntersectionObserver` - Görünürlük izleme
- `localStorage` - Ek lokal depolama
- `Clipboard API` - Kopyalama işlemleri

## Recommended Libraries (İsteğe Bağlı)

### UI
- **None required** - Vanilla JS/CSS yeterli
- Alternatif: Tailwind CSS (build gerektirir)

### Markdown Parsing
```javascript
// Basit markdown parser (built-in)
const parseMarkdown = (text) => {
    // Bold, italic, links, headers...
};
```

### Date Formatting
```javascript
// Native Intl API kullan
new Intl.DateTimeFormat('tr-TR', {
    dateStyle: 'medium',
    timeStyle: 'short'
}).format(new Date());
```

## Build Tools (İsteğe Bağlı)

Bu proje build tool gerektirmez, ancak büyüdükçe:

```bash
# Eğer TypeScript kullanmak isterseniz
npm init -y
npm install --save-dev typescript
npx tsc --init
```

## Testing

### Manuel Test
1. `chrome://extensions` → "Load unpacked"
2. Hedef siteye git
3. DevTools Console'da hataları kontrol et

### Automated Testing (Opsiyonel)
```bash
npm install --save-dev jest puppeteer
```

## Performance Considerations

1. **Lazy Loading**: Büyük işlemleri gerektiğinde yükle
2. **Debouncing**: Sık tetiklenen event'lerde kullan
3. **DOM Batch Updates**: DOM manipülasyonlarını grupla
4. **Memory Management**: Event listener'ları temizle

## Security

1. **XSS Prevention**: `textContent` kullan, `innerHTML` dikkatli
2. **API Keys**: Asla hardcode etme, storage kullan
3. **CSP Compliance**: Inline script'lerden kaçın
4. **Input Validation**: Kullanıcı girdilerini validate et
TECH_STACK_EOF

# ============================================
# CURSOR_RULES.md - Cursor AI için özel kurallar
# ============================================
cat > .cursorrules << 'CURSOR_RULES_EOF'
# Cursor AI Rules for Browser Extension Development

## Project Type
This is a Chrome/Firefox browser extension using Manifest V3.

## Code Style
- Use vanilla JavaScript (ES2020+)
- No build tools required
- CSS with CSS variables for theming
- Turkish comments are acceptable

## File Naming
- Use kebab-case for files
- Prefix CSS classes with extension name to avoid conflicts

## Important Patterns

### Storage Access
Always use chrome.storage.sync for settings:
```javascript
chrome.storage.sync.get({ key: 'default' }, (items) => {
    // use items.key
});
```

### DOM Manipulation
Always escape HTML to prevent XSS:
```javascript
const escapeHtml = (str) => {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
};
```

### Async Operations
Use async/await with proper error handling:
```javascript
try {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
} catch (err) {
    console.error('Fetch error:', err);
    showError(err.message);
}
```

## Don't Do
- Don't use eval() or new Function()
- Don't use inline event handlers in HTML
- Don't hardcode API keys
- Don't use document.write()
- Don't block the main thread with sync operations

## Testing
- Test in both Chrome and Firefox
- Check dark mode compatibility
- Verify storage operations work correctly

## Localization
- Keep user-facing strings in Turkish
- Console logs can be in English
CURSOR_RULES_EOF

# ============================================
# Git repository oluştur ve initial commit yap
# ============================================
echo ""
echo -e "${CYAN}Git repository oluşturuluyor...${NC}"

git init -q

# Tüm dosyaları ekle
git add .

# Initial commit
git commit -q -m "Initial commit: $EXTENSION_NAME browser extension

- Chrome ve Firefox manifest dosyaları
- Temel content script ve stiller
- Popup ve options sayfaları
- Paketleme scriptleri
- README dokümantasyonu"

# ============================================
# Özet
# ============================================
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                    ${BOLD}PROJE OLUŞTURULDU!${NC}                      ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Proje konumu:${NC} $PROJECT_PATH"
echo ""
echo -e "${BOLD}📁 Oluşturulan Dosyalar:${NC}"
echo "  ├── manifest.json / manifest.firefox.json"
echo "  ├── src/ (content.js, popup, options)"
echo "  ├── icons/, images/"
echo "  ├── package.sh, generate-icons.sh"
echo "  ├── .gitignore, README.md"
echo "  ├── STORE_LISTING.md    (Mağaza listeleme bilgileri)"
echo "  └── ${CYAN}AI Context Dosyaları:${NC}"
echo "      ├── AI_CONTEXT.md    (Proje yapısı ve API'ler)"
echo "      ├── TECH_STACK.md    (Teknoloji stack)"
echo "      └── .cursorrules     (Cursor AI kuralları)"
echo ""
echo -e "${YELLOW}Sonraki adımlar:${NC}"
echo "  1. cd $PROJECT_PATH"
echo "  2. icons/icon128.png dosyasını ekleyin (128x128 PNG)"
echo "  3. ./generate-icons.sh ile diğer boyutları oluşturun"
echo "  4. manifest.json dosyalarını düzenleyin:"
echo "     - description"
echo "     - author"
echo "     - host_permissions (hedef site)"
echo "     - content_scripts matches"
echo "  5. Vibe coding başlasın! 🎨"
echo ""
echo -e "${CYAN}AI ile Geliştirme:${NC}"
echo "  • AI_CONTEXT.md   → Projeyi anlaması için"
echo "  • TECH_STACK.md   → Teknoloji stack bilgisi için"
echo "  • .cursorrules    → Cursor AI için özel kurallar"
echo ""
echo -e "${CYAN}Faydalı komutlar:${NC}"
echo "  ./package.sh          # Paket oluştur"
echo "  ./generate-icons.sh   # İkonları oluştur"
echo ""
echo -e "${GREEN}İyi vibe coding'ler! 🚀✨${NC}"
echo ""

# ============================================
# Editör ile Aç
# ============================================
if [ -n "$EDITOR_CMD" ]; then
    if command -v "$EDITOR_CMD" &> /dev/null; then
        echo -e "${CYAN}Proje ${EDITOR_CMD} ile açılıyor...${NC}"
        "$EDITOR_CMD" "$PROJECT_PATH"
    else
        echo -e "${RED}Uyarı: '${EDITOR_CMD}' komutu bulunamadı!${NC}"
    fi
fi
