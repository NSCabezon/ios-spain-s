//

import Foundation

class ApplePayConfirmationRequest: BSANSoapRequest<ApplePayConfirmationRequestParams, ApplePayConfirmationHandler, ApplePayConfirmationResponse, ApplePayConfirmationParser> {
    
    static var serviceName = "generaPassDataLA"
    
    override var serviceName: String {
        return ApplePayConfirmationRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/INAPP/Inappprovisionla/F_inappr_inappprovisionla/ACINAPPRAppelPay/v1"
    }
    
    override var message: String {
        let publicCertificates: String = params.publicCertificates
            .map({ "<publicCertificateE>\($0.hexEncodedString())</publicCertificateE>" })
            .reduce(into: "", { $0 += $1 })
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                <entrada>
                    <token>\(params.otpValidation.magicPhrase ?? "")</token>
                    <codigoOTP>\(params.otpCode)</codigoOTP>
                   <ticket>\(params.otpValidation.ticket ?? "")</ticket>
                   <contratoTjta>
                      <CENTRO>
                        <EMPRESA>\(params.card.contract?.bankCode ?? "")</EMPRESA>
                        <CENTRO>\(params.card.contract?.branchCode ?? "")</CENTRO>
                      </CENTRO>
                      <PRODUCTO>\(params.card.contract?.product ?? "")</PRODUCTO>
                      <NUMERO_DE_CONTRATO>\(params.card.contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                   </contratoTjta>
                   <datosEnrolEntrada>
                      <application>Apple Pay</application>
                      <encryptionScheme>\(params.encryptionScheme)</encryptionScheme>
                      <publicCertificates>
                        \(publicCertificates)
                      </publicCertificates>
                      <nonce>\(params.nonce.hexEncodedString())</nonce>
                      <nonceSignature>\(params.nonceSignature.hexEncodedString())</nonceSignature>
                      <clientAppID></clientAppID>
                      <clientDeviceID></clientDeviceID>
                      <clientWalletAccountID></clientWalletAccountID>
                      <pan>\(params.card.formattedPAN ?? "")</pan>
                      <expDate>\(params.cardDetail.expirationDate?.string(format: "yyMM") ?? "")</expDate>
                      <cardholderName>\(params.cardDetail.holder ?? "")</cardholderName>
                   </datosEnrolEntrada>
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
                   <empresaAsociada>\(params.linkedCompany)</empresaAsociada>
                </datosCabecera>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}

private extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
