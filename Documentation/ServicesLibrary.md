# ServicesLibrary

Nueva librería de servicios para España.

## Componentes

La nueva librería se compone de los siguientes componentes:

* SANCoreLibrary (una librería que va a contener los **protocolos** de los servicios de Core)
* SANSpainLibrary (una librería que va a contener los **protocolos** de los servicios de España)
* SANServicesLibrary (la librería que depende de las 2 anteriores y que contiene las implementaciones de las llamadas a los servicios de España y Core).

## Funcionalidades

La librería es capaz de:

* Ejecutar servicios Rest
* Ejecutar servicios Soap
* Almacenar en memoria la respuesta de los servicios
* Un sincronizador para evitar hacer 2 peticiones a la vez


## Estructura

Para seguir la estructura de SANLibraryV3 (se ha renombrado Manager por Repository), la estructura general de los servicios será la siguiente:

* Repository (Protocol): Define los métodos de una funcionalidad general. Estos protocolos estarán en SANCore o SANSpain.
* Repository (Implementación): La implementación del Manager en particular con la llamada a los servicios.

### Interceptors

Cuando vayamos a ejecutar una petición (ya sea Rest o Soap), tendremos la posibilidad de añadir Interceptors a la request y a la response.

#### Request Interceptor

Se basa en la idea de que, añadiendo tantos como queramos, antes de ejecutar la petición, podamos crear una nueva Request dada la Request creada. Esto, nos sirve para poder modificar el body, las headers, la url...

```swift
protocol SoapRequestInterceptor {
    func interceptRequest(_ request: SoapRequest) -> SoapRequest
}
protocol RestRequestInterceptor {
    func interceptRequest(_ request: RestRequest) -> RestRequest
}
```

#### Response Interceptor

Se basa en la idea de que, añadiendo tantos como queramos, una vez obtenemos la respuesta del servicio, podamos hacer algún checkeo para, por ejemplo, retornar un error en el caso de que encontremos un campo determinado en la respuesta.

```swift
protocol RestResponseInterceptor {
    func interceptResponse(_ response: RestResponse) -> Result<RestResponse, Error>
}
protocol SoapResponseInterceptor {
    func interceptResponse(_ response: SoapResponse) -> Result<SoapResponse, Error>
}
```

### Ejemplo de uso

#### Soap

```swift
func loginWithUser(_ userName: String, magic: String, type: LoginTypeRepresentable) -> Result<Void, Error> {
    let request = SoapSpainRequest(
        serviceName: "authenticateCredential",
        url: environmentProvider.getEnvironment().soapBaseUrl + "/SANMOV_IPAD_NSeg_ENS/ws/SANMOV_Def_Listener",
        facade: "loginServicesNSegSAN",
        nameSpace: "http://www.isban.es/webservices/TECHNICAL_FACADES/Security/F_facseg_security/internet/",
        input: LoginRequest(userName: userName, magic: magic, type: type)
    )
    let response = self.soapManager.request(
        request,
        requestInterceptors: [
            BodySoapInterceptor(type: .vBody, version: .n0),
            EnvelopeSoapInterceptor(type: .vEnvelope)
        ],
        responseInterceptors: [
            SoapErrorInterceptor(errorKey: "codigoError", descriptionKey: "descripcionError")
        ]
    )
    let result: Result<AuthenticationTokenDto, Error> = response.map(to: AuthenticationTokenDto.self)
    result.store(on: self.storage)
    return result.map()
}
```

#### Rest

```swift
func checkPayment(defaultXPAN: String) -> Result<BizumCheckPaymentRepresentable, Error> {
    guard let authToken: AuthenticationTokenDto = self.dataSource.get() else { return .failure(ServiceError.unknown) }
    if let checkPayment = self.dataSource.get(BizumCheckPaymentDto.self) {
        return .success(checkPayment)
    }
    let url = self.environmentProvider.getEnvironment().restBaseUrl
    let request = RestSpainRequest(
        method: "POST",
        serviceName: "check-payment",
        url: url + "/payments/check-payment"
    )
    let mulmovUrls = self.storage.get(ConfigurationRepresentable.self)?.mulmovUrls ?? []
    let response = self.restManager.request(
        request,
        requestInterceptors: [
            AuthorizationRestInterceptor(token: authToken.token),
            MulmovRestRequestInterceptor(urls: mulmovUrls),
            SantanderChannelRestInterceptor()
        ],
        responseInterceptors: [
            BizumReponseInterceptor()
        ]
    )
    return response
        .map(to: BizumCheckPaymentDto.self)
        .map {
            guard ($0.xpan ?? "").isEmpty else { return $0 }
            return BizumCheckPaymentDto(checkpayment: $0, xpan: defaultXPAN)
        }
}
```
