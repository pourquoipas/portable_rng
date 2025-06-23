// lib/src/rng_state.dart

/// Rappresenta lo stato immutabile del generatore di numeri pseudo-casuali.
///
/// Contiene il seed corrente e un contatore di iterazioni. Essendo immutabile,
/// ogni operazione di generazione non modifica questo stato, ma ne crea uno nuovo.
class RNGState {
  /// Il seed a 64-bit da cui vengono derivati tutti i numeri casuali.
  final int seed;

  /// Il numero di volte che il generatore è stato chiamato.
  final int iterations;

  const RNGState(this.seed, this.iterations);

  /// Crea lo stato iniziale del generatore.
  factory RNGState.initial(int seed) {
    // Un seed pari a 0 bloccherebbe l'algoritmo. Lo modifichiamo per sicurezza.
    return RNGState(seed == 0 ? 1 : seed, 0);
  }

  @override
  String toString() {
    return 'RNGState(seed: $seed, iterations: $iterations)';
  }
}

/// Contiene il risultato di un'operazione di generazione casuale.
///
/// Incapsula sia il valore generato (`value`) sia il nuovo stato (`nextState`)
/// da usare per la chiamata successiva.
class RNGResult<T> {
  /// Il valore casuale generato (es. int, double).
  final T value;

  /// Lo stato del generatore dopo questa generazione.
  final RNGState nextState;

  const RNGResult(this.value, this.nextState);

  @override
  String toString() {
    return 'RNGResult(value: $value, nextState: $nextState)';
  }
}
