# Deeba Match House - Complete Project Master Plan

## 1. Project Overview

Deeba Match House needs a complete digital management system for customer-facing business operations and internal company operations.

The complete project will include:

1. Customer Website
2. Customer Mobile App
3. Online Order System
4. Admin Website Dashboard
5. Admin Mobile App
6. Staff Website Dashboard
7. Staff Mobile App
8. Purchase Management
9. Raw Material Management
10. Stock Management
11. Production Management
12. Finished Product Management
13. Sales Management
14. Agent Sales Management
15. Store Sales Management
16. Worker Management
17. Attendance Management
18. Daily Work Tracking
19. Salary Management
20. Reports and Analytics

---

## 2. Technology Stack

### Frontend
- Flutter
- Responsive Web Support
- Android Mobile App

### Backend
- Java
- Spring Boot
- REST API

### Database
- MongoDB

### Development Tools
- Git
- GitHub
- Docker
- Postman

---

## 3. System Users

### Customer
Customers can:
- Visit the website or use the mobile app
- View products
- View product details
- Select products
- Place an online order
- Submit contact details
- View company information

### Admin
Admin has complete access to:
- Products
- Staff
- Workers
- Purchases
- Materials
- Stock
- Production
- Sales
- Agents
- Stores
- Attendance
- Salaries
- Reports
- Online Orders

### Staff
Staff can access assigned modules such as:
- Profile
- Purchase entry
- Stock updates
- Production entry
- Worker attendance
- Daily worker activities
- Assigned sales records

---

# 4. Customer Website and Mobile App

Both the Customer Website and Customer Mobile App will use the same Spring Boot backend.

## Main Features

### Home
- Company introduction
- Banner
- Featured products
- Product categories
- Company information
- Contact details

### About Us
- Company history
- Company details
- Mission and vision

### Products
Initial product types:
- Eagle
- Pulli
- Joker

Each product can contain:
- Product image
- Product name
- Product type
- Description
- Available options

### Product Details
Customers can view complete product information before placing an order.

### Online Order
Online payment is not required for the initial version.

Order form:
- Customer Name
- Mobile Number
- Address
- Product
- Product Type
- Quantity
- Additional Notes

### Contact Us
- Phone number
- Email
- Address
- Contact form

---

# 5. Online Order Management

Order flow:

Customer Website / App
        |
        v
Customer Places Order
        |
        v
Order Received in Admin System
        |
        v
Admin Reviews Order
        |
        v
Admin Updates Order Status
        |
        v
Company Contacts Customer

## Order Status
- New
- Confirmed
- Processing
- Completed
- Cancelled

---

# 6. Admin Website and Mobile App

The Admin Website and Admin Mobile App will use the same backend API.

## Admin Dashboard

Dashboard summary:
- Total Online Orders
- Total Purchases
- Total Raw Material Stock
- Total Finished Stock
- Total Production
- Total Sales
- Agent Sales
- Store Sales
- Pending Payments
- Total Workers
- Today's Attendance
- Low Stock Items

Admin can monitor and manage all company operations.

---

# 7. Staff Website and Mobile App

Staff can use the website or mobile app for assigned work.

Main features:
- Profile
- Purchase Entry
- Stock Update
- Production Entry
- Worker Attendance
- Daily Work Entry
- Assigned Sales Management

---

# 8. Material Management

The system should not permanently hardcode material names or prices.

Admin should be able to:
- Add new materials
- Edit materials
- Change prices
- Update stock
- Disable unused materials

## Outer Materials

Product types:
- Eagle
- Pulli
- Joker

Price categories:
- Rs. 1
- Rs. 2

## Inner Bundle

Product types:
- Eagle
- Pulli
- Joker

Price categories:
- Rs. 1
- Rs. 2

## Package Covers

Package covers should support different combinations based on:
- Eagle
- Pulli
- Joker
- Rs. 1
- Rs. 2

The configuration should be manageable by Admin.

## Bundle Sheets

Support:
- Eagle Bundle Sheet
- Pulli Bundle Sheet
- Joker Bundle Sheet
- Rs. 1 Bundle Sheet
- Rs. 2 Bundle Sheet
- Common Bundle Sheet

A common bundle sheet can be used when a specific printed sheet is unavailable.

## Labels

Labels can be managed based on:
- Eagle
- Pulli
- Joker
- Rs. 1
- Rs. 2

Label prices must be editable.

---

# 9. Chemical and Production Materials

Initial materials mentioned:
- Chlorine
- Hydrochlorine
- Sulphur
- Zinc White
- Super Black Capsule
- Biogram
- Wax
- Manjeram

The Admin can add new materials later.

Each material should contain:
- Material Name
- Category
- Quantity
- Unit
- Purchase Price
- Total Amount
- Supplier
- Purchase Date
- Available Quantity
- Used Quantity
- Remaining Quantity

---

# 10. Purchase Management

Every company purchase should be recorded.

Purchase details:
- Material Name
- Material Category
- Quantity
- Unit
- Purchase Price
- Total Amount
- Supplier Name
- Purchase Date
- Notes

Purchase prices should remain editable because prices may change.

---

# 11. Stock Management

The Stock Management system should automatically calculate available stock.

## Calculation

Opening Stock

+ New Purchase

- Used for Production

- Sold or Dispatched

= Current Available Stock

The system should show:
- Total Purchased
- Total Used
- Total Produced
- Total Sold
- Total Dispatched
- Current Balance

Every stock movement should be stored as a transaction.

---

# 12. Production Management

When matchboxes are produced, Staff or Admin should enter production details.

