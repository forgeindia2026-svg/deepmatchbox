enum UserRole { customer, admin, staff }

enum OrderStatus {
  newOrder('New'),
  confirmed('Confirmed'),
  processing('Processing'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const OrderStatus(this.label);
}

enum MaterialCategory {
  outerMaterial('Outer Bundle'),
  innerBundle('Inner Bundle'),
  packageCover('Packing Cover'),
  bundleSheet('Packing Bundle Sheet'),
  labels('Label'),
  chemical('Chemical (8 Types)');

  final String label;
  const MaterialCategory(this.label);
}

enum CustomerType {
  agent('Agent'),
  store('Store'),
  directCustomer('Direct Customer');

  final String label;
  const CustomerType(this.label);
}

enum AttendanceStatus {
  present('Present'),
  absent('Absent'),
  halfDay('Half Day'),
  leave('Leave');

  final String label;
  const AttendanceStatus(this.label);
}

enum WorkType {
  packing('Packing'),
  production('Production'),
  labelWork('Label Work'),
  bundleWork('Bundle Work'),
  chemicalWork('Chemical Work'),
  otherWork('Other Work');

  final String label;
  const WorkType(this.label);
}

enum SalaryType {
  monthly('Monthly Salary'),
  daily('Daily Salary');

  final String label;
  const SalaryType(this.label);
}

class ProductItem {
  final String id;
  String name; // e.g., Eagle, Pulli, Joker
  String productType; // e.g., Safety Matches, Deluxe Wax Matches, Kitchen Matches
  List<String> priceCategories; // e.g., ['Rs. 1', 'Rs. 2']
  Map<String, double> bundlePriceByCategory; // Wholesale price per bundle
  String description;
  String sticksPerBox;
  String boxesPerBundle;
  int colorHex;
  bool isActive;

  ProductItem({
    required this.id,
    required this.name,
    required this.productType,
    required this.priceCategories,
    required this.bundlePriceByCategory,
    required this.description,
    this.sticksPerBox = '40 Sticks',
    this.boxesPerBundle = '600 Boxes (10x60)',
    this.colorHex = 0xFFD84315,
    this.isActive = true,
  });
}

class MaterialItem {
  final String id;
  String name;
  MaterialCategory category;
  String brandType; // Eagle, Pulli, Joker, or Common / All
  String priceCategory; // Rs. 1, Rs. 2, or Standard
  String unit; // kg, bundles, reams, rolls, packets, litres
  double purchasePrice;
  double openingStock;
  double totalPurchased;
  double usedQuantity;
  double minStockAlert;
  String supplier;
  DateTime lastPurchaseDate;
  bool isActive;

  MaterialItem({
    required this.id,
    required this.name,
    required this.category,
    this.brandType = 'Common',
    this.priceCategory = 'Standard',
    required this.unit,
    required this.purchasePrice,
    required this.openingStock,
    this.totalPurchased = 0,
    this.usedQuantity = 0,
    this.minStockAlert = 20,
    this.supplier = 'Default Supplier',
    required this.lastPurchaseDate,
    this.isActive = true,
  });

  double get currentBalance => openingStock + totalPurchased - usedQuantity;
  double get totalStockValue => currentBalance * purchasePrice;
  bool get isLowStock => isActive && currentBalance <= minStockAlert;
}

class PurchaseRecord {
  final String id;
  final String materialId;
  final String materialName;
  final MaterialCategory category;
  final double quantity;
  final String unit;
  double purchasePrice;
  final String supplierName;
  final DateTime purchaseDate;
  final String notes;
  final String recordedBy;

  PurchaseRecord({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.purchasePrice,
    required this.supplierName,
    required this.purchaseDate,
    this.notes = '',
    this.recordedBy = 'Admin',
  });

  double get totalAmount => quantity * purchasePrice;
}

class MaterialUsageItem {
  final String materialId;
  final String materialName;
  final double quantityUsed;
  final String unit;

  MaterialUsageItem({
    required this.materialId,
    required this.materialName,
    required this.quantityUsed,
    required this.unit,
  });
}

class ProductionRecord {
  final String id;
  final DateTime productionDate;
  final String productBrand; // Eagle, Pulli, Joker
  final String priceCategory; // Rs. 1, Rs. 2
  final double quantityProduced; // in bundles
  final List<MaterialUsageItem> materialsUsed;
  final String staffResponsible;
  final String notes;

  ProductionRecord({
    required this.id,
    required this.productionDate,
    required this.productBrand,
    required this.priceCategory,
    required this.quantityProduced,
    required this.materialsUsed,
    required this.staffResponsible,
    this.notes = '',
  });
}

class FinishedProductStock {
  final String id;
  final String productBrand; // Eagle, Pulli, Joker
  final String priceCategory; // Rs. 1, Rs. 2
  double openingBalance;
  double quantityProduced;
  double quantitySold;
  double quantityDispatched;
  double salePricePerBundle;

