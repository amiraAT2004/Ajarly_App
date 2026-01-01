import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_edit_property_screen.dart';

/// ✅ OwnerPropertiesScreen
/// صفحة "عقاراتي" للمالك:
/// - تجيب فقط عقارات المستخدم الحالي من Firestore
/// - تعرضهم في ListView بشكل كروت حديثة
/// - FloatingActionButton لإضافة عقار جديد
/// - لكل عقار: تعديل / حذف
class OwnerPropertiesScreen extends StatelessWidget {
  const OwnerPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// اللون الأساسي للتطبيق (Brand Color)
    const primary = Color.fromRGBO(26, 141, 153, 1);

    /// ✅ 1) نجيب uid للمستخدم الحالي من FirebaseAuth
    final uid = FirebaseAuth.instance.currentUser?.uid;

    /// ✅ إذا المستخدم مش مسجل دخول، نعرض رسالة فقط
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("الرجاء تسجيل الدخول")));
    }

    /// ✅ 2) Firestore Query
    /// نجيب العقارات من collection اسمها properties
    /// ونفلترها حسب ownerId == uid
    /// ونرتبها بالأحدث createdAt تنازلي
    final query = FirebaseFirestore.instance
        .collection('properties')
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      /// ✅ AppBar
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("عقاراتي", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      /// ✅ Floating Button لإضافة عقار جديد
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,

        /// عند الضغط: نفتح شاشة AddEditPropertyScreen بدون بيانات (يعني إضافة)
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditPropertyScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      /// ✅ StreamBuilder
      /// يسمع (live) لأي تغيير في البيانات داخل Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          /// ✅ في حالة صار خطأ في Firestore
          if (snapshot.hasError) {
            debugPrint("🔥 Firestore error: ${snapshot.error}");
            return Center(child: Text("حدث خطأ: ${snapshot.error}"));
          }

          /// ✅ في حالة البيانات لسه ما وصلتش
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ✅ هنا وصلت البيانات: docs = قائمة الوثائق (العقارات)
          final docs = snapshot.data!.docs;

          /// ✅ إذا القائمة فارغة
          if (docs.isEmpty) {
            return const Center(child: Text("لا يوجد عقارات بعد"));
          }

          /// ✅ ListView.separated
          /// تعرض كروت مع مسافة فاصلة بين كل عنصر
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              /// ✅ كل عنصر يمثل وثيقة (document) من Firestore
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;

              /// ✅ استخراج بيانات العقار
              final name = (data['name'] ?? '').toString();
              final city = (data['city'] ?? '').toString();
              final price = data['price'] ?? 0;

              /// images عبارة عن List فيها روابط الصور
              final images = (data['images'] as List?)?.cast<String>() ?? [];

              /// أول صورة في القائمة (إذا موجودة)
              final firstImage = images.isNotEmpty ? images.first : null;

              /// ✅ نعرض كرت حديث للعقار
              return _ModernPropertyCard(
                primary: primary,
                docId: d.id, // id متاع الوثيقة في Firestore
                data: data, // البيانات كلها (نمررها للكرت)
                name: name,
                city: city,
                price: price,
                firstImage: firstImage,

                /// ✅ تعديل
                /// يفتح نفس شاشة AddEditPropertyScreen ولكن مع propertyId و initialData
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => AddEditPropertyScreen(
                            propertyId: d.id,
                            initialData: data,
                          ),
                    ),
                  );
                },

                /// ✅ حذف
                /// أولاً نفتح Dialog تأكيد، بعدين نحذف document من Firestore
                onDelete: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text(
                            "حذف العقار؟",
                            style: TextStyle(color: primary),
                          ),
                          content: const Text("هل أنت متأكد من حذف العقار؟"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                "إلغاء",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "حذف",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                  );

                  /// ✅ إذا المستخدم أكد الحذف
                  if (ok == true) {
                    await FirebaseFirestore.instance
                        .collection('properties')
                        .doc(d.id)
                        .delete();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// ✅ _ModernPropertyCard
/// كرت عرض العقار بشكل حديث:
/// - صورة
/// - سعر
/// - اسم + مدينة
/// - خدمات (chips)
/// - PopupMenu (تعديل / حذف)
class _ModernPropertyCard extends StatelessWidget {
  final Color primary;
  final String docId;
  final Map<String, dynamic> data;
  final String name;
  final String city;
  final dynamic price;
  final String? firstImage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ModernPropertyCard({
    required this.primary,
    required this.docId,
    required this.data,
    required this.name,
    required this.city,
    required this.price,
    required this.firstImage,
    required this.onEdit,
    required this.onDelete,
  });

  /// ✅ دالة صغيرة لتنسيق السعر:
  /// - إذا كان رقم صحيح يظهر بدون كسور
  /// - إذا فيه كسور يظهر رقمين بعد الفاصلة
  String _formatPrice(dynamic p) {
    if (p == null) return "0 د.ل";
    if (p is num) return "${p.toStringAsFixed(p % 1 == 0 ? 0 : 2)} د.ل";
    return "$p د.ل";
  }

  @override
  Widget build(BuildContext context) {
    /// ✅ استخراج الخدمات من البيانات
    final services = (data['services'] as List?)?.cast<String>() ?? [];

    /// نعرض فقط أول 3 خدمات في الكرت
    final displayedServices = services.take(3).toList();

    /// عدد الخدمات الإضافية (+2 مثلا)
    final moreCount = services.length - displayedServices.length;

    return InkWell(
      /// ✅ InkWell يعطي تأثير "ضغط" (Ripple)
      borderRadius: BorderRadius.circular(18),

      /// هنا خليته يفتح edit عند الضغط على الكرت
      /// (تقدر تغيّرها لتفتح صفحة تفاصيل بدل edit)
      onTap: onEdit,

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ الجزء العلوي: صورة + Overlay + سعر + Menu
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    /// ✅ عرض الصورة الأولى لو موجودة، وإلا placeholder
                    if (firstImage != null)
                      Image.network(
                        firstImage!,
                        fit: BoxFit.cover,

                        /// ✅ أثناء التحميل نعرض Loader
                        loadingBuilder: (c, w, p) {
                          if (p == null) return w;
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },

                        /// ✅ لو الرابط خربان
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.image_not_supported_outlined),
                              ),
                            ),
                      )
                    else
                      Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 34,
                          ),
                        ),
                      ),

                    /// ✅ Overlay Gradient يعطي جمال للصورة
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: .05),
                            Colors.black.withValues(alpha: .35),
                          ],
                        ),
                      ),
                    ),

                    /// ✅ Badge السعر
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_money, size: 16, color: primary),
                            const SizedBox(width: 6),
                            Text(
                              _formatPrice(price),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// ✅ Menu (تعديل / حذف)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Material(
                        color: Colors.white.withValues(alpha: .85),
                        borderRadius: BorderRadius.circular(999),
                        child: PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          icon: const Icon(Icons.more_vert),

                          /// قيمة الاختيار: edit أو delete
                          onSelected: (v) {
                            if (v == 'edit') onEdit();
                            if (v == 'delete') onDelete();
                          },
                          itemBuilder:
                              (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text("تعديل"),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text("حذف"),
                                ),
                              ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// ✅ الجزء السفلي: الاسم + المدينة + الخدمات
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// اسم العقار
                  Text(
                    name.isEmpty ? "بدون اسم" : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),

                  /// المدينة
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          city.isEmpty ? "غير محدد" : city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// الخدمات (Chips)
                  if (services.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...displayedServices.map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: primary.withValues(alpha: .25),
                              ),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                        /// إذا في خدمات زيادة: نعرض +عددها
                        if (moreCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              "+$moreCount",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    Text(
                      "لا توجد خدمات",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
