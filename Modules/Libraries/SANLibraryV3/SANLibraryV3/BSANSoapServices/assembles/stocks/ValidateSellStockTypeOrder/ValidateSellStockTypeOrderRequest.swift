import Foundation
public class ValidateSellStockTypeOrderRequest: BSANSoapRequest <ValidateSellStockTypeOrderRequestParams, ValidateSellStockTypeOrderHandler, ValidateSellStockTypeOrderResponse, ValidateSellStockTypeOrderParser> {
    
    public static let serviceName = "validaVentaValoresTipoOrden_LIP"
    
    public override var serviceName: String {
        return ValidateSellStockTypeOrderRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Valores/F_bamobi_valores_lip/internet/"
    }
    
    override var message: String {
        
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
            "                   <tipoOrden>\(params.stockTradingType)</tipoOrden>" +
            "                   <datosBasicos>" +
            XMLHelper.getContractXML(parentKey: "contratoID", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractNumber) +
            "                       <codigoEmisionValores>" +
            "                           <CODIGO_DE_VALOR>\(params.stockCode)</CODIGO_DE_VALOR>" +
            "                           <CODIGO_DE_EMISION>\(params.identificationNumber)</CODIGO_DE_EMISION>" +
            "                       </codigoEmisionValores>" +
            "                       <numeroTitulos>\(params.tradesShares)</numeroTitulos>" +
            getDateXml(tagDate: "fechaLimite", date: params.limitDate) +
            "                   </datosBasicos>" +
            "               </entrada>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
