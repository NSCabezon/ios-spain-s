import Foundation
public class ConfirmBuyStockTypeOrderRequest: BSANSoapRequest <ConfirmBuyStockTypeOrderRequestParams, ConfirmBuyStockTypeOrderHandler, ConfirmBuyStockTypeOrderResponse, ConfirmBuyStockTypeOrderParser> {
    
    public static let serviceName = "confirmaCompraValoresTipoOrden_LIP"
    
    public override var serviceName: String {
        return ConfirmBuyStockTypeOrderRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Valores/F_bamobi_valores_lip/internet/"
    }
    
    override var message: String {
        let signatureXml: String
        if let signatureDTO = params.signatureDTO {
            signatureXml = getSignatureXml(signatureDTO: signatureDTO)
        } else {
            signatureXml = ""
        }
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
            "                       <tipoOrden>\(params.stockTradingType)</tipoOrden>" +
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
            "                   <datosFirma>\(signatureXml)</datosFirma>" +
            "               </entrada>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
