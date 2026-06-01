import 'package:flutter_test/flutter_test.dart';
import 'package:project_armoire/util/extensions.dart';

void main() {
  group('CapExtension', () {
    test('inCaps capitalises the first letter', () {
      expect('left'.inCaps, 'Left');
      expect('a'.inCaps, 'A');
    });

    test('inCaps returns empty for empty input', () {
      expect(''.inCaps, '');
    });

    test('allInCaps upper-cases everything', () {
      expect('left'.allInCaps, 'LEFT');
    });

    test('capitalizeFirstofEach capitalises each word and collapses spaces', () {
      expect('hello there world'.capitalizeFirstofEach, 'Hello There World');
      expect('hello   there'.capitalizeFirstofEach, 'Hello There');
    });
  });
}
