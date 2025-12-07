# revise_car

🔑 Configurando sua chave de API do Google Maps
Para usar a aplicação, você precisa adicionar sua própria chave de API do Google Maps nos arquivos de configuração do projeto.
1. Gerar sua chave
Acesse o Console do Google Cloud
Gere uma chave para uso com Google Maps Android SDK e/ou iOS SDK
Libere as APIs necessárias (Maps, Geocoding etc.)
2. Android
Abra o arquivo:
android/app/src/main/AndroidManifest.xml
E substitua:
<meta-data    android:name="com.google.android.geo.API_KEY"    android:value="SUA_KEY_API"/>
Coloque sua chave no lugar de "SUA_KEY_API".
3. iOS
Abra o arquivo:
ios/Runner/AppDelegate.swift
E substitua:
GMSServices.provideAPIKey("SUA_KEY_API")
Coloque sua chave no lugar de "SUA_KEY_API".
