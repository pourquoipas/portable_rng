library portable_rng;

// lib/portable_rng.dart

import 'dart:math';

// Importa le dipendenze interne della libreria. In un progetto reale,
// questi percorsi sarebbero relativi alla cartella 'lib'.
import 'src/rng_state.dart';
import 'src/rng_value_converter.dart';

// Esporta le classi pubbliche, così l'utente deve importare solo questo file
// per avere accesso a tutto ciò che serve.
export 'src/rng_state.dart';
export 'src/rng_value_converter.dart';


/// Implementazione di un generatore di numeri pseudo-casuali (PRNG) portabile.
///
/// Questa classe ha la sola responsabilità di far avanzare lo stato del generatore
/// in modo deterministico e riproducibile, basandosi sull'algoritmo xorshift64*.
class PortableRNG {
  // Costante per la moltiplicazione finale dell'algoritmo xorshift64*.
  static const int _multiplier = 0x2545F4914F6CDD1D;

  /// Esegue un singolo passo dell'algoritmo per generare il seed successivo.
  static int _nextSeed(int seed) {
    seed ^= (seed >> 12);
    seed ^= (seed << 25);
    seed ^= (seed >> 27);
    // Maschera per assicurare il comportamento corretto su 64-bit.
    return (seed * _multiplier) & 0xFFFFFFFFFFFFFFFF;
  }

  /// Genera il prossimo valore grezzo a 64-bit e il nuovo stato del generatore.
  /// Questa è la funzione "core" che fa avanzare lo stato di una singola iterazione.
  static RNGResult<int> next(RNGState currentState) {
    final newSeed = _nextSeed(currentState.seed);
    final newState = RNGState(newSeed, currentState.iterations + 1);
    return RNGResult(newSeed, newState);
  }

  /// Genera un numero casuale da una distribuzione Gaussiana (Normale).
  /// NOTA: Richiede due iterazioni del generatore.
  static RNGResult<double> nextGaussian(RNGState currentState) {
    // 1. Genera il primo valore grezzo e convertilo in double
    final res1 = next(currentState);
    // Evita log(0) passando includeZero: false
    final u1 = RNGValueConverter.asDouble(res1.value, includeZero: false);

    // 2. Genera il secondo valore grezzo e convertilo in double
    final res2 = next(res1.nextState);
    final u2 = RNGValueConverter.asDouble(res2.value);

    // 3. Applica la formula di Box-Muller
    final double z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);

    return RNGResult(z0, res2.nextState);
  }

  /// Verifica se un `expectedFinalSeed` è coerente dopo un numero di `iterations`
  /// a partire da un `initialSeed`.
  static bool verify(int initialSeed, int iterations, int expectedFinalSeed) {
    int currentSeed = initialSeed == 0 ? 1 : initialSeed;
    for (int i = 0; i < iterations; i++) {
      currentSeed = _nextSeed(currentSeed);
    }
    return currentSeed == expectedFinalSeed;
  }
}
