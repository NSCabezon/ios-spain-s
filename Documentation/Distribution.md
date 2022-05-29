# Distribución

Para la distribución de la app, usamos `fastlane` como herramienta para crear los scripts.

## AppCenter

Para la distribución en AppCenter tenemos el lane `release` que recibe los siguientes parámetros:

`fastlane ios release deploy_env:intern notify_testers:false branch:develop`

Los valores para `deploy_env` están listados en el [Fastfile](../fastlane/Fastfile) en la variable `CONFIGURATIONS`.

## AppStore

TBD