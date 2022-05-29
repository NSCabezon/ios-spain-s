//

import Foundation

public class OTPValidateOperabilityRequest: BSANSoapRequest<OTPValidateOperabilityRequestParams, OTPValidateOperabilityHandler, OTPValidateOperabilityResponse, OTPValidateOperabilityParser> {
    
    static public var serviceName = "validaCambioOperatividadOTP_LA"
    
    public override var serviceName: String {
        return OTPValidateOperabilityRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/ADFIEL/Gestionfirma_la/F_adfiel_gestionfirma_la/internet/ACADFIELGestionFirma/v1"
    }
    
    override var message: String {
        var signatureXml: String?
        if let signatureDTO = params.signatureWithTokenDTO.signatureDTO {
            signatureXml = FieldsUtils.getSignatureXml(signatureDTO: signatureDTO)
        }

        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                   <entrada>
                      <token>\(params.signatureWithTokenDTO.magicPhrase ?? "")</token>
                      <indOperatividad>\(params.newOperabilityInd.trim().uppercased())</indOperatividad>
                      <datosFirma>\(signatureXml ?? "")</datosFirma>
                   </entrada>
                   <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>
                   <datosCabecera>
                       <idioma>
                           <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>
                           <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>
                       </idioma>
                       <empresaAsociada>\(params.linkedCompany)</empresaAsociada>
                   </datosCabecera>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
