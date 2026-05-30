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

class TransactionData {
  final String id;
  final String product;
  final String timestamp; // e.g., "14:20" or "Kemarin"
  final int quantity;
  final String unit; // "Botol" or "Sachet"
  final double amount; // in Rupiah, e.g. 150000

  TransactionData({
    required this.id,
    required this.product,
    required this.timestamp,
    required this.quantity,
    required this.unit,
    required this.amount,
  });

  factory TransactionData.fromMap(String id, Map<String, dynamic> map) {
    return TransactionData(
      id: id,
      product: map['product'] ?? 'Ekstrak Temulawak',
      timestamp: map['timestamp'] ?? '',
      quantity: (map['quantity'] ?? 1).toInt(),
      unit: map['unit'] ?? 'Botol',
      amount: (map['amount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product': product,
      'timestamp': timestamp,
      'quantity': quantity,
      'unit': unit,
      'amount': amount,
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
}
