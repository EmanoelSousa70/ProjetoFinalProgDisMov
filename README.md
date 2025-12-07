🔑 Configuração da Chave de API do Google Maps

Para que a aplicação funcione corretamente, é necessário configurar sua chave de API do Google Maps nos arquivos do projeto.

🚀 Como gerar sua chave de API

Acesse o Google Cloud Console.

Crie ou selecione um projeto.

Gere uma chave de API compatível com:

Google Maps Android SDK

Google Maps iOS SDK

Habilite as APIs necessárias:

Maps SDK

Geocoding API

Places API (se usar)

Outras conforme necessidade

📱 Configuração no Android

Abra o arquivo:

android/app/src/main/AndroidManifest.xml


Localize:

<meta-data android:name="com.google.android.geo.API_KEY"
    android:value="SUA_KEY_API"/>


Substitua "SUA_KEY_API" pela sua chave real:

<meta-data android:name="com.google.android.geo.API_KEY"
    android:value="AQUI_SUA_CHAVE_REAL"/>

🍏 Configuração no iOS

Abra o arquivo:

ios/Runner/AppDelegate.swift


Localize:

GMSServices.provideAPIKey("SUA_KEY_API")


Substitua "SUA_KEY_API" pela sua chave real:

GMSServices.provideAPIKey("AQUI_SUA_CHAVE_REAL")
