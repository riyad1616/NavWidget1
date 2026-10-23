# 📱 NavWidget - دليل البناء عبر Termux

## ما هو المشروع؟
ويدجت عائم يعرض معلومات الملاحة (خطوط سير Google Maps، Waze، Mapbox) فوق جميع التطبيقات.

---

## 🚀 طريقة البناء السريع

### الخطوة 1: انسخ ملفات المشروع لهاتفك
انسخ مجلد `NavWidget` كاملاً (أو ملف الـ tar.gz) إلى هاتفك.

### الخطوة 2: افتح Termux واذهب لمجلد المشروع
```bash
cd /sdcard/NavWidget
# أو المكان الذي نسخت فيه الملفات
```

### الخطوة 3: شغّل السكربت تلقائياً
```bash
chmod +x build_termux.sh
bash build_termux.sh
```

### الخطوة 4: انتظر حتى ينتهي البناء
- التحميل الأولي (SDK + Gradle): **~3-5 GB**
- مدة البناء: **5-15 دقيقة** حسب سرعة الهاتف

### الخطوة 5: ثبّت APK
سيقوم السكربت بنسخ APK إلى `/Download/` — افتحه من مدير الملفات وثبّته.

---

## 📋 ما يفعله السكربت تلقائياً؟

| الخطوة | الوصف |
|--------|-------|
| 1 | تحديث حزم Termux |
| 2 | تثبيت JDK 17 + wget + unzip |
| 3 | تحميل وتثبيت Android SDK 34 |
| 4 | قبول تراخيص SDK |
| 5 | إعداد Gradle Wrapper 8.2 |
| 6 | بناء APK عبر `assembleDebug` |
| 7 | نسخ APK لمجلد التحميل |

---

## ⚠️ ملاحظات مهمة

- **مساحة التخزين**: تحتاج **~5 GB** فارغة على الأقل
- **الذاكرة**: تحتاج **~4 GB RAM** للبناء
- **إنترنت**: مطلوب لتحميل SDK و Gradle
- **المدة**: أول مرة **15-30 دقيقة** (التحميلات + البناء)
- **المرات القادمة**: ~5 دقائق فقط (SDK محفوظ)

---

## 🔧 مشاكل شائعة

### `Permission denied` عند الوصول لـ `/sdcard/`
```bash
termux-setup-storage
```
ثم جرّب مرة أخرى.

### `Gradle build failed`
تأكد من أن مجلد `gradle/wrapper/` يحتوي على `gradle-wrapper.jar`.

### `SDK manager not found`
تأكد من أن `$ANDROID_HOME` مضبوط صحيح:
```bash
echo $ANDROID_HOME
# يجب أن يطبع: /data/data/com.termux/files/home/android-sdk
```

---

## 📱 صلاحيات التطبيق بعد التثبيت

بعد تثبيت NavWidget، افتحه وامنحه هذه الصلاحيات:
1. **إقرأ الإشعارات** — لعرض معلومات الملاحة
2. **العرض فوق التطبيقات** — لعرض الويدجت العائم
3. **إحصائيات الاستخدام** (اختياري) — لإخفاء الويدجت داخل Maps تلقائياً

---

## 📂 بنية المشروع

```
NavWidget/
├── build_termux.sh          ← سكربت البناء (شغّله!)
├── build.gradle             ← إعدادات Gradle الرئيسية
├── settings.gradle          ← إعدادات المشروع
├── app/
│   ├── build.gradle         ← إعدادات التطبيق
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/com/navwidget/
│       │   ├── model/NavigationInfo.kt
│       │   ├── receiver/UsageStatsReceiver.kt
│       │   ├── service/
│       │   │   ├── FloatingWidgetService.kt
│       │   │   └── NotificationParserService.kt
│       │   └── ui/MainActivity.kt
│       └── res/
│           ├── layout/
│           ├── values/
│           └── drawable/
```
