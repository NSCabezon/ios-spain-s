import Foundation

public class GetStockCCVRequest: BSANSoapRequest <GetStockCCVRequestParams, GetStockCCVHandler, GetStockCCVResponse, GetStockCCVParser> {
    
    public static let serviceName = "listaCarteraValoresSaldoPos_LIP"
    
    public override var serviceName: String {
        return GetStockCCVRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Valores/F_bamobi_valores_lip/internet/"
    }
    
    override var message: String {
        let empresa = params.contract?.bankCode ?? ""
        let centro = params.contract?.branchCode ?? ""
        let producto = params.contract?.product ?? ""
        let numeroContrato = params.contract?.contractNumber ?? ""
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "           <entrada>" +
            "               <datosCabecera>" +
            "                   <version>\(params.version)</version>" +
            "                   <terminalID>\(params.terminalId)</terminalID>" +
            "                   <idioma>\(serviceLanguage(params.language))</idioma>" +
            "               </datosCabecera>" +
            "               <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            "               <contratoID>" +
            "                    <CENTRO>" +
            "                        <EMPRESA>\(empresa)</EMPRESA>" +
            "                        <CENTRO>\(centro)</CENTRO>" +
            "                    </CENTRO>" +
            "                    <PRODUCTO>\(producto)</PRODUCTO>" +
            "                    <NUMERO_DE_CONTRATO>\(numeroContrato)</NUMERO_DE_CONTRATO>" +
            "               </contratoID>" +
            "           </entrada>" +
            "           <indicadores>" +
            "               <esUnaPaginacion>\(params.pagination?.endList == false ? "S" : "N")</esUnaPaginacion>" +
            "           </indicadores>" +
            "           \(params.pagination?.repositionXML ?? "")" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
