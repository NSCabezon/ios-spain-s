import Foundation
public class GetFeesEasyPayRequest: BSANSoapRequest <GetFeesEasyPayRequestParams, GetFeesEasyPayHandler, GetFeesEasyPayResponse, GetFeesEasyPayParser> {
    
    public static let serviceName = "consultarCuotasPagoFacil_LA"
    
    public override var serviceName: String {
        return GetFeesEasyPayRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Mvtospagofacil_la/F_tarsan_mvtospagofacil_la/internet/"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "          <entrada>" +
            XMLHelper.getContractXML(parentKey: "contratoTarjeta", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractNumber) +
            XMLHelper.getProductTypeAndSubtypeXML(parentKey: "subtipoProd", company: params.company, productType: params.productType, productSubType: params.productSubtype) +
            "          </entrada>" +
            "          <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
            "          <datosCabecera>" +
            "               <idioma>" +
            "                   <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                   <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "               </idioma>" +
            "          </datosCabecera>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
    
}
