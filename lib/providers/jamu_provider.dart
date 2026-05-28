import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import '../models/jamu_models.dart';

class JamuProvider with ChangeNotifier {
  // State Data
  BoilerData _boilerData = BoilerData(temperature: 32.4, status: 'NORMAL');
  double _targetTemperature = 32.5;
  String _lastUpdatedTime = "10:30 WIB";
  
  double _totalMonthlyRevenue = 12450000.0;
  double _revenuePercentageIncrease = 15.0;
  double _stockLevel = 85.0; // 85%
  int _transactionsCountToday = 42;
  bool _isIotConnected = true;

  List<TemperatureReading> _tempHistory = [];
  List<TransactionData> _recentTransactions = [];
  List<ActivityLog> _recentActivities = [];

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

  bool get isFirebaseConnected => _isFirebaseConnected;
  bool get isLoading => _isLoading;

  // Firebase Subscriptions
  StreamSubscription? _boilerSub;
  StreamSubscription? _historySub;
  StreamSubscription? _transactionSub;
  StreamSubscription? _activitySub;
  StreamSubscription? _summarySub;
  StreamSubscription? _inventorySub;

  // Local Simulation tools
  Timer? _simulationTimer;
  final Random _random = Random();

  JamuProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _setupFirebaseStreams();
      } else {
        _startSimulation();
      }
    } catch (e) {
      debugPrint('Failed to connect to Firebase, fallback to simulation mode: $e');
      _startSimulation();
    }
  }

  // Set up Firebase listeners
  void _setupFirebaseStreams() {
    final firestore = FirebaseFirestore.instance;
    _isFirebaseConnected = true;
    _isLoading = false;
    notifyListeners();

    // 1. Stream Boiler Data
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
      } else {
        // Jika dokumen boiler tidak ada, asumsi database masih kosong. Seed data!
        seedFirebaseInitialData();
      }
    }, onError: (e) => debugPrint('Error boiler stream: $e'));

    // 2. Stream Temperature History (Limit 15, newest first)
    _historySub = firestore.collection('temperature_history')
        .orderBy('timestamp', descending: true)
        .limit(15)
        .snapshots()
        .listen((snapshot) {
      _tempHistory = snapshot.docs.map((doc) => TemperatureReading.fromMap(doc.data())).toList();
      notifyListeners();
    }, onError: (e) => debugPrint('Error temp history stream: $e'));

    // 3. Stream Transactions (Limit 15, newest first)
    _transactionSub = firestore.collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(15)
        .snapshots()
        .listen((snapshot) {
      _recentTransactions = snapshot.docs.map((doc) {
        final data = doc.data();
        // format timestamp for display
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

    // 4. Stream Activities (Limit 10, newest first)
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

    // 5. Stream Revenue Summary
    _summarySub = firestore.collection('revenue').doc('summary').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        _totalMonthlyRevenue = (doc.data()?['totalMonthlyRevenue'] ?? 12450000.0).toDouble();
        _revenuePercentageIncrease = (doc.data()?['percentChange'] ?? 15.0).toDouble();
        _transactionsCountToday = (doc.data()?['transactionsCountToday'] ?? 42).toInt();
        notifyListeners();
      }
    }, onError: (e) => debugPrint('Error revenue summary stream: $e'));

    // 6. Stream Inventory Stock
    _inventorySub = firestore.collection('inventory').doc('turmeric').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        _stockLevel = (doc.data()?['stockPercentage'] ?? 85.0).toDouble();
        _isIotConnected = doc.data()?['iotConnected'] ?? true;
        notifyListeners();
      }
    }, onError: (e) => debugPrint('Error inventory stream: $e'));
  }

  // Populate mock data and start simulated updates
  void _startSimulation() {
    _isFirebaseConnected = false;
    _isLoading = false;

    // Load initial mockup data
    _totalMonthlyRevenue = 12450000.0;
    _revenuePercentageIncrease = 15.0;
    _stockLevel = 85.0;
    _transactionsCountToday = 42;
    _isIotConnected = true;

    // Mock Temperature History
    _tempHistory = [
      TemperatureReading(time: "10:30 WIB", temperature: 32.4, status: "Suhu Stabil"),
      TemperatureReading(time: "10:15 WIB", temperature: 32.2, status: "Suhu Stabil"),
      TemperatureReading(time: "10:00 WIB", temperature: 31.8, status: "Penyesuaian Api"),
      TemperatureReading(time: "09:45 WIB", temperature: 32.1, status: "Suhu Stabil"),
      TemperatureReading(time: "09:30 WIB", temperature: 30.5, status: "Inisiasi Proses"),
    ];

    // Mock Transactions
    _recentTransactions = [
      TransactionData(id: "tx1", product: "Ekstrak Temulawak", timestamp: "14:20", quantity: 2, unit: "Botol", amount: 150000),
      TransactionData(id: "tx2", product: "Jahe Merah Instan", timestamp: "12:05", quantity: 5, unit: "Sachet", amount: 75000),
      TransactionData(id: "tx3", product: "Ekstrak Temulawak", timestamp: "Kemarin", quantity: 1, unit: "Botol", amount: 75000),
    ];

    // Mock Activities
    _recentActivities = [
      ActivityLog(id: "act1", type: "temp", title: "Suhu Stabil", description: "Semua sensor beroperasi normal", timestamp: "10:00"),
      ActivityLog(id: "act2", type: "transaction", title: "Transaksi Baru", description: "Order #TRX-8829 Berhasil", timestamp: "09:45"),
      ActivityLog(id: "act3", type: "temp", title: "Suhu Stabil", description: "Pengecekan rutin otomatis", timestamp: "09:00"),
    ];

    notifyListeners();

    // Simulated IoT timer: updates temperature slowly every 4 seconds
    _simulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      double change = (_random.nextDouble() - 0.5) * 0.4;
      double newTemp = double.parse((_boilerData.temperature + change).toStringAsFixed(1));

      // Keep it within a realistic range
      if (newTemp < 30.0) newTemp = 30.5;
      if (newTemp > 35.0) newTemp = 34.5;

      String status = "Suhu Stabil";
      if (newTemp > 33.5) {
        status = "Overheat Ringan";
      } else if (newTemp < 31.0) {
        status = "Penyesuaian Api";
      }

      _boilerData = BoilerData(temperature: newTemp, status: status);
      _lastUpdatedTime = DateFormat('HH:mm').format(DateTime.now()) + " WIB";

      // Append reading to temp history
      _tempHistory.insert(0, TemperatureReading(
        time: _lastUpdatedTime,
        temperature: newTemp,
        status: status,
      ));
      if (_tempHistory.length > 20) {
        _tempHistory.removeLast();
      }

      // Randomly trigger auto-check activities
      if (_random.nextDouble() < 0.15) {
        _recentActivities.insert(0, ActivityLog(
          id: "act_${DateTime.now().millisecondsSinceEpoch}",
          type: "temp",
          title: "Suhu Stabil",
          description: _random.nextBool() ? "Pengecekan rutin otomatis" : "Semua sensor beroperasi normal",
          timestamp: DateFormat('HH:mm').format(DateTime.now()),
        ));
        if (_recentActivities.length > 10) {
          _recentActivities.removeLast();
        }
      }

      notifyListeners();
    });
  }

  // Method to add new POS Transaction
  Future<void> addPOSTransaction(String product, int quantity, String unit, double amount) async {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);

    if (_isFirebaseConnected) {
      try {
        final firestore = FirebaseFirestore.instance;
        final batch = firestore.batch();

        // 1. Add to transaction log
        final txRef = firestore.collection('transactions').doc();
        batch.set(txRef, {
          'product': product,
          'quantity': quantity,
          'unit': unit,
          'amount': amount,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 2. Add to Activity log
        final actRef = firestore.collection('activities').doc();
        batch.set(actRef, {
          'type': 'transaction',
          'title': 'Transaksi Baru',
          'description': 'Order $product x$quantity Berhasil',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 3. Update summary
        final summaryRef = firestore.collection('revenue').doc('summary');
        batch.set(summaryRef, {
          'totalMonthlyRevenue': FieldValue.increment(amount),
          'transactionsCountToday': FieldValue.increment(1),
        }, SetOptions(merge: true));

        // 4. Slightly decrement stock percentage (simulating inventory usage, e.g. -0.5% per item)
        final invRef = firestore.collection('inventory').doc('turmeric');
        double stockChange = -0.5 * quantity;
        batch.set(invRef, {
          'stockPercentage': FieldValue.increment(stockChange < -10 ? -10.0 : stockChange),
        }, SetOptions(merge: true));

        await batch.commit();
      } catch (e) {
        debugPrint("Error pushing transaction to Firebase, writing locally: $e");
        _addTransactionLocally(product, quantity, unit, amount, timeStr);
      }
    } else {
      _addTransactionLocally(product, quantity, unit, amount, timeStr);
    }
  }

  void _addTransactionLocally(String product, int quantity, String unit, double amount, String timeStr) {
    // 1. Add to transaction list
    final txId = "tx_${DateTime.now().millisecondsSinceEpoch}";
    _recentTransactions.insert(0, TransactionData(
      id: txId,
      product: product,
      timestamp: timeStr,
      quantity: quantity,
      unit: unit,
      amount: amount,
    ));
    if (_recentTransactions.length > 20) {
      _recentTransactions.removeLast();
    }

    // 2. Add to activities log
    final actId = "act_${DateTime.now().millisecondsSinceEpoch}";
    _recentActivities.insert(0, ActivityLog(
      id: actId,
      type: "transaction",
      title: "Transaksi Baru",
      description: "Order $product x$quantity Berhasil",
      timestamp: timeStr,
    ));
    if (_recentActivities.length > 10) {
      _recentActivities.removeLast();
    }

    // 3. Update counters
    _totalMonthlyRevenue += amount;
    _transactionsCountToday += 1;

    // 4. Decrement stock level
    _stockLevel -= (0.5 * quantity);
    if (_stockLevel < 0) _stockLevel = 0.0;

    notifyListeners();
  }

  // Utility to seed initial dummy data to Cloud Firestore if connected
  Future<void> seedFirebaseInitialData() async {
    if (!_isFirebaseConnected) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // Seed boiler
      batch.set(firestore.collection('monitoring').doc('boiler'), {
        'temperature': 32.4,
        'status': 'NORMAL',
        'targetTemperature': 32.5,
        'lastUpdated': '10:30 WIB',
      });

      // Seed summary
      batch.set(firestore.collection('revenue').doc('summary'), {
        'totalMonthlyRevenue': 12450000.0,
        'percentChange': 15.0,
        'transactionsCountToday': 42,
      });

      // Seed stock
      batch.set(firestore.collection('inventory').doc('turmeric'), {
        'stockPercentage': 85.0,
        'iotConnected': true,
      });

      // Seed historical temperatures
      final List<Map<String, dynamic>> mockHistory = [
        {'time': '10:30 WIB', 'temperature': 32.4, 'status': 'Suhu Stabil', 'timestamp': DateTime.now().subtract(const Duration(minutes: 0))},
        {'time': '10:15 WIB', 'temperature': 32.2, 'status': 'Suhu Stabil', 'timestamp': DateTime.now().subtract(const Duration(minutes: 15))},
        {'time': '10:00 WIB', 'temperature': 31.8, 'status': 'Penyesuaian Api', 'timestamp': DateTime.now().subtract(const Duration(minutes: 30))},
        {'time': '09:45 WIB', 'temperature': 32.1, 'status': 'Suhu Stabil', 'timestamp': DateTime.now().subtract(const Duration(minutes: 45))},
        {'time': '09:30 WIB', 'temperature': 30.5, 'status': 'Inisiasi Proses', 'timestamp': DateTime.now().subtract(const Duration(minutes: 60))},
      ];

      for (var index = 0; index < mockHistory.length; index++) {
        final docRef = firestore.collection('temperature_history').doc("temp_hist_$index");
        batch.set(docRef, mockHistory[index]);
      }

      // Seed activities
      final List<Map<String, dynamic>> mockActs = [
        {'type': 'temp', 'title': 'Suhu Stabil', 'description': 'Semua sensor beroperasi normal', 'timestamp': DateTime.now().subtract(const Duration(minutes: 5))},
        {'type': 'transaction', 'title': 'Transaksi Baru', 'description': 'Order #TRX-8829 Berhasil', 'timestamp': DateTime.now().subtract(const Duration(minutes: 20))},
        {'type': 'temp', 'title': 'Suhu Stabil', 'description': 'Pengecekan rutin otomatis', 'timestamp': DateTime.now().subtract(const Duration(minutes: 65))},
      ];

      for (var index = 0; index < mockActs.length; index++) {
        final docRef = firestore.collection('activities').doc("act_$index");
        batch.set(docRef, mockActs[index]);
      }

      // Seed transactions
      final List<Map<String, dynamic>> mockTxs = [
        {'product': 'Ekstrak Temulawak', 'quantity': 2, 'unit': 'Botol', 'amount': 150000.0, 'timestamp': DateTime.now().subtract(const Duration(hours: 1))},
        {'product': 'Jahe Merah Instan', 'quantity': 5, 'unit': 'Sachet', 'amount': 75000.0, 'timestamp': DateTime.now().subtract(const Duration(hours: 3))},
        {'product': 'Ekstrak Temulawak', 'quantity': 1, 'unit': 'Botol', 'amount': 75000.0, 'timestamp': DateTime.now().subtract(const Duration(days: 1))},
      ];

      for (var index = 0; index < mockTxs.length; index++) {
        final docRef = firestore.collection('transactions').doc("tx_$index");
        batch.set(docRef, mockTxs[index]);
      }

      await batch.commit();
      debugPrint("Firebase Database successfully seeded with mockup defaults!");
    } catch (e) {
      debugPrint("Failed to seed initial data: $e");
    }
  }

  @override
  void dispose() {
    _boilerSub?.cancel();
    _historySub?.cancel();
    _transactionSub?.cancel();
    _activitySub?.cancel();
    _summarySub?.cancel();
    _inventorySub?.cancel();
    _simulationTimer?.cancel();
    super.dispose();
  }
}