  FinishedProductStock({
    required this.id,
    required this.productBrand,
    required this.priceCategory,
    this.openingBalance = 0,
    required this.quantityProduced,
    this.quantitySold = 0,
    this.quantityDispatched = 0,
    required this.salePricePerBundle,
  });

  String get fullName => '$productBrand ($priceCategory)';

  // Stock Calculation: Opening + Produced - Sold/Dispatched
  double get currentBalance =>
      openingBalance + quantityProduced - quantitySold;
}

class StockTransaction {
  final String id;
  final DateTime date;
  final String itemName;
  final String itemType; // 'Raw Material' or 'Finished Product'
  final String transactionType; // 'PURCHASE_IN', 'PRODUCTION_USE', 'PRODUCTION_OUT', 'SALE_OUT'
  final double quantity;
  final String unit;
  final double balanceAfter;
  final String referenceNote;

  StockTransaction({
    required this.id,
    required this.date,
    required this.itemName,
    required this.itemType,
    required this.transactionType,
    required this.quantity,
    required this.unit,
    required this.balanceAfter,
    required this.referenceNote,
  });
}

class OnlineOrder {
  final String id;
  final String customerName;
  final String mobileNumber;
  final String address;
  final String productBrand; // Eagle, Pulli, Joker
  final String productCategory; // Rs. 1, Rs. 2
  final int quantityBundles;
  final String additionalNotes;
  final DateTime orderDate;
  OrderStatus status;

  OnlineOrder({
    required this.id,
    required this.customerName,
    required this.mobileNumber,
    required this.address,
    required this.productBrand,
    required this.productCategory,
    required this.quantityBundles,
    this.additionalNotes = '',
    required this.orderDate,
    this.status = OrderStatus.newOrder,
  });
}

class SaleRecord {
  final String id;
  final CustomerType customerType; // Agent, Store, Direct Customer
  final String partyName; // Agent Name, Store Name, or Customer Name
  final String mobileNumber;
  final String address;
  final String productBrand; // Eagle, Pulli, Joker
  final String priceCategory; // Rs. 1, Rs. 2
  final double quantity; // in bundles
  final double salePrice;
  double amountReceived;
  final DateTime salesDate;
  final String recordedBy;

  SaleRecord({
    required this.id,
    required this.customerType,
    required this.partyName,
    required this.mobileNumber,
    this.address = '',
    required this.productBrand,
    required this.priceCategory,
    required this.quantity,
    required this.salePrice,
    required this.amountReceived,
    required this.salesDate,
    this.recordedBy = 'Admin',
  });

  double get totalAmount => quantity * salePrice;
  double get pendingAmount =>
      (totalAmount - amountReceived).clamp(0, double.infinity);
  String get paymentStatus {
    if (pendingAmount <= 0) return 'Paid';
    if (amountReceived > 0) return 'Partial';
    return 'Pending';
  }
}

class WorkerModel {
  final String id;
  String name;
  String mobileNumber;
  String jobType; // Packing, Dipping/Chemical, Box Filling, Labeling, Bundling
  DateTime joiningDate;
  SalaryType salaryType;
  double salaryAmount; // Monthly salary or Daily wage rate
  double paidSalaryAmount; // Paid for current month
  bool isActive;

  WorkerModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.jobType,
    required this.joiningDate,
    required this.salaryType,
    required this.salaryAmount,
    this.paidSalaryAmount = 0,
    this.isActive = true,
  });
}

class WorkerDailyRecord {
  final String id;
  final String workerId;
  final String workerName;
  final DateTime date;
  AttendanceStatus attendanceStatus;
  WorkType workPerformed;
  String notes;
  String markedBy;

  WorkerDailyRecord({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.date,
    required this.attendanceStatus,
    required this.workPerformed,
    this.notes = '',
    this.markedBy = 'Staff',
  });
}

class ContactInquiry {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String message;
  final DateTime createdAt;

  ContactInquiry({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.message,
    required this.createdAt,
  });
}

// ==================== DAILY FACTORY PRODUCTION & STOCK SHEET ====================
class DailySheetBrandRow {
  final String brand;
  final String priceCategory;
  double openingStock;
  double producedBundles;
  double get totalAvailable => openingStock + producedBundles;
  double salesBundles;
  double get closingStock => totalAvailable - salesBundles;

  DailySheetBrandRow({
    required this.brand,
    required this.priceCategory,
    this.openingStock = 0.0,
    this.producedBundles = 0.0,
    this.salesBundles = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'priceCategory': priceCategory,
        'openingStock': openingStock,
        'producedBundles': producedBundles,
        'totalAvailable': totalAvailable,
        'salesBundles': salesBundles,
        'closingStock': closingStock,
      };

  factory DailySheetBrandRow.fromJson(Map<String, dynamic> json) =>
      DailySheetBrandRow(
        brand: json['brand'] ?? 'Eagle',
        priceCategory: json['priceCategory'] ?? 'Rs. 1',
        openingStock: (json['openingStock'] as num?)?.toDouble() ?? 0.0,
        producedBundles: (json['producedBundles'] as num?)?.toDouble() ?? 0.0,
        salesBundles: (json['salesBundles'] as num?)?.toDouble() ?? 0.0,
      );
}

class DailyProductionSheet {
  final String sheetId;
  final String date; // YYYY-MM-DD
  final String dayOfWeek;
  final String recordedBy;
  int adappuFrames;
  int dippingFrames;
  int balanceFrames;
  int totalBoxes;
  double avgBoxesPerFrame;
  double grossCount;
  int totalBundlesProduced;
  List<DailySheetBrandRow> brandRows;
  String companyMaterialInward;
  String companyMaterialOutward;
  String closingCardNote;
  final DateTime createdAt;

