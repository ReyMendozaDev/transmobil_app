# Instrucciones para Configurar la API Key de Google Maps

## 📍 Ubicación del Archivo

La API key de Google Maps debe configurarse en el siguiente archivo:

**`android/app/src/main/AndroidManifest.xml`**

## 🔑 Pasos para Configurar la API Key

### 1. Obtener la API Key

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita la **"Maps SDK for Android"**:
   - Ve a "APIs & Services" > "Library"
   - Busca "Maps SDK for Android"
   - Haz clic en "Enable"
4. Ve a "APIs & Services" > "Credentials"
5. Haz clic en "Create Credentials" > "API Key"
6. Copia la API key generada

### 2. Configurar la API Key en el Proyecto

1. Abre el archivo: `android/app/src/main/AndroidManifest.xml`
2. Busca la siguiente sección (debe estar dentro de `<application>`):

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE" />
```

3. Reemplaza `YOUR_API_KEY_HERE` con tu API key real:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUI" />
```

### 3. Restricciones de Seguridad (Recomendado)

Para mayor seguridad, configura restricciones en tu API key:

1. En Google Cloud Console, ve a "APIs & Services" > "Credentials"
2. Haz clic en tu API key
3. En "Application restrictions", selecciona "Android apps"
4. Agrega el nombre del paquete de tu app (encontrado en `android/app/build.gradle` como `applicationId`)
5. Agrega el SHA-1 fingerprint de tu certificado de firma

### 4. Verificar la Configuración

Después de configurar la API key:

1. Ejecuta `flutter clean`
2. Ejecuta `flutter pub get`
3. Ejecuta la aplicación en un dispositivo Android o emulador

Si el mapa no se muestra, verifica:
- Que la API key esté correctamente escrita (sin espacios)
- Que "Maps SDK for Android" esté habilitada
- Que las restricciones de la API key permitan tu aplicación

## ⚠️ Importante

- **NUNCA** subas tu API key a repositorios públicos
- Considera usar variables de entorno o archivos de configuración locales
- Revisa los límites de uso de la API key en Google Cloud Console

