# دليل أوامر Git و GitHub - Flutter Todo App

## 🚀 **الأوامر الأساسية للرفع والاسترداد**

### **1. فحص حالة المشروع**
```bash
# عرض حالة الملفات
git status

# عرض تاريخ الـ commits
git log --oneline

# عرض آخر 5 commits
git log --oneline -5
```

### **2. رفع التحديثات إلى GitHub**

#### **الطريقة الكاملة:**
```bash
# 1. فحص التغييرات
git status

# 2. إضافة الملفات
git add .                    # إضافة جميع الملفات
git add filename.txt         # إضافة ملف محدد

# 3. إنشاء commit
git commit -m "وصف التغييرات"

# 4. رفع إلى GitHub
git push origin main
```

#### **الطريقة السريعة (للملفات المعدلة فقط):**
```bash
git add . && git commit -m "وصف التغييرات" && git push origin main
```

### **3. استرداد التحديثات من GitHub**

#### **جلب التحديثات:**
```bash
# جلب التحديثات من GitHub
git fetch origin

# دمج التحديثات مع المشروع المحلي
git pull origin main

# أو في أمر واحد
git pull origin main
```

### **4. استرداد commit معين**

#### **العودة إلى commit معين:**
```bash
# عرض تاريخ الـ commits
git log --oneline

# العودة إلى commit معين (استبدل HASH بالرقم الفعلي)
git checkout <commit-hash>

# مثال
git checkout b2b22bf

# العودة إلى الإصدار الحالي
git checkout main
```

#### **إنشاء branch من commit معين:**
```bash
# إنشاء branch جديد من commit معين
git checkout -b new-branch-name <commit-hash>

# مثال
git checkout -b fix-branch b2b22bf
```

---

## 🔄 **أوامر متقدمة للاسترداد**

### **1. إلغاء آخر commit**
```bash
# إلغاء آخر commit مع الاحتفاظ بالتغييرات
git reset --soft HEAD~1

# إلغاء آخر commit مع حذف التغييرات (حذر!)
git reset --hard HEAD~1

# إلغاء آخر commit مع الاحتفاظ بالتغييرات في working directory
git reset --mixed HEAD~1
```

### **2. العودة إلى commit معين نهائياً**
```bash
# العودة إلى commit معين مع حذف جميع التغييرات اللاحقة
git reset --hard <commit-hash>

# مثال
git reset --hard 76b96c6
```

### **3. استرداد ملف محدد**
```bash
# استرداد ملف من commit معين
git checkout <commit-hash> -- filename.txt

# مثال
git checkout b2b22bf -- test_file.txt
```

---

## 🏷️ **إنشاء الإصدارات (Tags)**

### **1. إنشاء إصدار**
```bash
# إنشاء إصدار بسيط
git tag v1.0.0

# إنشاء إصدار مفصل
git tag -a v1.0.0 -m "الإصدار الأول من التطبيق"

# إنشاء إصدار لـ commit معين
git tag -a v1.0.0 <commit-hash> -m "وصف الإصدار"
```

### **2. رفع الإصدارات**
```bash
# رفع إصدار واحد
git push origin v1.0.0

# رفع جميع الإصدارات
git push origin --tags
```

### **3. العودة إلى إصدار معين**
```bash
# عرض جميع الإصدارات
git tag

# العودة إلى إصدار معين
git checkout v1.0.0

# العودة إلى الإصدار الحالي
git checkout main
```

---

## 🔍 **أوامر الفحص والمراجعة**

### **1. فحص الملفات**
```bash
# عرض الملفات المعدلة
git status

# عرض الفروق في الملفات
git diff

# عرض الفروق في ملف محدد
git diff filename.txt

# عرض الفروق بين commit معين والحالي
git diff <commit-hash>
```

### **2. فحص التاريخ**
```bash
# عرض تاريخ مفصل
git log

# عرض تاريخ مختصر
git log --oneline

# عرض تاريخ مع الرسائل
git log --oneline --graph

# عرض تفاصيل commit معين
git show <commit-hash>
```

