// ============================================================================
// Deeba Match House - MongoDB 20 Collections Setup & Initial Seed Script
// Run with: mongosh deeba_match_house init_collections.js
// ============================================================================

const dbName = 'deeba_match_house';
const dbRef = db.getSiblingDB(dbName);

// 20 Initial Collections from Section 21 of Master Plan
const collections = [
  'users',
  'staff',
  'workers',
  'products',
  'product_categories',
  'materials',
  'material_categories',
  'suppliers',
  'purchases',
  'stock_transactions',
  'production_records',
  'finished_products',
  'online_orders',
  'agents',
  'stores',
  'sales',
  'attendance',
  'worker_daily_work',
  'salary_records',
  'notifications'
];

collections.forEach((col) => {
  if (!dbRef.getCollectionNames().includes(col)) {
    dbRef.createCollection(col);
  }
});

// Seed Dynamic Product Categories
dbRef.product_categories.insertMany([
  { code: 'RS1', name: 'Rs. 1', sticksPerBox: 40, boxesPerBundle: 600, active: true },
  { code: 'RS2', name: 'Rs. 2', sticksPerBox: 75, boxesPerBundle: 600, active: true }
]);

// Seed Initial Matchbox Products (Eagle, Pulli, Joker)
dbRef.products.insertMany([
  {
    code: 'PROD-EAGLE',
    name: 'Eagle',
    productType: 'Premium Safety Matches',
    priceCategories: ['Rs. 1', 'Rs. 2'],
    bundlePriceByCategory: { 'Rs. 1': 450, 'Rs. 2': 840 },
    active: true
  },
  {
    code: 'PROD-PULLI',
    name: 'Pulli',
    productType: 'Household & Kitchen Safety Matches',
    priceCategories: ['Rs. 1', 'Rs. 2'],
    bundlePriceByCategory: { 'Rs. 1': 430, 'Rs. 2': 800 },
    active: true
  },
  {
    code: 'PROD-JOKER',
    name: 'Joker',
    productType: 'High-Strike Retail Matches',
    priceCategories: ['Rs. 1', 'Rs. 2'],
    bundlePriceByCategory: { 'Rs. 1': 420, 'Rs. 2': 780 },
    active: true
  }
]);

// Seed Material Categories (Section 8 & 9)
dbRef.material_categories.insertMany([
  { code: 'OUTER_MATERIAL', name: 'Outer Materials', editable: true },
  { code: 'INNER_BUNDLE', name: 'Inner Bundle', editable: true },
  { code: 'PACKAGE_COVER', name: 'Package Covers', editable: true },
  { code: 'BUNDLE_SHEET', name: 'Bundle Sheets (incl. Common Sheet)', editable: true },
  { code: 'LABEL', name: 'Labels', editable: true },
  { code: 'CHEMICAL', name: 'Chemical and Production Materials', editable: true }
]);

// Seed Initial Chemicals & Bundle Sheets (Section 8 & 9)
dbRef.materials.insertMany([
  { name: 'Chlorine', category: 'CHEMICAL', unit: 'Kg', purchasePrice: 145, openingStock: 500, active: true },
  { name: 'Hydrochlorine', category: 'CHEMICAL', unit: 'Litres', purchasePrice: 95, openingStock: 200, active: true },
  { name: 'Sulphur', category: 'CHEMICAL', unit: 'Kg', purchasePrice: 68, openingStock: 350, active: true },
  { name: 'Zinc White', category: 'CHEMICAL', unit: 'Kg', purchasePrice: 190, openingStock: 120, active: true },
  { name: 'Super Black Capsule', category: 'CHEMICAL', unit: 'Kg', purchasePrice: 310, openingStock: 40, active: true },
  { name: 'Biogram', category: 'CHEMICAL', unit: 'Kg', purchasePrice: 240, openingStock: 150, active: true },
  { name: 'Wax', category: 'CHEMICAL', unit: 'Kg', purchasePrice: 118, openingStock: 600, active: true },
  { name: 'Manjeram', category: 'CHEMICAL', unit: 'Kg', purchasePrice: 520, openingStock: 50, active: true },
  { name: 'Common Bundle Sheet', category: 'BUNDLE_SHEET', unit: 'Reams', purchasePrice: 550, openingStock: 80, active: true }
]);

print('Deeba Match House MongoDB 20 collections initialized successfully!');

