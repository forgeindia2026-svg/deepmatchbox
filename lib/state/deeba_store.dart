import 'package:flutter/foundation.dart';
import '../models/deeba_models.dart';
import '../services/api_service.dart';

class DeebaStore extends ChangeNotifier {
  final ApiService api = ApiService();
  bool isApiConnected = false;
  bool isSyncing = false;
  String syncStatusMessage = '';

  UserRole _currentRole = UserRole.customer;
  String _loggedInUserName = 'Guest Customer';

  UserRole get currentRole => _currentRole;
  String get loggedInUserName => _loggedInUserName;
  String _loggedInUserUsername = 'guest';
  String get loggedInUserUsername => _loggedInUserUsername;

  // Dynamic master lists (Admin can add more brands or price categories anytime)
  final List<String> brandTypes = ['Eagle', 'Pulli', 'Joker'];
  final List<String> priceCategories = ['Rs. 1', 'Rs. 2'];

  List<ProductItem> products = [];
  List<MaterialItem> materials = [];
  List<PurchaseRecord> purchases = [];
  List<ProductionRecord> productionRecords = [];
  List<FinishedProductStock> finishedStocks = [];
  List<StockTransaction> stockTransactions = [];
  List<OnlineOrder> onlineOrders = [];
  List<SaleRecord> sales = [];
  List<WorkerModel> workers = [];
  List<WorkerDailyRecord> dailyRecords = [];
  final List<ContactInquiry> contactInquiries = [];
  List<DailyProductionSheet> dailySheets = [];
  DailyProductionSheet? todayDailySheet;
  List<UserModel> systemUsers = [];

  DeebaStore() {
    _seedInitialData();
    loadLiveFromBackend();
  }

