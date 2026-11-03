import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/deeba_models.dart';

class PrintingService {
  static final PrintingService instance = PrintingService._internal();
  PrintingService._internal();

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }

  // ===========================================================================
  // 1. DAILY FACTORY PRODUCTION & STOCK SLIP (Paper Slip Digitized Print)
  // ===========================================================================
  Future<void> printDailyFactorySheet(DailyProductionSheet sheet) async {
    final pdf = pw.Document();

    final eaaBundles = sheet.brandRows
        .where((r) => r.brand.toLowerCase().contains('eagle'))
        .fold(0.0, (s, r) => s + r.producedBundles);
    final plBundles = sheet.brandRows
        .where((r) => r.brand.toLowerCase().contains('pulli'))
        .fold(0.0, (s, r) => s + r.producedBundles);
    final jokBundles = sheet.brandRows
        .where((r) => r.brand.toLowerCase().contains('joker'))
        .fold(0.0, (s, r) => s + r.producedBundles);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.teal800, width: 1.5),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DEEBA MATCH WORKS',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal900,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Daily Production, Stock & Sales Report Slip',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          'Safety Matchbox Factory - Sivakasi, Tamil Nadu',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Slip ID: ${sheet.sheetId.isNotEmpty ? sheet.sheetId : "SLIP-TODAY"}',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Date: ${sheet.date} (${sheet.dayOfWeek})',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal800,
                          ),
                        ),
                        pw.Text(
                          'Recorded By: ${sheet.recordedBy}',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // SECTION 1: MACHINE & FRAME MATHEMATICS
              pw.Text(
                '1. Machine Output & Frame Balance Mathematics',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
              ),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _th('Metric'),
                      _th('Value / Calculation'),
                      _th('Frame Balances'),
                      _th('Count'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _td('Total Matchboxes Produced'),
                      _tdBold('${sheet.totalBoxes} Boxes'),
                      _td('Adappu Frames Fed'),
                      _tdBold('${sheet.adappuFrames} Frames'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _td('Avg Boxes per Frame'),
                      _td('${sheet.avgBoxesPerFrame.toStringAsFixed(1)} Boxes/Frm'),
                      _td('Dipping Frames Today'),
                      _td('${sheet.dippingFrames} Frames'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _td('Gross Count (1 Gross = 144)'),
                      _td('${sheet.grossCount.toStringAsFixed(1)} Gross'),
                      _td('Closing Balance Frames'),
                      _tdBold('${sheet.balanceFrames} Frames', color: PdfColors.teal900),
                    ],
                  ),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.teal50),
                    children: [
                      _tdBold('Total Bundles (1 Bdl = 600)'),
                      _tdBold('${sheet.totalBundlesProduced} Bundles', color: PdfColors.teal900),
                      _tdBold('Produced by Brand'),
                      _td('EAA: ${eaaBundles.toInt()} | PL: ${plBundles.toInt()} | JOK: ${jokBundles.toInt()}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 14),

              // SECTION 2: BRAND STOCK RECONCILIATION
              pw.Text(
                '2. Master Brand Stock Reconciliation (Opening + Produced - Sales = Closing)',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
              ),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _th('Brand Name'),
                      _th('Price Category'),
                      _th('Opening Stock'),
                      _th('Produced (Madippu)'),
                      _th('Total Available'),
                      _th('Sales Bundles'),
                      _th('Closing Stock'),
                    ],
                  ),
                  ...sheet.brandRows.map((r) => pw.TableRow(
                        children: [
                          _tdBold(r.brand),
                          _td(r.priceCategory),
                          _td(r.openingStock.toInt().toString()),
                          _td(r.producedBundles > 0 ? '+${r.producedBundles.toInt()}' : '0',
                              color: r.producedBundles > 0 ? PdfColors.blue800 : PdfColors.black),
                          _tdBold(r.totalAvailable.toInt().toString()),
                          _td(r.salesBundles > 0 ? '-${r.salesBundles.toInt()}' : '0',
                              color: r.salesBundles > 0 ? PdfColors.red800 : PdfColors.black),
                          _tdBold(r.closingStock.toInt().toString(), color: PdfColors.teal900),
                        ],
                      )),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.teal50),
                    children: [
                      _tdBold('TOTAL BUNDLES'),
                      _td('-'),
                      _tdBold(sheet.totalOpeningBundles.toInt().toString()),
                      _tdBold('+${sheet.totalProducedBundles.toInt()}'),
                      _tdBold(sheet.totalAvailableBundles.toInt().toString()),
                      _tdBold('-${sheet.totalSalesBundles.toInt()}'),
                      _tdBold(sheet.totalClosingBundles.toInt().toString(), color: PdfColors.teal900),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 14),

              // SECTION 3: COMPANY INWARD, OUTWARD & CLOSING NOTES
              pw.Text(
                '3. Company Lines Material Movement & Closing Card',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Company Material Inward (Kozhumuthal):',
                                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                              pw.Text(
                                sheet.companyMaterialInward.isNotEmpty
                                    ? sheet.companyMaterialInward
                                    : 'Nil / No material inwards recorded today.',
                                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 14),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Company Material Outward (Issue):',
                                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                              pw.Text(
                                sheet.companyMaterialOutward.isNotEmpty
                                    ? sheet.companyMaterialOutward
                                    : 'Nil / No materials issued outwards today.',
                                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Divider(color: PdfColors.grey300),
                    pw.Text('Closing Card & Brand Notes (Card Kurippu):',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                      sheet.closingCardNote.isNotEmpty
                          ? sheet.closingCardNote
                          : 'Daily floor audit verified & stock matched physical warehouse balances.',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),

              // SIGNATURES
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 160, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Floor Supervisor Signature',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('(${sheet.recordedBy})',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(width: 160, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Factory Owner / Manager Signature',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Deeba Match Works, Sivakasi',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Daily_Slip_${sheet.date.replaceAll('/', '_')}.pdf',
    );
  }

  // ===========================================================================
  // 2. KADAI & AGENT SALES TAX / COMMERCIAL INVOICE (A4 / A5 Format)
  // ===========================================================================
  Future<void> printSalesInvoiceA4(SaleRecord sale) async {
    final pdf = pw.Document();
    final totalAmt = sale.totalAmount;
    final received = sale.amountReceived;
    final balance = sale.pendingAmount;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'DEEBA MATCH WORKS',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text('Manufacturers of Safety Matches (Eagle, Pulli, Joker)',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Factory & Head Office: Sivakasi, Tamil Nadu - 626123',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.Text('Phone: 9842100000 | Email: sales@deebamatchworks.com',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: balance <= 0 ? PdfColors.green100 : PdfColors.amber100,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(
                          balance <= 0 ? 'PAID IN FULL' : 'PAYMENT PENDING',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: balance <= 0 ? PdfColors.green900 : PdfColors.amber900,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('COMMERCIAL SALES INVOICE',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Invoice #: ${sale.id}',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        'Date: ${_formatDate(sale.salesDate)}',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: PdfColors.grey400, thickness: 1),
              pw.SizedBox(height: 8),

              // Billed To
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Billed To (Kadai / Agent):',
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text(sale.partyName,
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        if (sale.address.isNotEmpty)
                          pw.Text(sale.address, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                        pw.Text('Mobile: ${sale.mobileNumber.isNotEmpty ? sale.mobileNumber : "N/A"}',
                            style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Customer Type:',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        pw.Text(sale.customerType.label.toUpperCase(),
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('Sales Representative:',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        pw.Text(sale.recordedBy,
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _th('S.No'),
                      _th('Item Description'),
                      _th('Price Category'),
                      _th('Quantity (Bundles)'),
                      _th('Rate / Bundle (Rs.)'),
                      _th('Total Amount (Rs.)'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _td('1'),
                      _tdBold('${sale.productBrand} Safety Matches (600 Boxes/Bdl)'),
                      _td(sale.priceCategory),
                      _tdBold('${sale.quantity.toInt()} Bundles'),
                      _td('Rs. ${sale.salePrice.toStringAsFixed(0)}'),
                      _tdBold('Rs. ${totalAmt.toStringAsFixed(0)}', color: PdfColors.blue900),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 240,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Column(
                      children: [
                        _totalRow('Sub Total:', 'Rs. ${totalAmt.toStringAsFixed(0)}'),
                        _totalRow('Amount Paid:', 'Rs. ${received.toStringAsFixed(0)}',
                            color: PdfColors.green800),
                        pw.Divider(color: PdfColors.grey400),
                        _totalRow('Balance Due:', 'Rs. ${balance.toStringAsFixed(0)}',
                            bold: true,
                            color: balance > 0 ? PdfColors.red900 : PdfColors.green900),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // Terms & Conditions
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Terms & Conditions:',
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text('1. Goods once sold will not be taken back or exchanged.',
                        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                    pw.Text('2. Any complaints regarding bundle counts must be reported within 24 hours of delivery.',
                        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                    pw.Text('3. All disputes are subject to Sivakasi Jurisdiction.',
                        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Customer / Receiver Signature',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('For DEEBA MATCH WORKS',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Authorized Signatory',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Sales_Invoice_${sale.id}.pdf',
    );
  }

  // ===========================================================================
  // 3. THERMAL RECEIPT PRINT (58mm / 80mm Bluetooth Lorry / POS Slip)
  // ===========================================================================
  Future<void> printSalesReceiptThermal(SaleRecord sale) async {
    final pdf = pw.Document();
    final totalAmt = sale.totalAmount;
    final received = sale.amountReceived;
    final balance = sale.pendingAmount;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('DEEBA MATCH WORKS',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text('Sivakasi, Tamil Nadu', style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Ph: 9842100000', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 4),
              pw.Text('--------------------------------', style: const pw.TextStyle(fontSize: 8)),
              pw.Text('DELIVERY & CASH SLIP',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text('--------------------------------', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 4),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Bill #: ${sale.id}', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(_formatDate(sale.salesDate),
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('Kadai: ${sale.partyName}',
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ),
              if (sale.mobileNumber.isNotEmpty)
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text('Ph: ${sale.mobileNumber}', style: const pw.TextStyle(fontSize: 8)),
                ),
              pw.SizedBox(height: 4),
              pw.Text('--------------------------------', style: const pw.TextStyle(fontSize: 8)),

              // Item row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${sale.productBrand} (${sale.priceCategory})',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${sale.quantity.toInt()} Bdl',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Rate: Rs. ${sale.salePrice.toStringAsFixed(0)}/Bdl',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.Text('Rs. ${totalAmt.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Text('--------------------------------', style: const pw.TextStyle(fontSize: 8)),

              // Amount summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Bill:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text('Rs. ${totalAmt.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Cash Paid:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text('Rs. ${received.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Balance Due:',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Rs. ${balance.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Text('--------------------------------', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 10),
              pw.Text('Driver / Receiver Signature', style: const pw.TextStyle(fontSize: 7)),
              pw.SizedBox(height: 16),
              pw.Text('*** THANK YOU ***',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Thermal_Slip_${sale.id}.pdf',
    );
  }

  // Helpers
  static pw.Widget _th(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
      ),
    );
  }

  static pw.Widget _td(String text, {PdfColor color = PdfColors.black}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 8, color: color)),
    );
  }

  static pw.Widget _tdBold(String text, {PdfColor color = PdfColors.black}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: color),
      ),
    );
  }

  static pw.Widget _totalRow(String label, String value,
      {bool bold = false, PdfColor color = PdfColors.black}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }
}
