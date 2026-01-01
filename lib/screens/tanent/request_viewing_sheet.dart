import 'package:ajarly/const/app_dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ✅ BottomSheet (نافذة من الأسفل) لإرسال "طلب معاينة" لصاحب العقار.
/// يتم فتحها من صفحة تفاصيل العقار.
/// الهدف: المستخدم (المستأجر) يكتب ملاحظة اختيارية، ثم يضغط إرسال،
/// فيتم حفظ الطلب داخل Firestore في collection اسمها requests.
class RequestViewingSheet extends StatefulWidget {
  // ✅ بيانات العقار التي نحتاجها لحفظها في الطلب
  final String propertyId; // معرف العقار
  final String ownerId; // معرف صاحب العقار
  final String propertyName; // اسم العقار (للعرض + للحفظ)
  final String propertyCity; // مدينة العقار (للعرض + للحفظ)
  final String? propertyImage; // صورة العقار (اختياري)

  const RequestViewingSheet({
    super.key,
    required this.propertyId,
    required this.ownerId,
    required this.propertyName,
    required this.propertyCity,
    required this.propertyImage,
  });

  @override
  State<RequestViewingSheet> createState() => _RequestViewingSheetState();
}

class _RequestViewingSheetState extends State<RequestViewingSheet> {
  // ✅ مفتاح الفورم: نستخدمه لعمل validate قبل الإرسال
  final _formKey = GlobalKey<FormState>();

  // ✅ كنترول لحقل الرسالة (الملاحظة)
  final _msgCtrl = TextEditingController();

  // ✅ متغير حالة: هل نحن في وضع إرسال/تحميل؟
  bool _loading = false;

  @override
  void dispose() {
    // ✅ مهم جداً: التخلص من الكنترول لتفادي تسريب الذاكرة (Memory Leak)
    _msgCtrl.dispose();
    super.dispose();
  }

  /// ✅ الدالة الرئيسية لإرسال الطلب إلى Firestore
  Future<void> _submit() async {
    // 1) ✅ نجيب uid للمستخدم الحالي (المستأجر)
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // لو المستخدم مش مسجل دخول -> ما نسمح بالإرسال
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لازم تسجل دخول باش ترسل طلب")),
      );
      return;
    }

    // 2) ✅ تحقق من الفورم (لو كان فيه validators)
    // في هذا الكود ما فيش validator لحقل الملاحظة لأنه اختياري
    // لكن وجود الفورم يسمح بإضافة حقول أخرى لاحقاً مثل تاريخ المعاينة، رقم هاتف، إلخ
    if (!_formKey.currentState!.validate()) return;

    // 3) ✅ تشغيل حالة التحميل لتعطيل الزر وتغيير النص/الأيقونة
    setState(() => _loading = true);

    try {
      // 4) ✅ إضافة وثيقة جديدة في requests
      // كل وثيقة تمثل طلب معاينة واحد
      await FirebaseFirestore.instance.collection('requests').add({
        // ✅ بيانات العقار
        "propertyId": widget.propertyId,
        "ownerId": widget.ownerId,

        // ✅ من أرسل الطلب (المستأجر)
        "tenantId": uid,

        // ✅ نخزن معلومات إضافية للعرض السريع بدون ما نعمل join في كل مرة
        "propertyName": widget.propertyName,
        "propertyCity": widget.propertyCity,
        "propertyImage": widget.propertyImage,

        // ✅ رسالة المستأجر (اختيارية)
        "message": _msgCtrl.text.trim(),

        // ✅ حالة الطلب: تبدأ pending (معلق)
        "status": "pending",

        // ❗ ملاحظة مهمة:
        // الأفضل إضافة createdAt للترتيب في شاشة طلبات المالك:
        // "createdAt": FieldValue.serverTimestamp(),
      });

      // 5) ✅ تأكد أن الواجهة ما زالت موجودة قبل التعامل معها
      // mounted = true يعني الصفحة/الـ widget ما زالت على الشاشة
      if (!mounted) return;

      // ✅ نقفل الـ BottomSheet بعد الإرسال
      Navigator.pop(context);

      // ✅ رسالة نجاح للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم إرسال طلب المعاينة لصاحب العقار")),
      );
    } catch (e) {
      // ✅ في حال صار خطأ (نت/صلاحيات/Firestore rules...)
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
    } finally {
      // 6) ✅ إيقاف التحميل سواء نجح أو فشل
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color.fromRGBO(26, 141, 153, 1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          // ✅ هذا الـ padding مهم جداً:
          // MediaQuery.of(context).viewInsets.bottom
          // يرفع الـ BottomSheet لما تفتح الكيبورد حتى ما يغطي الحقول/الزر
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              // ✅ mainAxisSize.min يجعل الـ BottomSheet يأخذ حجم المحتوى فقط
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ "handle" شريط صغير بالأعلى كإشارة أن هذا BottomSheet يمكن سحبه
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingMedium),

                // ✅ عنوان النافذة
                const Text(
                  "طلب معاينة",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),

                const SizedBox(height: AppDimensions.paddingSmall),

                // ✅ اسم العقار + المدينة (معلومة للمستخدم)
                Text(
                  "${widget.propertyName} • ${widget.propertyCity}",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingMedium),

                // ✅ حقل الرسالة (اختياري)
                TextFormField(
                  controller: _msgCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        "ملاحظة لصاحب العقار (اختياري)\nمثال: نبي معاينة في أقرب وقت لو أمكن.",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),

                  // ✅ لو تبي تخلي الرسالة إجبارية، أضف validator مثل:
                  // validator: (v) =>
                  //   (v == null || v.trim().isEmpty) ? "اكتب رسالة قصيرة" : null,
                ),

                const SizedBox(height: AppDimensions.paddingSmall),

                // ✅ زر الإرسال
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    // ✅ لو _loading true نقفل الزر (null)
                    onPressed: _loading ? null : _submit,

                    // ✅ أثناء التحميل نظهر دائرة صغيرة بدل الأيقونة
                    icon:
                        _loading
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.send, color: Colors.white),

                    // ✅ نص الزر يتغير حسب الحالة
                    label: Text(
                      _loading ? "جار الإرسال..." : "إرسال الطلب",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    // ✅ تنسيق الزر
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
