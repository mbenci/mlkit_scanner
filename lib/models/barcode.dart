/// Barcode formats supported by the barcode scanner.
/// Options for specifying the barcode formats that the library can detect.
enum BarcodeFormat {
  /// Barcode format representing all supported formats.
  all,

  /// Barcode format unknown to the current SDK.
  unknown,

  /// Barcode format constant for Code 128.
  code128,

  /// Barcode format constant for Code 39.
  code39,

  /// Barcode format constant for Code 93.
  code93,

  /// Barcode format constant for CodaBar.
  codabar,

  /// Barcode format constant for Data Matrix.
  dataMatrix,

  /// Barcode format constant for EAN-13.
  ean13,

  /// Barcode format constant for EAN-8.
  ean8,

  /// Barcode format constant for ITF (Interleaved Two-of-Five).
  itf,

  /// Barcode format constant for QR Code.
  qrCode,

  /// Barcode format constant for UPC-A.
  upca,

  /// Barcode format constant for UPC-E.
  upce,

  /// Barcode format constant for PDF-417.
  pdf417,

  /// Barcode format constant for AZTEC.
  aztec,
}

extension BarcodeFormatValue on BarcodeFormat {
  int get rawValue {
    switch (this) {
      case BarcodeFormat.all:
        return 0xFFFF;
      case BarcodeFormat.unknown:
        return 0;
      case BarcodeFormat.code128:
        return 0x0001;
      case BarcodeFormat.code39:
        return 0x0002;
      case BarcodeFormat.code93:
        return 0x0004;
      case BarcodeFormat.codabar:
        return 0x0008;
      case BarcodeFormat.dataMatrix:
        return 0x0010;
      case BarcodeFormat.ean13:
        return 0x0020;
      case BarcodeFormat.ean8:
        return 0x0040;
      case BarcodeFormat.itf:
        return 0x0080;
      case BarcodeFormat.qrCode:
        return 0x0100;
      case BarcodeFormat.upca:
        return 0x0200;
      case BarcodeFormat.upce:
        return 0x0400;
      case BarcodeFormat.pdf417:
        return 0x0800;
      case BarcodeFormat.aztec:
        return 0x1000;
    }
  }

  static BarcodeFormat fromRawValue(int rawValue) {
    return BarcodeFormat.values.firstWhere(
        (element) => element.rawValue == rawValue,
        orElse: () => BarcodeFormat.unknown);
  }
}

/// [Barcode] types returned by [BarcodeScanner].
enum BarcodeType {
  /// Unknown Barcode value types.
  unknown,

  /// Barcode value type for contact info.
  contactInfo,

  /// Barcode value type for email addresses.
  email,

  /// Barcode value type for ISBNs.
  isbn,

  /// Barcode value type for phone numbers.
  phone,

  /// Barcode value type for product codes.
  product,

  /// Barcode value type for SMS details.
  sms,

  /// Barcode value type for plain text.
  text,

  /// Barcode value type for URLs/bookmarks.
  url,

  /// Barcode value type for Wi-Fi access point details.
  wifi,

  /// Barcode value type for geo coordinates.
  geoCoordinates,

  /// Barcode value type for calendar events.
  calendarEvent,

  /// Barcode value type for driver's license data.
  driverLicense,
}

/// A class to represent the contents of a barcode in an [InputImage].
class Barcode {
  /// The format type of the barcode value.
  ///
  /// For example, [BarcodeType.text], [BarcodeType.product], [BarcodeType.url], etc.
  ///
  final BarcodeType type;

  /// The format (symbology) of the barcode value.
  ///
  /// For example, [BarcodeFormat.upca], [BarcodeFormat.code128], [BarcodeFormat.dataMatrix]
  final BarcodeFormat format;

  /// A barcode value in a user-friendly format.
  /// This value may be multiline, for example, when line breaks are encoded into the original TEXT barcode value.
  /// May include the supplement value.
  ///
  /// Null if nothing found.
  final String? displayValue;

  /// A barcode value as it was encoded in the barcode.
  ///
  /// Null if nothing found.
  final String? rawValue;

  /// Constructor to create an instance of [Barcode].
  Barcode({
    required this.type,
    required this.format,
    required this.displayValue,
    required this.rawValue,
  });

  /// Returns an instance of [Barcode] from a given [json].
  factory Barcode.fromMap(Map<dynamic, dynamic> map) {
    final type = BarcodeType.values[map['type'] ?? 0.toInt()];
    final format = BarcodeFormatValue.fromRawValue(map['format']);
    final displayValue = map['displayValue'];
    final rawValue = map['rawValue'];

    return Barcode(
      type: type,
      format: format,
      displayValue: displayValue,
      rawValue: rawValue,
    );
  }
}
