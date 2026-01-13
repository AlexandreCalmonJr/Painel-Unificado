// File: test/utils/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:painel_windowns/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('validateUsername', () {
      test('retorna null para username válido', () {
        expect(Validators.validateUsername('validuser'), null);
        expect(Validators.validateUsername('user_123'), null);
        expect(Validators.validateUsername('ABC'), null);
      });

      test('retorna erro para username vazio', () {
        expect(Validators.validateUsername(''), isNotNull);
        expect(Validators.validateUsername(null), isNotNull);
      });

      test('retorna erro para username muito curto', () {
        expect(Validators.validateUsername('ab'), isNotNull);
      });

      test('retorna erro para username com caracteres inválidos', () {
        expect(Validators.validateUsername('user@123'), isNotNull);
        expect(Validators.validateUsername('user name'), isNotNull);
        expect(Validators.validateUsername('user-name'), isNotNull);
      });
    });

    group('validatePassword', () {
      test('retorna null para senha válida', () {
        expect(Validators.validatePassword('Password123'), null);
        expect(Validators.validatePassword('MyPass1234'), null);
      });

      test('retorna erro para senha vazia', () {
        expect(Validators.validatePassword(''), isNotNull);
        expect(Validators.validatePassword(null), isNotNull);
      });

      test('retorna erro para senha muito curta', () {
        expect(Validators.validatePassword('Pass1'), isNotNull);
      });

      test('retorna erro para senha sem maiúscula', () {
        expect(Validators.validatePassword('password123'), isNotNull);
      });

      test('retorna erro para senha sem minúscula', () {
        expect(Validators.validatePassword('PASSWORD123'), isNotNull);
      });

      test('retorna erro para senha sem número', () {
        expect(Validators.validatePassword('PasswordABC'), isNotNull);
      });
    });

    group('validateIP', () {
      test('retorna null para IP válido', () {
        expect(Validators.validateIP('192.168.0.1'), null);
        expect(Validators.validateIP('10.0.0.1'), null);
        expect(Validators.validateIP('255.255.255.255'), null);
      });

      test('retorna erro para IP vazio', () {
        expect(Validators.validateIP(''), isNotNull);
        expect(Validators.validateIP(null), isNotNull);
      });

      test('retorna erro para IP inválido', () {
        expect(Validators.validateIP('256.1.1.1'), isNotNull);
        expect(Validators.validateIP('192.168.0'), isNotNull);
        expect(Validators.validateIP('abc.def.ghi.jkl'), isNotNull);
      });
    });

    group('validatePort', () {
      test('retorna null para porta válida', () {
        expect(Validators.validatePort('80'), null);
        expect(Validators.validatePort('3000'), null);
        expect(Validators.validatePort('65535'), null);
      });

      test('retorna erro para porta vazia', () {
        expect(Validators.validatePort(''), isNotNull);
        expect(Validators.validatePort(null), isNotNull);
      });

      test('retorna erro para porta inválida', () {
        expect(Validators.validatePort('0'), isNotNull);
        expect(Validators.validatePort('65536'), isNotNull);
        expect(Validators.validatePort('abc'), isNotNull);
      });
    });

    group('validateEmail', () {
      test('retorna null para email válido', () {
        expect(Validators.validateEmail('test@example.com'), null);
        expect(Validators.validateEmail('user.name@domain.co.uk'), null);
      });

      test('retorna erro para email vazio', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
      });

      test('retorna erro para email inválido', () {
        expect(Validators.validateEmail('invalid'), isNotNull);
        expect(Validators.validateEmail('test@'), isNotNull);
        expect(Validators.validateEmail('@example.com'), isNotNull);
      });
    });

    group('validateMacAddress', () {
      test('retorna null para MAC válido', () {
        expect(Validators.validateMacAddress('AA:BB:CC:DD:EE:FF'), null);
        expect(Validators.validateMacAddress('00:11:22:33:44:55'), null);
        expect(Validators.validateMacAddress('aa-bb-cc-dd-ee-ff'), null);
      });

      test('retorna erro para MAC vazio', () {
        expect(Validators.validateMacAddress(''), isNotNull);
        expect(Validators.validateMacAddress(null), isNotNull);
      });

      test('retorna erro para MAC inválido', () {
        expect(Validators.validateMacAddress('AA:BB:CC:DD:EE'), isNotNull);
        expect(Validators.validateMacAddress('GG:HH:II:JJ:KK:LL'), isNotNull);
      });
    });
  });
}
