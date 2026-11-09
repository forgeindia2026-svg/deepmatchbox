import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/deeba_models.dart';

class ApiService {
  static const String defaultLiveCloudUrl = 'https://deepmatchbox.onrender.com/api/v1';
  static const String defaultBaseUrl = 'https://deepmatchbox.onrender.com/api/v1';
  static const String defaultLanBaseUrl = 'http://192.168.1.170:8080/api/v1';
  static const String defaultLocalhostUrl = 'http://localhost:8080/api/v1';
  static const String defaultEmulatorBaseUrl = 'http://10.0.2.2:8080/api/v1';

  String baseUrl;

  ApiService({this.baseUrl = defaultBaseUrl});

  void updateBaseUrl(String newUrl) {
    var trimmed = newUrl.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (!trimmed.endsWith('/api/v1')) {
      trimmed = '$trimmed/api/v1';
    }
    baseUrl = trimmed;
  }

  // 1. Health & Connection Check
  Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['status'] == 'UP' && data['databaseConnected'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('ApiService.checkHealth error: $e');
      return false;
    }
  }

  // 2. Database Seeder
  Future<bool> seedDatabase({bool force = false}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/seed?force=$force'),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.seedDatabase error: $e');
      return false;
    }
  }

  // 3. Products
  Future<List<ProductItem>> fetchProducts() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/products'));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) {
          final m = Map<String, dynamic>.from(item);
          return ProductItem(
            id: m['id'] ?? 'PROD-1',
            name: m['name'] ?? 'Product',
            productType: m['tagline'] ?? m['productType'] ?? 'Safety Matches',
            priceCategories: (m['priceCategories'] as List?)?.cast<String>() ??
                ['Rs. 1', 'Rs. 2'],
            bundlePriceByCategory: {
              'Rs. 1': 450.0,
              'Rs. 2': 820.0,
            },
            description: m['description'] ?? '',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchProducts error: $e');
    }
    return [];
  }

  // 4. Materials (6 Sections)
  Future<List<MaterialItem>> fetchMaterials() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/materials'));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) {
          final m = Map<String, dynamic>.from(item);
          MaterialCategory cat;
          final catStr = (m['category'] ?? '').toString();
          switch (catStr) {
            case 'outerBundle':
            case 'outerMaterial':
              cat = MaterialCategory.outerMaterial;
              break;
            case 'innerBundle':
              cat = MaterialCategory.innerBundle;
              break;
            case 'packingCover':
            case 'packageCover':
              cat = MaterialCategory.packageCover;
              break;
            case 'packingBundleSheet':
            case 'bundleSheet':
              cat = MaterialCategory.bundleSheet;
              break;
            case 'labels':
              cat = MaterialCategory.labels;
              break;
            default:
              cat = MaterialCategory.chemical;
              break;
          }

          return MaterialItem(
            id: m['id'] ?? '',
            name: m['name'] ?? '',
            category: cat,
            brandType: m['brand'] ?? 'Common',
            priceCategory: m['categoryOption'] ?? 'Standard',
            unit: m['unit'] ?? 'Bundles',
            purchasePrice: (m['unitPrice'] as num?)?.toDouble() ?? 100.0,
            openingStock: (m['currentStock'] as num?)?.toDouble() ?? 0.0,
            totalPurchased: (m['totalPurchased'] as num?)?.toDouble() ?? 0.0,
            usedQuantity: (m['usedQuantity'] as num?)?.toDouble() ?? 0.0,
            supplier: m['supplier'] ?? 'Supplier',
            lastPurchaseDate: DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchMaterials error: $e');
    }
    return [];
  }

  // 5. Purchases
  Future<List<PurchaseRecord>> fetchPurchases() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/purchases'));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) {
          final m = Map<String, dynamic>.from(item);
          return PurchaseRecord(
            id: m['id'] ?? '',
            materialId: m['materialId'] ?? m['id'] ?? '',
            materialName: m['materialName'] ?? '',
            category: _parseCategory(m['category']),
            quantity: (m['quantity'] as num?)?.toDouble() ?? 0.0,
            unit: m['unit'] ?? 'Bundles',
            purchasePrice: (m['unitPrice'] as num?)?.toDouble() ?? 0.0,
            supplierName: m['supplier'] ?? '',
            purchaseDate: DateTime.now(),
            recordedBy: m['recordedBy'] ?? 'Admin',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchPurchases error: $e');
    }
    return [];
  }

  Future<PurchaseRecord?> createPurchase(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/purchases'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        final m = jsonDecode(res.body);
        return PurchaseRecord(
          id: m['id'] ?? '',
          materialId: m['materialId'] ?? '',
          materialName: m['materialName'] ?? '',
          category: _parseCategory(m['category']),
          quantity: (m['quantity'] as num?)?.toDouble() ?? 0.0,
          unit: m['unit'] ?? 'Bundles',
          purchasePrice: (m['unitPrice'] as num?)?.toDouble() ?? 0.0,
          supplierName: m['supplier'] ?? '',
          purchaseDate: DateTime.now(),
          recordedBy: m['recordedBy'] ?? 'Admin',
        );
      }
    } catch (e) {
      debugPrint('ApiService.createPurchase error: $e');
    }
    return null;
  }

  // 6. Finished Stocks & Transactions
  Future<List<FinishedProductStock>> fetchFinishedStock() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/stock/finished'));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) {
          final m = Map<String, dynamic>.from(item);
          return FinishedProductStock(
            id: m['id'] ?? '',
            productBrand: m['productBrand'] ?? 'Eagle',
            priceCategory: m['priceCategory'] ?? 'Rs. 1',
            openingBalance: (m['openingStock'] as num?)?.toDouble() ?? 0.0,
            quantityProduced: (m['quantityProduced'] as num?)?.toDouble() ?? 0.0,
            quantitySold: (m['quantitySold'] as num?)?.toDouble() ?? 0.0,
            quantityDispatched:
                (m['quantityDispatched'] as num?)?.toDouble() ?? 0.0,
            salePricePerBundle:
                (m['priceCategory'] == 'Rs. 2') ? 800.0 : 450.0,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchFinishedStock error: $e');
    }
    return [];
  }

  Future<List<StockTransaction>> fetchStockTransactions() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/stock/transactions'));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) {
          final m = Map<String, dynamic>.from(item);
          return StockTransaction(
            id: m['id'] ?? '',
            date: DateTime.now(),
            itemName: m['itemName'] ?? '',
            itemType: m['itemType'] ?? 'Finished Product',
            transactionType: m['transactionType'] ?? 'SALE_OUT',
            quantity: (m['quantity'] as num?)?.toDouble() ?? 0.0,
            unit: m['unit'] ?? 'Bundles',
            balanceAfter: (m['balanceAfter'] as num?)?.toDouble() ?? 0.0,
            referenceNote: m['remarks'] ?? '',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchStockTransactions error: $e');
    }
    return [];
  }

  // 7. Sales (Agent, Store, Direct)
  Future<List<SaleRecord>> fetchSales() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/sales'));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) {
          final m = Map<String, dynamic>.from(item);
          CustomerType type;
          final tStr = (m['customerType'] ?? '').toString();
          if (tStr == 'store') {
            type = CustomerType.store;
          } else if (tStr == 'directCustomer') {
            type = CustomerType.directCustomer;
          } else {
            type = CustomerType.agent;
          }

          return SaleRecord(
            id: m['id'] ?? '',
            customerType: type,
            partyName: m['partyName'] ?? '',
            mobileNumber: m['mobileNumber'] ?? '',
            address: m['address'] ?? '',
            productBrand: m['productBrand'] ?? 'Eagle',
            priceCategory: m['priceCategory'] ?? 'Rs. 1',
            quantity: (m['quantity'] as num?)?.toDouble() ?? 0.0,
            salePrice: (m['salePrice'] as num?)?.toDouble() ?? 0.0,
            amountReceived: (m['amountReceived'] as num?)?.toDouble() ?? 0.0,
            salesDate: DateTime.now(),
            recordedBy: m['recordedBy'] ?? 'Admin',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchSales error: $e');
    }
    return [];
  }

  Future<SaleRecord?> createSale(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/sales'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        final m = jsonDecode(res.body);
        CustomerType type = CustomerType.agent;
        if (body['customerType'] == 'store') type = CustomerType.store;
        if (body['customerType'] == 'directCustomer') {
          type = CustomerType.directCustomer;
        }

        return SaleRecord(
          id: m['id'] ?? '',
          customerType: type,
          partyName: m['partyName'] ?? '',
          mobileNumber: m['mobileNumber'] ?? '',
          address: m['address'] ?? '',
          productBrand: m['productBrand'] ?? '',
          priceCategory: m['priceCategory'] ?? '',
          quantity: (m['quantity'] as num?)?.toDouble() ?? 0.0,
          salePrice: (m['salePrice'] as num?)?.toDouble() ?? 0.0,
          amountReceived: (m['amountReceived'] as num?)?.toDouble() ?? 0.0,
          salesDate: DateTime.now(),
          recordedBy: m['recordedBy'] ?? 'Admin',
        );
      }
    } catch (e) {
      debugPrint('ApiService.createSale error: $e');
    }
    return null;
  }

  Future<bool> collectSalePayment(String saleId, double amount) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/sales/$saleId/payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.collectSalePayment error: $e');
      return false;
    }
  }

  // 8. Online Orders
  Future<List<OnlineOrder>> fetchOrders() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/orders')).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) {
          final m = Map<String, dynamic>.from(item);
          DateTime parsedDate = DateTime.now();
          if (m['createdAt'] != null) {
            parsedDate = DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now();
          }
          return OnlineOrder(
            id: m['id'] ?? '',
            customerName: m['customerName'] ?? '',
            mobileNumber: m['mobileNumber'] ?? '',
            address: '${m['address'] ?? ''} ${m['city'] ?? ''}'.trim(),
            productBrand: m['productBrand'] ?? 'Eagle',
            productCategory: m['priceCategory'] ?? 'Rs. 1',
            quantityBundles: (m['quantity'] as num?)?.toInt() ?? 10,
            additionalNotes: m['notes'] ?? '',
            orderDate: parsedDate,
            status: _parseOrderStatus(m['status']),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchOrders error: $e');
    }
    return [];
  }

  Future<OnlineOrder?> placeOrder(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 25));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final m = jsonDecode(res.body);
        DateTime parsedDate = DateTime.now();
        if (m['createdAt'] != null) {
          parsedDate = DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now();
        }
        return OnlineOrder(
          id: m['id'] ?? '',
          customerName: m['customerName'] ?? '',
          mobileNumber: m['mobileNumber'] ?? '',
          address: m['address'] ?? '',
          productBrand: m['productBrand'] ?? '',
          productCategory: m['priceCategory'] ?? 'Rs. 1',
          quantityBundles: (m['quantity'] as num?)?.toInt() ?? 10,
          additionalNotes: m['notes'] ?? '',
          orderDate: parsedDate,
          status: OrderStatus.newOrder,
        );
      } else {
        debugPrint('ApiService.placeOrder failed HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('ApiService.placeOrder error: $e');
    }
    return null;
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      ).timeout(const Duration(seconds: 15));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.updateOrderStatus error: $e');
      return false;
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/orders/$orderId'),
      ).timeout(const Duration(seconds: 15));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.deleteOrder error: $e');
      return false;
    }
  }

  // 9. Workers & Attendance
  Future<List<WorkerModel>> fetchWorkers() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/workers'));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) {
          final m = Map<String, dynamic>.from(item);
          DateTime parsedDate;
          if (m['joiningDate'] != null) {
            parsedDate = DateTime.tryParse(m['joiningDate'].toString()) ?? DateTime.now();
          } else {
            parsedDate = DateTime.now();
          }

          return WorkerModel(
            id: m['id'] ?? '',
            name: m['name'] ?? '',
            mobileNumber: m['mobileNumber']?.toString() ?? '',
            jobType: m['role'] ?? 'Worker',
            joiningDate: parsedDate,
            salaryType: m['salaryType'] == 'monthly'
                ? SalaryType.monthly
                : SalaryType.daily,
            salaryAmount: (m['salaryRate'] as num?)?.toDouble() ?? 500.0,
            paidSalaryAmount: (m['paidSalary'] as num?)?.toDouble() ?? 0.0,
            isActive: m['active'] != false,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchWorkers error: $e');
    }
    return [];
  }

  Future<bool> createWorker(Map<String, dynamic> workerData) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/workers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(workerData),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.createWorker error: $e');
      return false;
    }
  }

  Future<bool> deleteWorker(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/workers/$id'));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.deleteWorker error: $e');
      return false;
    }
  }

  Future<bool> clearAllWorkers() async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/workers'));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.clearAllWorkers error: $e');
      return false;
    }
  }

  Future<bool> resetWorkerSalaries() async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/workers/reset-salaries'));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.resetWorkerSalaries error: $e');
      return false;
    }
  }

  Future<bool> payWorkerSalary(String workerId, double amount) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/workers/$workerId/pay'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.payWorkerSalary error: $e');
      return false;
    }
  }

  // 12. Daily Factory Sheets (Paper Slip Digitization)
  Future<List<DailyProductionSheet>> fetchDailySheets() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/daily-sheets'));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list
            .map((item) =>
                DailyProductionSheet.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchDailySheets error: $e');
    }
    return [];
  }

  Future<DailyProductionSheet?> fetchTodayDailySheet() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/daily-sheets/today'));
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        return DailyProductionSheet.fromJson(data);
      }
    } catch (e) {
      debugPrint('ApiService.fetchTodayDailySheet error: $e');
    }
    return null;
  }

  Future<bool> saveDailySheet(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/daily-sheets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.saveDailySheet error: $e');
      return false;
    }
  }

  // Production Records
  Future<List<ProductionRecord>> fetchProductionRecords() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/production'));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) {
          final m = Map<String, dynamic>.from(item);
          return ProductionRecord(
            id: m['id'] ?? '',
            productionDate:
                DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
            productBrand: m['productBrand'] ?? 'Eagle',
            priceCategory: m['priceCategory'] ?? 'Rs. 1',
            quantityProduced: ((m['quantityProduced'] ??
                    m['totalBundlesProduced']) as num?)
                    ?.toDouble() ??
                0.0,
            materialsUsed: [],
            staffResponsible: m['staffResponsible'] ?? 'Floor Supervisor',
            notes: m['notes'] ?? '',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchProductionRecords error: $e');
    }
    return [];
  }

  Future<bool> createProduction(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/production'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.createProduction error: $e');
      return false;
    }
  }

  // Attendance & Daily Work
  Future<List<WorkerDailyRecord>> fetchAttendance() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/attendance'));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) {
          final m = Map<String, dynamic>.from(item);
          final statusStr = (m['attendanceStatus'] ?? m['status'] ?? 'present')
              .toString()
              .toLowerCase();
          AttendanceStatus st = AttendanceStatus.present;
          if (statusStr.contains('half')) st = AttendanceStatus.halfDay;
          if (statusStr.contains('absent')) st = AttendanceStatus.absent;

          return WorkerDailyRecord(
            id: m['id'] ?? '',
            workerId: m['workerId'] ?? '',
            workerName: m['workerName'] ?? '',
            date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
            attendanceStatus: st,
            workPerformed: WorkType.production,
            notes: m['notes'] ?? '',
            markedBy: m['markedBy'] ?? 'Staff',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchAttendance error: $e');
    }
    return [];
  }

  Future<bool> markAttendance(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.markAttendance error: $e');
      return false;
    }
  }

  // 14. AUTHENTICATION & STAFF USER ACCOUNTS
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {'success': false, 'message': 'HTTP ${res.statusCode}: ${res.body}'};
    } catch (e) {
      debugPrint('ApiService.login error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String username,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('ApiService.changePassword error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<List<UserModel>> fetchUsers() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/users'));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list
            .map((item) => UserModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchUsers error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('ApiService.createUser error: $e');
      return {'success': false, 'message': 'Failed to create user: $e'};
    }
  }

  Future<Map<String, dynamic>> updateUser(
      String id, Map<String, dynamic> updates) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updates),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('ApiService.updateUser error: $e');
      return {'success': false, 'message': 'Failed to update user: $e'};
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/users/$id'));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.deleteUser error: $e');
      return false;
    }
  }

  // Helpers
  MaterialCategory _parseCategory(dynamic cat) {
    final s = cat.toString().toLowerCase();
    if (s.contains('outer')) return MaterialCategory.outerMaterial;
    if (s.contains('inner')) return MaterialCategory.innerBundle;
    if (s.contains('cover')) return MaterialCategory.packageCover;
    if (s.contains('sheet')) return MaterialCategory.bundleSheet;
    if (s.contains('label')) return MaterialCategory.labels;
    return MaterialCategory.chemical;
  }

  OrderStatus _parseOrderStatus(dynamic st) {
    final s = st.toString().toLowerCase();
    if (s.contains('confirm')) return OrderStatus.confirmed;
    if (s.contains('process')) return OrderStatus.processing;
    if (s.contains('complete')) return OrderStatus.completed;
    if (s.contains('cancel')) return OrderStatus.cancelled;
    return OrderStatus.newOrder;
  }
}
