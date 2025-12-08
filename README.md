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








**TELAS DO APLICATIVO**
![00](https://github.com/user-attachments/assets/2db8b247-34e9-42bb-b7be-320f713b9fcf)

![01](https://github.com/user-attachments/assets/855c59eb-1155-4b7f-9ebe-3cbed582fa17)

![02](https://github.com/user-attachments/assets/bce370a6-4a28-4406-8cb8-95cfa1512847)

![03](https://github.com/user-attachments/assets/27dab033-1597-4d8d-9e66-9f0727ae8888)

![04](https://github.com/user-attachments/assets/aebd75b0-79ef-4f49-b0fa-19c0411f65d5)

![05](https://github.com/user-attachments/assets/15d4be33-f6cc-4a43-96d0-4d059c7515f4)

![06](https://github.com/user-attachments/assets/7e0009f7-73b1-4f4c-930b-8e901ed9a180)

![07](https://github.com/user-attachments/assets/08ae4b86-cbff-4597-8353-cfade824fc3d)


![08](https://github.com/user-attachments/assets/e93fc9f5-e085-4256-b0ec-49df065944c5)

![09](https://github.com/user-attachments/assets/e584b710-a04b-43bc-b1ec-b5cfafd84a4f)


![10](https://github.com/user-attachments/assets/2ac5fd38-242b-4b22-b44d-d0787ab15e8c)



