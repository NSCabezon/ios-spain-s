import Foundation

public class GetStockOrderRequest: BSANSoapRequest<GetStockOrderRequestParams, GetStockOrderHandler, GetStockOrderResponse, GetStockOrderParser> {

    public static let serviceName = "listaOrdenesValores_LIP"
    public static let serviceNameFechas = "listaOrdenesValoresFechas_LIP"

    public override var serviceName: String {
        if let _ = params.dateFilter {
            return GetStockOrderRequest.serviceNameFechas
        }
        return GetStockOrderRequest.serviceName
    }


    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Valores/F_bamobi_valores_lip/internet/"
    }

    override var message: String {
        let empresa = params.stockContract?.bankCode ?? ""
        let centro = params.stockContract?.branchCode ?? ""
        let producto = params.stockContract?.product ?? ""
        let numeroContrato = params.stockContract?.contractNumber ?? ""

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
                "                   <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
                "                   <contratoID>" +
                "                       <CENTRO>" +
                "                           <CENTRO>\(centro)</CENTRO>" +
                "                           <EMPRESA>\(empresa)</EMPRESA>" +
                "                       </CENTRO>" +
                "                       <PRODUCTO>\(producto)</PRODUCTO>" +
                "                       <NUMERO_DE_CONTRATO>\(numeroContrato)</NUMERO_DE_CONTRATO>" +
                "                   </contratoID>" +
                getDateFilterMessage() +
                "               </entrada>" +
                "               <indicadores>" +
                "                   <esUnaPaginacion>\(params.pagination?.endList == false ? "S" : "N")</esUnaPaginacion>" +
                "               </indicadores>" +
                "               \(params.pagination?.repositionXML ?? "")" +
                "       </v1:\(serviceName)>" +
                "   </soapenv:Body>" +
                "</soapenv:Envelope>"
        return returnString
    }
}
