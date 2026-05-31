class BoilerData {
  final double temperature;
  final String status;

  BoilerData({required this.temperature, required this.status});

  factory BoilerData.fromMap(Map<String, dynamic> map) {
    return BoilerData(
      temperature: (map['temperature'] ?? 32.4).toDouble(),
      status: map['status'] ?? 'NORMAL',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'status': status,
    };
  }
}

class BatchData {
  final String name;
  final String phase;

  BatchData({required this.name, required this.phase});

  factory BatchData.fromMap(Map<String, dynamic> map) {
    return BatchData(
      name: map['name'] ?? 'Ekstrak Temulawak',
      phase: map['phase'] ?? 'Pengecekan rutin otomatis',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phase': phase,
    };
  }
}

class StockData {
  final double weightKg;
  final String materialName;
  final String status;

  StockData({
    required this.weightKg,
    required this.materialName,
    required this.status,
  });

  factory StockData.fromMap(Map<String, dynamic> map) {
    return StockData(
      weightKg: (map['weightKg'] ?? 85.0).toDouble(), // represent percentage or kg
      materialName: map['materialName'] ?? 'Raw Turmeric',
      status: map['status'] ?? '85%',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weightKg': weightKg,
      'materialName': materialName,
      'status': status,
    };
  }
}

class RevenueData {
  final String label; // "Mon", "Tue", etc.
  final double amount; // in Rupiah or Millions

  RevenueData({required this.label, required this.amount});

  factory RevenueData.fromMap(Map<String, dynamic> map) {
    return RevenueData(
      label: map['label'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'amount': amount,
    };
  }
}

class TransactionItem {
  final String name;
  final int quantity;
  final double price;

  TransactionItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      name: map['nama_produk'] ?? map['product'] ?? '',
      quantity: (map['jumlah'] ?? map['quantity'] ?? 1).toInt(),
      price: (map['harga'] ?? map['amount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_produk': name,
      'jumlah': quantity,
      'harga': price,
    };
  }
}

class TransactionData {
  final String id;
  final String product;
  final String timestamp; // e.g., "14:20" or "Kemarin"
  final int quantity;
  final String unit; // "Botol" or "Sachet"
  final double amount; // in Rupiah, e.g. 150000
  final List<TransactionItem> items;

  TransactionData({
    required this.id,
    required this.product,
    required this.timestamp,
    required this.quantity,
    required this.unit,
    required this.amount,
    required this.items,
  });

  factory TransactionData.fromMap(String id, Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((e) => TransactionItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    if (itemsList.isEmpty && map['product'] != null) {
      itemsList.add(TransactionItem(
        name: map['product'] ?? '',
        quantity: (map['quantity'] ?? 1).toInt(),
        price: (map['amount'] ?? 0.0).toDouble(),
      ));
    }

    String productStr = map['product'] ?? '';
    if (itemsList.isNotEmpty) {
      productStr = itemsList.map((e) => '${e.quantity}x ${e.name}').join(', ');
    }

    int totalQty = (map['quantity'] ?? 0).toInt();
    if (totalQty == 0) {
      totalQty = itemsList.fold(0, (sum, item) => sum + item.quantity);
    }

    return TransactionData(
      id: id,
      product: productStr,
      timestamp: map['timestamp'] ?? '',
      quantity: totalQty,
      unit: map['unit'] ?? 'Botol',
      amount: (map['amount'] ?? 0.0).toDouble(),
      items: itemsList,
    );
  }

  factory TransactionData.fromJsonMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((e) => TransactionItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    if (itemsList.isEmpty && map['product'] != null) {
      itemsList.add(TransactionItem(
        name: map['product'] ?? '',
        quantity: (map['quantity'] ?? 1).toInt(),
        price: (map['amount'] ?? 0.0).toDouble(),
      ));
    }

    String productStr = map['product'] ?? '';
    if (itemsList.isNotEmpty) {
      productStr = itemsList.map((e) => '${e.quantity}x ${e.name}').join(', ');
    }

    int totalQty = (map['quantity'] ?? 0).toInt();
    if (totalQty == 0) {
      totalQty = itemsList.fold(0, (sum, item) => sum + item.quantity);
    }

    return TransactionData(
      id: map['id'] ?? '',
      product: productStr,
      timestamp: map['timestamp'] ?? '',
      quantity: totalQty,
      unit: map['unit'] ?? 'Botol',
      amount: (map['amount'] ?? 0.0).toDouble(),
      items: itemsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product,
      'timestamp': timestamp,
      'quantity': quantity,
      'unit': unit,
      'amount': amount,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}

class ActivityLog {
  final String id;
  final String type; // "temp" or "transaction"
  final String title;
  final String description;
  final String timestamp; // "10:00"

  ActivityLog({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  factory ActivityLog.fromMap(String id, Map<String, dynamic> map) {
    return ActivityLog(
      id: id,
      type: map['type'] ?? 'temp',
      title: map['title'] ?? 'Suhu Stabil',
      description: map['description'] ?? 'Semua sensor beroperasi normal',
      timestamp: map['timestamp'] ?? '10:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'timestamp': timestamp,
    };
  }
}

class TemperatureReading {
  final String time; // "10:30"
  final double temperature; // 32.4
  final String status; // "Suhu Stabil" or "Penyesuaian Api"

  TemperatureReading({
    required this.time,
    required this.temperature,
    required this.status,
  });

  factory TemperatureReading.fromMap(Map<String, dynamic> map) {
    return TemperatureReading(
      time: map['time'] ?? '10:30',
      temperature: (map['temperature'] ?? 32.4).toDouble(),
      status: map['status'] ?? 'Suhu Stabil',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'temperature': temperature,
      'status': status,
    };
  }
}

class ProductMenu {
  final String name;
  final double price;
  final String imagePath;

  ProductMenu({
    required this.name,
    required this.price,
    required this.imagePath,
  });

  factory ProductMenu.fromMap(Map<String, dynamic> map) {
    return ProductMenu(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imagePath: map['imagePath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imagePath': imagePath,
    };
  }
}

class CartItem {
  final ProductMenu product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
  
  double get totalAmount => product.price * quantity;
}
