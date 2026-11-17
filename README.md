# Flutter + Firebase Cloud Firestore

La aplicación está configurada para el proyecto Firebase `flutterappfirebase-792bf`.
`firebase_core` y `cloud_firestore` están declarados en `pubspec.yaml`; las opciones
de plataforma están en `lib/firebase_options.dart`.

## Inicialización

`lib/main.dart` inicializa Firebase antes de mostrar la aplicación:

```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

En un proyecto nuevo, las dependencias se agregan con:

```bash
flutter pub add firebase_core cloud_firestore
```

## Colección `usuarios`

`lib/models/usuario_model.dart` convierte los documentos y conserva exactamente
los nombres de campo definidos en Firestore, incluido el espacio final en
`nombre `. Al leer, también acepta el campo `nombre` sin espacio para mostrar
documentos existentes guardados con ese nombre. Los campos ausentes o que no
sean texto se muestran como advertencias en la lista, donde se pueden corregir
o eliminar; al crear o editar, se guardan los nombres correctos.

- `email` (String)
- `nombre ` (String)
- `numero de cuenta` (String)

`lib/services/firestore_service.dart` implementa creación con ID automático,
lectura en tiempo real, búsquedas exactas por email o número de cuenta,
actualización y eliminación. La pantalla en `lib/usuarios_page.dart` permite
registrar usuarios y listar, modificar o eliminar cada registro.

Las reglas de Firestore deben permitir estas operaciones para la aplicación
(idealmente con autenticación y permisos adecuados); los errores de acceso se
muestran en la interfaz.
