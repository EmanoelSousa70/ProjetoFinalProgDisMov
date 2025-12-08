# 🔑 **Configuração da Chave de API do Google Maps**

**IMPORTANTE:** Para a aplicação funcionar corretamente, é necessário configurar a **chave de API do Google Maps** nos arquivos do projeto (Android e iOS). Siga cada etapa com atenção.

---

## 📘 **1. Gerando sua Chave de API**

1. Acesse o **Google Cloud Console**.  
2. Crie ou selecione um **projeto**.  
3. Gere uma **chave de API** para:  
   - **Google Maps Android SDK**  
   - **Google Maps iOS SDK**  
4. **Habilite as APIs necessárias**, por exemplo:  
   - **Maps SDK for Android / iOS**  
   - **Geocoding API**  



---

## 🤖 **2. Configuração no Android**

**📄 Arquivo a editar:**  
`android/app/src/main/AndroidManifest.xml`

**🔧 Substitua o valor da chave:**

**Original:**
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
    android:value="SUA_KEY_API"/>











