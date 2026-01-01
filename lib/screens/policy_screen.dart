import 'package:flutter/material.dart';

/// ✅ PrivacyPolicyScreen
/// شاشة تعرض سياسة الخصوصية داخل التطبيق.
/// فيها:
/// - AppBar بعنوان "سياسة الخصوصية"
/// - محتوى طويل قابل للتمرير (Scroll)
/// - أقسام مرتبة (عنوان + نص)
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// ✅ Directionality
    /// لأن المحتوى عربي: نخلي اتجاه الكتابة RTL (يمين ➜ يسار)
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        /// ✅ AppBar (الشريط العلوي)
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(26, 141, 153, 1),
          elevation: 0, // بدون ظل أسفل الـ AppBar
          centerTitle: true, // العنوان في الوسط
          title: const Text(
            'سياسة الخصوصية',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ), // لون زر الرجوع (Back)
        ),

        /// ✅ Body: محتوى الشاشة
        body: Padding(
          padding: const EdgeInsets.all(20), // مسافة داخلية حول المحتوى
          child: SingleChildScrollView(
            /// ✅ SingleChildScrollView
            /// لأن النص طويل، لازم نخلي الصفحة قابلة للتمرير
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // محاذاة لليسار (RTL)
              children: [
                /// ✅ كل قسم = عنوان + نص
                _sectionTitle('١. المعلومات التي نقوم بجمعها'),
                _sectionText(
                  'قد نقوم بجمع معلومات أساسية لإنشاء الحساب مثل البريد الإلكتروني والاسم، '
                  'وبعض بيانات الاستخدام داخل التطبيق. '
                  'كما يقوم المالك/الوكيل بإضافة بيانات العقار مثل الاسم، المدينة، السعر، الوصف، الخدمات، والصور.',
                ),
                const SizedBox(height: 16), // مسافة بين الأقسام

                _sectionTitle('٢. كيف نستخدم المعلومات'),
                _sectionText(
                  'نستخدم البيانات لتقديم الخدمة الأساسية: عرض العقارات للمستأجرين، '
                  'تمكين التواصل وطلبات الزيارة، وتحسين تجربة المستخدم. '
                  'قد نستخدم بيانات عامة (غير حساسة) لأغراض التحسين والتحليلات.',
                ),
                const SizedBox(height: 16),

                _sectionTitle('٣. مشاركة المعلومات'),
                _sectionText(
                  'لا نقوم ببيع أو مشاركة بياناتك الشخصية مع أي طرف ثالث. '
                  'قد يتم عرض معلومات العقار التي ينشرها المالك/الوكيل للمستخدمين داخل التطبيق. '
                  'ولا يتم الإفصاح عن بيانات حساسة إلا بموافقة المستخدم أو بطلب قانوني رسمي.',
                ),
                const SizedBox(height: 16),

                _sectionTitle('٤. الصور والمحتوى'),
                _sectionText(
                  'الصور والمحتوى الذي يرفعه المالك/الوكيل (مثل صور العقار) يكون بهدف عرض العقار داخل التطبيق. '
                  'يُمنع رفع محتوى غير قانوني أو مخالف.',
                ),
                const SizedBox(height: 16),

                _sectionTitle('٥. الأمان'),
                _sectionText(
                  'نستخدم وسائل حماية مناسبة لتأمين البيانات، '
                  'ولكن لا يمكن ضمان الحماية بنسبة 100٪ عبر الإنترنت. '
                  'ننصحك بالحفاظ على سرية كلمة المرور وعدم مشاركتها مع أي شخص.',
                ),
                const SizedBox(height: 16),

                _sectionTitle('٦. حقوق المستخدم'),
                _sectionText(
                  'يحق لك طلب تعديل أو حذف بياناتك أو حسابك حسب الإمكانيات المتاحة داخل التطبيق. '
                  'كما يمكنك حذف المفضلة أو تعديل بياناتك من الإعدادات عند توفرها.',
                ),
                const SizedBox(height: 16),

                _sectionTitle('٧. التحديثات'),
                _sectionText(
                  'قد نقوم بتحديث هذه السياسة من وقت لآخر. '
                  'سيتم إعلام المستخدمين بأي تغييرات مهمة داخل التطبيق.',
                ),

                const SizedBox(height: 30),

                /// ✅ تاريخ آخر تحديث في نهاية الصفحة
                Center(
                  child: Text(
                    'آخر تحديث: 27 ديسمبر 2025',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ _sectionTitle
  /// دالة تساعدنا نعمل عنوان القسم بنفس الشكل (لون + حجم + Bold)
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(26, 141, 153, 1),
      ),
    );
  }

  /// ✅ _sectionText
  /// دالة تساعدنا نعرض نص القسم بشكل موحد:
  /// - حجم 16
  /// - تباعد أسطر 1.7
  /// - Padding علوي بسيط
  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.7,
          color: Colors.black87,
        ),
      ),
    );
  }
}
