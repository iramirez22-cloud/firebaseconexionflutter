import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'models/usuario_model.dart';
import 'services/firestore_service.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key, this.service});

  final UsuarioRepository? service;

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _numeroDeCuentaController = TextEditingController();
  late final UsuarioRepository _service;
  final Set<String> _busyUserIds = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? FirestoreService();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _numeroDeCuentaController.dispose();
    super.dispose();
  }

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _service.crearUsuario(
        UsuarioModel(
          email: _emailController.text.trim(),
          nombre: _nombreController.text.trim(),
          numeroDeCuenta: _numeroDeCuentaController.text.trim(),
        ),
      );
      _formKey.currentState!.reset();
      _nombreController.clear();
      _emailController.clear();
      _numeroDeCuentaController.clear();
      if (mounted) _showMessage('Usuario guardado correctamente.');
    } on FirebaseException catch (error) {
      if (mounted) {
        _showMessage('No se pudo guardar el usuario: ${error.message}');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _editarUsuario(UsuarioModel usuario) async {
    final id = usuario.id;
    if (id == null) return;

    final formKey = GlobalKey<FormState>();
    var nombre = usuario.nombre;
    var email = usuario.email;
    var numeroDeCuenta = usuario.numeroDeCuenta;

    final usuarioActualizado = await showDialog<UsuarioModel>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Modificar usuario'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nombre,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  onSaved: (value) => nombre = value!.trim(),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => email = value!.trim(),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  initialValue: numeroDeCuenta,
                  decoration: const InputDecoration(
                    labelText: 'Número de cuenta',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => numeroDeCuenta = value!.trim(),
                  validator: _requiredValidator,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              formKey.currentState!.save();
              Navigator.pop(
                dialogContext,
                UsuarioModel(
                  id: usuario.id,
                  email: email,
                  nombre: nombre,
                  numeroDeCuenta: numeroDeCuenta,
                ),
              );
            },
            child: const Text('Guardar cambios'),
          ),
        ],
      ),
    );

    if (usuarioActualizado == null || !mounted) return;

    setState(() => _busyUserIds.add(id));
    try {
      await _service.actualizarUsuario(id, usuarioActualizado);
      if (mounted) _showMessage('Usuario actualizado correctamente.');
    } on FirebaseException catch (error) {
      if (mounted) {
        _showMessage('No se pudo actualizar el usuario: ${error.message}');
      }
    } finally {
      if (mounted) setState(() => _busyUserIds.remove(id));
    }
  }

  Future<void> _eliminarUsuario(UsuarioModel usuario) async {
    final id = usuario.id;
    if (id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Deseas eliminar a ${usuario.nombre.isEmpty ? 'este usuario' : usuario.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    setState(() => _busyUserIds.add(id));
    try {
      await _service.eliminarUsuario(id);
      if (mounted) _showMessage('Usuario eliminado correctamente.');
    } on FirebaseException catch (error) {
      if (mounted) {
        _showMessage('No se pudo eliminar el usuario: ${error.message}');
      }
    } finally {
      if (mounted) setState(() => _busyUserIds.remove(id));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Registrar usuario',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  textInputAction: TextInputAction.next,
                  validator: _requiredValidator,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _requiredValidator,
                ),
                TextFormField(
                  controller: _numeroDeCuentaController,
                  decoration: const InputDecoration(
                    labelText: 'Número de cuenta',
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _crearUsuario,
                    child: _isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar usuario'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          Text(
            'Usuarios registrados',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<UsuarioModel>>(
            stream: _service.obtenerUsuarios(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error al cargar usuarios: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final users = snapshot.data ?? const <UsuarioModel>[];
              if (users.isEmpty) return const Text('Aún no hay usuarios.');
              return _buildUserList(users);
            },
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty ? 'Campo obligatorio' : null;

  Widget _buildUserList(List<UsuarioModel> users) {
    if (users.isEmpty) return const Text('No se encontraron usuarios.');
    return Column(
      children: users
          .map(
            (user) => Card(
              child: ListTile(
                title: Text(user.nombre.isEmpty ? '(sin nombre)' : user.nombre),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${user.email}\nCuenta: ${user.numeroDeCuenta}'),
                    if (user.dataWarnings.isNotEmpty)
                      Text(
                        'Revisar datos: ${user.dataWarnings.join(' ')}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
                trailing: user.id == null
                    ? null
                    : _busyUserIds.contains(user.id)
                    ? const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            tooltip: 'Editar usuario',
                            onPressed: () => _editarUsuario(user),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Eliminar usuario',
                            onPressed: () => _eliminarUsuario(user),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
