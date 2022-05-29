import Foundation
public class GetLiquidationDetailRequest: BSANSoapRequest <GetLiquidationDetailRequestParams, GetLiquidationDetailHandler, GetLiquidationDetailResponse, GetLiquidationDetailParser> {
    
    public static let serviceName = "detalleLiquidacion_LA"
    
    public override var serviceName: String {
        return GetLiquidationDetailRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Depositos/F_bamobi_depositos_la/internet/"
    }
    
    override var message: String {
        let bankCode = params.bankCode
        let branchCode = params.branchCode
        let product = params.product
        let contractNumber = params.contractNumber
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        let dateString: String
        if let validityClosingDate = params.validityClosingDate {
            dateString = DateFormats.toString(date: validityClosingDate, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            dateString = ""
        }
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <entrada>" +
            "               <fechaFinValidez>\(dateString)</fechaFinValidez>" +
            XMLHelper.getAmountXML(parentKey: "importeLiq", importe: AmountFormats.getValueForWS(value: params.settlementValue), divisa: params.currencySettlement) +
            "               <subcontratoImposicion>" +
            "                   <CONTRATO>" +
            "                       <CENTRO>" +
            "                           <EMPRESA>\(bankCode)</EMPRESA>" +
            "                           <CENTRO>\(branchCode)</CENTRO>" +
            "                       </CENTRO>" +
            "                       <PRODUCTO>\(product)</PRODUCTO>" +
            "                       <NUMERO_DE_CONTRATO>\(contractNumber)</NUMERO_DE_CONTRATO>" +
            "                   </CONTRATO>" +
            "                   <SUBCONTRATO>\(params.subcontractString)</SUBCONTRATO>" +
            "               </subcontratoImposicion>" +
            "           </entrada>" +
            "           <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
            "           <datosCabecera>" +
            "               <version>\(params.version)</version>" +
            "               <terminalID>\(params.terminalId)</terminalID>" +
            "               <idioma>\(serviceLanguage(params.language))</idioma>" +
            "           </datosCabecera>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