  Future<void> loadLiveFromBackend() async {
    isSyncing = true;
    notifyListeners();
    try {
      final healthy = await api.checkHealth();
      if (healthy) {
        isApiConnected = true;
        final prods = await api.fetchProducts();
        final mats = await api.fetchMaterials();
        final purs = await api.fetchPurchases();
        final stocks = await api.fetchFinishedStock();
        final sls = await api.fetchSales();
        final ords = await api.fetchOrders();
        final wrks = await api.fetchWorkers();
        final txns = await api.fetchStockTransactions();
        final sheets = await api.fetchDailySheets();
        final todaySheet = await api.fetchTodayDailySheet();
        final prdRecs = await api.fetchProductionRecords();
        final attRecs = await api.fetchAttendance();
        final usrs = await api.fetchUsers();

        if (prods.isNotEmpty) products = prods;
        if (mats.isNotEmpty) materials = mats;
        purchases = purs;
        if (stocks.isNotEmpty) finishedStocks = stocks;
        sales = sls;
        onlineOrders = ords;
        workers = wrks;
        stockTransactions = txns;
        dailySheets = sheets;
        todayDailySheet = todaySheet;
        if (prdRecs.isNotEmpty) productionRecords = prdRecs;
        if (attRecs.isNotEmpty) dailyRecords = attRecs;
        if (usrs.isNotEmpty) systemUsers = usrs;
        syncStatusMessage = 'Live Connected to MongoDB (deeba_match_house)';
      } else {
        isApiConnected = false;
        syncStatusMessage = 'Backend offline. Tap to reconnect.';
      }
    } catch (e) {
      isApiConnected = false;
      syncStatusMessage = 'Error connecting to backend: $e';
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> updateServerUrl(String newUrl) async {
    api.updateBaseUrl(newUrl);
    isSyncing = true;
    notifyListeners();
    final healthy = await api.checkHealth();
    if (healthy) {
      await loadLiveFromBackend();
      return true;
    } else {
      isApiConnected = false;
      syncStatusMessage = 'Could not reach server at ${api.baseUrl}';
      isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  void switchRole(UserRole role, {String? userName}) {
    _currentRole = role;
    if (userName != null) {
      _loggedInUserName = userName;
    } else {
      switch (role) {
        case UserRole.customer:
          _loggedInUserName = 'Guest Customer';
        case UserRole.admin:
          _loggedInUserName = 'Deeba Admin';
        case UserRole.staff:
          _loggedInUserName = 'Ramesh (Production & Floor Staff)';
      }
    }
    notifyListeners();
  }

  bool loginWithCredentials(String username, String password) {
    final u = username.trim().toLowerCase();
    final p = password.trim();
    if ((u == 'admin' || u == 'admin@deeba.com') && p == 'admin123') {
      _loggedInUserUsername = 'admin';
      switchRole(UserRole.admin, userName: 'Deeba Admin');
      return true;
    }
    if ((u == 'staff' || u == 'staff@deeba.com') && p == 'staff123') {
      _loggedInUserUsername = 'staff';
      switchRole(UserRole.staff, userName: 'Ramesh (Floor Supervisor)');
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> loginOnline(
      String username, String password) async {
    final res = await api.login(username, password);
    if (res['success'] == true) {
      final roleStr = (res['role'] ?? 'staff').toString().toLowerCase();
      final userRole = roleStr == 'admin' ? UserRole.admin : UserRole.staff;
      final name = res['userName']?.toString() ?? username;
      _loggedInUserUsername = res['username']?.toString() ?? username;
      switchRole(userRole, userName: name);
      await reloadUsers();
      return {'success': true, 'role': userRole, 'name': name};
    }

    // Local fallback if server unreachable or offline
    final localOk = loginWithCredentials(username, password);
    if (localOk) {
      return {
        'success': true,
        'role': _currentRole,
        'name': _loggedInUserName,
        'isLocal': true,
      };
    }
    return {
      'success': false,
      'message': res['message'] ?? 'Invalid username or password.',
    };
  }

  Future<Map<String, dynamic>> changeMyPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await api.changePassword(
      username: _loggedInUserUsername,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  Future<void> reloadUsers() async {
    try {
      final list = await api.fetchUsers();
      if (list.isNotEmpty) {
        systemUsers = list;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>> addSystemUser(Map<String, dynamic> data) async {
    final res = await api.createUser(data);
    if (res['success'] == true) {
      await reloadUsers();
    }
    return res;
  }

  Future<Map<String, dynamic>> updateSystemUser(
      String id, Map<String, dynamic> data) async {
    final res = await api.updateUser(id, data);
    if (res['success'] == true) {
      await reloadUsers();
    }
    return res;
  }

  Future<bool> deleteSystemUser(String id) async {
    final ok = await api.deleteUser(id);
    if (ok) {
      systemUsers.removeWhere((u) => u.id == id);
      notifyListeners();
    }
    return ok;
  }

  void logout() {
    _currentRole = UserRole.customer;
    _loggedInUserName = 'Guest Customer';
    _loggedInUserUsername = 'guest';
    notifyListeners();
  }

  void addBrandType(String newBrand) {
    final trimmed = newBrand.trim();
    if (trimmed.isNotEmpty && !brandTypes.contains(trimmed)) {
      brandTypes.add(trimmed);
      for (final cat in priceCategories) {
        finishedStocks.add(
          FinishedProductStock(
            id: 'FP-${finishedStocks.length + 1}',
            productBrand: trimmed,
            priceCategory: cat,
            openingBalance: 0,
            quantityProduced: 0,
            salePricePerBundle: cat == 'Rs. 1' ? 450 : 820,
          ),
        );
      }
      notifyListeners();
    }
  }

  void addPriceCategory(String newCat) {
    final trimmed = newCat.trim();
    if (trimmed.isNotEmpty && !priceCategories.contains(trimmed)) {
      priceCategories.add(trimmed);
      notifyListeners();
    }
  }

  // ==================== DASHBOARD KPI GETTERS ====================
  int get totalOnlineOrdersCount => onlineOrders.length;
  int get newOnlineOrdersCount =>
      onlineOrders.where((o) => o.status == OrderStatus.newOrder).length;

  double get totalPurchaseAmount =>
      purchases.fold(0.0, (sum, p) => sum + p.totalAmount);

  double get totalRawMaterialItemsCount =>
      materials.where((m) => m.isActive).length.toDouble();

  double get totalRawMaterialStockValue => materials
      .where((m) => m.isActive)
      .fold(0.0, (sum, m) => sum + m.totalStockValue);

  double get totalFinishedBundlesStock =>
      finishedStocks.fold(0.0, (sum, f) => sum + f.currentBalance);

  double get totalProductionBundles =>
      productionRecords.fold(0.0, (sum, p) => sum + p.quantityProduced);

  double get totalSalesAmount =>
      sales.fold(0.0, (sum, s) => sum + s.totalAmount);

  double get agentSalesAmount => sales
      .where((s) => s.customerType == CustomerType.agent)
      .fold(0.0, (sum, s) => sum + s.totalAmount);

  double get storeSalesAmount => sales
      .where((s) => s.customerType == CustomerType.store)
      .fold(0.0, (sum, s) => sum + s.totalAmount);

  double get directSalesAmount => sales
      .where((s) => s.customerType == CustomerType.directCustomer)
      .fold(0.0, (sum, s) => sum + s.totalAmount);

  double get totalPendingPayments =>
      sales.fold(0.0, (sum, s) => sum + s.pendingAmount);

  int get totalActiveWorkers => workers.where((w) => w.isActive).length;

  int get todayPresentWorkersCount {
    final now = DateTime.now();
    return dailyRecords
        .where(
          (r) =>
              r.date.year == now.year &&
              r.date.month == now.month &&
              r.date.day == now.day &&
              (r.attendanceStatus == AttendanceStatus.present ||
                  r.attendanceStatus == AttendanceStatus.halfDay),
        )
        .length;
  }

  List<MaterialItem> get lowStockMaterials =>
      materials.where((m) => m.isLowStock).toList();

  // ==================== CUSTOMER ACTIONS ====================
  void placeOnlineOrder({
    required String customerName,
    required String mobileNumber,
    required String address,
    required String productBrand,
    required String productCategory,
    required int quantityBundles,
    String additionalNotes = '',
  }) {
    final order = OnlineOrder(
      id: 'ORD-${1001 + onlineOrders.length}',
      customerName: customerName,
      mobileNumber: mobileNumber,
      address: address,
      productBrand: productBrand,
      productCategory: productCategory,
      quantityBundles: quantityBundles,
      additionalNotes: additionalNotes,
      orderDate: DateTime.now(),
      status: OrderStatus.newOrder,
    );
    onlineOrders.insert(0, order);
    if (isApiConnected) {
      api.placeOrder({
        'customerName': customerName,
        'mobileNumber': mobileNumber,
        'address': address,
        'productBrand': productBrand,
        'priceCategory': productCategory,
        'quantity': quantityBundles,
        'notes': additionalNotes,
      });
    }
    notifyListeners();
  }

  void submitContactInquiry({
    required String name,
    required String phone,
    required String email,
    required String message,
  }) {
    contactInquiries.insert(
      0,
      ContactInquiry(
        id: 'INQ-${contactInquiries.length + 1}',
        name: name,
        phone: phone,
        email: email,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // ==================== ADMIN / STAFF ACTIONS ====================
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final idx = onlineOrders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      onlineOrders[idx].status = newStatus;
      if (isApiConnected) {
        api.updateOrderStatus(orderId, newStatus.label);
      }
      notifyListeners();
    }
  }

  void addOrUpdateProduct(ProductItem product) {
    final idx = products.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      products[idx] = product;
    } else {
      products.add(product);
      if (!brandTypes.contains(product.name)) {
        brandTypes.add(product.name);
      }
      for (final cat in product.priceCategories) {
        final exists = finishedStocks.any(
          (f) => f.productBrand == product.name && f.priceCategory == cat,
        );
        if (!exists) {
          finishedStocks.add(
            FinishedProductStock(
              id: 'FP-${finishedStocks.length + 1}',
              productBrand: product.name,
              priceCategory: cat,
              openingBalance: 0,
              quantityProduced: 0,
              salePricePerBundle: product.bundlePriceByCategory[cat] ?? 450,
            ),
          );
        }
      }
    }
    notifyListeners();
  }

  void addOrUpdateMaterial(MaterialItem material) {
    final idx = materials.indexWhere((m) => m.id == material.id);
    if (idx != -1) {
      materials[idx] = material;
    } else {
      materials.add(material);
    }
    notifyListeners();
  }

  void toggleMaterialActive(String materialId) {
    final idx = materials.indexWhere((m) => m.id == materialId);
    if (idx != -1) {
      materials[idx].isActive = !materials[idx].isActive;
      notifyListeners();
    }
  }

  void recordPurchase({
    required String materialId,
    required double quantity,
    required double purchasePrice,
    required String supplierName,
    required DateTime purchaseDate,
    String notes = '',
  }) {
    final matIdx = materials.indexWhere((m) => m.id == materialId);
    if (matIdx == -1) return;
    final mat = materials[matIdx];

    // Update material stock & latest editable purchase price
    mat.totalPurchased += quantity;
    mat.purchasePrice = purchasePrice;
    mat.supplier = supplierName;
    mat.lastPurchaseDate = purchaseDate;

    final purchase = PurchaseRecord(
      id: 'PUR-${101 + purchases.length}',
      materialId: mat.id,
      materialName: mat.name,
      category: mat.category,
      quantity: quantity,
      unit: mat.unit,
      purchasePrice: purchasePrice,
      supplierName: supplierName,
      purchaseDate: purchaseDate,
      notes: notes,
      recordedBy: _loggedInUserName,
    );
    purchases.insert(0, purchase);

    stockTransactions.insert(
      0,
      StockTransaction(
        id: 'TXN-${1001 + stockTransactions.length}',
        date: purchaseDate,
        itemName: mat.name,
        itemType: 'Raw Material',
        transactionType: 'PURCHASE_IN',
        quantity: quantity,
        unit: mat.unit,
        balanceAfter: mat.currentBalance,
        referenceNote: 'Purchase from $supplierName (${purchase.id})',
      ),
    );
    if (isApiConnected) {
      api.createPurchase({
        'materialId': mat.id,
        'materialName': mat.name,
        'category': mat.category.name,
        'quantity': quantity,
        'unit': mat.unit,
        'unitPrice': purchasePrice,
        'supplier': supplierName,
        'recordedBy': _loggedInUserName,
        'notes': notes,
      });
    }
    notifyListeners();
  }

  void recordProduction({
    required DateTime productionDate,
    required String productBrand,
    required String priceCategory,
    required double quantityProduced,
    required List<MaterialUsageItem> materialsUsed,
    required String staffResponsible,
    String notes = '',
  }) {
    final prodId = 'PROD-${101 + productionRecords.length}';

    // 1. Decrease raw material stock
    for (final usage in materialsUsed) {
      final mIdx = materials.indexWhere((m) => m.id == usage.materialId);
      if (mIdx != -1) {
        final mat = materials[mIdx];
        mat.usedQuantity += usage.quantityUsed;
        stockTransactions.insert(
          0,
          StockTransaction(
            id: 'TXN-${1001 + stockTransactions.length}',
            date: productionDate,
            itemName: mat.name,
            itemType: 'Raw Material',
            transactionType: 'PRODUCTION_USE',
            quantity: -usage.quantityUsed,
            unit: mat.unit,
            balanceAfter: mat.currentBalance,
            referenceNote:
                'Used for $productBrand ($priceCategory) [$prodId]',
          ),
        );
      }
    }

    // 2. Increase finished product stock
    var fpIdx = finishedStocks.indexWhere(
      (f) =>
          f.productBrand == productBrand && f.priceCategory == priceCategory,
    );
    if (fpIdx == -1) {
      finishedStocks.add(
        FinishedProductStock(
          id: 'FP-${finishedStocks.length + 1}',
          productBrand: productBrand,
          priceCategory: priceCategory,
          openingBalance: 0,
          quantityProduced: quantityProduced,
          salePricePerBundle: priceCategory == 'Rs. 1' ? 450 : 820,
        ),
      );
      fpIdx = finishedStocks.length - 1;
    } else {
      finishedStocks[fpIdx].quantityProduced += quantityProduced;
    }

    final fp = finishedStocks[fpIdx];
    stockTransactions.insert(
      0,
      StockTransaction(
        id: 'TXN-${1001 + stockTransactions.length}',
        date: productionDate,
        itemName: fp.fullName,
        itemType: 'Finished Product',
        transactionType: 'PRODUCTION_OUT',
        quantity: quantityProduced,
        unit: 'Bundles',
        balanceAfter: fp.currentBalance,
        referenceNote: 'Produced by $staffResponsible [$prodId]',
      ),
    );

    productionRecords.insert(
      0,
      ProductionRecord(
        id: prodId,
        productionDate: productionDate,
        productBrand: productBrand,
        priceCategory: priceCategory,
        quantityProduced: quantityProduced,
        materialsUsed: materialsUsed,
        staffResponsible: staffResponsible,
        notes: notes,
      ),
    );
    if (isApiConnected) {
      api.createProduction({
        'productBrand': productBrand,
        'priceCategory': priceCategory,
        'quantityProduced': quantityProduced,
        'totalBundlesProduced': quantityProduced,
        'staffResponsible': staffResponsible,
        'notes': notes,
      });
    }
    notifyListeners();
  }

  // ==================== DAILY FACTORY PRODUCTION & STOCK SHEET ====================
  Future<bool> saveDailyProductionSheet(DailyProductionSheet sheet) async {
    final idx = dailySheets.indexWhere((s) => s.sheetId == sheet.sheetId);
    if (idx >= 0) {
      dailySheets[idx] = sheet;
    } else {
      dailySheets.insert(0, sheet);
    }
    todayDailySheet = sheet;

    // Auto-update finished stocks in memory
    for (final r in sheet.brandRows) {
      final stockIdx = finishedStocks.indexWhere((fs) =>
          fs.productBrand.toLowerCase() == r.brand.toLowerCase() &&
          fs.priceCategory.toLowerCase() == r.priceCategory.toLowerCase());
      if (stockIdx >= 0) {
        finishedStocks[stockIdx].quantityProduced += r.producedBundles;
        finishedStocks[stockIdx].quantitySold += r.salesBundles;
        finishedStocks[stockIdx].quantityDispatched += r.salesBundles;
      }
    }

    if (isApiConnected) {
      final success = await api.saveDailySheet(sheet.toJson());
      notifyListeners();
      return success;
    }
    notifyListeners();
    return true;
  }

  void recordSale({
    required CustomerType customerType,
    required String partyName,
    required String mobileNumber,
    String address = '',
    required String productBrand,
    required String priceCategory,
    required double quantity,
    required double salePrice,
    required double amountReceived,
    required DateTime salesDate,
  }) {
    final saleId = 'SALE-${101 + sales.length}';
    final sale = SaleRecord(
      id: saleId,
      customerType: customerType,
      partyName: partyName,
      mobileNumber: mobileNumber,
      address: address,
      productBrand: productBrand,
      priceCategory: priceCategory,
      quantity: quantity,
      salePrice: salePrice,
      amountReceived: amountReceived,
      salesDate: salesDate,
      recordedBy: _loggedInUserName,
    );
    sales.insert(0, sale);

    // Deduct from Finished Product Stock
    final fpIdx = finishedStocks.indexWhere(
      (f) =>
          f.productBrand == productBrand && f.priceCategory == priceCategory,
    );
    if (fpIdx != -1) {
      final fp = finishedStocks[fpIdx];
      fp.quantitySold += quantity;
      fp.quantityDispatched += quantity;
      stockTransactions.insert(
        0,
        StockTransaction(
          id: 'TXN-${1001 + stockTransactions.length}',
          date: salesDate,
          itemName: fp.fullName,
          itemType: 'Finished Product',
          transactionType: 'SALE_DISPATCH',
          quantity: -quantity,
          unit: 'Bundles',
          balanceAfter: fp.currentBalance,
          referenceNote:
              '${customerType.label}: $partyName [$saleId]',
        ),
      );
    }
    if (isApiConnected) {
      api.createSale({
        'customerType': customerType.name,
        'partyName': partyName,
        'mobileNumber': mobileNumber,
        'address': address,
        'productBrand': productBrand,
        'priceCategory': priceCategory,
        'quantity': quantity,
        'salePrice': salePrice,
        'amountReceived': amountReceived,
        'recordedBy': _loggedInUserName,
      });
    }
    notifyListeners();
  }

  void receiveSalePayment(String saleId, double additionalPayment) {
    final idx = sales.indexWhere((s) => s.id == saleId);
    if (idx != -1) {
      sales[idx].amountReceived = (sales[idx].amountReceived + additionalPayment)
          .clamp(0.0, sales[idx].totalAmount);
      if (isApiConnected) {
        api.collectSalePayment(saleId, additionalPayment);
      }
      notifyListeners();
    }
  }

  // ==================== WORKER, ATTENDANCE & SALARY ====================
  void addOrUpdateWorker(WorkerModel worker) {
    final idx = workers.indexWhere((w) => w.id == worker.id);
    if (idx != -1) {
      workers[idx] = worker;
    } else {
      workers.add(worker);
    }
    if (isApiConnected) {
      api.createWorker({
        'id': worker.id,
        'name': worker.name,
        'role': worker.jobType,
        'mobileNumber': worker.mobileNumber,
        'joiningDate': worker.joiningDate.toIso8601String(),
        'salaryType':
            worker.salaryType == SalaryType.monthly ? 'monthly' : 'daily',
        'salaryRate': worker.salaryAmount,
        'paidSalary': worker.paidSalaryAmount,
        'active': worker.isActive,
      });
    }
    notifyListeners();
  }

  Future<void> removeWorker(String workerId) async {
    workers.removeWhere((w) => w.id == workerId);
    if (isApiConnected) {
      await api.deleteWorker(workerId);
    }
    notifyListeners();
  }

  Future<void> clearAllWorkers() async {
    workers.clear();
    dailyRecords.clear();
    if (isApiConnected) {
      await api.clearAllWorkers();
    }
    notifyListeners();
  }

  Future<void> resetAllWorkerSalaries() async {
    for (final w in workers) {
      w.paidSalaryAmount = 0.0;
    }
    if (isApiConnected) {
      await api.resetWorkerSalaries();
    }
    notifyListeners();
  }

  void markWorkerDailyRecord({
    required String workerId,
    required DateTime date,
    required AttendanceStatus attendanceStatus,
    required WorkType workPerformed,
    String notes = '',
  }) {
    final worker = workers.firstWhere((w) => w.id == workerId);
    final existingIdx = dailyRecords.indexWhere(
      (r) =>
          r.workerId == workerId &&
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day,
    );

    if (existingIdx != -1) {
      dailyRecords[existingIdx].attendanceStatus = attendanceStatus;
      dailyRecords[existingIdx].workPerformed = workPerformed;
      dailyRecords[existingIdx].notes = notes;
      dailyRecords[existingIdx].markedBy = _loggedInUserName;
    } else {
      dailyRecords.insert(
        0,
        WorkerDailyRecord(
          id: 'ATT-${1001 + dailyRecords.length}',
          workerId: worker.id,
          workerName: worker.name,
          date: date,
          attendanceStatus: attendanceStatus,
          workPerformed: workPerformed,
          notes: notes,
          markedBy: _loggedInUserName,
        ),
      );
    }
    if (isApiConnected) {
      api.markAttendance({
        'workerId': worker.id,
        'workerName': worker.name,
        'date':
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        'attendanceStatus': attendanceStatus.label,
        'workPerformed': workPerformed.label,
        'notes': notes,
        'markedBy': _loggedInUserName,
      });
    }
    notifyListeners();
  }

  double getWorkingDaysForWorker(String workerId) {
    final records = dailyRecords.where((r) => r.workerId == workerId);
    double days = 0;
    for (final r in records) {
      if (r.attendanceStatus == AttendanceStatus.present) {
        days += 1.0;
      } else if (r.attendanceStatus == AttendanceStatus.halfDay) {
        days += 0.5;
      }
    }
    return days;
  }

  double calculateTotalSalaryForWorker(WorkerModel worker) {
    if (worker.salaryType == SalaryType.monthly) {
      return worker.salaryAmount;
    } else {
      final workingDays = getWorkingDaysForWorker(worker.id);
      return worker.salaryAmount * workingDays;
    }
  }

  void recordSalaryPayment(String workerId, double amountPaid) {
    final idx = workers.indexWhere((w) => w.id == workerId);
    if (idx != -1) {
      workers[idx].paidSalaryAmount += amountPaid;
      if (isApiConnected) {
        api.payWorkerSalary(workerId, amountPaid);
      }
      notifyListeners();
    }
  }

  // ==================== SEED INITIAL DATA ====================
  void _seedInitialData() {
    final now = DateTime.now();

    // 1. Products (Eagle, Pulli, Joker with Rs. 1 and Rs. 2 categories)
    products = [
      ProductItem(
        id: 'PROD-EAGLE',
        name: 'Eagle',
        productType: 'Premium Safety Matches',
        priceCategories: ['Rs. 1', 'Rs. 2'],
        bundlePriceByCategory: {'Rs. 1': 450.0, 'Rs. 2': 840.0},
        description:
            'Flagship safety matchbox brand of Deeba Match House. Extra-strong carbonized splints, damp-resistant side friction coating, and instant ignition.',
        sticksPerBox: '40 / 75 Sticks (Rs. 1 / Rs. 2)',
        boxesPerBundle: '600 Boxes (10 Pack × 60)',
        colorHex: 0xFFC62828,
      ),
      ProductItem(
        id: 'PROD-PULLI',
        name: 'Pulli',
        productType: 'Household & Kitchen Safety Matches',
        priceCategories: ['Rs. 1', 'Rs. 2'],
        bundlePriceByCategory: {'Rs. 1': 430.0, 'Rs. 2': 800.0},
        description:
            'Popular domestic safety matches crafted with smooth wax-coated splints and bright laminated outer boxes for everyday household and kitchen use.',
        sticksPerBox: '40 / 70 Sticks (Rs. 1 / Rs. 2)',
        boxesPerBundle: '600 Boxes (10 Pack × 60)',
        colorHex: 0xFFAD1457,
      ),
      ProductItem(
        id: 'PROD-JOKER',
        name: 'Joker',
        productType: 'High-Strike Retail Matches',
        priceCategories: ['Rs. 1', 'Rs. 2'],
        bundlePriceByCategory: {'Rs. 1': 420.0, 'Rs. 2': 780.0},
        description:
            'Fast-moving wholesale and retail matchboxes built for stores and distributors with durable outer board and long-burn chemical tip.',
        sticksPerBox: '38 / 70 Sticks (Rs. 1 / Rs. 2)',
        boxesPerBundle: '600 Boxes (10 Pack × 60)',
        colorHex: 0xFFE65100,
      ),
    ];

    // 2. Materials (Thani Thaniya: Outer Bundle, Inner Bundle, Packing Cover, Packing Bundle Sheet, Label, Chemical 8 Types)
    materials = [
      // ==================== 1. OUTER BUNDLE (Eagle, Pulli, Joker × Rs. 1, Rs. 2) ====================
      MaterialItem(
        id: 'MAT-OUT-E1',
        name: 'Eagle Rs. 1 Outer Bundle',
        category: MaterialCategory.outerMaterial,
        brandType: 'Eagle',
        priceCategory: 'Rs. 1',
        unit: 'Bundles',
        purchasePrice: 120.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 80,
        supplier: 'Sivakasi Print Pack',
        lastPurchaseDate: now.subtract(const Duration(days: 5)),
      ),
      MaterialItem(
        id: 'MAT-OUT-E2',
        name: 'Eagle Rs. 2 Outer Bundle',
        category: MaterialCategory.outerMaterial,
        brandType: 'Eagle',
        priceCategory: 'Rs. 2',
        unit: 'Bundles',
        purchasePrice: 165.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 60,
        supplier: 'Sivakasi Print Pack',
        lastPurchaseDate: now.subtract(const Duration(days: 6)),
      ),
      MaterialItem(
        id: 'MAT-OUT-JU1',
        name: 'Pulli Rs. 1 Outer Bundle',
        category: MaterialCategory.outerMaterial,
        brandType: 'Pulli',
        priceCategory: 'Rs. 1',
        unit: 'Bundles',
        purchasePrice: 115.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 75,
        supplier: 'Sivakasi Print Pack',
        lastPurchaseDate: now.subtract(const Duration(days: 7)),
      ),
      MaterialItem(
        id: 'MAT-OUT-JU2',
        name: 'Pulli Rs. 2 Outer Bundle',
        category: MaterialCategory.outerMaterial,
        brandType: 'Pulli',
        priceCategory: 'Rs. 2',
        unit: 'Bundles',
        purchasePrice: 160.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 60,
        supplier: 'Sivakasi Print Pack',
        lastPurchaseDate: now.subtract(const Duration(days: 6)),
      ),
      MaterialItem(
        id: 'MAT-OUT-JK1',
        name: 'Joker Rs. 1 Outer Bundle',
        category: MaterialCategory.outerMaterial,
        brandType: 'Joker',
        priceCategory: 'Rs. 1',
        unit: 'Bundles',
        purchasePrice: 112.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 60,
        supplier: 'Sri Murugan Offset',
        lastPurchaseDate: now.subtract(const Duration(days: 8)),
      ),
      MaterialItem(
        id: 'MAT-OUT-JK2',
        name: 'Joker Rs. 2 Outer Bundle',
        category: MaterialCategory.outerMaterial,
        brandType: 'Joker',
        priceCategory: 'Rs. 2',
        unit: 'Bundles',
        purchasePrice: 155.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 50,
        supplier: 'Sri Murugan Offset',
        lastPurchaseDate: now.subtract(const Duration(days: 8)),
      ),

      // ==================== 2. INNER BUNDLE (Eagle, Pulli, Joker × Rs. 1, Rs. 2) ====================
      MaterialItem(
        id: 'MAT-INN-E1',
        name: 'Eagle Rs. 1 Inner Bundle',
        category: MaterialCategory.innerBundle,
        brandType: 'Eagle',
        priceCategory: 'Rs. 1',
        unit: 'Bundles',
        purchasePrice: 85.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 80,
        supplier: 'Kovilpatti Board Mills',
        lastPurchaseDate: now.subtract(const Duration(days: 4)),
      ),
      MaterialItem(
        id: 'MAT-INN-E2',
        name: 'Eagle Rs. 2 Inner Bundle',
        category: MaterialCategory.innerBundle,
        brandType: 'Eagle',
        priceCategory: 'Rs. 2',
        unit: 'Bundles',
        purchasePrice: 115.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 60,
        supplier: 'Kovilpatti Board Mills',
        lastPurchaseDate: now.subtract(const Duration(days: 5)),
      ),
      MaterialItem(
        id: 'MAT-INN-JU1',
        name: 'Pulli Rs. 1 Inner Bundle',
        category: MaterialCategory.innerBundle,
        brandType: 'Pulli',
        priceCategory: 'Rs. 1',
        unit: 'Bundles',
        purchasePrice: 82.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 80,
        supplier: 'Kovilpatti Board Mills',
        lastPurchaseDate: now.subtract(const Duration(days: 6)),
      ),
      MaterialItem(
        id: 'MAT-INN-JU2',
        name: 'Pulli Rs. 2 Inner Bundle',
        category: MaterialCategory.innerBundle,
        brandType: 'Pulli',
        priceCategory: 'Rs. 2',
        unit: 'Bundles',
        purchasePrice: 112.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 50,
        supplier: 'Kovilpatti Board Mills',
        lastPurchaseDate: now.subtract(const Duration(days: 7)),
      ),
      MaterialItem(
        id: 'MAT-INN-JK1',
        name: 'Joker Rs. 1 Inner Bundle',
        category: MaterialCategory.innerBundle,
        brandType: 'Joker',
        priceCategory: 'Rs. 1',
        unit: 'Bundles',
        purchasePrice: 80.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 60,
        supplier: 'Kovilpatti Board Mills',
        lastPurchaseDate: now.subtract(const Duration(days: 8)),
      ),
      MaterialItem(
        id: 'MAT-INN-JK2',
        name: 'Joker Rs. 2 Inner Bundle',
        category: MaterialCategory.innerBundle,
        brandType: 'Joker',
        priceCategory: 'Rs. 2',
        unit: 'Bundles',
        purchasePrice: 110.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 50,
        supplier: 'Kovilpatti Board Mills',
        lastPurchaseDate: now.subtract(const Duration(days: 9)),
      ),

      // ==================== 3. PACKING COVER (Eagle, Pulli, Joker × Rs. 1, Rs. 2) ====================
      MaterialItem(
        id: 'MAT-COV-E1',
        name: 'Eagle Rs. 1 Packing Cover',
        category: MaterialCategory.packageCover,
        brandType: 'Eagle',
        priceCategory: 'Rs. 1',
        unit: 'Kg',
        purchasePrice: 210.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 25,
        supplier: 'VNR Poly Packs',
        lastPurchaseDate: now.subtract(const Duration(days: 5)),
      ),
      MaterialItem(
        id: 'MAT-COV-E2',
        name: 'Eagle Rs. 2 Packing Cover',
        category: MaterialCategory.packageCover,
        brandType: 'Eagle',
        priceCategory: 'Rs. 2',
        unit: 'Kg',
        purchasePrice: 225.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 25,
        supplier: 'VNR Poly Packs',
        lastPurchaseDate: now.subtract(const Duration(days: 6)),
      ),
      MaterialItem(
        id: 'MAT-COV-JU1',
        name: 'Pulli Rs. 1 Packing Cover',
        category: MaterialCategory.packageCover,
        brandType: 'Pulli',
        priceCategory: 'Rs. 1',
        unit: 'Kg',
        purchasePrice: 208.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 25,
        supplier: 'VNR Poly Packs',
        lastPurchaseDate: now.subtract(const Duration(days: 7)),
      ),
      MaterialItem(
        id: 'MAT-COV-JU2',
        name: 'Pulli Rs. 2 Packing Cover',
        category: MaterialCategory.packageCover,
        brandType: 'Pulli',
        priceCategory: 'Rs. 2',
        unit: 'Kg',
        purchasePrice: 220.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 25,
        supplier: 'VNR Poly Packs',
        lastPurchaseDate: now.subtract(const Duration(days: 10)),
      ),
      MaterialItem(
        id: 'MAT-COV-JK1',
        name: 'Joker Rs. 1 Packing Cover',
        category: MaterialCategory.packageCover,
        brandType: 'Joker',
        priceCategory: 'Rs. 1',
        unit: 'Kg',
        purchasePrice: 205.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 20,
        supplier: 'VNR Poly Packs',
        lastPurchaseDate: now.subtract(const Duration(days: 8)),
      ),
      MaterialItem(
        id: 'MAT-COV-JK2',
        name: 'Joker Rs. 2 Packing Cover',
        category: MaterialCategory.packageCover,
        brandType: 'Joker',
        priceCategory: 'Rs. 2',
        unit: 'Kg',
        purchasePrice: 218.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 20,
        supplier: 'VNR Poly Packs',
        lastPurchaseDate: now.subtract(const Duration(days: 9)),
      ),

      // ==================== 4. PACKING BUNDLE SHEET (Eagle, Pulli, Joker, Rs. 1, Rs. 2 + Common) ====================
      MaterialItem(
        id: 'MAT-SHT-E1',
        name: 'Eagle Rs. 1 Packing Bundle Sheet',
        category: MaterialCategory.bundleSheet,
        brandType: 'Eagle',
        priceCategory: 'Rs. 1',
        unit: 'Reams',
        purchasePrice: 640.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 15,
        supplier: 'Sivakasi Paper Mart',
        lastPurchaseDate: now.subtract(const Duration(days: 7)),
      ),
      MaterialItem(
        id: 'MAT-SHT-E2',
        name: 'Eagle Rs. 2 Packing Bundle Sheet',
        category: MaterialCategory.bundleSheet,
        brandType: 'Eagle',
        priceCategory: 'Rs. 2',
        unit: 'Reams',
        purchasePrice: 680.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 15,
        supplier: 'Sivakasi Paper Mart',
        lastPurchaseDate: now.subtract(const Duration(days: 7)),
      ),
      MaterialItem(
        id: 'MAT-SHT-JU1',
        name: 'Pulli Rs. 1 Packing Bundle Sheet',
        category: MaterialCategory.bundleSheet,
        brandType: 'Pulli',
        priceCategory: 'Rs. 1',
        unit: 'Reams',
        purchasePrice: 630.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 15,
        supplier: 'Sivakasi Paper Mart',
        lastPurchaseDate: now.subtract(const Duration(days: 8)),
      ),
      MaterialItem(
        id: 'MAT-SHT-JU2',
        name: 'Pulli Rs. 2 Packing Bundle Sheet',
        category: MaterialCategory.bundleSheet,
        brandType: 'Pulli',
        priceCategory: 'Rs. 2',
        unit: 'Reams',
        purchasePrice: 670.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 12,
        supplier: 'Sivakasi Paper Mart',
        lastPurchaseDate: now.subtract(const Duration(days: 8)),
      ),
      MaterialItem(
        id: 'MAT-SHT-JK1',
        name: 'Joker Rs. 1 Packing Bundle Sheet',
        category: MaterialCategory.bundleSheet,
        brandType: 'Joker',
        priceCategory: 'Rs. 1',
        unit: 'Reams',
        purchasePrice: 625.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 12, // Low stock!
        supplier: 'Sivakasi Paper Mart',
        lastPurchaseDate: now.subtract(const Duration(days: 14)),
      ),
      MaterialItem(
        id: 'MAT-SHT-JK2',
        name: 'Joker Rs. 2 Packing Bundle Sheet',
        category: MaterialCategory.bundleSheet,
        brandType: 'Joker',
        priceCategory: 'Rs. 2',
        unit: 'Reams',
        purchasePrice: 660.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 12,
        supplier: 'Sivakasi Paper Mart',
        lastPurchaseDate: now.subtract(const Duration(days: 10)),
      ),
      MaterialItem(
        id: 'MAT-SHT-COMMON',
        name: 'Common Packing Bundle Sheet (Universal Fallback)',
        category: MaterialCategory.bundleSheet,
        brandType: 'Common',
        priceCategory: 'All (Rs. 1 / Rs. 2)',
        unit: 'Reams',
        purchasePrice: 550.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 25,
        supplier: 'Sivakasi Paper Mart',
        lastPurchaseDate: now.subtract(const Duration(days: 3)),
      ),

      // ==================== 5. LABEL (Eagle, Pulli, Joker × Rs. 1, Rs. 2) ====================
      MaterialItem(
        id: 'MAT-LBL-E1',
        name: 'Eagle Rs. 1 Label',
        category: MaterialCategory.labels,
        brandType: 'Eagle',
        priceCategory: 'Rs. 1',
        unit: 'Packets (1000 pcs)',
        purchasePrice: 180.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 20,
        supplier: 'Sri Murugan Offset',
        lastPurchaseDate: now.subtract(const Duration(days: 5)),
      ),
      MaterialItem(
        id: 'MAT-LBL-E2',
        name: 'Eagle Rs. 2 Label',
        category: MaterialCategory.labels,
        brandType: 'Eagle',
        priceCategory: 'Rs. 2',
        unit: 'Packets (1000 pcs)',
        purchasePrice: 215.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 20,
        supplier: 'Sri Murugan Offset',
        lastPurchaseDate: now.subtract(const Duration(days: 6)),
      ),
      MaterialItem(
        id: 'MAT-LBL-JU1',
        name: 'Pulli Rs. 1 Label',
        category: MaterialCategory.labels,
        brandType: 'Pulli',
        priceCategory: 'Rs. 1',
        unit: 'Packets (1000 pcs)',
        purchasePrice: 178.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 18,
        supplier: 'Sri Murugan Offset',
        lastPurchaseDate: now.subtract(const Duration(days: 6)),
      ),
      MaterialItem(
        id: 'MAT-LBL-JU2',
        name: 'Pulli Rs. 2 Label',
        category: MaterialCategory.labels,
        brandType: 'Pulli',
        priceCategory: 'Rs. 2',
        unit: 'Packets (1000 pcs)',
        purchasePrice: 210.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 15,
        supplier: 'Sri Murugan Offset',
        lastPurchaseDate: now.subtract(const Duration(days: 6)),
      ),
      MaterialItem(
        id: 'MAT-LBL-JK1',
        name: 'Joker Rs. 1 Label',
        category: MaterialCategory.labels,
        brandType: 'Joker',
        priceCategory: 'Rs. 1',
        unit: 'Packets (1000 pcs)',
        purchasePrice: 175.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 15,
        supplier: 'Sri Murugan Offset',
        lastPurchaseDate: now.subtract(const Duration(days: 9)),
      ),
      MaterialItem(
        id: 'MAT-LBL-JK2',
        name: 'Joker Rs. 2 Label',
        category: MaterialCategory.labels,
        brandType: 'Joker',
        priceCategory: 'Rs. 2',
        unit: 'Packets (1000 pcs)',
        purchasePrice: 205.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 15,
        supplier: 'Sri Murugan Offset',
        lastPurchaseDate: now.subtract(const Duration(days: 9)),
      ),

      // ==================== 6. CHEMICAL (8 TYPES) ====================
      MaterialItem(
        id: 'MAT-CHEM-1',
        name: '1. Chlorine (Potassium Chlorate)',
        category: MaterialCategory.chemical,
        brandType: 'All Brands',
        priceCategory: 'Chemical',
        unit: 'Kg',
        purchasePrice: 145.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 100,
        supplier: 'Tuticorin Chemical Corp',
        lastPurchaseDate: now.subtract(const Duration(days: 4)),
      ),
      MaterialItem(
        id: 'MAT-CHEM-2',
        name: '2. Hydrochlorine',
        category: MaterialCategory.chemical,
        brandType: 'All Brands',
        priceCategory: 'Chemical',
        unit: 'Litres',
        purchasePrice: 95.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 50,
        supplier: 'Tuticorin Chemical Corp',
        lastPurchaseDate: now.subtract(const Duration(days: 7)),
      ),
      MaterialItem(
        id: 'MAT-CHEM-3',
        name: '3. Sulphur',
        category: MaterialCategory.chemical,
        brandType: 'All Brands',
        priceCategory: 'Chemical',
        unit: 'Kg',
        purchasePrice: 68.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 80,
        supplier: 'Southern Minerals & Chem',
        lastPurchaseDate: now.subtract(const Duration(days: 6)),
      ),
      MaterialItem(
        id: 'MAT-CHEM-4',
        name: '4. Zinc White',
        category: MaterialCategory.chemical,
        brandType: 'All Brands',
        priceCategory: 'Chemical',
        unit: 'Kg',
        purchasePrice: 190.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 30,
        supplier: 'Southern Minerals & Chem',
        lastPurchaseDate: now.subtract(const Duration(days: 10)),
      ),
      MaterialItem(
        id: 'MAT-CHEM-5',
        name: '5. Super Black Capsule',
        category: MaterialCategory.chemical,
        brandType: 'All Brands',
        priceCategory: 'Chemical',
        unit: 'Kg',
        purchasePrice: 310.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 20, // Low stock!
        supplier: 'Madurai Dye & Pigments',
        lastPurchaseDate: now.subtract(const Duration(days: 12)),
      ),
      MaterialItem(
        id: 'MAT-CHEM-6',
        name: '6. Biogram',
        category: MaterialCategory.chemical,
        brandType: 'All Brands',
        priceCategory: 'Chemical',
        unit: 'Kg',
        purchasePrice: 240.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 40,
        supplier: 'Madurai Dye & Pigments',
        lastPurchaseDate: now.subtract(const Duration(days: 5)),
      ),
      MaterialItem(
        id: 'MAT-CHEM-7',
        name: '7. Wax (Paraffin Wax)',
        category: MaterialCategory.chemical,
        brandType: 'All Brands',
        priceCategory: 'Chemical',
        unit: 'Kg',
        purchasePrice: 118.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 150,
        supplier: 'Chennai Petro Wax Traders',
        lastPurchaseDate: now.subtract(const Duration(days: 3)),
      ),
      MaterialItem(
        id: 'MAT-CHEM-8',
        name: '8. Manjeram',
        category: MaterialCategory.chemical,
        brandType: 'All Brands',
        priceCategory: 'Chemical',
        unit: 'Kg',
        purchasePrice: 520.0,
        openingStock: 0,
        totalPurchased: 0,
        usedQuantity: 0,
        minStockAlert: 18, // Low stock!
        supplier: 'Tuticorin Chemical Corp',
        lastPurchaseDate: now.subtract(const Duration(days: 11)),
      ),
    ];

    // 3. Purchases (Empty - real purchases recorded via Purchase Entry)
    purchases = [];

    // 4. Finished Product Stock
    finishedStocks = [
      FinishedProductStock(
        id: 'FP-1',
        productBrand: 'Eagle',
        priceCategory: 'Rs. 1',
        openingBalance: 0,
        quantityProduced: 0,
        quantitySold: 0,
        quantityDispatched: 0,
        salePricePerBundle: 450.0,
      ),
      FinishedProductStock(
        id: 'FP-2',
        productBrand: 'Eagle',
        priceCategory: 'Rs. 2',
        openingBalance: 0,
        quantityProduced: 0,
        quantitySold: 0,
        quantityDispatched: 0,
        salePricePerBundle: 840.0,
      ),
      FinishedProductStock(
        id: 'FP-3',
        productBrand: 'Pulli',
        priceCategory: 'Rs. 1',
        openingBalance: 0,
        quantityProduced: 0,
        quantitySold: 0,
        quantityDispatched: 0,
        salePricePerBundle: 430.0,
      ),
      FinishedProductStock(
        id: 'FP-4',
        productBrand: 'Pulli',
        priceCategory: 'Rs. 2',
        openingBalance: 0,
        quantityProduced: 0,
        quantitySold: 0,
        quantityDispatched: 0,
        salePricePerBundle: 800.0,
      ),
      FinishedProductStock(
        id: 'FP-5',
        productBrand: 'Joker',
        priceCategory: 'Rs. 1',
        openingBalance: 0,
        quantityProduced: 0,
        quantitySold: 0,
        quantityDispatched: 0,
        salePricePerBundle: 420.0,
      ),
      FinishedProductStock(
        id: 'FP-6',
        productBrand: 'Joker',
        priceCategory: 'Rs. 2',
        openingBalance: 0,
        quantityProduced: 0,
        quantitySold: 0,
        quantityDispatched: 0,
        salePricePerBundle: 780.0,
      ),
    ];

    // 5. Production Records (Empty - real output added via Production Entry)
    productionRecords = [];

    // 6. Stock Transactions (Empty - added automatically on real operations)
    stockTransactions = [];

    // 7. Online Orders (Empty - added when customer places order)
    onlineOrders = [];

    // 8. Sales (Empty - added when recording Agent/Store/Direct sale)
    sales = [];

    // 9. Workers (Loaded live from MongoDB)
    workers = [];

    // 10. Worker Daily Attendance & Activity Records (Empty - marked daily)
    dailyRecords = [];
  }
}

