import Foundation

public class CheckEntityAdheredRequest: BSANSoapRequest <CheckEntityAdheredRequestParams, CheckEntityAdheredHandler, BSANSoapResponse, CheckEntityAdheredParser> {
    
    public static let serviceName = "entidadAdherida_LA"
    
    public override var serviceName: String {
        return CheckEntityAdheredRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Inmediatas_la/F_trasan_inmediatas_la/"
    }
    
    override var message: String {
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <datosEntrada>" +
            "                   <cuentaDestino>" +
            "                       <PAIS>\(params.ibanTransferencia?.countryCode ?? "")</PAIS>" +
            "                       <DIGITO_DE_CONTROL>\(params.ibanTransferencia?.checkDigits ?? "")</DIGITO_DE_CONTROL>" +
            "                       <CODBBAN>\(params.ibanTransferencia?.codBban30 ?? "")</CODBBAN >" +
            "                   </cuentaDestino>" +
            "                   <importePago>" +
            "                       <IMPORTE>1.00</IMPORTE>" +
            "                       <DIVISA>EUR</DIVISA>" +
            "                   </importePago>" +
            "                   <empresaOrigen>\(params.company)</empresaOrigen>" +
            "               </datosEntrada>" +
            "               <datosCabecera>" +
            "                   <empresa>\(params.linkedCompany)</empresa>" +
            "                   <idioma>" +
            "                       <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                       <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "                   </idioma>" +
            "               </datosCabecera>" +
            "               <datosConexion>" +
            "                \(params.userDataDTO.datosUsuarioWithEmpresa)" +
            "               </datosConexion>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
