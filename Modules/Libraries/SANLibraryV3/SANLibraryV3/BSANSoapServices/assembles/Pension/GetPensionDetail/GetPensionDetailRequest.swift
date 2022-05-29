import Foundation

public class GetPensionDetailRequest: BSANSoapRequest <GetPensionDetailRequestParams, GetPensionDetailHandler, GetPensionDetailResponse, GetPensionDetailParser> {
    
    public static let serviceName = "detallePlan_LA"
    
    public override var serviceName: String {
        return GetPensionDetailRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Plans/F_bamobi_plans_lip/internet/"
    }
    
    override var message: String {
        let empresa = params.bankCode
        let centro = params.branchCode
        let producto = params.product
        let numeroContrato = params.contractNumber
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <entrada>" +
            "                   <contrato>" +
            "                       <CENTRO>" +
            "                           <EMPRESA>\(empresa)</EMPRESA>" +
            "                           <CENTRO>\(centro)</CENTRO>" +
            "                       </CENTRO>" +
            "                       <PRODUCTO>\(producto)</PRODUCTO>" +
            "                       <NUMERO_DE_CONTRATO>\(numeroContrato)</NUMERO_DE_CONTRATO>" +
            "                   </contrato>" +
            "               </entrada>" +
            "               <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            "               <datosCabecera>" +
            "                   <version>\(params.version)</version>" +
            "                   <terminalID>\(params.terminalId)</terminalID>" +
            "                   <idioma>\(serviceLanguage(params.language))</idioma>" +
            "               </datosCabecera>" +
            "           </v1:\(serviceName)>" +
            "       </soapenv:Body>" +
        "   </soapenv:Envelope>"
        return returnString
    }
}
