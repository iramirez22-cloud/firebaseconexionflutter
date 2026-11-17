import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  const UsuarioModel({
    required this.email,
    required this.nombre,
    required this.numeroDeCuenta,
    this.id,
    this.dataWarnings = const [],
  });

  final String? id;
  final String email;
  final String nombre;
  final String numeroDeCuenta;
  final List<String> dataWarnings;

  factory UsuarioModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final warnings = <String>[];

    String readString(String key) {
      final value = data?[key];
      if (value is! String) {
        warnings.add('El campo "$key" falta o no es de tipo String.');
        return '';
      }
      return value;
    }

    String readName() {
      final exactName = data?['nombre '];
      if (exactName is String) return exactName;

      final legacyName = data?['nombre'];
      if (legacyName is String) {
        warnings.add(
          'El campo "nombre" no tiene el espacio final; edítalo para corregirlo.',
        );
        return legacyName;
      }

      warnings.add('El campo "nombre " falta o no es de tipo String.');
      return '';
    }

    return UsuarioModel(
      id: snapshot.id,
      email: readString('email'),
      nombre: readName(),
      numeroDeCuenta: readString('numero de cuenta'),
      dataWarnings: warnings,
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'nombre ': nombre,
    'numero de cuenta': numeroDeCuenta,
  };
}
