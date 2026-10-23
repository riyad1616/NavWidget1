#!/bin/bash
# ============================================================
#  NavWidget - سكربت بناء APK تلقائي عبر Termux
#  يُنفّذ داخل Termux على الهاتف مباشرة
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[✓]${NC}   $1"; }
warn()  { echo -e "${YELLOW}[!]${NC}   $1"; }
err()   { echo -e "${RED}[✗]${NC}   $1"; exit 1; }

# ---- الخطوة 0: تأكد أنك في Termux ----
if [[ "$SHELL" != *termux* ]] && [[ "$TERMUX_VERSION" = "" ]]; then
    warn "هذا السكربت مُصمم لـ Termux فقط!"
    warn "انسخه لهاتفك وافتحه من Termux"
fi

# ---- الخطوة 1: تحديث الحزم ----
info "تحديث حزم Termux..."
pkg update -y || err "فشل تحديث الحزم"
pkg upgrade -y || err "فشل ترقية الحزم"
ok "تم تحديث الحزم"

# ---- الخطوة 2: تثبيت المتطلبات ----
info "تثبيت JDK 17 وأدوات البناء..."
pkg install -y openjdk-17 wget unzip || err "فشل تثبيت JDK"

JAVA_VER=$(java -version 2>&1 | head -1)
ok "Java مثبت: $JAVA_VER"

# ---- الخطوة 3: تثبيت Android SDK ----
info "تحميل وتثبيت Android SDK..."

ANDROID_HOME="$HOME/android-sdk"
mkdir -p "$ANDROID_HOME/cmdline-tools"

CMDLINE_ZIP="$HOME/cmdline-tools.zip"
CMDLINE_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

if [[ ! -f "$CMDLINE_ZIP" ]]; then
    info "تحميل Command Line Tools (${CMDLINE_URL##*/})..."
    wget -q --show-progress -O "$CMDLINE_ZIP" "$CMDLINE_URL" || \
        err "فشل تحميل Command Line Tools"
    ok "تم التحميل"
fi

unzip -o -q "$CMDLINE_ZIP" -d "$ANDROID_HOME/cmdline-tools/" || \
    err "فشل فك ضغط Command Line Tools"
mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest" 2>/dev/null || true

export ANDROID_HOME="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

info "قبول تراخيص SDK..."
sdkmanager --licenses -y 2>/dev/null || true

info "تثبيت Android SDK 34 و Build Tools..."
sdkmanager "platforms;android-34" "build-tools;34.0.0" || \
    err "فشل تثبيت SDK"
ok "تم تثبيت Android SDK 34"

# ---- الخطوة 4: إعداد Gradle ----
info "إعداد Gradle Wrapper..."

WRAPPER_JAR="./gradle/wrapper/gradle-wrapper.jar"
WRAP_SCRIPT="./gradlew"

if [[ -f "$WRAP_SCRIPT" ]] && [[ -f "$WRAPPER_JAR" ]]; then
    ok "Gradle Wrapper موجود ومتكامل"
    chmod +x "$WRAP_SCRIPT"
else
    warn "ملفات Gradle Wrapper مفقودة — سيتم تنزيلها من Gradle 8.2..."

    GRADLE_VER="8.2"
    GRADLE_HOME="$HOME/gradle-$GRADLE_VER"

    if [[ ! -d "$GRADLE_HOME" ]]; then
        info "تحميل Gradle $GRADLE_VER..."
        GRADLE_ZIP="$HOME/gradle-${GRADLE_VER}-bin.zip"
        wget -q --show-progress -O "$GRADLE_ZIP" \
            "https://services.gradle.org/distributions/gradle-${GRADLE_VER}-bin.zip" || \
            err "فشل تحميل Gradle"

        unzip -o -q "$GRADLE_ZIP" -d "$HOME/" || err "فشل فك ضغط Gradle"
    fi

    export PATH="$GRADLE_HOME/bin:$PATH"
    gradle wrapper || err "فشل إنشاء Gradle Wrapper"
    rm -rf "$GRADLE_HOME" "$HOME/gradle-${GRADLE_VER}-bin.zip"
    ok "تم إنشاء Gradle Wrapper"
    chmod +x ./gradlew
fi

# ---- الخطوة 5: بناء APK ----
info "بناء APK (assembleDebug)..."
export ANDROID_HOME="$ANDROID_HOME"
export JAVA_HOME="/data/data/com.termux/files/usr"

./gradlew assembleDebug --no-daemon 2>&1 || {
    err "فشل بناء APK — راجع الأخطاء أعلاه"
}
ok "تم بناء APK بنجاح!"

# ---- الخطوة 6: عرض نتيجة البناء ----
APK_DIR="app/build/outputs/apk/debug"
if [[ -d "$APK_DIR" ]] && ls "$APK_DIR"/*.apk 1>/dev/null 2>&1; then
    APK_FILE=$(ls -t "$APK_DIR"/*.apk | head -1)
    APK_SIZE=$(du -h "$APK_FILE" | cut -f1)
    ok "ملف APK جاهز:"
    info "   المسار: $APK_FILE"
    info "   الحجم:  $APK_SIZE"

    # ---- الخطوة 7: التثبيت ----
    info "تثبيت APK..."
    if command -v adb &>/dev/null; then
        adb install -r "$APK_FILE" || warn "فشل ADB — ثبّت يدوياً"
        ok "تم التثبيت عبر ADB"
    else
        info "كوبّي APK إلى مجلد التحميل..."
        cp "$APK_FILE" "$HOME/../Download/" 2>/dev/null && \
            ok "تم النسخ إلى /Download/ — ثبّته من مدير الملفات" || \
            warn "لا يمكن النسخ تلقائياً — انقله يدوياً من: $APK_FILE"
    fi
else
    err "لم يُعثر على ملف APK في $APK_DIR"
fi

echo ""
echo "=========================================="
ok "انتهى البناء والتثبيت!"
echo "=========================================="
