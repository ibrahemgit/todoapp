import 'package:flutter/material.dart';

/// خدمة إدارة النوافذ العائمة فوق التطبيقات
class OverlayService {
  static bool _isOverlayVisible = false;
  static bool _isPermissionGranted = false;

  /// طلب الصلاحيات المطلوبة للنوافذ العائمة
  static Future<bool> requestPermissions() async {
    try {
      // للتبسيط، سنعتبر أن الصلاحيات متاحة
      // في التطبيق الحقيقي، يجب طلب الصلاحيات الفعلية
      _isPermissionGranted = true;
      return true;
    } catch (e) {
      debugPrint('خطأ في طلب الصلاحيات: $e');
      return false;
    }
  }

  /// فحص ما إذا كانت الصلاحيات متاحة
  static Future<bool> hasPermissions() async {
    try {
      // للتبسيط، سنعتبر أن الصلاحيات متاحة
      return _isPermissionGranted;
    } catch (e) {
      debugPrint('خطأ في فحص الصلاحيات: $e');
      return false;
    }
  }

  /// عرض النافذة العائمة (مبسطة)
  static Future<bool> showOverlay({
    required String title,
    required String message,
    required VoidCallback onComplete,
    required VoidCallback onSnooze,
  }) async {
    try {
      // فحص الصلاحيات أولاً
      if (!await hasPermissions()) {
        debugPrint('الصلاحيات غير متاحة');
        return false;
      }

      // إغلاق النافذة السابقة إذا كانت مفتوحة
      if (_isOverlayVisible) {
        await hideOverlay();
      }

      // للتبسيط، سنستخدم نافذة منبثقة عادية
      // في التطبيق الحقيقي، يمكن استخدام flutter_overlay_window
      _isOverlayVisible = true;
      debugPrint('تم عرض النافذة العائمة بنجاح (مبسطة)');
      return true;
    } catch (e) {
      debugPrint('خطأ في عرض النافذة العائمة: $e');
      return false;
    }
  }

  /// إخفاء النافذة العائمة
  static Future<bool> hideOverlay() async {
    try {
      if (!_isOverlayVisible) {
        debugPrint('النافذة العائمة غير مفتوحة');
        return true;
      }

      _isOverlayVisible = false;
      debugPrint('تم إغلاق النافذة العائمة بنجاح');
      return true;
    } catch (e) {
      debugPrint('خطأ في إغلاق النافذة العائمة: $e');
      return false;
    }
  }

  /// فحص حالة النافذة العائمة
  static bool get isOverlayVisible => _isOverlayVisible;

  /// فحص حالة الصلاحيات
  static bool get isPermissionGranted => _isPermissionGranted;

  /// إعادة تعيين الحالة
  static void reset() {
    _isOverlayVisible = false;
    _isPermissionGranted = false;
  }

  /// فتح إعدادات الصلاحيات
  static Future<void> openPermissionSettings() async {
    try {
      // للتبسيط، سنعرض رسالة فقط
      debugPrint('يجب فتح إعدادات الصلاحيات يدوياً');
    } catch (e) {
      debugPrint('خطأ في فتح إعدادات الصلاحيات: $e');
    }
  }

  /// عرض رسالة خطأ للمستخدم
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'الإعدادات',
          textColor: Colors.white,
          onPressed: () => openPermissionSettings(),
        ),
      ),
    );
  }

  /// عرض رسالة نجاح للمستخدم
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