Production entry:
- Production Date
- Product Type
- Eagle / Pulli / Joker
- Rs. 1 / Rs. 2 Category
- Quantity Produced
- Materials Used
- Staff Responsible
- Notes

After production:
- Raw material stock decreases
- Finished product stock increases

---

# 13. Finished Product Stock

Finished products should show:
- Product Name
- Product Type
- Quantity Produced
- Quantity Sold
- Quantity Dispatched
- Current Balance

---

# 14. Sales Management

All company sales should be recorded.

Sales details:
- Product Name
- Product Type
- Quantity
- Sale Price
- Total Amount
- Customer Type
- Sales Date

Customer types:
- Agent
- Store
- Direct Customer

---

# 15. Agent Sales Management

Each agent record should contain:
- Agent Name
- Mobile Number
- Address
- Products Sold
- Quantity
- Total Sales Amount
- Amount Received
- Pending Amount
- Sales Date

The system should provide agent-wise reports.

---

# 16. Store Sales Management

Each store record should contain:
- Store Name
- Contact Details
- Product
- Quantity
- Sales Amount
- Amount Received
- Pending Amount
- Sales Date

Reports should support filtering by:
- Date
- Store
- Product
- Payment Status

---

# 17. Worker Management

Worker details:
- Worker Name
- Mobile Number
- Job Type
- Joining Date
- Salary Type
- Salary Amount
- Active Status

---

# 18. Worker Attendance

Workers will not log in to mark attendance.

A Staff member will maintain attendance for all workers.

Attendance options:
- Present
- Absent
- Half Day
- Leave

Staff should be able to select attendance for each worker daily.

---

# 19. Daily Worker Activity

Staff should record the work completed by each worker.

Examples:
- Packing
- Production
- Label Work
- Bundle Work
- Chemical Work
- Other Work

Each entry should contain:
- Worker Name
- Date
- Attendance Status
- Work Performed
- Notes

---

# 20. Salary Management

The system supports two salary types.

## Monthly Salary
For fixed salary workers:
- Monthly Salary
- Paid Amount
- Pending Amount

## Daily Salary
For daily wage workers:

Daily Wage × Number of Working Days = Total Salary

Attendance data can be used to calculate working days.

---

# 21. MongoDB Collections

Initial collections:

- users
- staff
- workers
- products
- product_categories
- materials
- material_categories
- suppliers
- purchases
- stock_transactions
- production_records
- finished_products
- online_orders
- agents
- stores
- sales
- attendance
- worker_daily_work
- salary_records
- notifications

---

# 22. Backend API Modules

## Authentication
- Admin Login
- Staff Login
- Customer Authentication if required

## Product
- Add Product
- Update Product
- View Products

## Material
- Add Material
- Update Material
- Manage Categories

## Purchase
- Create Purchase
- View Purchases
- Update Purchase Records

## Stock
- Stock In
- Stock Out
- Stock History
- Current Balance

## Production
- Create Production Record
- Track Material Usage
- Update Finished Stock

## Sales
- Agent Sales
- Store Sales
- Direct Sales

## Worker
- Add Worker
- Update Worker
- Attendance
- Daily Work
- Salary

## Order
- Customer Order
- Admin Order Management
- Order Status Updates

---

# 23. High-Level Architecture

Customer Website
        |
Customer Mobile App
        |
        v
Spring Boot REST API
        |
        v
      MongoDB
        |
  -------------------
  |        |        |
Admin     Staff    Reports
Website   Website
        |        |
Admin     Staff
App       App

All applications will communicate with the same backend API.

---

# 24. Recommended Project Structure

```text
deeba-match-house/
│
├── frontend/
│   ├── customer_website/
│   ├── admin_dashboard/
│   └── staff_dashboard/
│
├── mobile/
│   ├── customer_app/
│   ├── admin_app/
│   └── staff_app/
│
├── backend/
│   └── spring_boot_api/
│
├── database/
│   └── mongodb_structure/
│
└── documentation/
    └── project_plan.md
```

---

# 25. Important Development Rules

The following items should be dynamic and manageable from the Admin system:

- Product Types
- Material Types
- Purchase Prices
- Sale Prices
- Package Covers
- Bundle Sheets
- Labels
- Chemical Materials

These should not be permanently hardcoded because company requirements and prices may change.

---

# 26. Three-Day Development Priority Plan

## Day 1 - Foundation and Customer Platform

- Create project structure
- Set up MongoDB
- Set up Spring Boot backend
- Create core authentication
- Build Customer Website
- Build Customer Mobile App base
- Create Products Page
- Create Contact Page
- Create Online Order Form

## Day 2 - Internal Management System

- Build Admin Website Dashboard
- Build Admin Mobile App base
- Build Staff Website Dashboard
- Build Staff Mobile App base
- Create Material Management
- Create Purchase Management
- Create Stock Management
- Create Production Management

## Day 3 - Workers, Sales and Final Testing

- Worker Management
- Attendance System
- Salary Management
- Agent Sales
- Store Sales
- Online Order Management
- Dashboard Reports
- Full Testing
- Bug Fixing

---

# 27. Final Project Goal

The Deeba Match House platform will provide one complete digital system for:

- Customer Website and Mobile App
- Online Orders
- Company Products
- Raw Materials
- Purchases
- Stock
- Production
- Finished Products
- Sales
- Agents
- Stores
- Workers
- Attendance
- Salaries
- Admin Operations
- Staff Operations

The system will use Flutter for the Website and Mobile Apps, Java Spring Boot for the backend, and MongoDB for data management.

