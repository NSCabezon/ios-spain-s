import Foundation
public class GetCardDetailTokenRequest: BSANSoapRequest <GetCardDetailTokenRequestParams, GetCardDetailTokenHandler, GetCardDetailTokenResponse, GetCardDetailTokenParser> {
    
    public static let serviceName = "detalleTarjetaToken_LIP"
    
    public override var serviceName: String {
        return GetCardDetailTokenRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Tarjetas/F_bamobi_tarjetas_lip/internet/"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <entrada>" +
            "               <datosCabecera>" +
            "                   <version>\(params.version)</version>" +
            "                   <terminalID>\(params.terminalId)</terminalID>" +
            "                   <idioma>\(serviceLanguage(params.language))</idioma>" +
            "               </datosCabecera>" +
            "               <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
            "               <numeroTarj>\((params.cardTokenType == CardTokenType.panWithSpaces) ? params.cardPAN : params.cardPAN.replace(" ", ""))</numeroTarj>" +
            "           </entrada>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
            "</soapenv:Envelope>"
        return returnString
    }
}
