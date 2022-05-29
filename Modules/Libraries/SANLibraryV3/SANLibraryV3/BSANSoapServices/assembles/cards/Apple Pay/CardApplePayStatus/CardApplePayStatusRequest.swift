//

import Foundation

class CardApplePayStatusRequest: BSANSoapRequest<CardApplePayStatusRequestParams, CardApplePayStatusHandler, CardApplePayStatusResponse, CardApplePayStatusParser> {
    
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
                    <tarjetaConsulta>\(params.card.formattedPAN ?? "")</tarjetaConsulta>
                    <fechaCaducidad>\(params.expirationDate.date.string(format: "yyyyMM"))</fechaCaducidad>
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
