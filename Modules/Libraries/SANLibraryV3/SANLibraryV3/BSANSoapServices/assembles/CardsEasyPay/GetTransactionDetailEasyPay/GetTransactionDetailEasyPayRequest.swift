import Foundation
public class GetTransactionDetailEasyPayRequest: BSANSoapRequest <GetTransactionDetailEasyPayRequestParams, GetTransactionDetailEasyPayHandler, GetTransactionDetailEasyPayResponse, GetTransactionDetailEasyPayParser> {
    
    public static let serviceName = "consultarDetalleMovtoPagoFacil_LA"
    
    public override var serviceName: String {
        return GetTransactionDetailEasyPayRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Mvtospagofacil_la/F_tarsan_mvtospagofacil_la/internet/"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        let annotationDateString: String
        if let annotationDate = params.annotationDate {
            annotationDateString = DateFormats.toString(date: annotationDate, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            annotationDateString = ""
        }
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "          <entrada>" +
            "               <codOpera>" +
            "                   <OPERACION_BASICA>\(params.basicOperation)</OPERACION_BASICA>" +
            "                   <OPERACION_BANCARIA>\(params.bankOperation)</OPERACION_BANCARIA>" +
            "               </codOpera>" +
            "               <fechaAnota>\(annotationDateString)</fechaAnota>" +
            "               <importeMovto>" +
            "                   <IMPORTE>\(params.amountTransactionValue)</IMPORTE>" +
            "                   <DIVISA>\(params.currencyTransactionValue)</DIVISA>" +
            "               </importeMovto>" +
            "               <datosMovto>" +
            "                   <NUMERO_EXTRACTO_PCAS>" +
XMLHelper.getContractXML(parentKey: "CONTRATO", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractNumber) +
            "                       <NUM_EXTRACTO></NUM_EXTRACTO>" +
            "                       <MONEDA>\(params.currency)</MONEDA>" +
            "                   </NUMERO_EXTRACTO_PCAS>" +
            "                   <NUM_MOVIMIENTO>\(params.transactionDay)</NUM_MOVIMIENTO>" +
            "               </datosMovto>" +
            "               <codigoSaldo>\(params.balanceCode)</codigoSaldo>" +
            "               <estadoMov>\(params.requestStatus)</estadoMov>" +
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
