import Foundation
public class GetStockOrderDetailRequest: BSANSoapRequest <GetStockOrderDetailRequestParams, GetStockOrderDetailHandler, GetStockOrderDetailResponse, GetStockOrderDetailParser> {
    
    public static let serviceName = "detalleOrdenValores_LIP"
    
    public override var serviceName: String {
        return GetStockOrderDetailRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Valores/F_bamobi_valores_lip/internet/"
    }
    
    override var message: String {
        let empresa = params.stockContractDTO?.bankCode ?? ""
        let centro = params.stockContractDTO?.branchCode ?? ""
        let producto = params.stockContractDTO?.product ?? ""
        let numeroContrato = params.stockContractDTO?.contractNumber ?? ""
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <entrada>" +
            "                   <datosCabecera>" +
            "                       <version>\(params.version)</version>" +
            "                       <terminalID>\(params.terminalId)</terminalID>" +
            "                       <idioma>\(serviceLanguage(params.language))</idioma>" +
            "                   </datosCabecera>" +
            "                   <datosConexion>\(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")</datosConexion>" +
            "                   <numeroOrdenValores>\(params.orderNumber)</numeroOrdenValores>" +
            "                   <contratoID>" +
            "                       <CENTRO>" +
            "                           <CENTRO>\(centro)</CENTRO>" +
            "                           <EMPRESA>\(empresa)</EMPRESA>" +
            "                       </CENTRO>" +
            "                       <PRODUCTO>\(producto)</PRODUCTO>" +
            "                       <NUMERO_DE_CONTRATO>\(numeroContrato)</NUMERO_DE_CONTRATO>" +
            "                   </contratoID>" +
            "               </entrada>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
