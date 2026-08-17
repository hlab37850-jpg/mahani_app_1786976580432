import 'package:flutter/material.dart';
import 'database.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مخزني',
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _service = ProductService();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _service.fetchAllProducts();
    setState(() => _products = products);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مخزني'),
        centerTitle: true,
      ),
      body: _products.isEmpty
          ? const Center(
              child: Text(
                'لا توجد منتجات',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final p = _products[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('الكمية: ${p.quantity} | سعر البيع: ${p.salePrice}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Simple dialog to add a product
          final name = await _showTextInput(context, 'اسم المنتج');
          if (name == null || name.isEmpty) return;
          final quantityStr = await _showTextInput(context, 'الكمية');
          if (quantityStr == null) return;
          final priceStr = await _showTextInput(context, 'سعر البيع');
          if (priceStr == null) return;
          final quantity = int.tryParse(quantityStr) ?? 0;
          final price = double.tryParse(priceStr) ?? 0.0;
          await _service.addProduct(Product(
            name: name,
            quantity: quantity,
            purchasePrice: 0.0,
            salePrice: price,
          ));
          _loadProducts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _showTextInput(BuildContext context, String label) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
