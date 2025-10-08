# 📋 Guía Completa para Colaboradores del Proyecto Flutter

## 📦 Instalación de Herramientas

### 1. **Instalar Git**
- Descarga Git desde: https://git-scm.com/
- Sigue el instalador con las opciones predeterminadas
- **Importante:** Durante la instalación, selecciona "Use Git from Windows Command Prompt"

### 2. **Instalar Flutter SDK**
- Descarga Flutter desde: https://docs.flutter.dev/get-started/install
- Extrae el archivo ZIP en una carpeta 
- **Configura la variable de entorno:**
  - Abre "Variables de entorno" en Windows
  - Agrega `C:\src\flutter\bin` a la variable `PATH`

### 3. **Instalar Android SDK Command Line Tools**
- Descarga Android SDK Command Line Tools desde: https://developer.android.com/studio#command-tools
- Extrae en: `C:\Users\TU_USUARIO\AppData\Local\Android\Sdk\cmdline-tools\latest`
- **Configura variables de entorno:**
  - `ANDROID_HOME`: `C:\Users\TU_USUARIO\AppData\Local\Android\Sdk`
  - `ANDROID_SDK_ROOT`: `C:\Users\TU_USUARIO\AppData\Local\Android\Sdk`
  - Agrega a `PATH`: 
    - `%ANDROID_HOME%\cmdline-tools\latest\bin`
    - `%ANDROID_HOME%\platform-tools`
    - `%ANDROID_HOME%\build-tools\33.0.0` (o la versión más reciente)

### 4. **Aceptar Licencias de Android**

flutter doctor --android-licenses

Sigue las instrucciones y escribe "y" para aceptar todas las licencias

### 5. Instalar VS Code y Extensiones
Descarga VS Code: https://code.visualstudio.com/
Abre VS Code y ve a Extensiones (Ctrl+Shift+X)
Instala la extensión: Flutter y Dart

  - ✅ Verificar Instalación

  - flutter doctor

Todos los puntos deben estar en verde (✓) excepto Android Studio (no es necesario tenerlo)

### 🚀 Clonar y Configurar el Proyecto
# 1. Clonar el Repositorio
    [git clone https://github.com/NOMBRE_DEL_LIDER/my_1st_one.git](https://github.com/DiegoNatanael/Blind)
    cd blind

# 2. Instalar Dependencias
    flutter pub get

# 3. Ejecutar el Proyecto
  flutter devices
  flutter run -d (el id de tu dispositivo)

### 🔄 Colaboración en el Proyecto
1. Flujo de Trabajo con Ramas (Branches)
Antes de empezar a trabajar:

    git pull origin main

Crear una nueva rama para tu trabajo:

    git checkout -b feature/nombre-de-tu-cambio

Ejemplos de nombres de rama:

feature/nueva-funcionalidad
bugfix/fix-camara
feature/mejora-ui

Hacer cambios y guardar:

    git add .
    git commit -m "Descripción clara de los cambios"
    git push origin feature/nombre-de-tu-cambio

2. Crear Pull Request (PR)
  Ve al repositorio en GitHub
  Haz clic en la pestaña "Pull requests"
  Clic en "New pull request"
  Selecciona tu rama vs la rama main
  Describe tus cambios y envía el PR
  El líder revisará y aprobará los cambios

# 3. Actualizar tu rama main local
  git checkout main
  git pull origin main

# 📝 Buenas Prácticas
  1. Commits Claros
    Usa mensajes descriptivos: "Agrega funcionalidad de detección de objetos"
    No subas código roto
    Prueba tus cambios antes de hacer commit
  2. Trabajar con Ramas
    No trabajes directamente en main
    Crea una rama para cada tarea
    Borra la rama después de que se acepte el PR
  3. Resolver Conflictos
    Si hay conflictos, el líder los resolverá
    Si te sale error al hacer pull, pide ayuda al líder

Si tienes problemas:
Verificar estado del repositorio:

  git status

Ver commits recientes:
  git log --oneline

Deshacer último commit (si es necesario):
  git reset --soft HEAD~1

Comandos útiles:

  # Ver todas las ramas
    git branch -a

  # Cambiar de rama
    git checkout nombre-de-la-rama

  # Ver diferencias antes de commit
    git diff
