import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const PastryShopApp());
}

// --- МОДЕЛИ ДАННЫХ ---

class User {
  final String username;
  final String password;
  final bool isAdmin;

  User({required this.username, required this.password, this.isAdmin = false});
}

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String? imageUrl;      // Для стартовых демо-товаров
  final Uint8List? imageBytes; // Для фото, загруженных админом с ПК

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
    this.imageBytes,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// --- ОСНОВНОЕ ПРИЛОЖЕНИЕ ---

class PastryShopApp extends StatelessWidget {
  const PastryShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Пастельная Кондитерская',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF4C2C2),
          primary: const Color(0xFFF4C2C2),
          secondary: const Color(0xFFE0F2F1),
          surface: Colors.white,
        ),
        fontFamily: 'Segoe UI',
        useMaterial3: true,
      ),
      home: const BakeryHomePage(),
    );
  }
}

class BakeryHomePage extends StatefulWidget {
  const BakeryHomePage({super.key});

  @override
  State<BakeryHomePage> createState() => _BakeryHomePageState();
}

class _BakeryHomePageState extends State<BakeryHomePage> {
  // Цветовая палитра
  final Color pastelPink = const Color(0xFFF4C2C2);
  final Color pastelMint = const Color(0xFFE0F2F1);
  final Color darkCocoa = const Color(0xFF4A3531);

  // База пользователей (по умолчанию создан ваш админ-аккаунт)
  final List<User> _users = [
    User(username: 'admin', password: '123', isAdmin: true),
    User(username: 'guest', password: '123', isAdmin: false),
  ];

  User? _currentUser;

  // Витрина товаров
  final List<Product> _products = [
    Product(
      id: '1',
      title: 'Клубничный Макарон',
      description: 'Нежное миндальное пирожное с кремом из свежей клубники и белого шоколада.',
      price: 180,
      imageUrl: 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?auto=format&fit=crop&w=600&q=80',
    ),
    Product(
      id: '2',
      title: 'Мятный Чизкейк',
      description: 'Воздушный творожный мусс с лёгкой прохладой мяты на песочной основе.',
      price: 340,
      imageUrl: 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=600&q=80',
    ),
    Product(
      id: '3',
      title: 'Торт «Малиновое облако»',
      description: 'Бисквитные коржи с крем-чизом, малиновым конфи и ванильной пропиткой.',
      price: 420,
      imageUrl: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=600&q=80',
    ),
  ];

  // Корзина
  final List<CartItem> _cart = [];

