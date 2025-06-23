# PortableRNG

A simple, deterministic, and portable pseudo-random number generator (PRNG) for Dart.

---

## Overview

**PortableRNG** is a lightweight library that provides a predictable sequence of pseudo-random numbers from an initial seed. Unlike standard library generators, it guarantees that the same seed will always produce the exact same sequence of numbers, even across different platforms and languages (like Java or JavaScript), provided the algorithm is implemented correctly.

The core algorithm is **xorshift64***, chosen for its speed, simplicity, and good statistical properties.

## Scope and Features

The primary goal of this library is **reproducibility** and **verifiability**.

* **Deterministic Generation**: The entire sequence of numbers is solely determined by an initial integer seed.
* **Stateful but Pure**: The generator's state (seed and iteration count) is not hidden. Each call to generate a number takes the current state and returns both the result and the *next* state, promoting a pure functional style.
* **Sequence Verification**: The library includes a utility to verify if a final number in a sequence is valid. Given an initial seed, the number of steps (iterations), and a final seed, you can confirm that no data has been tampered with.
* **Portability**: The underlying algorithm uses standard 64-bit integer operations, making it straightforward to port to other languages for consistent results.

## Core Concepts

The library is built on a clear separation of concerns:

1.  `RNGState`: An immutable class that holds the generator's current state (`seed` and `iterations`).
2.  `PortableRNG`: A static class responsible for advancing the generator's state. Its main function, `next()`, produces the next raw 64-bit integer and the next `RNGState`.
3.  `RNGValueConverter`: A static utility class to convert the raw 64-bit integer from `PortableRNG` into useful types like `bool`, `double`, or an `int` within a specific range.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  portable_rng: ^1.0.0 # Replace with the actual version
```

## Usage

### 1. Basic Setup

First, import the library and create an initial state from a seed.

```dart
import 'package:portable_rng/portable_rng.dart';

void main() {
  // 1. Initialize the state with a seed.
  var myState = RNGState.initial(12345);
}
```

### 2. Generating Numbers

To get a random number, you first generate the next "raw" result and then use `RNGValueConverter` to interpret it.

```dart
// 2. Generate the next raw result (value + new state).
var rawResult = PortableRNG.next(myState);

// 3. Use the converter to get the type you need.
int myInt = RNGValueConverter.asIntRange(rawResult.value, 0, 100); // An int between 0 and 99
double myDouble = RNGValueConverter.asDouble(rawResult.value);   // A double between 0.0 and 1.0
bool myBool = RNGValueConverter.asBool(rawResult.value);          // true or false

print("Random Integer: $myInt");
print("Random Double: $myDouble");
print("Random Boolean: $myBool");

// 4. IMPORTANT: Always use the new state for the next generation.
myState = rawResult.nextState;
```

### 3. Generating a Gaussian (Normal) Value

Generating a Gaussian-distributed number requires two cycles of the generator. This logic is handled for you in a dedicated function.

```dart
// The nextGaussian function is a composite operation.
var gaussianResult = PortableRNG.nextGaussian(myState);

print("Gaussian Value: ${gaussianResult.value}");

// The state will have advanced by 2 iterations.
myState = gaussianResult.nextState;
```

### 4. Verifying a Sequence

You can check if a final seed is the correct outcome after a certain number of iterations from a starting seed. This is useful for validating data integrity.

```dart
const initialSeed = 9876;
const iterationsToTest = 10;

// Let's simulate 10 steps to find the expected final seed.
var tempState = RNGState.initial(initialSeed);
for (int i = 0; i < iterationsToTest; i++) {
  tempState = PortableRNG.next(tempState).nextState;
}
final int correctFinalSeed = tempState.seed;

// Now, verify.
bool isConsistent = PortableRNG.verify(
  initialSeed: initialSeed,
  iterations: iterationsToTest,
  expectedFinalSeed: correctFinalSeed,
);

print("Verification successful: $isConsistent"); // true

// A check with a manipulated seed will fail.
bool isFake = PortableRNG.verify(
  initialSeed: initialSeed,
  iterations: iterationsToTest,
  expectedFinalSeed: correctFinalSeed + 1,
);

print("Verification with fake data: $isFake"); // false
```

## License

This project is licensed under the CC BY-NC-SA 4.0 License. See the `LICENSE` file for details.
