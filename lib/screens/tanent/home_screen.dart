import 'package:ajarly/const/app_dimensions.dart';
import 'package:ajarly/screens/tanent/property_details_screen.dart';
import 'package:ajarly/screens/tanent/all_offers_screen.dart';
import 'package:ajarly/widgets/imageSlider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ✅ شاشة الرئيسية للمستأجر
/// - فيها شريط بحث (ما يفلترش هنا)
/// - Slider للصور
/// - عرض 3 عروض فقط (آخر عقارات)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// اللون الأساسي للتطبيق
  static const primary = Color.fromRGBO(26, 141, 153, 1);

  /// Controller لحقل البحث (نقرأ منه النص، ونمسحه، ونسمع لتغييره)
  final TextEditingController _searchCtrl = TextEditingController();

  /// نخزن قيمة البحث الحالية هنا (باش نقرر نظهر X ولا لا)
  String _q = "";

  @override
  void initState() {
    super.initState();

    /// ✅ Listener: كل ما المستخدم يكتب في البحث، يحدث _q
    /// ونعمل setState باش الواجهة تحدث (مثلاً يظهر زر X)
    _searchCtrl.addListener(() {
      setState(() => _q = _searchCtrl.text.trim());
    });
  }

  @override
  void dispose() {
    /// ✅ لازم نتخلص من الـ controller لتجنب Memory Leak
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// ✅ Query: نجيب آخر 3 عروض فقط من properties
    /// ترتيب حسب createdAt من الأحدث للأقدم
    final offersQuery = FirebaseFirestore.instance
        .collection('properties')
        .orderBy('createdAt', descending: true)
        .limit(3);

    return Directionality(
      textDirection: TextDirection.rtl, // دعم RTL
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =======================
                  // ✅ Search Bar (في Home)
                  // =======================
                  TextFormField(
                    controller: _searchCtrl,
                    obscureText: false, // مش حقل كلمة مرور
                    decoration: InputDecoration(
                      hintText: 'ابحث عن عقار (اسم / مدينة)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(width: 2, color: primary),
                      ),

                      /// أيقونة البحث على اليسار
                      prefixIcon: const Icon(Icons.search, color: primary),

                      /// ✅ suffixIcon فيه زرين:
                      /// - زر X يظهر فقط لما يكون فيه نص
                      /// - زر send ينقلنا لصفحة AllOffersScreen ويعرض النتائج هناك
                      suffixIcon: Row(
                        mainAxisSize:
                            MainAxisSize.min, // مهم جداً عشان ما يأخذ كل العرض
                        children: [
                          // ✅ زر X: يظهر فقط إذا _q مش فارغ
                          if (_q.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close, color: primary),
                              onPressed: () {
                                /// يمسح النص
                                _searchCtrl.clear();

                                /// يسكر الكيبورد
                                FocusScope.of(context).unfocus();
                              },
                            ),

                          // ✅ زر الإرسال: يبدأ البحث فعلياً
                          IconButton(
                            icon: const Icon(Icons.send, color: primary),
                            onPressed: () {
                              /// نقرأ النص اللي كتبه المستخدم
                              final q = _searchCtrl.text.trim();

                              /// نفتح صفحة AllOffersScreen ونمرر query
                              /// هناك الصفحة هي اللي تقوم بالفلترة وعرض النتائج
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AllOffersScreen(query: q),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    cursorColor: primary,
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge * 1.5),

                  // =======================
                  // ✅ Slider (صور/إعلانات)
                  // =======================
                  AutoImageSlider(),

                  SizedBox(height: AppDimensions.paddingMedium),

                  // =======================
                  // ✅ عنوان العروض + زر عرض الكل
                  // =======================
                  Row(
                    children: [
                      const Text(
                        "العروض",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),

                      /// ✅ عند الضغط على عرض الكل: يفتح AllOffersScreen بدون query
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AllOffersScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "عرض الكل",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppDimensions.paddingMedium),

                  // =======================
                  // ✅ ListView للعروض (3 فقط)
                  // =======================
                  SizedBox(
                    height: AppDimensions.screenHeight * .32,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: offersQuery.snapshots(), // realtime stream
                      builder: (context, snapshot) {
                        /// لو صار خطأ من Firestore
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("حدث خطأ: ${snapshot.error}"),
                          );
                        }

                        /// لو البيانات لسه ما وصلت
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        /// البيانات جاهزة
                        final docs = snapshot.data!.docs;

                        /// لو مافيش عروض
                        if (docs.isEmpty) {
                          return const Center(
                              child: Text("لا توجد عروض حالياً"));
                        }

                        /// ✅ عرض العروض أفقياً
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder:
                              (_, __) =>
                                  SizedBox(width: AppDimensions.paddingSmall),
                          itemBuilder: (context, i) {
                            final d = docs[i];

                            /// نحول بيانات المستند إلى Map
                            final data = d.data() as Map<String, dynamic>;

                            /// ID للعقار (نحتاجه لصفحة التفاصيل)
                            final propertyId = d.id;

                            /// نقرأ البيانات
                            final name = (data['name'] ?? '').toString();
                            final city = (data['city'] ?? '').toString();
                            final price = data['price'];

                            /// images عبارة عن List في Firestore
                            final images =
                                (data['images'] as List?)?.cast<String>() ??
                                    [];

                            /// أول صورة نستخدمها للكرت
                            final img = images.isNotEmpty ? images.first : null;

                            /// ✅ نبني كرت العرض
                            return _PropertyOfferCard(
                              primary: primary,
                              width: AppDimensions.screenWidth * .65,
                              propertyId: propertyId,
                              imageUrl: img,
                              name: name,
                              city: city,
                              price: price,

                              /// ✅ عند الضغط يفتح صفحة تفاصيل العقار
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => PropertyDetailsScreen(
                                      propertyId: propertyId,
                                    ),
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
          ),
        ),
      ),
    );
  }
}

/// ✅ كرت عرض العقار (اللي يظهر في Home داخل ListView)
class _PropertyOfferCard extends StatelessWidget {
  final Color primary;
  final double width;
  final String propertyId;
  final String? imageUrl;
  final String name;
  final String city;
  final dynamic price;
  final VoidCallback onTap;

  const _PropertyOfferCard({
    required this.primary,
    required this.width,
    required this.propertyId,
    required this.imageUrl,
    required this.name,
    required this.city,
    required this.price,
    required this.onTap,
  });

  /// ✅ تبديل حالة المفضلة (إضافة/حذف) في Firestore
  Future<void> _toggleFavorite(BuildContext context, bool isFav) async {
    /// نجيب uid للمستخدم
    final uid = FirebaseAuth.instance.currentUser?.uid;

    /// لو مش مسجل دخول مانسمحش بالمفضلة
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("سجّل دخولك باش تستخدم المفضلة")),
      );
      return;
    }

    /// مكان حفظ المفضلة:
    /// users/{uid}/favorites/{propertyId}
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(propertyId);

    try {
      /// لو كان موجود في المفضلة -> نحذف
      if (isFav) {
        await favRef.delete();
      } else {
        /// لو مش موجود -> نضيفه
        await favRef.set({
          "propertyId": propertyId,
          "name": name,
          "city": city,
          "price":
              (price is num) ? price : (double.tryParse(price.toString()) ?? 0),
          "image": imageUrl,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    /// تحويل السعر لنص للعرض
    final priceTxt =
        (price is num) ? price.toString() : (price ?? "0").toString();

    /// uid للمستخدم
    final uid = FirebaseAuth.instance.currentUser?.uid;

    /// مرجع مستند المفضلة لنفس العقار
    final favDoc = (uid == null)
        ? null
        : FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favorites')
            .doc(propertyId);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              /// ✅ صورة العقار (أو placeholder)
              Positioned.fill(
                child: imageUrl == null
                    ? Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                        ),
                      )
                    : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                          ),
                        ),
                      ),
              ),

              /// ✅ طبقة Gradient للقراءة فوق الصورة
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: .05),
                        Colors.black.withValues(alpha: .55),
                      ],
                    ),
                  ),
                ),
              ),

              /// ✅ زر المفضلة: يتغير حسب وجود المستند في favorites
              Positioned(
                top: 10,
                left: 10,
                child: favDoc == null
                    ? _FavButton(
                        isFav: false,
                        onTap: () => _toggleFavorite(context, false),
                      )
                    : StreamBuilder<DocumentSnapshot>(
                        stream: favDoc.snapshots(),
                        builder: (context, snap) {
                          final isFav = (snap.data?.exists ?? false);
                          return _FavButton(
                            isFav: isFav,
                            onTap: () => _toggleFavorite(context, isFav),
                          );
                        },
                      ),
              ),

              /// ✅ معلومات العقار في الأسفل
              Positioned(
                right: 12,
                left: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? "عقار بدون اسم" : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white.withValues(alpha: .9),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .9),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
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
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
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

/// ✅ زر القلب (مفضلة) مستقل
class _FavButton extends StatelessWidget {
  final bool isFav;
  final VoidCallback onTap;

  const _FavButton({required this.isFav, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .85),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color: isFav ? Colors.red : Colors.black87,
        ),
      ),
    );
  }
}