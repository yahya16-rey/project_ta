import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/jamu_models.dart';

class JamuProvider with ChangeNotifier {
  // State Data
  BoilerData _boilerData = BoilerData(temperature: 32.4, status: 'NORMAL');
  double _targetTemperature = 32.5;
  String _lastUpdatedTime = "10:30 WIB";
  
  double _totalMonthlyRevenue = 0.0;
  double _revenuePercentageIncrease = 0.0;
  double _stockLevel = 100.0; // 100%
  int _transactionsCountToday = 0;
  bool _isIotConnected = true;

  List<TemperatureReading> _tempHistory = [];
  List<TransactionData> _recentTransactions = [];
  List<ActivityLog> _recentActivities = [];
  List<ProductMenu> _catalogMenu = [
    ProductMenu(name: 'Kunyit Asam', price: 15000, imagePath: 'assets/images/jamu_kunyit_asam.png'),
    ProductMenu(name: 'Beras Kencur', price: 18000, imagePath: 'assets/images/jamu_beras_kencur.png'),
    ProductMenu(name: 'Temulawak', price: 16000, imagePath: 'assets/images/jamu_temulawak.png'),
    ProductMenu(name: 'Jahe Merah', price: 20000, imagePath: 'assets/images/jamu_jahe_merah.png'),
    ProductMenu(name: 'Gula Asem', price: 12000, imagePath: 'assets/images/jamu_gula_asem.png'),
  ];
  
  List<CartItem> _cartItems = [];

  bool _isFirebaseConnected = false;
  bool _isLoading = true;

  // Getters
  BoilerData get boilerData => _boilerData;
  double get targetTemperature => _targetTemperature;
  String get lastUpdatedTime => _lastUpdatedTime;
  double get totalMonthlyRevenue => _totalMonthlyRevenue;
  double get revenuePercentageIncrease => _revenuePercentageIncrease;
  double get stockLevel => _stockLevel;
  int get transactionsCountToday => _transactionsCountToday;
  bool get isIotConnected => _isIotConnected;

