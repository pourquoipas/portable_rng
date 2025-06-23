// lib/src/rng_value_converter.dart

/// Classe di utility per convertire un valore grezzo a 64-bit generato da
/// PortableRNG in tipi di dato specifici.
///
/// Queste funzioni sono "pure": non hanno stato e si limitano a
/// trasformare un input in un output.
class RNGValueConverter {

  /// Converte un valore grezzo in un booleano (true/false).
  static bool asBool(int rawValue) {
    // Usa il bit più significativo (il segno del numero).
    return rawValue < 0;
  }

  /// Converte un valore grezzo in un double nell'intervallo [0.0, 1.0).
  ///
  /// Se `includeZero` è false, l'intervallo diventa (0.0, 1.0].
  static double asDouble(int rawValue, {bool includeZero = true}) {
    // Usa i 53 bit più significativi (precisione di un double).
    var result = (rawValue >>> 11) * (1.0 / (1 << 53));
    if (!includeZero && result == 0.0) {
      return 1.0;
    }
    return result;
  }

  /// Converte un valore grezzo in un intero nell'intervallo [min, max).
  /// `max` è escluso.
  static int asIntRange(int rawValue, int min, int max) {
    if (min >= max) {
      throw ArgumentError('Il valore minimo deve essere minore del massimo.');
    }
    final range = max - min;
    // Mappa il valore nell'intervallo usando l'operatore modulo.
    return min + (rawValue.abs() % range);
  }
}
