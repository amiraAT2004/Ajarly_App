import 'package:ajarly/screens/tanent/property_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// شاشة تعرض "كل العروض" أو "نتائج بحث" عن العقارات
/// - تجيب البيانات من Firestore (Collection اسمها properties)
/// - تعمل فلترة محلية (Local Filter) حسب الاسم أو المدينة
class AllOffersScreen extends StatefulWidget {
  /// query: نص البحث اللي يجي من الصفحة اللي قبل (اختياري)
  final String query;

  const AllOffersScreen({super.key, this.query = ""});

  @override
  State<AllOffersScreen> createState() => _AllOffersScreenState();
}

class _AllOffersScreenState extends State<AllOffersScreen> {
  /// اللون الأساسي للتطبيق
  static const primary = Color.fromRGBO(26, 141, 153, 1);

  /// Controller للتحكم في حقل البحث (TextFormField)
  late final TextEditingController _searchCtrl;

  /// المتغير اللي نخزنوا فيه نص البحث الحالي (محدث مع كل كتابة)
  String _q = "";

  @override
  void initState() {
    super.initState();

    // نجهّز قيمة البحث المبدئية اللي جاية من صفحة قبل
    _q = widget.query.trim();

    // نعبّي الـ controller بنفس قيمة البحث المبدئية
    _searchCtrl = TextEditingController(text: _q);

    // كل ما المستخدم يكتب، نحدّث _q ونعمل setState لإعادة بناء الواجهة
    _searchCtrl.addListener(() => setState(() => _q = _searchCtrl.text.trim()));
  }

  @override
  void dispose() {
    // لازم نعمل dispose للـ controller باش ما يصيرش memory leak
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Reference لاستعلام Firestore:
    /// - نجلب كل العقارات من properties
    /// - نرتبهم حسب createdAt تنازلي (الأحدث أولاً)
    final queryRef = FirebaseFirestore.instance
        .collection('properties')
        .orderBy('createdAt', descending: true);

    return Directionality(
      textDirection: TextDirection.rtl, // ✅ دعم RTL للعربي
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),

        /// AppBar: العنوان يتغير حسب وجود بحث أو لا
        appBar: AppBar(
          backgroundColor: primary,
          title: Text(
            _q.isEmpty ? "كل العروض" : "نتائج البحث",
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        /// Body عبارة عن Column:
        /// - Search bar فوق
        /// - النتائج تحت داخل Expanded
        body: Column(
          children: [
            // Search bar داخل صفحة النتائج
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: TextFormField(
                controller: _searchCtrl, //  مربوط بالـ controller
                decoration: InputDecoration(
                  hintText: "ابحث (اسم / مدينة)",
                  filled: true,
                  fillColor: Colors.white,

                  //  Border بدون خطوط (شكل ناعم)
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),

                  // أيقونة بحث على اليسار
                  prefixIcon: const Icon(Icons.search, color: primary),

                  //  أيقونة X تظهر فقط لو فيه نص داخل البحث
                  suffixIcon:
                      _q.isEmpty
                          ? null
                          : IconButton(
                            icon: const Icon(Icons.close, color: primary),
                            onPressed: () {
                              // يمسح النص ويقفل الكيبورد
                              _searchCtrl.clear();
                              FocusScope.of(context).unfocus();
                            },
                          ),
                ),
              ),
            ),

            /// Expanded باش GridView تاخذ باقي مساحة الشاشة
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                /// stream: نسمع لتحديثات Firestore "live"
                stream: queryRef.snapshots(),

                builder: (context, snap) {
                  //  لو صار خطأ في Firestore
                  if (snap.hasError) {
                    return Center(child: Text("حدث خطأ: ${snap.error}"));
                  }

                  // ✅ لو البيانات لسه ما وصلتش
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  /// كل الدوكيومنتات اللي جتنا من Firestore
                  final allDocs = snap.data!.docs;

                  ///  فلترة محلية:
                  /// - لو _q فاضي: نعرض كل العروض
                  /// - لو _q فيه نص: نفلتر حسب name أو city
                  final docs =
                      _q.isEmpty
                          ? allDocs
                          : allDocs.where((d) {
                            final data = d.data() as Map<String, dynamic>;
                            final name = (data['name'] ?? '').toString();
                            final city = (data['city'] ?? '').toString();

                            // contains: هل النص موجود داخل الاسم أو المدينة؟
                            return name.contains(_q) || city.contains(_q);
                          }).toList();

                  //  لو مافيش نتائج بعد الفلترة
                  if (docs.isEmpty) {
                    return const Center(child: Text("لا توجد نتائج"));
                  }

                  ///  عرض النتائج في Grid (شبكة)
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(),

                    //  إعدادات الشبكة
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // عمودين
                          mainAxisSpacing: 12, // مسافة عمودية
                          crossAxisSpacing: 12, // مسافة أفقية
                          childAspectRatio: 0.82, // نسبة عرض/ارتفاع الكرت
                        ),

                    itemCount: docs.length,

                    itemBuilder: (context, i) {
                      /// الوثيقة الحالية
                      final d = docs[i];

                      /// البيانات داخل الوثيقة (Map)
                      final data = d.data() as Map<String, dynamic>;

                      // استخراج البيانات اللي نحتاجوها
                      final id = d.id; // id مهم للانتقال لصفحة التفاصيل
                      final name = (data['name'] ?? '').toString();
                      final city = (data['city'] ?? '').toString();
                      final price = data['price'] ?? 0;

                      // images مخزنة كـ List في Firestore
                      final images =
                          (data['images'] as List?)?.cast<String>() ?? [];
                      final img = images.isNotEmpty ? images.first : null;

                      /// كرت الشبكة
                      return _GridCard(
                        primary: primary,
                        imageUrl: img,
                        name: name,
                        city: city,
                        price: price,

                        // عند الضغط: نمشي لصفحة التفاصيل
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PropertyDetailsScreen(propertyId: id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// كرت واحد داخل الـ Grid
class _GridCard extends StatelessWidget {
  final Color primary;
  final String? imageUrl;
  final String name;
  final String city;
  final dynamic price;
  final VoidCallback onTap;

  const _GridCard({
    required this.primary,
    required this.imageUrl,
    required this.name,
    required this.city,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// تحويل السعر لنص (سواء كان num أو string)
    final priceTxt =
        (price is num) ? price.toString() : (price ?? "0").toString();

    return InkWell(
      onTap: onTap, // الضغط على الكرت
      borderRadius: BorderRadius.circular(18),
      child: Container(
        // شكل الكرت + ظل
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        // قصّ أي شيء يطلع برا الحدود
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              /// جزء الصورة ياخذ أكبر مساحة
              Expanded(
                child: Stack(
                  children: [
                    // الصورة (أو Placeholder لو مافيش صورة)
                    Positioned.fill(
                      child:
                          imageUrl == null
                              ? Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                ),
                              )
                              : Image.network(
                                imageUrl!,
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

                    //  شارة السعر فوق الصورة
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: .75),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "$priceTxt د.ل",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// جزء البيانات (اسم + مدينة)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  اسم العقار
                    Text(
                      name.isEmpty ? "عقار بدون اسم" : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),

                    //  المدينة
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
                            city.isEmpty ? "—" : city,
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
            ],
          ),
        ),
      ),
    );
  }
}
