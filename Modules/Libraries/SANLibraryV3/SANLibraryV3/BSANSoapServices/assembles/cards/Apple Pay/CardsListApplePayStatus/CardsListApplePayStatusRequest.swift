class CardsListApplePayStatusRequest: BSANSoapRequest<CardsListApplePayStatusRequestParams, CardsListApplePayStatusHandler, CardsListApplePayStatusResponse, CardsListApplePayStatusParser> {
    
    static var serviceName = "identificarTokenTjtaLA"
    
    override var serviceName: String {
        return CardApplePayStatusRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/INAPP/Inappprovisionla/F_inappr_inappprovisionla/ACINAPPRAppelPay/v1"
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                <entrada>
                    <application>Apple Pay</application>
                    <listDeviceAccountIdentifier>
                        \(params.addedPasses.map({ "<deviceAccountIdentifierE>\($0)</deviceAccountIdentifierE>" }).joined())
                    </listDeviceAccountIdentifier>
                </entrada>
                <datosConexion>
                \(params.userDataDTO.datosUsuario)
                </datosConexion>
                <datosCabecera>
                   <idioma>
                      <IDIOMA_ISO>\(params.language)</IDIOMA_ISO>
                      <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>
                   </idioma>
                   <empresa>\(params.userDataDTO.company ?? "")</empresa>
                   <empresaAsociada>\(params.userDataDTO.company ?? "")</empresaAsociada>
                </datosCabecera>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
