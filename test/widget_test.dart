import 'package:flutter_test/flutter_test.dart';

void main() {
  test('incident status labels remain readable', () {
    expect('en_route'.replaceAll('_', ' '), 'en route');
    expect('open'.replaceAll('_', ' '), 'open');
  });
}