  DailyProductionSheet({
    required this.sheetId,
    required this.date,
    required this.dayOfWeek,
    required this.recordedBy,
    this.adappuFrames = 0,
    this.dippingFrames = 0,
    this.balanceFrames = 0,
    this.totalBoxes = 0,
    this.avgBoxesPerFrame = 0.0,
    this.grossCount = 0.0,
    this.totalBundlesProduced = 0,
    required this.brandRows,
    this.companyMaterialInward = '',
    this.companyMaterialOutward = '',
    this.closingCardNote = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalOpeningBundles =>
      brandRows.fold(0.0, (sum, r) => sum + r.openingStock);
  double get totalProducedBundles =>
      brandRows.fold(0.0, (sum, r) => sum + r.producedBundles);
  double get totalAvailableBundles =>
      brandRows.fold(0.0, (sum, r) => sum + r.totalAvailable);
  double get totalSalesBundles =>
      brandRows.fold(0.0, (sum, r) => sum + r.salesBundles);
  double get totalClosingBundles =>
      brandRows.fold(0.0, (sum, r) => sum + r.closingStock);

  Map<String, dynamic> toJson() => {
        'sheetId': sheetId,
        'date': date,
        'dayOfWeek': dayOfWeek,
        'recordedBy': recordedBy,
        'adappuFrames': adappuFrames,
        'dippingFrames': dippingFrames,
        'balanceFrames': balanceFrames,
        'totalBoxes': totalBoxes,
        'avgBoxesPerFrame': avgBoxesPerFrame,
        'grossCount': grossCount,
        'totalBundlesProduced': totalBundlesProduced,
        'brandRows': brandRows.map((r) => r.toJson()).toList(),
        'companyMaterialInward': companyMaterialInward,
        'companyMaterialOutward': companyMaterialOutward,
        'closingCardNote': closingCardNote,
      };

  factory DailyProductionSheet.fromJson(Map<String, dynamic> json) =>
      DailyProductionSheet(
        sheetId: json['sheetId'] ?? '',
        date: json['date'] ?? '',
        dayOfWeek: json['dayOfWeek'] ?? '',
        recordedBy: json['recordedBy'] ?? 'Staff',
        adappuFrames: (json['adappuFrames'] as num?)?.toInt() ?? 0,
        dippingFrames: (json['dippingFrames'] as num?)?.toInt() ?? 0,
        balanceFrames: (json['balanceFrames'] as num?)?.toInt() ?? 0,
        totalBoxes: (json['totalBoxes'] as num?)?.toInt() ?? 0,
        avgBoxesPerFrame: (json['avgBoxesPerFrame'] as num?)?.toDouble() ?? 0.0,
        grossCount: (json['grossCount'] as num?)?.toDouble() ?? 0.0,
        totalBundlesProduced:
            (json['totalBundlesProduced'] as num?)?.toInt() ?? 0,
        brandRows: (json['brandRows'] as List?)
                ?.map((r) =>
                    DailySheetBrandRow.fromJson(Map<String, dynamic>.from(r)))
                .toList() ??
            [],
        companyMaterialInward: json['companyMaterialInward'] ?? '',
        companyMaterialOutward: json['companyMaterialOutward'] ?? '',
        closingCardNote: json['closingCardNote'] ?? '',
      );
}

class UserModel {
  final String id;
  final String username;
  final String name;
  final String role; // 'admin' | 'staff'
  final String phone;
  final String designation;
  final bool active;
  final String? createdAt;
  final String? lastLoginAt;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.phone = '',
    this.designation = '',
    this.active = true,
    this.createdAt,
    this.lastLoginAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isStaff => role.toLowerCase() == 'staff';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        username: json['username'] ?? '',
        name: json['name'] ?? json['username'] ?? '',
        role: json['role'] ?? 'staff',
        phone: json['phone'] ?? '',
        designation: json['designation'] ??
            (json['role'] == 'admin' ? 'Factory Admin' : 'Floor Staff'),
        active: json['active'] as bool? ?? true,
        createdAt: json['createdAt']?.toString(),
        lastLoginAt: json['lastLoginAt']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'role': role,
        'phone': phone,
        'designation': designation,
        'active': active,
        if (createdAt != null) 'createdAt': createdAt,
        if (lastLoginAt != null) 'lastLoginAt': lastLoginAt,
      };
}


