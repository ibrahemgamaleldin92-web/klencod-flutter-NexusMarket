import 'package:flutter/material.dart';

void main() => runApp(const NexusMarketApp());

const Color gold = Color(0xFFE7BE70);
const Color background = Color(0xFF0B0D11);
const Color surface = Color(0xFF151922);
const Color muted = Color(0xFF9299A8);
const Color green = Color(0xFF52D6A0);
const Color red = Color(0xFFFF6B76);

class Product {
  String name;
  double price;
  String category;
  bool available;

  Product({
    required this.name,
    required this.price,
    required this.category,
    this.available = true,
  });
}

class MarketOrder {
  final List<MapEntry<Product, int>> items;
  final double total;
  final String deliveryType;
  String status;

  MarketOrder({
    required this.items,
    required this.total,
    required this.deliveryType,
    this.status = 'طلب جديد',
  });
}

class NexusMarketApp extends StatelessWidget {
  const NexusMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXUS MARKET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          surface: surface,
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif',
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          labelStyle: const TextStyle(color: muted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const NexusHome(),
    );
  }
}

class NexusHome extends StatefulWidget {
  const NexusHome({super.key});

  @override
  State<NexusHome> createState() => _NexusHomeState();
}

class _NexusHomeState extends State<NexusHome> {
  int page = 0;
  String marketName = 'NEXUS MARKET';
  String marketAddress = 'متجرك المفضل';
  bool deliveryEnabled = true;
  bool pickupEnabled = true;
  bool storeOpen = true;
  double deliveryFee = 15;
  String search = '';
  String category = 'الكل';

  final List<String> categories = [
    'الكل',
    'ألبان',
    'مشروبات',
    'بقالة',
    'منظفات',
    'سناكس',
    'مخبوزات',
  ];

  final List<Product> products = [
    Product(name: 'لبن كامل الدسم', price: 45, category: 'ألبان'),
    Product(name: 'سكر أبيض', price: 35, category: 'بقالة'),
    Product(
      name: 'زيت طعام',
      price: 75,
      category: 'بقالة',
      available: false,
    ),
    Product(name: 'مياه معدنية', price: 10, category: 'مشروبات'),
    Product(name: 'مكرونة', price: 15, category: 'بقالة'),
    Product(name: 'شيبسي', price: 10, category: 'سناكس'),
  ];

  final Map<Product, int> cart = {};
  final List<MarketOrder> orders = [];

  List<Product> get filteredProducts => products.where((p) {
        final matchesSearch = p.name
            .toLowerCase()
            .contains(search.trim().toLowerCase());
        final matchesCategory =
            category == 'الكل' || p.category == category;
        return matchesSearch && matchesCategory;
      }).toList();

  int get cartCount =>
      cart.values.fold(0, (sum, q) => sum + q);

