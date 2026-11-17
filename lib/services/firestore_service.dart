import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/usuario_model.dart';

abstract interface class UsuarioRepository {
  Stream<List<UsuarioModel>> obtenerUsuarios();
  Future<String> crearUsuario(UsuarioModel usuario);
  Future<List<UsuarioModel>> buscarPorEmail(String email);
  Future<List<UsuarioModel>> buscarPorNumeroDeCuenta(String numeroDeCuenta);
  Future<void> actualizarUsuario(String id, UsuarioModel usuario);
  Future<void> eliminarUsuario(String id);
}

class FirestoreService implements UsuarioRepository {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _firestore.collection('usuarios');

  @override
  Stream<List<UsuarioModel>> obtenerUsuarios() => _usuarios.snapshots().map(
    (snapshot) =>
        snapshot.docs.map(UsuarioModel.fromFirestore).toList(growable: false),
  );

  @override
  Future<String> crearUsuario(UsuarioModel usuario) async {
    final documento = _usuarios.doc();
    await documento.set(usuario.toMap());
    return documento.id;
  }

  @override
  Future<List<UsuarioModel>> buscarPorEmail(String email) async {
    final resultado = await _usuarios.where('email', isEqualTo: email).get();
    return resultado.docs
        .map(UsuarioModel.fromFirestore)
        .toList(growable: false);
  }

  @override
  Future<List<UsuarioModel>> buscarPorNumeroDeCuenta(
    String numeroDeCuenta,
  ) async {
    final resultado = await _usuarios
        .where('numero de cuenta', isEqualTo: numeroDeCuenta)
        .get();
    return resultado.docs
        .map(UsuarioModel.fromFirestore)
        .toList(growable: false);
  }

  @override
  Future<void> actualizarUsuario(String id, UsuarioModel usuario) =>
      _usuarios.doc(id).set(usuario.toMap());

  @override
  Future<void> eliminarUsuario(String id) => _usuarios.doc(id).delete();
}
