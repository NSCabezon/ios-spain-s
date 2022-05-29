import Foundation
public class ConfirmSignatureChangeRequest: BSANSoapRequest <ConfirmSignatureChangeRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser> {
    
    public static let serviceName = "confirmarCambioClaveFirma_LA"
    
    public override var serviceName: String {
        return ConfirmSignatureChangeRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/SWENDI/Enviodinero_la/F_swendi_enviodinero_la/internet/"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <entrada>" +
            "               <datosFirma>\(FieldsUtils.getSignatureXml(signatureDTO: params.signatureDTO))</datosFirma>" +
            "               <nuevaFirma>\(params.newSignatureCiphered)</nuevaFirma>" +
            "               <confirmFirma>\(params.newSignatureCiphered)</confirmFirma>" +
            "           </entrada>" +
            "           <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
            "           <datosCabecera>" +
            "               <idioma>" +
            "                   <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                   <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "               </idioma>" +
            "               <empresaAsociada>\(params.linkedCompany)</empresaAsociada>" +
            "           </datosCabecera>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
    
}