### **3. فحص الفروع**
```bash
# عرض الفروع المحلية
git branch

# عرض جميع الفروع
git branch -a

# عرض الفروع البعيدة
git branch -r
```

---

## 🛠️ **أوامر إدارة المشروع**

### **1. إنشاء فروع جديدة**
```bash
# إنشاء فرع جديد
git checkout -b new-feature

# إنشاء فرع من commit معين
git checkout -b new-feature <commit-hash>

# التبديل بين الفروع
git checkout main
git checkout new-feature
```

### **2. دمج الفروع**
```bash
# دمج فرع مع الفرع الحالي
git merge new-feature

# حذف فرع محلي
git branch -d new-feature

# حذف فرع بعيد
git push origin --delete new-feature
```

### **3. إدارة الملفات**
```bash
# حذف ملف من Git
git rm filename.txt

# حذف ملف من Git مع الاحتفاظ به محلياً
git rm --cached filename.txt

# إعادة تسمية ملف
git mv oldname.txt newname.txt
```

---

## ⚠️ **أوامر الطوارئ**

### **1. إلغاء التغييرات**
```bash
# إلغاء التغييرات في ملف محدد
git checkout -- filename.txt

# إلغاء جميع التغييرات غير المحفوظة
git checkout -- .

# إلغاء إضافة ملفات للـ staging
git reset HEAD filename.txt
```

### **2. استرداد من GitHub**
```bash
# جلب جميع التحديثات
git fetch origin

# إعادة تعيين المشروع المحلي ليطابق GitHub
git reset --hard origin/main

# جلب فرع معين
git fetch origin branch-name:branch-name
```

### **3. تنظيف المشروع**
```bash
# حذف الملفات غير المتتبعة
git clean -f

# حذف الملفات والمجلدات غير المتتبعة
git clean -fd

# عرض الملفات التي سيتم حذفها (بدون حذف فعلي)
git clean -n
```

---

## 📋 **سير العمل المقترح**

### **للتطوير اليومي:**
```bash
# 1. فحص التغييرات
git status

# 2. إضافة الملفات
git add .

# 3. إنشاء commit
git commit -m "وصف التغييرات"

# 4. رفع التحديثات
git push origin main
```

### **للاسترداد:**
```bash
# 1. عرض التاريخ
git log --oneline

# 2. العودة إلى commit معين
git checkout <commit-hash>

# 3. العودة للحالي
git checkout main
```

### **لإنشاء إصدار:**
```bash
# 1. التأكد من أن كل شيء مرفوع
git push origin main

# 2. إنشاء إصدار
git tag -a v1.0.0 -m "الإصدار الأول"

# 3. رفع الإصدار
git push origin v1.0.0
```

---

## 🎯 **أمثلة عملية**

### **مثال 1: رفع تحديث جديد**
```bash
git status
git add .
git commit -m "إضافة ميزة الإشعارات"
git push origin main
```

### **مثال 2: العودة إلى commit سابق**
```bash
git log --oneline
git checkout faa1d10
# مراجعة الملفات
git checkout main
```

### **مثال 3: إنشاء إصدار**
```bash
git tag -a v1.0.0 -m "الإصدار الأول الرسمي"
git push origin v1.0.0
```

---

## 💡 **نصائح مهمة**

1. **اكتب رسائل commit واضحة** - مثل "إضافة صفحة تسجيل الدخول"
2. **احفظ نسخة احتياطية** قبل أي عملية `reset --hard`
3. **استخدم `git status`** دائماً قبل أي عملية
4. **اختبر المشروع** قبل إنشاء إصدار
5. **احتفظ بهذا الملف** للرجوع إليه عند الحاجة

---

## 🔗 **روابط مفيدة**

- **GitHub Repository**: https://github.com/ibrahemgit/todoapp
- **Git Documentation**: https://git-scm.com/doc
- **Flutter Documentation**: https://flutter.dev/docs

---

**تاريخ الإنشاء**: $(Get-Date)  
**المشروع**: Flutter Todo App  
**المطور**: Smart Todo App Team
