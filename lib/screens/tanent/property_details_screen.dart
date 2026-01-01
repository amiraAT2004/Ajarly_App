import 'package:ajarly/screens/tanent/request_viewing_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// ✅ شاشة تفاصيل عقار معين
/// تستقبل propertyId (معرف الوثيقة في Firestore)
/// وتعرض بيانات العقار + زر "اطلب معاينة" يفتح BottomSheet لإرسال الطلب
class PropertyDetailsScreen extends StatelessWidget {
  final String propertyId;
  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    // ✅ اللون الأساسي للتطبيق
    const primary = Color.fromRGBO(26, 141, 153, 1);

    // ✅ مرجع الوثيقة (DocumentReference) في Firestore للعقار المحدد
    final docRef = FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyId);

    return Directionality(
      // ✅ التطبيق RTL للغة العربية
      textDirection: TextDirection.rtl,
      child: StreamBuilder<DocumentSnapshot>(
        // ✅ نسمع تغييرات الوثيقة لحظياً (Realtime)
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          // ✅ إذا صار خطأ من Firestore
          if (snapshot.hasError) {
            return _ErrorView(error: snapshot.error.toString());
          }

          // ✅ أثناء التحميل (أول ما الصفحة تفتح)
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ✅ إذا الوثيقة مش موجودة (propertyId غلط أو انحذفت)
          if (!snapshot.data!.exists) {
            return const _ErrorView(error: "العقار غير موجود");
          }

          // ✅ نحول بيانات الوثيقة إلى Map
          final data = snapshot.data!.data() as Map<String, dynamic>;

          // ✅ نقرأ القيم من Firestore مع fallback إذا ناقصة
          final ownerId = (data['ownerId'] ?? '').toString();
          final name = (data['name'] ?? '').toString();
          final city = (data['city'] ?? '').toString();
          final price = data['price'] ?? 0;
          final description = (data['description'] ?? '').toString();

          // ✅ services و images قائمة strings
          final services = (data['services'] as List?)?.cast<String>() ?? [];
          final images = (data['images'] as List?)?.cast<String>() ?? [];

          // ✅ تحويل السعر إلى نص للعرض
          final priceTxt = (price is num) ? price.toString() : price.toString();

          // ✅ صورة الغلاف الرئيسية (أول صورة)
          final heroImage = images.isNotEmpty ? images.first : null;

          return Scaffold(
            backgroundColor: const Color(0xFFF7F8FA),

            /// ✅ CustomScrollView + Slivers
            /// يعطيك AppBar متحرك (SliverAppBar) مع محتوى تحت
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                /// ✅ AppBar كبير مع صورة (يتقلص عند النزول)
                SliverAppBar(
                  backgroundColor: primary,
                  expandedHeight: 320,
                  pinned: true, // ✅ يبقى ظاهر عند النزول
                  elevation: 0,

                  // ✅ زر الرجوع
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // ✅ عنوان الصفحة
                  title: Text(
                    name.isEmpty ? "تفاصيل العقار" : name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  /// ✅ FlexibleSpaceBar: الخلفية اللي فيها الصورة + تدرج + معلومات
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // ✅ لو ما فيش صورة -> placeholder
                        if (heroImage == null)
                          Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 60,
                              ),
                            ),
                          )
                        else
                          // ✅ صورة من الانترنت
                          Image.network(
                            heroImage,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 60,
                                    ),
                                  ),
                                ),
                          ),

                        // ✅ تدرج أسود شفاف فوق الصورة لتحسين قراءة النص
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: .15),
                                  Colors.black.withValues(alpha: .55),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ✅ معلومات العنوان/المدينة/السعر أسفل الصورة
                        Positioned(
                          right: 16,
                          left: 16,
                          bottom: 16,
                          child: _HeaderInfo(
                            name: name,
                            city: city,
                            priceTxt: priceTxt,
                            primary: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// ✅ محتوى الصفحة تحت الـ SliverAppBar
                SliverToBoxAdapter(
                  child: Padding(
                    // ✅ padding سفلي كبير لأن عندنا bottomNavigationBar
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =====================
                        // ✅ قسم الصور المصغرة
                        // =====================
                        if (images.length > 1) ...[
                          const SizedBox(height: 6),
                          const Text(
                            "الصور",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ✅ قائمة صور صغيرة أفقية
                          SizedBox(
                            height: 92,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: images.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 10),
                              itemBuilder: (_, i) {
                                final url = images[i];

                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: AspectRatio(
                                    aspectRatio: 1.3,
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.broken_image_outlined,
                                            ),
                                          ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        // =====================
                        // ✅ قسم الوصف
                        // =====================
                        const Text(
                          "الوصف",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ✅ كرت الوصف
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .05),
                                blurRadius: 16,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Text(
                            description.isEmpty ? "لا يوجد وصف" : description,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 14.5,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // =====================
                        // ✅ قسم الخدمات
                        // =====================
                        const Text(
                          "الخدمات",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ✅ إذا ما فيش خدمات نعرض رسالة
                        if (services.isEmpty)
                          Text(
                            "لا توجد خدمات محددة",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          // ✅ Wrap لعرض الخدمات كـ Chips
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                services
                                    .map(
                                      (s) => _Chip(primary: primary, text: s),
                                    )
                                    .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // =====================
            // ✅ شريط سفلي ثابت فيه زر طلب المعاينة
            // =====================
            bottomNavigationBar: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 18,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  // ✅ لو ownerId فاضي => نوقف الزر (null)
                  onPressed:
                      ownerId.isEmpty
                          ? null
                          : () {
                            // ✅ BottomSheet لإرسال طلب معاينة
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder:
                                  (_) => Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(22),
                                      ),
                                    ),
                                    child: RequestViewingSheet(
                                      propertyId: propertyId,
                                      ownerId: ownerId,
                                      propertyName: name,
                                      propertyCity: city,
                                      propertyImage: heroImage,
                                    ),
                                  ),
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.event_available, color: Colors.white),
                  label: const Text(
                    "اطلب معاينة",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ✅ Widget صغير لعرض (اسم العقار + المدينة + السعر) فوق صورة الـ AppBar
class _HeaderInfo extends StatelessWidget {
  final String name;
  final String city;
  final String priceTxt;
  final Color primary;

  const _HeaderInfo({
    required this.name,
    required this.city,
    required this.priceTxt,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ اسم العقار
        Text(
          name.isEmpty ? "عقار بدون اسم" : name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),

        // ✅ المدينة + السعر
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: Colors.white.withValues(alpha: .95),
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                city.isEmpty ? "—" : city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .92),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // ✅ كبسولة السعر
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                "$priceTxt د.ل",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ✅ Chip صغير لعرض خدمة واحدة
class _Chip extends StatelessWidget {
  final Color primary;
  final String text;

  const _Chip({required this.primary, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: primary.withValues(alpha: .18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: primary,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

/// ✅ صفحة خطأ عامة (تظهر رسالة في المنتصف)
class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
