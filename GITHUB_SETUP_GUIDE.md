# دليل رفع مشروع Flutter Todo App على GitHub

## 📋 الملفات المهمة التي تم رفعها

تم رفع الملفات الأساسية فقط (168 ملف) بدلاً من 2.5 جيجا:

### ✅ الملفات المرفوعة:
- **lib/** - كود التطبيق الأساسي
- **pubspec.yaml** - تبعيات المشروع
- **android/app/** - إعدادات Android الأساسية
- **ios/Runner/** - إعدادات iOS الأساسية
- **web/** - إعدادات الويب
- **windows/**, **linux/**, **macos/** - إعدادات المنصات الأخرى

### ❌ الملفات المستبعدة (توفير 2+ جيجا):
- **build/** - ملفات البناء
- **android/.gradle/** - ملفات Gradle
- **android/app/build/** - ملفات APK المبنية
- **ios/Flutter/ephemeral/** - ملفات iOS المؤقتة
- **reports/** - تقارير الاختبار
- ***.log** - ملفات السجلات

---

## 🚀 خطوات رفع المشروع على GitHub

### الخطوة 1: إنشاء Repository على GitHub
1. اذهب إلى [GitHub.com](https://github.com)
2. اضغط على زر **"New"** أو **"+"** ثم **"New repository"**
3. أدخل اسم المشروع: `todoapp`
4. اختر **Private** أو **Public** حسب رغبتك
5. **لا** تضع علامة على "Initialize with README"
6. اضغط **"Create repository"**

### الخطوة 2: ربط المشروع المحلي بـ GitHub
```bash
# إضافة remote origin (استبدل USERNAME باسمك)
git remote add origin https://github.com/USERNAME/todoapp.git

# رفع الملفات
git push -u origin master
```

### الخطوة 3: التحقق من الرفع
- اذهب إلى repository على GitHub
- تأكد من ظهور جميع الملفات
- حجم المشروع يجب أن يكون أقل من 50 ميجا بدلاً من 2.5 جيجا

---

## 🔄 كيفية إرسال التحديثات (Push)

### عند إجراء تعديلات جديدة:

```bash
# 1. عرض التغييرات
git status

# 2. إضافة الملفات المعدلة
git add .

# 3. إنشاء commit مع رسالة وصفية
git commit -m "وصف التغييرات: إضافة ميزة جديدة"

# 4. رفع التحديثات
git push origin master
```

### مثال على الرسائل الوصفية:
```bash
git commit -m "إضافة شاشة إعدادات الإشعارات"
git commit -m "إصلاح مشكلة في حفظ المهام"
git commit -m "تحسين واجهة المستخدم"
git commit -m "إضافة دعم اللغة العربية"
```

---

## 📥 كيفية الاستيراد من GitHub (Pull)

### عند العمل على جهاز آخر أو الحصول على تحديثات:

```bash
# 1. استنساخ المشروع لأول مرة
git clone https://github.com/USERNAME/todoapp.git
cd todoapp

# 2. تحميل التبعيات
flutter pub get

# 3. تشغيل التطبيق
flutter run
```

### عند الحصول على تحديثات جديدة:

```bash
# 1. جلب التحديثات من GitHub
git pull origin master

# 2. تحديث التبعيات
flutter pub get

# 3. إعادة تشغيل التطبيق
flutter run
```

---

## 🛠️ أوامر Git مفيدة

### عرض حالة المشروع:
```bash
git status                    # عرض الملفات المعدلة
git log --oneline            # عرض تاريخ الـ commits
git diff                     # عرض التغييرات بالتفصيل
```

### إدارة الفروع:
```bash
git branch                   # عرض الفروع
git checkout -b feature-name # إنشاء فرع جديد
git merge feature-name       # دمج فرع
```

### التراجع عن التغييرات:
```bash
git checkout -- filename    # إلغاء تعديلات ملف معين
git reset --hard HEAD       # إلغاء جميع التعديلات
```

---

## 📱 إعادة بناء المشروع بعد الاستيراد

### بعد استيراد المشروع من GitHub:

1. **تحديث التبعيات:**
```bash
flutter pub get
```

2. **إنشاء ملفات البناء المطلوبة:**
```bash
flutter packages pub run build_runner build
```

3. **تشغيل التطبيق:**
```bash
flutter run
```

4. **بناء APK (اختياري):**
```bash
flutter build apk --release
```

---

## ⚠️ نصائح مهمة

### 1. قبل كل push:
- تأكد من أن التطبيق يعمل بدون أخطاء
- اختبر الوظائف الأساسية
- اكتب رسالة commit وصفية

### 2. عند العمل في فريق:
- استخدم فروع منفصلة للميزات الجديدة
- اكتب رسائل commit واضحة
- راجع التغييرات قبل الدمج

### 3. الأمان:
- لا تضع معلومات حساسة في الكود
- استخدم ملفات `.env` للمتغيرات السرية
- تأكد من أن `.gitignore` يستبعد الملفات المهمة

---

## 🔧 حل المشاكل الشائعة

### مشكلة: "repository not found"
```bash
# تأكد من رابط GitHub الصحيح
git remote -v
git remote set-url origin https://github.com/USERNAME/todoapp.git
```

### مشكلة: "conflict" عند pull
```bash
# حل التعارضات يدوياً ثم:
git add .
git commit -m "حل التعارضات"
git push origin master
```

### مشكلة: "permission denied"
- تأكد من تسجيل الدخول لـ GitHub
- استخدم Personal Access Token بدلاً من كلمة المرور

---

## 📊 حجم المشروع الآن

- **قبل التحسين:** 2.5 جيجا
- **بعد التحسين:** أقل من 50 ميجا
- **توفير:** أكثر من 98% من المساحة

هذا يجعل المشروع سريع الرفع والتحميل، ومتوافق مع حدود GitHub.
