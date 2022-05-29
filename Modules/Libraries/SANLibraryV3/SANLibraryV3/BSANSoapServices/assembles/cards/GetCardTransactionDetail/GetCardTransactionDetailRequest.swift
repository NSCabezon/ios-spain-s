import Foundation
public class GetCardTransactionDetailRequest: BSANSoapRequest <GetCardTransactionDetailRequestParams, GetCardTransactionDetailHandler, GetCardTransactionDetailResponse, GetCardTransactionDetailParser> {
    
    public static let serviceName = "detalleMovTarjeta_LIP"
    
    public override var serviceName: String {
        return GetCardTransactionDetailRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Tarjetas/F_bamobi_tarjetas_lip/internet/"
    }
    
    override var message: String {
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <entrada>" +
            "               <datosCabecera>" +
            "                   <version>\(params.version)</version>" +
            "                   <terminalID>\(params.terminalId)</terminalID>" +
            "                   <idioma>\(serviceLanguage(params.language))</idioma>" +
            "               </datosCabecera>" +
            "               <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
            "               <contratoTarjeta>" +
            "                   <PRODUCTO>\(params.cardContractProduct)</PRODUCTO>" +
            "                   <NUMERO_DE_CONTRATO>\(params.cardContractNumber)</NUMERO_DE_CONTRATO>" +
            "                   <CENTRO>" +
            "                       <CENTRO>\(params.cardContractBranchCode)</CENTRO>" +
            "                       <EMPRESA>\(params.cardContractBankCode)</EMPRESA>" +
            "                   </CENTRO>" +
            "               </contratoTarjeta>" +
            "               <fechaOpera>\((params.transactionOperationDate))</fechaOpera>" +
            "               <codigoSaldo>\((params.transactionBalanceCode))</codigoSaldo>" +
            "               <fechaAnota>\((params.transactionAnnotationDate))</fechaAnota>" +
            "               <movimDia>\((params.transactionTransactionDay))</movimDia>" +
            "               <codigoMoneda>\((params.transactionCurrency))</codigoMoneda>" +
            "           </entrada>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }

}
