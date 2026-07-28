/// Format angka jadi "Rp 15.000" seperti di mockup (Home, Cart, Checkout).
/// Tidak pakai package tambahan supaya ringan.
class CurrencyFormatter {
  static String format(num amount) {
    final str = amount.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromRight = str.length - i;
      buffer.write(str[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp $buffer';
  }
}
