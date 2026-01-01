import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// ✅ شاشة إضافة / تعديل عقار
/// - إذا propertyId = null => إضافة عقار جديد
/// - إذا propertyId != null => تعديل عقار موجود
class AddEditPropertyScreen extends StatefulWidget {
  final String? propertyId; // ✅ إذا موجود معناها تعديل
  final Map<String, dynamic>? initialData; // ✅ بيانات العقار عند التعديل

  const AddEditPropertyScreen({super.key, this.propertyId, this.initialData});

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  // ✅ مفتاح الفورم: للتحقق من المدخلات (Validation)
  final _formKey = GlobalKey<FormState>();

  // ✅ Controllers للحقول
  final _name = TextEditingController(); // اسم العقار
  final _city = TextEditingController(); // المدينة
  final _price = TextEditingController(); // السعر
  final _desc = TextEditingController(); // الوصف

  // ✅ حالة تحميل
  bool isLoading = false;

  // ✅ قائمة الخدمات الثابتة اللي يختار منها المالك
  final List<String> servicesAll = const [
    "واي فاي",
    "مرآب",
    "ثلاجة",
    "مكيف",
    "حراسة",
    "مصعد",
  ];

  // ✅ الخدمات المختارة (Set أفضل لأنه يمنع التكرار)
  final Set<String> selectedServices = {};

  // ✅ صور جديدة تم اختيارها (ملفات من الهاتف)
  final List<XFile> pickedImages = [];

  // ✅ روابط صور موجودة مسبقاً (لما نكون في وضع التعديل)
  final List<String> existingImageUrls = [];

  @override
  void initState() {
    super.initState();

    // ✅ لو هذي شاشة تعديل، نعبي الحقول من initialData
    final d = widget.initialData;
    if (d != null) {
      _name.text = (d['name'] ?? '').toString();
      _city.text = (d['city'] ?? '').toString();
      _price.text = (d['price'] ?? '').toString();
      _desc.text = (d['description'] ?? '').toString();

      // ✅ الخدمات المخزنة في Firestore تكون List<String>
      final services = (d['services'] as List?)?.cast<String>() ?? [];
      selectedServices.addAll(services);

      // ✅ الصور المخزنة في Firestore تكون List<String> (روابط)
      final images = (d['images'] as List?)?.cast<String>() ?? [];
      existingImageUrls.addAll(images);
    }
  }

