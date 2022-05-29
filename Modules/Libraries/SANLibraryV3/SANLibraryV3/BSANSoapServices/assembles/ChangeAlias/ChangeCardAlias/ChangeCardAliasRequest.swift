import Foundation
public class ChangeCardAliasRequest: BSANSoapRequest <ChangeCardAliasRequestParams, ChangeCardAliasHandler, BSANSoapResponse, ChangeCardAliasParser> {
    
    public static let serviceName = "cambiaAliasTarjeta_LA"
    
    public override var serviceName: String {
        return ChangeCardAliasRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Aliastarjeta_la/F_tarsan_aliastarjetas_la/internet/"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <entrada>" +
            "               <indPersonaliz>1</indPersonaliz>" +
            "               <numTarjeta>\(params.PAN)</numTarjeta>" +
            "               <aliasTarjeta>\(params.newAlias)</aliasTarjeta>" +
            "               <indVisibilidad>S</indVisibilidad>" +
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
