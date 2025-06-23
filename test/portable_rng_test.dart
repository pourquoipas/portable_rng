// test/portable_rng_test.dart

// Per eseguire questo test, assicurati di avere `flutter_test` (per progetti Flutter)
// o `test` (per pacchetti Dart puri) nelle tue dev_dependencies nel file pubspec.yaml.
import 'package:flutter_test/flutter_test.dart';

// Importa la libreria da testare.
// Il percorso dipende da come è configurato il tuo pacchetto.
import '../lib/portable_rng.dart';

void main() {
  // Gruppo di test per la funzionalità core del generatore
  group('PortableRNG Core Functionality', () {

    test('L\'algoritmo deve essere deterministico', () {
      // Due generatori con lo stesso seed devono produrre la stessa sequenza.
      var state1 = RNGState.initial(123);
      var state2 = RNGState.initial(123);

      for (int i = 0; i < 100; i++) {
        final result1 = PortableRNG.next(state1);
        final result2 = PortableRNG.next(state2);

        // I valori grezzi generati devono essere identici
        expect(result1.value, result2.value);
        // Anche i seed del nuovo stato devono essere identici
        expect(result1.nextState.seed, result2.nextState.seed);

        state1 = result1.nextState;
        state2 = result2.nextState;
      }
    });

    test('La funzione di verifica deve funzionare correttamente', () {
      const initialSeed = 555;
      const iterations = 50;

      var state = RNGState.initial(initialSeed);
      for (int i = 0; i < iterations; i++) {
        state = PortableRNG.next(state).nextState;
      }
      final expectedFinalSeed = state.seed;

      // La verifica con i dati corretti deve passare
      expect(PortableRNG.verify(initialSeed, iterations, expectedFinalSeed), isTrue);

      // La verifica con un seed finale errato deve fallire
      expect(PortableRNG.verify(initialSeed, iterations, expectedFinalSeed + 1), isFalse);

      // La verifica con un numero di iterazioni errato deve fallire
      expect(PortableRNG.verify(initialSeed, iterations - 1, expectedFinalSeed), isFalse);
    });

    test('Un seed iniziale di 0 deve essere gestito correttamente', () {
      // Un seed di 0 bloccherebbe l'algoritmo. La libreria lo converte in 1.
      final state = RNGState.initial(0);
      expect(state.seed, 1);

      // La generazione non deve bloccarsi
      final result = PortableRNG.next(state);
      expect(result.value, isNotNull);
      expect(result.nextState.seed, isNot(0));
    });

    test('Il contatore delle iterazioni deve avanzare correttamente', () {
      var state = RNGState.initial(101);
      expect(state.iterations, 0);

      // La funzione next() avanza di 1
      state = PortableRNG.next(state).nextState;
      expect(state.iterations, 1);
      state = PortableRNG.next(state).nextState;
      expect(state.iterations, 2);
    });

    test('nextGaussian() deve avanzare le iterazioni di 2', () {
      var state = RNGState.initial(102);
      expect(state.iterations, 0);

      // La funzione nextGaussian() è un'operazione composta e avanza di 2
      state = PortableRNG.nextGaussian(state).nextState;
      expect(state.iterations, 2);
    });
  });


  // Gruppo di test per il convertitore di valori
  group('RNGValueConverter', () {
    const rawValue1 = 0x123456789ABCDEF0; // Positivo
    const rawValue2 = 0xFEDCBA9876543210; // Negativo

    test('asBool deve restituire true per negativo, false per positivo', () {
      expect(RNGValueConverter.asBool(rawValue1), isFalse);
      expect(RNGValueConverter.asBool(rawValue2), isTrue);
    });

    test('asDouble deve restituire un valore nell\'intervallo [0.0, 1.0)', () {
      final doubleVal1 = RNGValueConverter.asDouble(rawValue1);
      final doubleVal2 = RNGValueConverter.asDouble(rawValue2);

      expect(doubleVal1, greaterThanOrEqualTo(0.0));
      expect(doubleVal1, lessThan(1.0));

      expect(doubleVal2, greaterThanOrEqualTo(0.0));
      expect(doubleVal2, lessThan(1.0));
    });

    test('asIntRange deve restituire un valore nell\'intervallo corretto', () {
      const min = 10;
      const max = 20; // L'intervallo è [10, 20)

      for (int i = 0; i < 100; i++) {
        // Generiamo 100 valori da semi diversi per testare più casi
        final raw = PortableRNG.next(RNGState.initial(i)).value;
        final val = RNGValueConverter.asIntRange(raw, min, max);

        expect(val, greaterThanOrEqualTo(min));
        expect(val, lessThan(max));
      }
    });

    test('asIntRange deve lanciare un errore se min >= max', () {
      // expect() con un Matcher `throwsArgumentError` verifica che la funzione
      // lanci l'eccezione attesa.
      expect(() => RNGValueConverter.asIntRange(rawValue1, 10, 10), throwsArgumentError);
      expect(() => RNGValueConverter.asIntRange(rawValue1, 20, 10), throwsArgumentError);
    });
  });
}