  // --- ЛОГИКА КОРЗИНЫ ---
  void _addToCart(Product product) {
    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == product.id);
      if (index >= 0) {
        _cart[index].quantity++;
      } else {
        _cart.add(CartItem(product: product));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('«${product.title}» добавлен в корзину', style: TextStyle(color: darkCocoa)),
        backgroundColor: pastelMint,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  double get _totalPrice =>
      _cart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  int get _totalItems =>
      _cart.fold(0, (sum, item) => sum + item.quantity);

  // --- ОКНО АВТОРИЗАЦИИ И РЕГИСТРАЦИИ ---
  void _showAuthDialog() {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool isLoginMode = true;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              isLoginMode ? 'Вход в аккаунт' : 'Регистрация покупателя',
              style: TextStyle(color: darkCocoa, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: pastelMint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Для управления товарами войдите как:\nЛогин: admin | Пароль: 123',
                      style: TextStyle(fontSize: 12, color: darkCocoa),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Юзернейм',
                      filled: true,
                      fillColor: pastelPink.withValues(alpha: 0.2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      filled: true,
                      fillColor: pastelPink.withValues(alpha: 0.2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      setDialogState(() {
                        isLoginMode = !isLoginMode;
                        errorMessage = null;
                      });
                    },
                    child: Text(
                      isLoginMode ? 'Нет аккаунта? Зарегистрироваться' : 'Уже есть аккаунт? Войти',
                      style: TextStyle(color: darkCocoa),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена', style: TextStyle(color: darkCocoa)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelPink,
                  foregroundColor: darkCocoa,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final uName = usernameCtrl.text.trim();
                  final pass = passwordCtrl.text.trim();

                  if (uName.isEmpty || pass.isEmpty) {
                    setDialogState(() => errorMessage = 'Заполните все поля');
                    return;
                  }

                  if (isLoginMode) {
                    final found = _users.where((u) => u.username == uName && u.password == pass);
                    if (found.isNotEmpty) {
                      setState(() => _currentUser = found.first);
                      Navigator.pop(context);
                    } else {
                      setDialogState(() => errorMessage = 'Неверный логин или пароль');
                    }
                  } else {
                    if (_users.any((u) => u.username == uName)) {
                      setDialogState(() => errorMessage = 'Такой юзернейм уже занят');
                    } else {
                      final newUser = User(username: uName, password: pass, isAdmin: false);
                      setState(() {
                        _users.add(newUser);
                        _currentUser = newUser;
                      });
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(isLoginMode ? 'Войти' : 'Создать аккаунт'),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- ОКНО ДОБАВЛЕНИЯ НОВОГО ТОВАРА (ТОЛЬКО ДЛЯ АДМИНА) ---
  void _showAddProductDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    Uint8List? pickedImageBytes;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Добавить десерт на витрину', style: TextStyle(color: darkCocoa, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                        if (file != null) {
                          final bytes = await file.readAsBytes();
                          setDialogState(() => pickedImageBytes = bytes);
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: pastelMint,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: pastelPink, width: 2),
                        ),
                        child: pickedImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.memory(pickedImageBytes!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 40, color: darkCocoa),
                                  const SizedBox(height: 8),
                                  Text('Нажмите, чтобы загрузить фото', style: TextStyle(color: darkCocoa)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Название пирожного / торта',
                        filled: true,
                        fillColor: pastelPink.withValues(alpha: 0.2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Цена (в сомах / рублях)',
                        filled: true,
                        fillColor: pastelPink.withValues(alpha: 0.2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Описание и состав',
                        filled: true,
                        fillColor: pastelPink.withValues(alpha: 0.2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    if (errorMsg != null) ...[
                      const SizedBox(height: 8),
                      Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                    ]
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена', style: TextStyle(color: darkCocoa)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelPink,
                  foregroundColor: darkCocoa,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final desc = descCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text.trim());

                  if (title.isEmpty || desc.isEmpty || price == null) {
                    setDialogState(() => errorMsg = 'Заполните название, описание и корректную цену');
                    return;
                  }

                  setState(() {
                    _products.insert(
                      0,
                      Product(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        description: desc,
                        price: price,
                        imageBytes: pickedImageBytes,
                        imageUrl: pickedImageBytes == null
                            ? 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=600&q=80'
                            : null,
                      ),
                    );
                  });
                  Navigator.pop(context);
                },
                child: const Text('Опубликовать товар'),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- ОКНО КОРЗИНЫ ---
  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ваша корзина сладостей', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkCocoa)),
                const SizedBox(height: 16),
                if (_cart.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text('Корзина пока пуста. Выберите что-нибудь вкусное!', style: TextStyle(color: darkCocoa)),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _cart.length,
                      itemBuilder: (context, i) {
                        final item = _cart[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: pastelMint.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.title, style: TextStyle(fontWeight: FontWeight.bold, color: darkCocoa)),
                                    Text('${item.product.price.toStringAsFixed(0)} × ${item.quantity} = ${(item.product.price * item.quantity).toStringAsFixed(0)}',
                                        style: TextStyle(color: darkCocoa)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        if (item.quantity > 1) {
                                          item.quantity--;
                                        } else {
                                          _cart.removeAt(i);
                                        }
                                      });
                                      setSheetState(() {});
                                    },
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      setState(() => item.quantity++);
                                      setSheetState(() {});
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                if (_cart.isNotEmpty) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Итого к оплате:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkCocoa)),
                      Text('${_totalPrice.toStringAsFixed(0)} сом', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkCocoa)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pastelPink,
                        foregroundColor: darkCocoa,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        if (_currentUser == null) {
                          Navigator.pop(context);
                          _showAuthDialog();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Пожалуйста, войдите в аккаунт для оформления заказа')),
                          );
                          return;
                        }
                        setState(() => _cart.clear());
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: pastelMint,
                            title: const Text('Заказ принят! 🧁'),
                            content: Text('Спасибо, ${_currentUser!.username}! Кондитер уже начал готовить ваши десерты.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отлично')),
                            ],
                          ),
                        );
                      },
                      child: const Text('Оформить заказ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // --- ИНТЕРФЕЙС СТРАНИЦЫ ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pastelPink.withValues(alpha: 0.45),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.cake_rounded, color: darkCocoa),
            const SizedBox(width: 10),
            Text('Pastel Bakery', style: TextStyle(color: darkCocoa, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // Кнопка для админа
          if (_currentUser != null && _currentUser!.isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelMint,
                  foregroundColor: darkCocoa,
                ),
                onPressed: _showAddProductDialog,
                icon: const Icon(Icons.add),
                label: const Text('Добавить десерт'),
              ),
            ),

          // Кнопка корзины
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_bag_outlined, color: darkCocoa, size: 28),
                onPressed: _showCartSheet,
              ),
              if (_totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: pastelMint,
                    child: Text('$_totalItems', style: TextStyle(fontSize: 11, color: darkCocoa, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),

          // Кнопка входа / профиля
          if (_currentUser == null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: darkCocoa,
                ),
                onPressed: _showAuthDialog,
                child: const Text('Войти'),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Chip(
                    backgroundColor: _currentUser!.isAdmin ? pastelPink : pastelMint,
                    label: Text(
                      _currentUser!.isAdmin ? '👑 ${_currentUser!.username}' : _currentUser!.username,
                      style: TextStyle(color: darkCocoa, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Выйти',
                    icon: Icon(Icons.logout, color: darkCocoa),
                    onPressed: () => setState(() => _currentUser = null),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Приветственный баннер
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [pastelPink.withValues(alpha: 0.6), pastelMint],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Нежные десерты ручной работы',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: darkCocoa),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Воздушные муссы, свежие ягоды и пастельная эстетика в каждом кусочке.',
                          style: TextStyle(fontSize: 16, color: darkCocoa.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Наша витрина', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkCocoa)),
                  const SizedBox(height: 16),

                  // Адаптивная сетка товаров
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 800
                          ? 3
                          : constraints.maxWidth > 500
                              ? 2
                              : 1;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final item = _products[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: pastelPink.withValues(alpha: 0.6), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: pastelPink.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Фото товара
                                Expanded(
                                  flex: 5,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: item.imageBytes != null
                                          ? Image.memory(item.imageBytes!, fit: BoxFit.cover)
                                          : Image.network(
                                              item.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: pastelMint,
                                                child: Icon(Icons.cake, size: 50, color: darkCocoa),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                // Описание и кнопка покупки
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: darkCocoa),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 13, color: darkCocoa.withValues(alpha: 0.75)),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: pastelMint,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '${item.price.toStringAsFixed(0)} сом',
                                                style: TextStyle(fontWeight: FontWeight.bold, color: darkCocoa),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: pastelPink,
                                                foregroundColor: darkCocoa,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              onPressed: () => _addToCart(item),
                                              child: const Text('В корзину'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
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