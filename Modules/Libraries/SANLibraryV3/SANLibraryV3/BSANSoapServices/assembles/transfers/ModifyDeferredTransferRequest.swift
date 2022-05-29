import Foundation

public class ModifyDeferredTransferRequest: BSANSoapRequest<ModifyDeferredTransferRequestParams, ModifyDeferredTransferHandler, ModifyDeferredTransferResponse, ModifyDeferredTransferParser> {
    
    private static let SERVICE_NAME = "modificarDiferidaDetalleLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Periodicas_la/F_trasan_periodicas_la/"
    }
    
    public override var serviceName: String {
        return ModifyDeferredTransferRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "   <soapenv:Body>" +
            "      <v1:\(serviceName) facade=\"\(facade)\">" +
            "       <datosConexion>" +
            "            <idioma>" +
            "               <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "               <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "            </idioma>" +
            "            \(params.userDataDTO.getClientChannelWithCompany())" +
            "         </datosConexion>" +
            "        <entrada>" +
            "            <numeroOrdenCabecera>\(params.orderHeaderNumber)</numeroOrdenCabecera>" +
            "            <ibanOrdenante>" +
            "               <PAIS>\(params.iban.countryCode)</PAIS>" +
            "               <DIGITO_DE_CONTROL>\(params.iban.checkDigits)</DIGITO_DE_CONTROL>" +
            "               <CODBBAN>\(params.iban.codBban30)</CODBBAN>" +
            "            </ibanOrdenante>" +
            "            <divisaIbanOrdenante>\(params.orderingCurrency)</divisaIbanOrdenante>" +
            "        </entrada>" +
            "     </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}

public struct ModifyDeferredTransferRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    public let orderHeaderNumber: String
    public let orderingCurrency: String
    public let iban: IBANDTO
}

