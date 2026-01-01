import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ✅ شاشة "المفضلة"
/// تعرض العقارات التي قام المستخدم (المستأجر) بحفظها في المفضلة.
/// البيانات تُحفظ داخل:
/// users/{uid}/favorites
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// اللون الأساسي للتطبيق
    const primary = Color.fromRGBO(26, 141, 153, 1);

    /// ✅ نجيب UID للمستخدم الحالي من FirebaseAuth
    /// إذا المستخدم مش مسجل دخول -> ما نقدرش نجيب مفضلة
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("سجّل دخولك لعرض المفضلة")),
      );
    }

    /// ✅ استعلام Firestore لجلب المفضلة لهذا المستخدم
    /// نرتب حسب createdAt من الأحدث للأقدم
    final favQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .orderBy('createdAt', descending: true);

    return Directionality(
      textDirection: TextDirection.rtl, // ✅ دعم RTL للواجهة العربية
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primary,
          title: const Text("المفضلة", style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),

        /// ✅ StreamBuilder: يسمع للتغييرات “Realtime”
        /// أي إضافة/حذف في favorites يظهر مباشرة بدون Refresh
        body: StreamBuilder<QuerySnapshot>(
          stream: favQuery.snapshots(),
          builder: (context, snapshot) {
            /// ✅ لو صار خطأ من Firestore (Index / Permission / Network ...)
            if (snapshot.hasError) {
              return Center(child: Text("حدث خطأ: ${snapshot.error}"));
            }

            /// ✅ لو البيانات لسه ما وصلت (Loading)
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            /// ✅ المستندات (العناصر) التي رجعت من Firestore
            final docs = snapshot.data!.docs;

            /// ✅ إذا ما فيش أي عنصر في المفضلة
            if (docs.isEmpty) {
              return const Center(child: Text("لا يوجد عناصر في المفضلة"));
            }

            /// ✅ عرض القائمة
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                /// ✅ المستند الحالي
                final d = docs[i];

                /// ✅ نحول بيانات Firestore إلى Map عشان نقرأ الحقول
                final data = d.data() as Map<String, dynamic>;

                /// ✅ قراءة الحقول المخزّنة داخل favorite
                final name = (data['name'] ?? '').toString();
                final city = (data['city'] ?? '').toString();

                /// ✅ السعر نخليه نص (string) عشان يظهر بسهولة
                /// (ممكن يكون int أو double في Firestore)
                final price = (data['price'] ?? 0).toString();

                /// ✅ رابط الصورة (قد يكون null)
                final img = data['image'] as String?;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    /// ✅ صورة مصغرة على اليسار
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 55,
                        height: 55,
                        color: Colors.grey.shade200,
                        child:
                            img == null
                                ? const Icon(Icons.image_not_supported_outlined)
                                : Image.network(
                                  img,
                                  fit: BoxFit.cover,
                                  // ✅ لو الصورة ما تحملتش لأي سبب (رابط غلط/انترنت)
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.broken_image_outlined,
                                      ),
                                ),
                      ),
                    ),

                    /// ✅ عنوان: اسم العقار
                    title: Text(
                      name.isEmpty ? "بدون اسم" : name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    /// ✅ وصف: المدينة + السعر
                    subtitle: Text("${city.isEmpty ? "—" : city} • $price د.ل"),

                    /// ✅ زر إزالة من المفضلة
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),

                      /// ✅ عند الضغط نحذف المستند من favorites
                      /// d.reference هو Reference لنفس المستند داخل Firestore
                      onPressed: () async {
                        await d.reference.delete();
                      },
                    ),

                    /// 💡 تقدر تضيف onTap هنا لاحقًا
                    /// باش يفتح تفاصيل العقار:
                    /// onTap: () => Navigator.push(...PropertyDetailsScreen...)
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
