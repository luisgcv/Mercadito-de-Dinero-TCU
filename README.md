# Mercadito de Dinero

Guía técnica para entender, ejecutar y continuar el desarrollo de la aplicación **"Mercadito de Dinero"** del TCU Laboratorio de Matemática, UCR Sede de Occidente.

> Si es la primera vez que trabaja en el proyecto, lea en este orden: [1. Introducción](#1-introducción), [4. Instalación y ejecución](#4-instalación-y-ejecución), [5. Estructura del proyecto](#5-estructura-del-proyecto) y [6. Arquitectura](#6-arquitectura). Después, [11. Estado actual y pendientes](#11-estado-actual-y-pendientes) le indica por dónde seguir.

---

## Tabla de contenidos

1. [Introducción](#1-introducción)
2. [Objetivos](#2-objetivos)
3. [Tecnologías y dependencias](#3-tecnologías-y-dependencias)
4. [Instalación y ejecución](#4-instalación-y-ejecución)
5. [Estructura del proyecto](#5-estructura-del-proyecto)
6. [Arquitectura](#6-arquitectura)
7. [Componentes principales](#7-componentes-principales)
8. [Datos y almacenamiento](#8-datos-y-almacenamiento)
9. [Identidad visual](#9-identidad-visual)
10. [Guías para extender la aplicación](#10-guías-para-extender-la-aplicación)
11. [Estado actual y pendientes](#11-estado-actual-y-pendientes)
12. [Cómo colaborar](#12-cómo-colaborar)
13. [Documentación del código](#13-documentación-del-código)

---

## 1. Introducción

"Mercadito de Dinero" es una aplicación educativa para niñas y niños. Simula una tienda: las personas participantes "compran" productos escaneando sus códigos QR y luego verifican si el dinero que tienen les alcanza y cuánto cambio reciben. Así practican suma, resta y manejo de dinero (colones, ₡).

**Características principales:**

- **Catálogo de productos**: crear y eliminar productos con nombre, precio e imagen. Cada producto recibe automáticamente un código QR único.
- **Exportar QR y catálogo PDF**: descargar el QR de un producto como PNG, o generar un PDF con todos los productos y sus QR para imprimirlos y pegarlos en los productos físicos.
- **Carrito de compras**: agregar productos escaneando su QR con la cámara (suena un "beep" de caja registradora) o buscándolos por nombre. Permite sumar o restar unidades.
- **Finalizar compra**: se ingresa el dinero del estudiante y la app muestra si **le alcanza**, y el **cambio** o el **faltante**.
- **Respaldos ZIP**: exportar, compartir e importar toda la base de datos con sus imágenes, para pasar el catálogo de un dispositivo a otro.
- **Funciona sin internet**: todos los datos se guardan localmente en el dispositivo (SQLite).

**Escenarios de uso:**

1. La persona facilitadora del TCU prepara el catálogo en un dispositivo e imprime los QR (PDF).
2. Durante el taller, los participantes escanean productos y calculan el pago en la pantalla de finalizar compra.
3. El catálogo se comparte a otros dispositivos por medio del respaldo ZIP.

## 2. Objetivos

**Objetivo principal:** ofrecer una herramienta lúdica y accesible que refuerce conceptos matemáticos básicos (operaciones y manejo de dinero) mediante la simulación de compras.

**Objetivos específicos:**

- Brindar una interfaz sencilla, colorida y con íconos grandes, adecuada para niñas y niños.
- Funcionar completamente offline para poder usarse en talleres sin conexión.
- Permitir que el personal del TCU administre fácilmente su propio catálogo de productos.
- Facilitar la distribución del catálogo entre dispositivos.

## 3. Tecnologías y dependencias

El proyecto está hecho en **Flutter** (lenguaje **Dart**). Todas las dependencias se declaran en [pubspec.yaml](pubspec.yaml).

| Paquete | Uso en el proyecto |
|---|---|
| `provider` | Manejo de estado (controladores `ChangeNotifier`). |
| `sqflite`, `path`, `path_provider` | Base de datos SQLite local y rutas de archivos. |
| `mobile_scanner` | Lectura de códigos QR con la cámara. |
| `qr_flutter` | Generación y dibujo de códigos QR. |
| `audioplayers` | Sonido de "beep" al agregar productos al carrito. |
| `file_picker` | Elegir imágenes y archivos ZIP; diálogo "Guardar como". |
| `share_plus` | Compartir el respaldo ZIP. |
| `archive` | Crear y leer archivos ZIP. |
| `pdf`, `printing` | Generar el catálogo PDF y abrir el diálogo de impresión. |
| `permission_handler` | Permisos (declarado; actualmente no se usa directamente en el código). |
| `flutter_launcher_icons` *(dev)* | Generar el ícono de la app. |
| `rename` *(dev)* | Cambiar el nombre visible o el identificador de la app. |

## 4. Instalación y ejecución

### 4.1 Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install), canal *stable*, con **Dart ≥ 3.11.1** (restricción `sdk: ^3.11.1` en `pubspec.yaml`). Verifique su versión con `flutter --version`.
- [Android Studio](https://developer.android.com/studio), con el Android SDK y un emulador, o un teléfono Android con la **depuración USB** activada.
- (Opcional) [Visual Studio Code](https://code.visualstudio.com/) con las extensiones *Flutter* y *Dart*.
- (Opcional, solo para iOS) macOS con Xcode.

Compruebe que todo esté bien instalado:

```bash
flutter doctor
```

### 4.2 Descargar el código

```bash
git clone https://github.com/luisgcv/Mercadito-de-Dinero-TCU.git
cd Mercadito-de-Dinero-TCU
```

> La raíz del repositorio es la carpeta del proyecto Flutter (donde está `pubspec.yaml`).

### 4.3 Instalar dependencias

```bash
flutter pub get
```

### 4.4 Ejecutar en modo desarrollo

Con un emulador abierto o un teléfono conectado:

```bash
flutter devices        # lista los dispositivos disponibles
flutter run            # compila e instala en el dispositivo
```

Mientras la app está corriendo, presione `r` en la terminal para aplicar los cambios (*hot reload*) o `R` para reiniciarla (*hot restart*).

> **Importante:** el escáner QR necesita cámara. En el emulador de Android se puede configurar una cámara virtual, pero es más práctico probar en un teléfono real.

### 4.5 Generar el instalador (APK)

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk` y se puede copiar al teléfono para instalarlo.

> Actualmente la versión *release* se firma con la llave de depuración (configuración por defecto de Flutter). Para publicar en Play Store hay que [configurar una llave de firma](https://docs.flutter.dev/deployment/android#sign-the-app) y cambiar el `applicationId` (ver [pendientes](#11-estado-actual-y-pendientes)).

### 4.6 Otros comandos útiles

```bash
flutter analyze                          # análisis estático (lints)
flutter test                             # pruebas automatizadas
dart run flutter_launcher_icons          # regenerar el ícono de la app
flutter clean && flutter pub get         # limpiar si algo falla al compilar
```

## 5. Estructura del proyecto

Solo se detallan las carpetas relevantes para el desarrollo. Las carpetas `android/`, `ios/`, `web/`, `windows/`, `linux/` y `macos/` son generadas por Flutter y casi no se modifican (salvo permisos y configuración nativa).

```
├── pubspec.yaml                 = Dependencias, assets y configuración del ícono
├── README.md                    = Este documento
├── docs/
│   └── identidad_visual.md      = Paleta de colores y lineamientos visuales
├── assets/                      = Recursos incluidos en la app
│   ├── icon/                    = Logos (logo_app2.png se usa como ícono del lanzador)
│   └── sounds/
│       └── success.mp3          = Sonido al agregar un producto al carrito
├── android/app/src/main/
│   └── AndroidManifest.xml      = Permisos Android (cámara, almacenamiento) y nombre visible
├── ios/Runner/Info.plist        = Permisos iOS (cámara, fotos)
├── test/
│   └── widget_test.dart         = Prueba de ejemplo (plantilla, ver pendientes)
└── lib/                         = TODO el código Dart de la app
    ├── main.dart                = Punto de entrada: registra los controladores y el tema
    ├── models/                  = Clases de datos (sin lógica)
    │   ├── producto.dart        = Producto (nombre, precio, código QR, imagen)
    │   └── carrito_item.dart    = Línea del carrito (producto + cantidad)
    ├── database/
    │   └── database_helper.dart = Conexión SQLite, esquema, migraciones y consultas
    ├── services/                = Lógica de negocio (sin widgets)
    │   ├── producto_service.dart       = CRUD de productos + manejo de su imagen
    │   ├── carrito_service.dart        = Lógica del carrito en memoria
    │   ├── image_storage_service.dart  = Copiar, borrar y resolver rutas de imágenes
    │   ├── import_export_service.dart  = Respaldo ZIP (exportar / compartir / importar)
    │   ├── pdf_export_service.dart     = Catálogo PDF con QR
    │   └── audio_service.dart          = Efectos de sonido
    ├── controllers/             = Estado observable (ChangeNotifier + Provider)
    │   ├── producto_controller.dart       = Lista de productos, imagen seleccionada, errores
    │   ├── carrito_controller.dart        = Carrito y total
    │   └── import_export_controller.dart  = Estado "cargando" de los respaldos
    ├── screens/                 = Pantallas (interfaz)
    │   ├── splash_screen.dart          = Bienvenida animada
    │   ├── home_screen.dart            = Menú principal
    │   ├── productos_screen.dart       = Lista de productos, QR, PDF
    │   ├── producto_form_screen.dart   = Formulario de nuevo producto
    │   ├── carrito_screen.dart         = Carrito de compras
    │   ├── scanner_screen.dart         = Escáner QR con cámara
    │   ├── checkout_result_screen.dart = ¿Le alcanza? Cambio / faltante
    │   └── import_export_screen.dart   = Respaldos ZIP
    ├── theme/
    │   └── app_brand.dart       = Colores oficiales y tema Material 3
    └── widgets/
        └── brand_logo.dart      = Logo reutilizable dibujado con widgets
```

## 6. Arquitectura

La app usa una arquitectura por capas sencilla. Cada capa solo conoce a la de abajo:

```
┌──────────────────────────────────────────────────────────┐
│ screens/      Pantallas (widgets). Leen el estado y       │
│               llaman métodos de los controladores.        │
├──────────────────────────────────────────────────────────┤
│ controllers/  ChangeNotifier registrados con Provider en  │
│               main.dart. Guardan el estado y avisan a la  │
│               interfaz con notifyListeners().             │
├──────────────────────────────────────────────────────────┤
│ services/     Lógica de negocio pura: reglas, archivos,   │
│               ZIP, PDF, sonido. No dependen de widgets.   │
├──────────────────────────────────────────────────────────┤
│ database/     SQLite (DatabaseHelper, singleton).         │
│ + archivos    Imágenes en <documentos de la app>/images/  │
└──────────────────────────────────────────────────────────┘
          models/ (Producto, CarritoItem) se usan en todas las capas
```

**Convenciones:**

- Las pantallas **no** acceden directamente a `DatabaseHelper`; siempre pasan por un controlador o un servicio. La excepción actual es `PdfExportService`, que `ProductosScreen` crea directamente porque no guarda estado.
- Los controladores se obtienen con `context.read<T>()` (para llamar métodos) o con `context.watch<T>()` / `Consumer<T>` (para redibujar cuando cambian).
- Los métodos de `ProductoController` que modifican datos devuelven `bool` (éxito o fallo) y dejan el detalle del error en `errorMessage`.
- El código, los nombres y los mensajes están en **español**.

### Flujo de navegación

```
SplashScreen ──(2.2 s)──► HomeScreen
                            ├─► ProductosScreen ──► ProductoFormScreen
                            │                   └─► Diálogo QR (exportar PNG)
                            ├─► CarritoScreen ────► ScannerScreen
                            │                   └─► CheckoutResultScreen
                            └─► ImportExportScreen
```

La navegación usa `Navigator.push` con `MaterialPageRoute` (no hay rutas con nombre ni un router central).

### Flujo de una compra (ejemplo completo)

1. `CarritoScreen` → botón de escáner → `ScannerScreen`.
2. `MobileScanner` detecta el texto del QR → `ProductoController.buscarPorQR()` → `ProductoService` → `DatabaseHelper.getProductoByQR()`.
3. Si existe: `CarritoController.agregarProducto()` → `CarritoService` suma la unidad → `notifyListeners()` redibuja el carrito. `AudioService.playSuccess()` reproduce el beep.
4. "Finalizar compra" → `CheckoutResultScreen` recibe una **copia** de las líneas y el total, y calcula el cambio o el faltante.
5. "Nuevo cliente" → `CarritoController.limpiar()`.

## 7. Componentes principales

| Componente | Archivo | Responsabilidad |
|---|---|---|
| `MyApp` | `lib/main.dart` | Registra los 3 controladores con `MultiProvider`, aplica el tema y abre el splash. |
| `Producto` | `lib/models/producto.dart` | Modelo inmutable; `toMap`/`fromMap` para SQLite y `copyWith`. |
| `CarritoItem` | `lib/models/carrito_item.dart` | Producto + cantidad + `subtotal`. |
| `DatabaseHelper` | `lib/database/database_helper.dart` | Singleton SQLite: esquema, migraciones, CRUD y lectura o reemplazo de todas las tablas (usado por los respaldos). |
| `ProductoService` | `lib/services/producto_service.dart` | CRUD de productos, coordinando BD e imágenes. |
| `ImageStorageService` | `lib/services/image_storage_service.dart` | Guarda las imágenes con nombre único en `images/` y maneja rutas relativas y absolutas. |
| `CarritoService` | `lib/services/carrito_service.dart` | Agregar, quitar, sumar y restar unidades; total. |
| `ImportExportService` | `lib/services/import_export_service.dart` | Crea, comparte e importa el ZIP (con reversión si falla). |
| `PdfExportService` | `lib/services/pdf_export_service.dart` | PDF A4 con tabla de imagen, nombre, precio y QR. |
| `AudioService` | `lib/services/audio_service.dart` | Sonido de éxito. |
| `ProductoController` | `lib/controllers/producto_controller.dart` | Lista de productos, imagen temporal del formulario y errores. |
| `CarritoController` | `lib/controllers/carrito_controller.dart` | Estado del carrito para la interfaz. |
| `ImportExportController` | `lib/controllers/import_export_controller.dart` | Bandera `isLoading` durante los respaldos. |
| `AppBrand` | `lib/theme/app_brand.dart` | Colores oficiales, gradiente y `ThemeData`. |
| `BrandLogo` | `lib/widgets/brand_logo.dart` | Logo reutilizable (splash y menú). |

Cada clase y método tiene comentarios de documentación (`///`) en el código con más detalle.

## 8. Datos y almacenamiento

### 8.1 Base de datos (SQLite)

- Archivo: `mercadito.db`, en el directorio de bases de datos de la app.
- Versión actual del esquema: **2** (`_databaseVersion` en `database_helper.dart`).

```sql
CREATE TABLE productos(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  precio REAL NOT NULL,          -- colones
  codigo_qr TEXT UNIQUE NOT NULL, -- "PROD_<milisegundos>"
  image_path TEXT                 -- ruta relativa, ej. "images/manzana_..._ab12.jpg"
)
```

Historial de migraciones: **v1 → v2** agrega `image_path`.

### 8.2 Imágenes de productos

Se copian a `<documentos de la app>/images/` con un nombre único. En la base de datos se guarda solo la **ruta relativa** (`images/archivo.jpg`), así los respaldos funcionan entre dispositivos distintos. Al eliminar un producto también se elimina su imagen.

### 8.3 Formato del respaldo ZIP

```
mercadito_backup_<timestamp>.zip
├── backup.json
└── images/
    └── <imágenes referenciadas por image_path>
```

```json
{
  "app": "mercadito",
  "version": 2,
  "exported_at": "2026-05-29T14:32:00.000",
  "tables": {
    "productos": [
      { "id": 1, "nombre": "Manzana", "precio": 500.0,
        "codigo_qr": "PROD_1716...", "image_path": "images/manzana_....jpg" }
    ]
  }
}
```

- `backup.json` incluye **todas** las tablas de la base de datos, así que una tabla nueva queda respaldada automáticamente.
- **Importar reemplaza todos los datos actuales.** Si ocurre un error a mitad de la importación, se restauran los datos anteriores.
- También se acepta un JSON antiguo que sea solo una lista de productos.

## 9. Identidad visual

La guía completa está en [docs/identidad_visual.md](docs/identidad_visual.md). Resumen:

| Color | Hex | Uso |
|---|---|---|
| Celeste | `#00C0F3` | Primario del tema |
| Azul oscuro | `#005DA4` | Textos, íconos, estructura |
| Naranja | `#F37021` | Acción (botones principales) |
| Amarillo naranja | `#F99D1C` | Detalles |
| Verde | `#8DC63F` | Acento educativo |
| Blanco | `#FFFFFF` | Superficies |

**Regla:** no escriba colores directamente en las pantallas. Use las constantes de `AppBrand` (por ejemplo `AppBrand.naranja`), y si necesita un color nuevo, agréguelo primero en `lib/theme/app_brand.dart`. Los estilos generales (botones, tarjetas, campos) ya vienen del tema, así que en la mayoría de los casos no hace falta indicar un color.

## 10. Guías para extender la aplicación

### 10.1 Agregar una pantalla nueva

1. Crear `lib/screens/mi_pantalla_screen.dart` con un `StatelessWidget` o `StatefulWidget`.
2. Si necesita estado compartido, crear un controlador en `lib/controllers/` (que extienda `ChangeNotifier`) y registrarlo en el `MultiProvider` de `lib/main.dart`.
3. Si tiene lógica de negocio o acceso a archivos o BD, ponerla en un servicio en `lib/services/`.
4. Para mostrarla en el menú, agregar otra llamada a `_menuCard(...)` en `lib/screens/home_screen.dart`.

### 10.2 Agregar un campo a los productos (o una tabla nueva)

1. En `lib/database/database_helper.dart`:
   - Incrementar `_databaseVersion` (por ejemplo de `2` a `3`).
   - Agregar la columna en `_createDB` (instalaciones nuevas).
   - Agregar la migración en `_onUpgrade`:
     ```dart
     if (oldVersion < 3) {
       await db.execute('ALTER TABLE productos ADD COLUMN categoria TEXT');
     }
     ```
2. En `lib/models/producto.dart`: agregar el campo al constructor, a `toMap`, a `fromMap` y a `copyWith`.
3. Actualizar el formulario (`producto_form_screen.dart`) y las pantallas que lo muestren.
4. Si el cambio no es compatible con respaldos anteriores, subir `version` en `_crearContenidoBackupZip` (`import_export_service.dart`) y manejar ambos formatos en `_extraerTablasDesdeJson`.

> **Nunca** cambie `_createDB` sin crear la migración correspondiente: los dispositivos que ya tienen la app instalada no volverían a ejecutar `_createDB`.

### 10.3 Agregar un sonido

1. Copiar el archivo a `assets/sounds/`.
2. Declararlo en `pubspec.yaml`, en `flutter: assets:`.
3. Agregar un método en `lib/services/audio_service.dart`, similar a `playSuccess()`.

### 10.4 Cambiar el ícono o el nombre de la app

- **Ícono:** reemplazar `assets/icon/logo_app2.png` (o cambiar `image_path` en la sección `flutter_launcher_icons` de `pubspec.yaml`) y ejecutar `dart run flutter_launcher_icons`.
- **Nombre visible:** `android:label` en `AndroidManifest.xml` y `CFBundleDisplayName` en `Info.plist`, o usar el paquete `rename`: `dart run rename setAppName --targets android,ios --value "Mercadito de Dinero"`.

## 11. Estado actual y pendientes

Estos son los puntos detectados al documentar el proyecto. Son buenos candidatos para continuar el trabajo:

**Funcionalidad**

- [ ] **Editar productos:** existe `ProductoController.actualizarProducto()` (que también reemplaza la imagen), pero ninguna pantalla lo usa. Se puede reutilizar `ProductoFormScreen` recibiendo un `Producto` opcional.
- [ ] **Validación del precio:** el formulario solo verifica que el campo no esté vacío. Si se escribe un valor no numérico (por ejemplo `1,5`), `double.parse` lanza una excepción. Conviene usar `double.tryParse` en el validador.
- [ ] **Basurero del carrito:** el ícono de eliminar quita **una unidad** (igual que `-`), no la línea completa. Decidir cuál es el comportamiento esperado.
- [ ] **Carrito no persistente:** se pierde al cerrar la app (es intencional por ahora, pero conviene tenerlo en cuenta).

**Calidad y mantenimiento**

- [ ] **Pruebas:** `test/widget_test.dart` es la plantilla original de Flutter (busca un contador que no existe), así que **falla**. Hay que reemplazarla por pruebas reales, por ejemplo de `CarritoService` (total, sumar y restar), `Producto.fromMap`/`toMap` y `ImageStorageService.normalizeRelativePath`.
- [ ] **Código legado:** `DatabaseHelper.exportarProductosJSON`, `exportarRespaldoCompleto` e `importarProductosJSON`, y `ProductoService.obtenerRutaImagenAbsoluta` e `imagenExiste`, no se usan. Se pueden eliminar.
- [ ] **Colores directos:** `carrito_screen.dart` y `checkout_result_screen.dart` usan `Colors.green`, `Colors.red`, `Colors.blue`, etc. Migrarlos a `AppBrand`.
- [ ] **Fuente:** el tema usa `fontFamily: 'Trebuchet MS'`, que no está incluida en `assets`, por lo que en Android se usa la fuente del sistema. Incluir la fuente o quitar la línea.
- [ ] `AudioService` usa `print`; reemplazarlo por `debugPrint`.
- [ ] **Seguridad del ZIP:** `_extraerArchivoZip` no valida que las rutas internas del ZIP no salgan de la carpeta temporal (*zip slip*). Es relevante si se importan ZIPs de origen desconocido.

**Publicación**

- [ ] `applicationId`/`namespace` siguen siendo `com.example.app` (`android/app/build.gradle.kts`). Hay que cambiarlos antes de publicar en Play Store, porque luego no se pueden modificar.
- [ ] `name: app` y `description: "A new Flutter project."` en `pubspec.yaml` son los valores por defecto.
- [ ] Configurar la llave de firma para *release*.
- [ ] Revisar los permisos `READ/WRITE_EXTERNAL_STORAGE` del `AndroidManifest.xml`: no son necesarios en Android 10 o superior, porque se usan el selector del sistema y el directorio privado de la app.

## 12. Cómo colaborar

Conceptos básicos de Git:

- **clone**: descargar el repositorio.
- **commit**: guardar los cambios localmente con un mensaje.
- **push**: subir los commits al repositorio remoto.
- **pull**: descargar e integrar los cambios de otras personas.
- **branch**: rama o línea de trabajo paralela.
- **pull request**: solicitud para integrar una rama en otra, con revisión.

Flujo recomendado:

1. Actualizar `main`: `git checkout main && git pull`.
2. Crear una rama para el cambio: `git checkout -b feature/editar-productos`.
3. Programar y probar en un dispositivo real. Ejecutar `flutter analyze` antes de hacer commit.
4. Hacer commit con mensajes descriptivos en español, por ejemplo: `git commit -m "Permite editar productos existentes"`.
5. Subir la rama (`git push -u origin feature/editar-productos`) y abrir un *pull request* hacia `main`.

Buenas prácticas:

- No subir código que no compila ni cambios sin probar.
- No hacer push directo a `main`.
- Documentar con `///` toda clase o método nuevo (ver la sección siguiente).
- Mantener actualizada la sección [Estado actual y pendientes](#11-estado-actual-y-pendientes) de este README.
- Si cambia el esquema de la base de datos, crear siempre la migración (ver [10.2](#102-agregar-un-campo-a-los-productos-o-una-tabla-nueva)).

## 13. Documentación del código

Todas las clases, atributos y métodos de `lib/` están documentados con comentarios de documentación de Dart (`///`). Esos comentarios:

- Se muestran al pasar el mouse sobre una clase o método en VS Code o Android Studio.
- Permiten generar un sitio HTML de referencia:
  ```bash
  dart doc
  ```
  El resultado queda en `doc/api/index.html` (esa carpeta está en `.gitignore`).

Al agregar código nuevo, siga el mismo estilo: una primera línea que resuma qué hace el elemento y, si hace falta, un párrafo con el porqué, los casos especiales o los pasos. Los nombres de otras clases o métodos se escriben entre corchetes (`[Producto]`) para que se conviertan en enlaces.
