import 'package:app_firebase/models/usuario_model.dart';
import 'package:app_firebase/services/firestore_service.dart';
import 'package:app_firebase/usuarios_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'UsuarioModel conserva exactamente los nombres de campos de Firestore',
    () {
      const usuario = UsuarioModel(
        email: 'iramirez@ucol.mx',
        nombre: 'Iramirez',
        numeroDeCuenta: '20214559',
      );

      expect(usuario.toMap(), {
        'email': 'iramirez@ucol.mx',
        'nombre ': 'Iramirez',
        'numero de cuenta': '20214559',
      });
    },
  );

  testWidgets('la pantalla muestra usuarios recibidos del servicio', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: UsuariosPage(service: _FakeUsuarioRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Iramirez'), findsOneWidget);
    expect(find.text('iramirez@ucol.mx\nCuenta: 20214559'), findsOneWidget);
  });

  testWidgets('cada usuario se puede modificar y eliminar', (tester) async {
    final service = _FakeUsuarioRepository(
      users: [
        const UsuarioModel(
          id: 'id-1',
          nombre: '',
          email: 'iramirez@ucol.mx',
          numeroDeCuenta: '20214559',
          dataWarnings: ['El campo "nombre " falta o no es de tipo String.'],
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp(home: UsuariosPage(service: service)));
    await tester.pumpAndSettle();

    expect(find.text('(sin nombre)'), findsOneWidget);
    expect(find.textContaining('Revisar datos:'), findsOneWidget);
    await tester.tap(find.byTooltip('Editar usuario'));
    await tester.pumpAndSettle();
    final editFields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(editFields.first, 'Nombre actualizado');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(service.updatedUser?.nombre, 'Nombre actualizado');
    expect(service.updatedId, 'id-1');

    await tester.tap(find.byTooltip('Eliminar usuario'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(service.deletedId, 'id-1');
  });
}

class _FakeUsuarioRepository implements UsuarioRepository {
  _FakeUsuarioRepository({
    this.users = const [
      UsuarioModel(
        id: 'id-1',
        nombre: 'Iramirez',
        email: 'iramirez@ucol.mx',
        numeroDeCuenta: '20214559',
      ),
    ],
  });

  final List<UsuarioModel> users;
  UsuarioModel? updatedUser;
  String? updatedId;
  String? deletedId;

  @override
  Future<String> crearUsuario(UsuarioModel usuario) async => 'nuevo-id';

  @override
  Future<List<UsuarioModel>> buscarPorEmail(String email) async => [];

  @override
  Future<List<UsuarioModel>> buscarPorNumeroDeCuenta(
    String numeroDeCuenta,
  ) async => [];

  @override
  Future<void> actualizarUsuario(String id, UsuarioModel usuario) async {
    updatedId = id;
    updatedUser = usuario;
  }

  @override
  Future<void> eliminarUsuario(String id) async {
    deletedId = id;
  }

  @override
  Stream<List<UsuarioModel>> obtenerUsuarios() => Stream.value(users);
}
