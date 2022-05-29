# iOS Spain

README del proyecto de España

## [Distribución](Documentation/Distribution.md)

Guía para la distribución de la app en AppCenter y en AppStore

## [Guía de estilo](https://sanes.atlassian.net/wiki/spaces/MOVPAR/pages/16687202778/OA-Style+Guide)

Guía de estilo de España y de Core

## [Fastlane](fastlane/README.md)

Todos los `lanes` de `fastlane`

## Provisioning profiles y certificados de desarrollo

Para descargar los provisionings y certificados de desarrollo:

Instalar fastlane
Ejecutar: en la carpeta project:

    $ fastlane ios certificates version:5.x #cada vez que se empieze nueva version de release cambiar 5.6, 5.7, 6.0..

La contraseña es "Santander2021"

## Cifrado de claves

En primer lugar abrimos una herramienta online para hacer encriptados en AES CBC 256.
https://www.devglan.com/online-tools/aes-encryption-decryption

Pasos para encriptar claves en la anterior herramienta online:

1. Introducimos el texto a encriptar
2. En Select Mode ponemos CBC
3. En Key Size in Bits ponemos 256
4. En Enter IV (Optional) no escribimos nada
5. En Enter Secret Key ponemos la password para encriptar que está en la clase DomainConstant del proyecto de Retail y se forma a partir de concatenar: K2 + K0 + K1
6. Dejamos marcado Output Text Format: Base64 y pulsamos en el botón Encrypt
7. La clave encriptada estará en Base64 y es la que copiaremos en el proyecto

## [ServicesLibrary](Documentation/ServicesLibrary.md)

Documentación de la nueva librería de servicios.
