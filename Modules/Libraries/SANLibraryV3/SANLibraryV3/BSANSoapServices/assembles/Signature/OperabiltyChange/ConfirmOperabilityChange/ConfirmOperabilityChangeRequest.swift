//

import Foundation

public class ConfirmOperabilityChangeRequest: BSANSoapRequest<ConfirmOperabilityChangeRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser> {
    
    static public var serviceName = "confirmaCambioOperatividad_LA"
    
    public override var serviceName: String {
        return ConfirmOperabilityChangeRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/ADFIEL/Gestionfirma_la/F_adfiel_gestionfirma_la/internet/ACADFIELGestionFirma/v1"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa

        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                    <entrada>
                        <token>\(params.otpToken)</token>
                        <ticketOTP>\(params.otpTicket)</ticketOTP>
                        <codigoOTP>\(params.otpCode)</codigoOTP>
                        <indOperatividad>\(params.newOperabilityInd.trim().uppercased())</indOperatividad>
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
