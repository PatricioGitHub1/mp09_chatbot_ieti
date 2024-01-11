# DAM-FlutterNodeJSExemplePostGet

Instal·lar dependències del servidor amb:
    
```bash
cd nodejs_server
npm install
```

Executar el servidor en mode desenvolupament amb:
    
```bash
cd nodejs_server
npm run dev
```

Comprovar que funciona amb un navegador web:

[http://localhost:8888](http://localhost:3000)

Fer anar el projecte Flutter:

```bash
cd flutter_postget
flutter clean
flutter create . --platform linux
flutter run -d linux
```

*Important*:

El projecte Flutter ha de tenir permisos de xarxa, això es configura a cada carpeta de sistema segons cal.

També ha de tenir permisos per tal que l'usuari trii un arxiu i per enviar-lo al servidor amb POST.

Per exemple, a macOS cal obrir el projecte de la carpeta 'macos/Runner.xcodeproj' amb Xcode i a la secció 'Signing & Capabilities' seleccionar:
- Els permisos de xarxa tant en mode 'Debug' com en mode 'Release'
- Els permisos 'File Access Type' a 'User selected file'