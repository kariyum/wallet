echo $GOOGLE_SERVICES | base64 -i --decode > android/app/google-services.json
echo $KEY_PROPERTIES | base64 -i --decode > android/key.properties
echo $UPLOAD_KEYSTORE_JKS | base64 -i --decode > android/app/upload-keystore.jks