  List<TemperatureReading> get tempHistory => _tempHistory;
  List<TransactionData> get recentTransactions => _recentTransactions;
  List<ActivityLog> get recentActivities => _recentActivities;
  List<ProductMenu> get catalogMenu => _catalogMenu;
  List<CartItem> get cartItems => _cartItems;
  
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.totalAmount);

  bool get isFirebaseConnected => _isFirebaseConnected;
  bool get isLoading => _isLoading;

  // Firebase Subscriptions
  StreamSubscription? _boilerSub;
  StreamSubscription? _historySub;
  StreamSubscription? _transactionSub;
  StreamSubscription? _activitySub;
  StreamSubscription? _summarySub;
  StreamSubscription? _inventorySub;

  final Random _random = Random();

  JamuProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadLocalData();
    try {
      if (Firebase.apps.isNotEmpty) {
        _setupFirebaseStreams();
      } else {
        _setupEmptyState();
      }
    } catch (e) {
      debugPrint('Failed to connect to Firebase, fallback to empty state: $e');
      _setupEmptyState();
    }
  }
  
  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Catalog
    final catalogStr = prefs.getString('catalogMenu');
    if (catalogStr != null) {
      final List decoded = jsonDecode(catalogStr);
      _catalogMenu = decoded.map((e) => ProductMenu.fromMap(e)).toList();
    }

    // Load Revenue
    _totalMonthlyRevenue = prefs.getDouble('totalMonthlyRevenue') ?? 0.0;
    _transactionsCountToday = prefs.getInt('transactionsCountToday') ?? 0;

    // Load Transactions
    final txStr = prefs.getString('recentTransactions');
    if (txStr != null) {
      final List decoded = jsonDecode(txStr);
      _recentTransactions = decoded.map((e) => TransactionData.fromJsonMap(e)).toList();
    }
  }

  Future<void> _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('catalogMenu', jsonEncode(_catalogMenu.map((e) => e.toMap()).toList()));
    prefs.setDouble('totalMonthlyRevenue', _totalMonthlyRevenue);
    prefs.setInt('transactionsCountToday', _transactionsCountToday);
    prefs.setString('recentTransactions', jsonEncode(_recentTransactions.map((e) => e.toMap()).toList()));
  }

  // Set up Firebase listeners
  void _setupFirebaseStreams() {
    final firestore = FirebaseFirestore.instance;
    _isFirebaseConnected = true;
    _isLoading = false;
    notifyListeners();

    _boilerSub = firestore.collection('monitoring').doc('boiler').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        _boilerData = BoilerData.fromMap(doc.data()!);
        _targetTemperature = (doc.data()?['targetTemperature'] ?? 32.5).toDouble();
        if (doc.data()?['lastUpdated'] != null) {
          _lastUpdatedTime = doc.data()?['lastUpdated'] ?? _lastUpdatedTime;
        } else {
          _lastUpdatedTime = DateFormat('HH:mm').format(DateTime.now()) + " WIB";
        }
        notifyListeners();
      }
    }, onError: (e) => debugPrint('Error boiler stream: $e'));

    _historySub = firestore.collection('temperature_history')
        .orderBy('timestamp', descending: true)
        .limit(15)
        .snapshots()
        .listen((snapshot) {
      _tempHistory = snapshot.docs.map((doc) => TemperatureReading.fromMap(doc.data())).toList();
      notifyListeners();
    }, onError: (e) => debugPrint('Error temp history stream: $e'));

    _transactionSub = firestore.collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(15)
        .snapshots()
        .listen((snapshot) {
      _recentTransactions = snapshot.docs.map((doc) {
        final data = doc.data();
        String timeStr = "Baru";
        if (data['timestamp'] != null) {
          final t = (data['timestamp'] as Timestamp).toDate();
          timeStr = DateFormat('HH:mm').format(t);
        }
        return TransactionData.fromMap(doc.id, {
          ...data,
          'timestamp': timeStr,
        });
      }).toList();
      notifyListeners();
    }, onError: (e) => debugPrint('Error transactions stream: $e'));

    _activitySub = firestore.collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
      _recentActivities = snapshot.docs.map((doc) {
        final data = doc.data();
        String timeStr = "Baru";
        if (data['timestamp'] != null) {
          final t = (data['timestamp'] as Timestamp).toDate();
          timeStr = DateFormat('HH:mm').format(t);
        }
        return ActivityLog.fromMap(doc.id, {
          ...data,
          'timestamp': timeStr,
        });
      }).toList();
      notifyListeners();
    }, onError: (e) => debugPrint('Error activities stream: $e'));

    _summarySub = firestore.collection('revenue').doc('summary').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        _totalMonthlyRevenue = (doc.data()?['totalMonthlyRevenue'] ?? 0.0).toDouble();
        _revenuePercentageIncrease = (doc.data()?['percentChange'] ?? 0.0).toDouble();
        _transactionsCountToday = (doc.data()?['transactionsCountToday'] ?? 0).toInt();
        notifyListeners();
      }
    }, onError: (e) => debugPrint('Error revenue summary stream: $e'));

    _inventorySub = firestore.collection('inventory').doc('turmeric').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        _stockLevel = (doc.data()?['stockPercentage'] ?? 100.0).toDouble();
        _isIotConnected = doc.data()?['iotConnected'] ?? true;
        notifyListeners();
      }
    }, onError: (e) => debugPrint('Error inventory stream: $e'));
  }

  void _setupEmptyState() {
    _isFirebaseConnected = false;
    _isLoading = false;
    notifyListeners();
  }

  // Cart Management
  void addToCart(ProductMenu product, int quantity) {
    int existingIndex = _cartItems.indexWhere((item) => item.product.name == product.name);
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(ProductMenu product) {
    _cartItems.removeWhere((item) => item.product.name == product.name);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<void> checkoutCart() async {
    if (_cartItems.isEmpty) return;

    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);

    if (_isFirebaseConnected) {
      try {
        final firestore = FirebaseFirestore.instance;
        final batch = firestore.batch();

        double totalAmount = 0;
        int totalQty = 0;
        
        List<Map<String, dynamic>> itemsList = [];
        
        for (var item in _cartItems) {
          totalAmount += item.totalAmount;
          totalQty += item.quantity;
          itemsList.add({
            'nama_produk': item.product.name,
            'jumlah': item.quantity,
            'harga': item.product.price,
          });
        }

        final txRef = firestore.collection('transactions').doc();
        batch.set(txRef, {
          'items': itemsList,
          'amount': totalAmount,
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
        final String detailDesc = '${_cartItems.length} Product\n' + _cartItems.map((e) {
          final total = e.quantity * e.product.price;
          return '${e.quantity} ${e.product.name} Rp ${currencyFormat.format(total).replaceAll('Rp ', '').replaceAll(',', '.')}';
        }).join('\n');

        final actRef = firestore.collection('activities').doc();
        batch.set(actRef, {
          'type': 'transaction',
          'title': 'Transaksi Checkout',
          'description': '$detailDesc\nTotal Rp ${currencyFormat.format(totalAmount).replaceAll('Rp ', '').replaceAll(',', '.')}',
          'timestamp': FieldValue.serverTimestamp(),
        });

        final summaryRef = firestore.collection('revenue').doc('summary');
        batch.set(summaryRef, {
          'totalMonthlyRevenue': FieldValue.increment(totalAmount),
          'transactionsCountToday': FieldValue.increment(_cartItems.length),
        }, SetOptions(merge: true));

        final invRef = firestore.collection('inventory').doc('turmeric');
        double stockChange = -0.5 * totalQty;
        batch.set(invRef, {
          'stockPercentage': FieldValue.increment(stockChange < -10 ? -10.0 : stockChange),
        }, SetOptions(merge: true));

        await batch.commit();
        clearCart();
        return; // Success Firebase
      } catch (e) {
        debugPrint("Error pushing batch to Firebase, doing locally: $e");
      }
    }
    
    // Local processing fallback
    double totalAmount = 0;
    int totalQty = 0;
    List<TransactionItem> localItemsList = [];
    
    for (var item in _cartItems) {
      totalAmount += item.totalAmount;
      totalQty += item.quantity;
      localItemsList.add(TransactionItem(
        name: item.product.name,
        quantity: item.quantity,
        price: item.product.price,
      ));
    }
    
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final String detailDesc = '${_cartItems.length} Product\n' + _cartItems.map((e) {
      final total = e.quantity * e.product.price;
      return '${e.quantity} ${e.product.name} Rp ${currencyFormat.format(total).replaceAll('Rp ', '').replaceAll(',', '.')}';
    }).join('\n');
    final txId = "tx_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(100)}";
    _recentTransactions.insert(0, TransactionData(
      id: txId,
      product: 'Transaksi Checkout',
      timestamp: timeStr,
      quantity: totalQty,
      unit: 'Botol',
      amount: totalAmount,
      items: localItemsList,
    ));
    
    if (_recentTransactions.length > 20) {
      _recentTransactions = _recentTransactions.sublist(0, 20);
    }

    _recentActivities.insert(0, ActivityLog(
      id: "act_${DateTime.now().millisecondsSinceEpoch}",
      type: "transaction",
      title: "Transaksi Checkout",
      description: '$detailDesc\nTotal Rp ${currencyFormat.format(totalAmount).replaceAll('Rp ', '').replaceAll(',', '.')}',
      timestamp: timeStr,
    ));
    if (_recentActivities.length > 10) {
      _recentActivities.removeLast();
    }

    _totalMonthlyRevenue += totalAmount;
    _transactionsCountToday += _cartItems.length;
    _stockLevel -= (0.5 * totalQty);
    if (_stockLevel < 0) _stockLevel = 0.0;

    await _saveLocalData();
    clearCart();
  }

  // Backwards compatibility for old method
  Future<void> addPOSTransaction(String product, int quantity, String unit, double amount) async {
    // Deprecated. We now use addToCart and checkoutCart
  }

  // Method to add dynamic product to POS catalog menu permanently
  Future<void> addProduct(String name, double price, String imagePath) async {
    String finalImagePath = imagePath;
    if (!imagePath.startsWith('assets/')) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = path.basename(imagePath);
        final savedImage = await File(imagePath).copy('${directory.path}/$fileName');
        finalImagePath = savedImage.path;
      } catch (e) {
        debugPrint('Failed to copy product image: $e');
      }
    }

    _catalogMenu.add(ProductMenu(name: name, price: price, imagePath: finalImagePath));
    await _saveLocalData();
    notifyListeners();
  }

  @override
  void dispose() {
    _boilerSub?.cancel();
    _historySub?.cancel();
    _transactionSub?.cancel();
    _activitySub?.cancel();
    _summarySub?.cancel();
    _inventorySub?.cancel();
    super.dispose();
  }
}
