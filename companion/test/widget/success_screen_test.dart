import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:companion/core/ypt_auth_service.dart';
import 'package:companion/screens/success_screen.dart';

void main() {
  const mockAuthResult = YptAuthResult(
    jwt: 'test_jwt_qr_payload_123',
    email: 'estudante@ypt.com',
    name: 'Estudante Dedicado',
  );

  testWidgets('SuccessScreen renders user profile, QR code and action buttons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SuccessScreen(authResult: mockAuthResult),
      ),
    );

    expect(find.text('Sessão Autenticada'), findsOneWidget);
    expect(find.text('Estudante Dedicado'), findsOneWidget);
    expect(find.text('estudante@ypt.com'), findsOneWidget);
    expect(find.text('Código de Pareamento QR Code'), findsOneWidget);
    expect(find.text('Copiar Token'), findsOneWidget);
    expect(find.text('Compartilhar'), findsOneWidget);
  });
}