  double get cartTotal => cart.entries.fold(
        0,
        (sum, entry) => sum + entry.key.price * entry.value,
      );

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, textAlign: TextAlign.center),
        backgroundColor: surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void addToCart(Product product) {
    if (!storeOpen) {
      return message('المتجر مغلق حاليًا');
    }
    if (!product.available) {
      return message('المنتج غير متوفر حاليًا');
    }
    setState(() {
      cart[product] = (cart[product] ?? 0) + 1;
    });
    message('تمت إضافة ${product.name} للسلة');
  }

  void changeQuantity(Product product, int change) {
    setState(() {
      final next = (cart[product] ?? 0) + change;
      if (next <= 0) {
        cart.remove(product);
      } else {
        cart[product] = next;
      }
    });
  }

  Future<void> editMarket() async {
    final name = TextEditingController(text: marketName);
    final address = TextEditingController(text: marketAddress);
    final fee = TextEditingController(
      text: deliveryFee.toStringAsFixed(0),
    );

    bool delivery = deliveryEnabled;
    bool pickup = pickupEnabled;
    bool open = storeOpen;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: surface,
          title: const Text('إعدادات المتجر'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'اسم السوبر ماركت',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: address,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'العنوان أو وصف المتجر',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'المتجر مفتوح لاستقبال الطلبات',
                  ),
                  value: open,
                  activeColor: gold,
                  onChanged: (v) {
                    setDialogState(() => open = v);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('تفعيل الدليفري'),
                  value: delivery,
                  activeColor: gold,
                  onChanged: (v) {
                    setDialogState(() => delivery = v);
                  },
                ),
                if (delivery) ...[
                  const SizedBox(height: 6),
                  TextField(
                    controller: fee,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'رسوم التوصيل بالجنيه',
                    ),
                  ),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'السماح بالاستلام من المتجر',
                  ),
                  value: pickup,
                  activeColor: gold,
                  onChanged: (v) {
                    setDialogState(() => pickup = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final parsedFee =
                    double.tryParse(fee.text.trim());

                if (name.text.trim().isEmpty) {
                  message('اكتب اسم المتجر أولًا');
                  return;
                }

                if (delivery &&
                    (parsedFee == null || parsedFee < 0)) {
                  message('اكتب رسوم توصيل صحيحة');
                  return;
                }

                setState(() {
                  marketName = name.text.trim();
                  marketAddress = address.text.trim();
                  deliveryEnabled = delivery;
                  pickupEnabled = pickup;
                  storeOpen = open;

                  if (delivery) {
                    deliveryFee = parsedFee!;
                  }
                });

                Navigator.pop(dialogContext);
                message('تم حفظ إعدادات المتجر');
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
    Future<void> addOrEditProduct({Product? product}) async {
    final name = TextEditingController(text: product?.name ?? '');
    final price = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );

    String selectedCategory = product?.category ?? 'بقالة';
    bool available = product?.available ?? true;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: surface,
          title: Text(
            product == null ? 'إضافة منتج' : 'تعديل المنتج',
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: 'اسم المنتج',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'اكتب اسم المنتج'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: price,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'السعر بالجنيه',
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      return n == null || n <= 0
                          ? 'اكتب سعرًا صحيحًا'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'القسم',
                    ),
                    items: categories
                        .where((c) => c != 'الكل')
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          selectedCategory = v;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('المنتج متوفر'),
                    value: available,
                    activeColor: gold,
                    onChanged: (v) {
                      setDialogState(() {
                        available = v;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                setState(() {
                  if (product == null) {
                    products.add(
                      Product(
                        name: name.text.trim(),
                        price: double.parse(price.text.trim()),
                        category: selectedCategory,
                        available: available,
                      ),
                    );
                  } else {
                    product.name = name.text.trim();
                    product.price = double.parse(price.text.trim());
                    product.category = selectedCategory;
                    product.available = available;
                  }
                });

                Navigator.pop(dialogContext);
                message('تم حفظ المنتج');
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> productOptions(Product product) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: gold,
              ),
              title: const Text('تعديل المنتج'),
              onTap: () {
                Navigator.pop(sheetContext);
                addOrEditProduct(product: product);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: red,
              ),
              title: const Text('حذف المنتج'),
              onTap: () {
                Navigator.pop(sheetContext);
                confirmDelete(product);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> confirmDelete(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surface,
        title: const Text('حذف المنتج'),
        content: Text('هل تريد حذف ${product.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        products.remove(product);
        cart.remove(product);
      });
      message('تم حذف المنتج');
    }
  }

  Widget sectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget buildCustomerPage() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF242018),
                Color(0xFF171922),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: gold.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: gold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marketName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          marketAddress,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: storeOpen ? green : red,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    storeOpen ? 'مفتوح' : 'مغلق',
                    style: TextStyle(
                      color: storeOpen ? green : red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'كل احتياجات بيتك في مكان واحد',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'اختار منتجاتك وأضفها للسلة بسهولة.',
                style: TextStyle(
                  color: muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (v) {
              setState(() {
                search = v;
              });
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن منتج...',
              prefixIcon: const Icon(
                Icons.search,
                color: gold,
              ),
              suffixIcon: search.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          search = '';
                        });
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = categories[index];
              final selected = category == item;

              return ChoiceChip(
                label: Text(item),
                selected: selected,
                selectedColor: gold,
                backgroundColor: surface,
                labelStyle: TextStyle(
                  color: selected ? background : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) {
                  setState(() {
                    category = item;
                  });
                },
              );
            },
          ),
        ),
        sectionTitle(
          'المنتجات',
          trailing: Text(
            '${filteredProducts.length} منتج',
            style: const TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: filteredProducts.isEmpty
              ? const Center(
                  child: Text(
                    'مفيش منتجات مطابقة للبحث',
                    style: TextStyle(color: muted),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    18,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.79,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return productCard(product);
                  },
                ),
        ),
      ],
    );
  }

  Widget productCard(Product product) {
    final quantity = cart[product] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    product.category == 'ألبان'
                        ? Icons.water_drop_outlined
                        : product.category == 'مشروبات'
                            ? Icons.local_drink_outlined
                            : product.category == 'منظفات'
                                ? Icons.cleaning_services_outlined
                                : product.category == 'مخبوزات'
                                    ? Icons.bakery_dining_outlined
                                    : product.category == 'سناكس'
                                        ? Icons.cookie_outlined
                                        : Icons.shopping_basket_outlined,
                    color: gold,
                    size: 38,
                  ),
                ),
              ),
            ),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              product.category,
              style: const TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${product.price.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(
                      color: gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (quantity > 0)
                  Text(
                    '×$quantity',
                    style: const TextStyle(
                      color: green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: FilledButton(
                onPressed: product.available && storeOpen
                    ? () => addToCart(product)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: background,
                  disabledBackgroundColor:
                      Colors.white.withValues(alpha: 0.06),
                  disabledForegroundColor: muted,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  !product.available
                      ? 'غير متوفر'
                      : !storeOpen
                          ? 'المتجر مغلق'
                          : 'أضف للسلة',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                onPressed: () => productOptions(product),
                icon: const Icon(
                  Icons.more_horiz,
                  color: muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
    Widget buildCartPage() {
    final entries = cart.entries.toList();

    return Column(
      children: [
        sectionTitle('سلة المشتريات'),
        if (entries.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: muted,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'السلة لسه فاضية',
                    style: TextStyle(
                      color: muted,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = entries[index].key;
                final quantity = entries[index].value;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: gold,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${(product.price * quantity).toStringAsFixed(2)} ج.م',
                              style: const TextStyle(
                                color: gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            changeQuantity(product, -1),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                        ),
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            changeQuantity(product, 1),
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: gold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'إجمالي المنتجات',
                      style: TextStyle(color: muted),
                    ),
                    const Spacer(),
                    Text(
                      '${cartTotal.toStringAsFixed(2)} ج.م',
                      style: const TextStyle(
                        color: gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: checkout,
                    icon: const Icon(
                      Icons.shopping_cart_checkout,
                    ),
                    label: const Text('إتمام الطلب'),
                    style: FilledButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: background,
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> checkout() async {
    if (cart.isEmpty) {
      message('السلة فاضية');
      return;
    }

    if (!storeOpen) {
      message('المتجر مغلق حاليًا');
      return;
    }

    String deliveryType = deliveryEnabled
        ? 'توصيل للمنزل'
        : 'استلام من المتجر';

    if (deliveryEnabled && pickupEnabled) {
      final choice = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: surface,
          title: const Text('طريقة استلام الطلب'),
          content: const Text(
            'اختار الطريقة المناسبة ليك',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                'استلام من المتجر',
              ),
              child: const Text('استلام من المتجر'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                'توصيل للمنزل',
              ),
              child: const Text('دليفري'),
            ),
          ],
        ),
      );

      if (choice == null) return;
      deliveryType = choice;
    } else if (!deliveryEnabled && !pickupEnabled) {
      message('الاستلام والتوصيل غير متاحين حاليًا');
      return;
    }

    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    final needsAddress = deliveryType == 'توصيل للمنزل';

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surface,
        title: const Text('بيانات الطلب'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'اسم العميل',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الموبايل',
                ),
              ),
              if (needsAddress) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'عنوان التوصيل بالتفصيل',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'المنتجات: ${cartTotal.toStringAsFixed(2)} ج.م',
              ),
              if (needsAddress)
                Text(
                  'التوصيل: ${deliveryFee.toStringAsFixed(2)} ج.م',
                ),
              const SizedBox(height: 8),
              Text(
                'الإجمالي: ${(cartTotal + (needsAddress ? deliveryFee : 0)).toStringAsFixed(2)} ج.م',
                style: const TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty ||
                  (needsAddress &&
                      addressController.text.trim().isEmpty)) {
                message('من فضلك أكمل البيانات المطلوبة');
                return;
              }

              Navigator.pop(dialogContext, true);
            },
            child: const Text('تأكيد الطلب'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      orders.insert(
        0,
        MarketOrder(
          items: cart.entries
              .map(
                (entry) => MapEntry(
                  entry.key,
                  entry.value,
                ),
              )
              .toList(),
          total: cartTotal +
              (needsAddress ? deliveryFee : 0),
          deliveryType: deliveryType,
        ),
      );
      cart.clear();
      page = 2;
    });

    message('تم تسجيل الطلب على هذا الجهاز');
  }

  Widget buildOrdersPage() {
    return Column(
      children: [
        sectionTitle('الطلبات'),
        Expanded(
          child: orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: muted,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'لسه مفيش طلبات',
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: gold.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.receipt_long,
                                color: gold,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'طلب رقم ${orders.length - index}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                order.status,
                                style: const TextStyle(
                                  color: green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          ...order.items.map(
                            (item) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(item.key.name),
                                  ),
                                  Text('×${item.value}'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            order.deliveryType,
                            style: const TextStyle(color: muted),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('الإجمالي'),
                              const Spacer(),
                              Text(
                                '${order.total.toStringAsFixed(2)} ج.م',
                                style: const TextStyle(
                                  color: gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }