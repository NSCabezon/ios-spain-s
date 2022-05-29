import Foundation
public class ConfirmSellStockLimitedRequest: BSANSoapRequest <ConfirmSellStockLimitedRequestParams, ConfirmSellStockLimitedHandler, ConfirmSellStockLimitedResponse, ConfirmSellStockLimitedParser> {
    
    public static let serviceName = "confirmaVentaValoresLimitada_LIP"
    
    public override var serviceName: String {
        return ConfirmSellStockLimitedRequest.serviceName
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
            "                   <datosValidacion>" +
            "                       <cambioMaximoParteEntera>\(params.maxExchange.wholePart)</cambioMaximoParteEntera>" +
            "                       <cambioMaximoParteDecimal>\(params.maxExchange.getDecimalPart(decimales: 4))</cambioMaximoParteDecimal>" +
            "                       <datosBasicos>" +
            XMLHelper.getContractXML(parentKey: "contratoID", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractNumber) +
            "                           <codigoEmisionValores>" +
            "                               <CODIGO_DE_VALOR>\(params.stockCode)</CODIGO_DE_VALOR>" +
            "                               <CODIGO_DE_EMISION>\(params.identificationNumber)</CODIGO_DE_EMISION>" +
            "                           </codigoEmisionValores>" +
            "                           <numeroTitulos>\(params.tradesShares)</numeroTitulos>" +
            getDateXml(tagDate: "fechaLimite", date: params.limitDate) +
            "                       </datosBasicos>" +
            "                   </datosValidacion>" +
            "                   <datosFirma>\(FieldsUtils.getSignatureXml(signatureDTO: params.signatureDTO))</datosFirma>" +
            "               </entrada>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
