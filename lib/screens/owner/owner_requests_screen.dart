import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ✅ OwnerRequestsScreen
/// صفحة تعرض "طلبات المعاينة" الخاصة بالمالك.
/// الفكرة:
/// 1) نجيب uid للمالك الحالي.
/// 2) نجيب من Firestore collection اسمها requests فقط الطلبات اللي ownerId فيها = uid.
/// 3) نعرضهم في ListView.
/// 4) لكل طلب نجيب بيانات المستأجر من users (الاسم + الهاتف) عن طريق tenantId.
class OwnerRequestsScreen extends StatelessWidget {
  const OwnerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color.fromRGBO(26, 141, 153, 1);

    /// ✅ 1) نجيب uid للمستخدم الحالي (المالك)
    final uid = FirebaseAuth.instance.currentUser?.uid;

    /// ✅ إذا المستخدم مش مسجّل دخول، نعرض رسالة
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("الرجاء تسجيل الدخول")));
    }

    /// ✅ 2) Query لجلب الطلبات اللي تخص المالك الحالي فقط
    /// requests: فيها documents لكل طلب معاينة
    /// where(ownerId == uid) يعني "جيبلي الطلبات اللي ownerId متاعها هو هذا المالك"
    final query = FirebaseFirestore.instance
        .collection('requests')
        .where('ownerId', isEqualTo: uid);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),

        /// ✅ AppBar
        appBar: AppBar(
          backgroundColor: primary,
          title: const Text(
            "طلبات المعاينة",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),

        /// ✅ 3) StreamBuilder
        /// يسمع لأي تغيير في الطلبات (إضافة/حذف/تعديل) ويحدّث الواجهة تلقائياً
        body: StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, snap) {
            /// ✅ لو صار خطأ في Firestore
            if (snap.hasError) {
              debugPrint("🔥 Firestore error: ${snap.error}");
              return Center(child: Text("حدث خطأ: ${snap.error}"));
            }

            /// ✅ لو البيانات لسه ما وصلتش
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            /// ✅ هنا وصلتنا البيانات: قائمة الوثائق
            final docs = snap.data!.docs;

            /// ✅ لو ما فيش طلبات
            if (docs.isEmpty) return const Center(child: Text("لا توجد طلبات"));

            /// ✅ ListView.separated لعرض كل طلب في Card/Container
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                /// ✅ كل doc يمثل طلب واحد
                final d = docs[i];

                /// ✅ data = بيانات الطلب نفسها (Map)
                final data = d.data() as Map<String, dynamic>;

                /// ✅ استخراج أهم الحقول من الطلب
                final tenantId =
                    (data['tenantId'] ?? '')
                        .toString(); // صاحب الطلب (المستأجر)
                final propertyName = (data['propertyName'] ?? '').toString();
                final propertyCity = (data['propertyCity'] ?? '').toString();
                final propertyImage = (data['propertyImage'] ?? '').toString();
                final message = (data['message'] ?? '').toString();

                /// ✅ 4) نجهز مرجع Document للمستأجر من users
                /// tenantId هو id المستخدم المستأجر
                /// users/{tenantId}
                final userDocRef =
                    tenantId.isEmpty
                        ? null
                        : FirebaseFirestore.instance
                            .collection('users')
                            .doc(tenantId);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Header: معلومات العقار (صورة + اسم + مدينة)
                        Row(
                          children: [
                            /// صورة العقار
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 56,
                                height: 56,
                                color: Colors.grey.shade200,
                                child:
                                    propertyImage.isEmpty
                                        ? const Icon(Icons.home_outlined)
                                        : Image.network(
                                          propertyImage,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => const Icon(
                                                Icons.broken_image_outlined,
                                              ),
                                        ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            /// اسم العقار + المدينة
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    propertyName.isEmpty
                                        ? "طلب معاينة"
                                        : propertyName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          propertyCity.isEmpty
                                              ? "—"
                                              : propertyCity,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            /// أيقونة جانبية
                            const Icon(Icons.mail_outline, color: primary),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ✅ Tenant info (من users)
                        // إذا tenantId فاضي، يعني ما نقدرش نجيب بياناته
                        if (userDocRef == null)
                          Text(
                            "المستأجر: غير معروف",
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        else
                          /// ✅ StreamBuilder ثاني لجلب بيانات المستأجر (الاسم + الهاتف)
                          StreamBuilder<DocumentSnapshot>(
                            stream: userDocRef.snapshots(),
                            builder: (context, userSnap) {
                              String tName = "مستأجر"; // اسم افتراضي
                              String tPhone = ""; // الهاتف (ممكن يكون فاضي)

                              /// ✅ إذا document موجود فعلاً في users
                              if (userSnap.hasData && userSnap.data!.exists) {
                                final u =
                                    userSnap.data!.data()
                                        as Map<String, dynamic>;

                                /// يدعم حالتين:
                                /// - name موجود (اسم كامل)
                                /// - أو firstName + lastName
                                final first = (u['firstName'] ?? '').toString();
                                final last = (u['lastName'] ?? '').toString();
                                final name = (u['name'] ?? '').toString();

                                if (name.isNotEmpty) {
                                  tName = name;
                                } else if (first.isNotEmpty ||
                                    last.isNotEmpty) {
                                  tName =
                                      "${first.trim()} ${last.trim()}".trim();
                                }

                                /// ✅ الهاتف جاي من users
                                tPhone = (u['phone'] ?? '').toString();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "المستأجر: $tName",
                                    style: TextStyle(
                                      color: Colors.grey.shade900,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),

                                  /// نعرض الهاتف فقط إذا موجود (مش فاضي)
                                  if (tPhone.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      "الهاتف: $tPhone",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),

                        const SizedBox(height: 10),
                        // ✅ رسالة المستأجر داخل Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F5F7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            message.isEmpty ? "بدون رسالة" : message,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
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
