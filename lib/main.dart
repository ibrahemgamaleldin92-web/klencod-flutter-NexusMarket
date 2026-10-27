import 'package:flutter/material.dart';

void main() {
  runApp(const NexusMarketApp());
}

const Color gold = Color(0xFFE7BE70);
const Color background = Color(0xFF0B0D11);
const Color surface = Color(0xFF151922);
const Color muted = Color(0xFF9299A8);

class Product {
  String name;
  double price;
  String category;
  bool available;
  int quantity;

  Product({
    required this.name,
    required this.price,
    required this.category,
    this.available = true,
    this.quantity = 0,
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
      debugShowCheckedModeBanner: false,
      title: 'NEXUS MARKET',
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
  double deliveryFee = 15;
  bool pickupEnabled = true;
  bool storeOpen = true;

  String search = '';
  String category = 'الكل';

  final List<String> categories = [
    'الكل',
    'ألبان',
    'مشروبات',
    'بقالة',
    'منظفات',
    'سناكس',
  ];

  final List<Product> products = [
    Product(
      name: 'لبن كامل الدسم',
      price: 45,
      category: 'ألبان',
      available: true,
    ),
    Product(
      name: 'سكر أبيض',
      price: 35,
      category: 'بقالة',
      available: true,
    ),
    Product(
      name: 'زيت طعام',
      price: 75,
      category: 'بقالة',
      available: false,
    ),
    Product(
      name: 'مياه معدنية',
      price: 10,
      category: 'مشروبات',
      available: true,
    ),
    Product(
      name: 'مكرونة',
      price: 15,
      category: 'بقالة',
      available: true,
    ),
    Product(
      name: 'شيبسي',
      price: 10,
      category: 'سناكس',
      available: true,
    ),
  ];

  final Map<Product, int> cart = {};
  final List<MarketOrder> orders = [];

  List<Product> get filteredProducts {
    return products.where((p) {
      final matchesSearch = p.name.contains(search.trim());
      final matchesCategory =
          category == 'الكل' || p.category == category;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  int get cartCount {
    return cart.values.fold(0, (sum, quantity) => sum + quantity);
  }

  double get cartTotal {
    return cart.entries.fold(
      0,
      (sum, entry) => sum + entry.key.price * entry.value,
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: surface,
      ),
    );
  }

  void addToCart(Product product) {
    if (!storeOpen) {
      showMessage('المتجر مغلق حاليًا');
      return;
    }

    if (!product.available) {
      showMessage('المنتج غير متوفر');
      return;
    }

    setState(() {
      cart[product] = (cart[product] ?? 0) + 1;
    });

    showMessage('تمت إضافة ${product.name} للسلة');
  }

  void changeCartQuantity(Product product, int change) {
    setState(() {
      final newQuantity = (cart[product] ?? 0) + change;

      if (newQuantity <= 0) {
        cart.remove(product);
      } else {
        cart[product] = newQuantity;
      }
    });
  }

  Future<void> editMarket() async {
    final nameController = TextEditingController(text: marketName);
    final addressController =
        TextEditingController(text: marketAddress);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surface,
          title: const Text('بيانات المتجر'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'اسم السوبر ماركت',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'العنوان أو وصف المتجر',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;

                setState(() {
                  marketName = nameController.text.trim();
                  marketAddress = addressController.text.trim();
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addOrEditProduct({Product? product}) async {
    final nameController =
        TextEditingController(text: product?.name ?? '');

    final priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );

    String selectedCategory = product?.category ?? 'بقالة';

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
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
                        controller: nameController,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          labelText: 'اسم المنتج',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'اكتب اسم المنتج';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'السعر بالجنيه',
                        ),
                        validator: (value) {
                          final price = double.tryParse(value ?? '');

                          if (price == null || price <= 0) {
                            return 'اكتب سعرًا صحيحًا';
                          }

                          return null;
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
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedCategory = value;
                            });
                          }
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

                    final name = nameController.text.trim();
                    final price =
                        double.parse(priceController.text.trim());

                    setState(() {
                      if (product == null) {
                        products.add(
                          Product(
                            name: name,
                            price: price,
                            category: selectedCategory,
                          ),
                        );
                      } else {
                        product.name = name;
                        product.price = price;
                        product.category = selectedCategory;
                      }
                    });

                    Navigator.pop(dialogContext);
                    showMessage('تم حفظ بيانات المنتج');
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showProductOptions(Product product) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: gold),
                title: const Text('تعديل المنتج'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  addOrEditProduct(product: product);
                },
              ),
              ListTile(
                leading: Icon(
                  product.available
                      ? Icons.remove_shopping_cart
                      : Icons.check_circle,
                  color: gold,
                ),
                title: Text(
                  product.available
                      ? 'تحديد كغير متوفر'
                      : 'تحديد كمتوفر',
                ),
                onTap: () {
                  setState(() {
                    product.available = !product.available;
                  });

                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('حذف المنتج'),
                onTap: () {
                  setState(() {
                    products.remove(product);
                    cart.remove(product);
                  });

                  Navigator.pop(sheetContext);
                  showMessage('تم حذف المنتج');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> checkout() async {
    if (cart.isEmpty) {
      showMessage('السلة فارغة');
      return;
    }

    if (!storeOpen) {
      showMessage('المتجر مغلق حاليًا');
      return;
    }

    String method = deliveryEnabled ? 'دليفري' : 'استلام من المتجر';

    if (!deliveryEnabled && !pickupEnabled) {
      showMessage('الطلبات غير متاحة حاليًا');
      return;
    }

    final Map<Product, int> items = Map.of(cart);
    final double subtotal = cartTotal;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: surface,
              title: const Text('تأكيد الطلب'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('قيمة المنتجات: ${subtotal.toStringAsFixed(2)} جنيه'),
                  const SizedBox(height: 12),
                  if (deliveryEnabled)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'دليفري (+${deliveryFee.toStringAsFixed(2)} جنيه)',
                      ),
                      value: 'دليفري',
                      groupValue: method,
                      onChanged: (value) {
                        setDialogState(() => method = value!);
                      },
                    ),
                  if (pickupEnabled)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('استلام من المتجر'),
                      value: 'استلام من المتجر',
                      groupValue: method,
                      onChanged: (value) {
                        setDialogState(() => method = value!);
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('رجوع'),
                ),
                FilledButton(
                  onPressed: () {
                    if (method == 'دليفري' && !deliveryEnabled) return;
                    if (method == 'استلام من المتجر' && !pickupEnabled) {
                      return;
                    }

                    setState(() {
                      orders.insert(
                        0,
                        MarketOrder(
                          items: items.entries
                              .map((e) => MapEntry(e.key, e.value))
                              .toList(),
                          total: subtotal +
                              (method == 'دليفري' ? deliveryFee : 0),
                          deliveryType: method,
                        ),
                      );

                      cart.clear();
                    });

                    Navigator.pop(dialogContext);
                    showMessage('تم تسجيل الطلب بنجاح');
                  },
                  child: const Text('تأكيد'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: gold.withValues(alpha: 0.4)),
                ),
                child: const Icon(
                  Icons.shopping_cart_rounded,
                  color: gold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marketName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'متجرك في مكان واحد',
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: IndexedStack(
          index: page,
          children: [
            buildCustomerPage(),
            buildOwnerPage(),
            buildOrdersPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: page,
          backgroundColor: surface,
          indicatorColor: gold.withValues(alpha: 0.15),
          onDestinationSelected: (index) {
            setState(() => page = index);
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront, color: gold),
              label: 'العميل',
            ),
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: gold),
              label: 'إدارة المتجر',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: orders.isNotEmpty,
                label: Text('${orders.length}'),
                child: const Icon(Icons.receipt_long_outlined),
              ),
              selectedIcon: const Icon(
                Icons.receipt_long,
                color: gold,
              ),
              label: 'الطلبات',
            ),
          ],
        ),
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
              colors: [Color(0xFF242018), Color(0xFF171922)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: gold.withValues