  @override
  void dispose() {
    // ✅ لازم Dispose للـ controllers
    _name.dispose();
    _city.dispose();
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  /// ✅ اختيار صور من المعرض (Multi Image Picker)
  Future<void> pickImages() async {
    final picker = ImagePicker();

    // ✅ pickMultiImage يسمح باختيار أكثر من صورة
    // imageQuality: 80 يقلل حجم الصورة قليلاً لتحسين الأداء
    final images = await picker.pickMultiImage(imageQuality: 80);

    // لو المستخدم ماختارش شيء
    if (images.isEmpty) return;

    setState(() {
      // ✅ نحن نسمح بحد أقصى 5 صور:
      // (عدد صور موجودة + عدد صور جديدة) <= 5
      final currentCount = existingImageUrls.length + pickedImages.length;
      final allowed = 5 - currentCount;
      if (allowed <= 0) return;

      // ✅ نضيف فقط العدد المسموح به
      pickedImages.addAll(images.take(allowed));
    });
  }

  /// ✅ رفع الصور الجديدة إلى Firebase Storage
  /// ثم يرجع List<String> روابط Download URLs
  Future<List<String>> uploadPickedImages(String ownerId) async {
    final List<String> urls = [];

    // ✅ نرفع كل صورة وحدة بوحدة
    for (final x in pickedImages) {
      try {
        final file = File(x.path);

        // ✅ استخراج امتداد الملف (jpg/png...)
        final ext = (x.name.contains('.')) ? x.name.split('.').last : 'jpg';

        // ✅ اسم ملف فريد لتفادي التكرار
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.$ext";

        // ✅ مسار التخزين:
        // properties/{ownerId}/{fileName}
        final ref = FirebaseStorage.instance
            .ref()
            .child("properties")
            .child(ownerId)
            .child(fileName);

        // ✅ رفع الملف
        final snap = await ref.putFile(file);

        // ✅ رابط التحميل
        final url = await snap.ref.getDownloadURL();
        urls.add(url);
      } on FirebaseException catch (e) {
        // ✅ أخطاء Storage (صلاحيات، حجم، نت...)
        debugPrint("🔥 Storage error: ${e.code} - ${e.message}");
        rethrow; // نخلي الخطأ يطلع لـ save() باش يظهر SnackBar
      } catch (e) {
        debugPrint("🔥 Unknown upload error: $e");
        rethrow;
      }
    }

    return urls;
  }

  /// ✅ حفظ العقار (إضافة أو تعديل)
  Future<void> save() async {
    // ✅ تحقق من الفورم
    if (!_formKey.currentState!.validate()) return;

    // ✅ المستخدم لازم يكون مسجل دخول (مالك)
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // ✅ لازم صورة واحدة على الأقل
    final totalImages = existingImageUrls.length + pickedImages.length;
    if (totalImages < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إضافة صورة واحدة على الأقل")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // ✅ 1) ارفع الصور الجديدة فقط
      final newUrls = await uploadPickedImages(uid);

      // ✅ 2) اجمع الصور القديمة + الجديدة
      final allUrls = [...existingImageUrls, ...newUrls];

      // ✅ 3) جهز الداتا اللي بتنحفظ في Firestore
      final data = {
        "ownerId": uid,
        "name": _name.text.trim(),
        "city": _city.text.trim(),
        // ✅ نخزن السعر كـ double
        "price": double.tryParse(_price.text.trim()) ?? 0,
        "description": _desc.text.trim(),
        "services": selectedServices.toList(),
        "images": allUrls,
        "updatedAt": FieldValue.serverTimestamp(), // ✅ وقت آخر تحديث
      };

      final col = FirebaseFirestore.instance.collection('properties');

      // ✅ إذا مافيش id => إضافة
      if (widget.propertyId == null) {
        await col.add({
          ...data,
          "createdAt": FieldValue.serverTimestamp(), // ✅ وقت الإنشاء
        });
      } else {
        // ✅ إذا فيه id => تعديل
        await col.doc(widget.propertyId).update(data);
      }

      // ✅ رجوع للشاشة السابقة بعد الحفظ
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      // ✅ عرض أي خطأ في SnackBar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
    } finally {
      // ✅ إيقاف التحميل
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color.fromRGBO(26, 141, 153, 1);

    // ✅ هل نحن في وضع تعديل؟
    final isEdit = widget.propertyId != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primary,
          title: Text(
            isEdit ? "تعديل عقار" : "إضافة عقار",
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        // ✅ لو Loading نظهر مؤشر تحميل
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator(color: primary))
                : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      /// ✅ اسم العقار
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: "اسم العقار",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              width: 2,
                              color: Color.fromRGBO(26, 141, 153, 1),
                            ),
                          ),
                        ),
                        cursorColor: primary,
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? "مطلوب"
                                    : null,
                      ),

                      const SizedBox(height: 12),

                      /// ✅ المدينة
                      TextFormField(
                        controller: _city,
                        decoration: const InputDecoration(
                          labelText: "المدينة",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              width: 2,
                              color: Color.fromRGBO(26, 141, 153, 1),
                            ),
                          ),
                        ),
                        cursorColor: primary,
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? "مطلوب"
                                    : null,
                      ),

                      const SizedBox(height: 12),

                      /// ✅ السعر (Numbers)
                      TextFormField(
                        controller: _price,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "السعر",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              width: 2,
                              color: Color.fromRGBO(26, 141, 153, 1),
                            ),
                          ),
                        ),
                        cursorColor: primary,
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? "مطلوب"
                                    : null,
                      ),

                      const SizedBox(height: 12),

                      /// ✅ الوصف
                      TextFormField(
                        controller: _desc,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "الوصف",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              width: 2,
                              color: Color.fromRGBO(26, 141, 153, 1),
                            ),
                          ),
                        ),
                        cursorColor: primary,
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? "مطلوب"
                                    : null,
                      ),

                      const SizedBox(height: 18),

                      /// ✅ الخدمات (Chips)
                      const Text(
                        "الخدمات",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ✅ FilterChip يسمح بالاختيار/الإلغاء
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children:
                            servicesAll.map((s) {
                              final selected = selectedServices.contains(s);
                              return FilterChip(
                                label: Text(s),
                                selected: selected,
                                onSelected: (val) {
                                  setState(() {
                                    if (val) {
                                      selectedServices.add(s);
                                    } else {
                                      selectedServices.remove(s);
                                    }
                                  });
                                },
                                selectedColor: primary.withValues(alpha: .2),
                                checkmarkColor: primary,
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 18),

                      /// ✅ الصور (إضافة + معاينة)
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "الصور (1–5)",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: pickImages,
                            icon: const Icon(
                              Icons.photo_library_outlined,
                              color: primary,
                            ),
                            label: const Text(
                              "إضافة صور",
                              style: TextStyle(fontSize: 14, color: primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ✅ عرض الصور الحالية + الصور الجديدة
                      _ImagesPreview(
                        existingUrls: existingImageUrls,
                        picked: pickedImages,
                        onRemoveExisting: (url) {
                          setState(() => existingImageUrls.remove(url));
                        },
                        onRemovePicked: (x) {
                          setState(() => pickedImages.remove(x));
                        },
                      ),

                      const SizedBox(height: 24),

                      /// ✅ زر حفظ / نشر
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: save,
                        child: Text(
                          isEdit ? "حفظ التعديل" : "نشر العقار",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

/// ✅ Widget مسؤولة عن عرض الصور (روابط + ملفات)
class _ImagesPreview extends StatelessWidget {
  final List<String> existingUrls; // صور موجودة (URLs)
  final List<XFile> picked; // صور جديدة (Files)
  final void Function(String url) onRemoveExisting; // حذف صورة قديمة
  final void Function(XFile x) onRemovePicked; // حذف صورة جديدة

  const _ImagesPreview({
    required this.existingUrls,
    required this.picked,
    required this.onRemoveExisting,
    required this.onRemovePicked,
  });

  @override
  Widget build(BuildContext context) {
    final total = existingUrls.length + picked.length;

    // ✅ لو ما فيش صور نعرض رسالة
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text("لا يوجد صور بعد"),
      );
    }

    // ✅ Wrap لعرض الصور مثل Grid مرن
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // ✅ عرض الصور القديمة (روابط)
        ...existingUrls.map(
          (url) => _Thumb(
            child: Image.network(url, fit: BoxFit.cover),
            onRemove: () => onRemoveExisting(url),
          ),
        ),

        // ✅ عرض الصور الجديدة (ملفات)
        ...picked.map(
          (x) => _Thumb(
            child: Image.file(File(x.path), fit: BoxFit.cover),
            onRemove: () => onRemovePicked(x),
          ),
        ),
      ],
    );
  }
}

/// ✅ Thumbnail (صورة صغيرة) مع زر حذف (X)
class _Thumb extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;

  const _Thumb({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ الصورة نفسها
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 95,
            height: 95,
            color: Colors.grey.shade200,
            child: child,
          ),
        ),

        // ✅ زر حذف فوق الصورة
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
