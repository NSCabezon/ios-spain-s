import Foundation
public class GetImpositionTransactionsRequest: BSANSoapRequest <GetImpositionTransactionsRequestParams, GetImpositionTransactionsHandler, GetImpositionTransactionsResponse, GetImpositionTransactionsParser> {
    
    public static let serviceName = "listaMovimientosImposicion_LA"
    public static let serviceNamePagination = "listaMovimientosImposicionRepos_LA"

    public override var serviceName: String {
        if params.pagination == nil {
            return GetImpositionTransactionsRequest.serviceName
        } else {
            return GetImpositionTransactionsRequest.serviceNamePagination
        }
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
        let amountString: String
        if let value = params.value {
            amountString = AmountFormats.formattedAmountForWS(amount: value)
        } else {
            amountString = ""
        }
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <entrada>" +
            "               <datosAux>" +
            "                   <!-- Primera consulta serian 15 ultimos dias-->" +
                                getDateFilterMessage() +
            "                   <subcontratoImposicion>" +
            "                       <CONTRATO>" +
            "                           <CENTRO>" +
            "                               <EMPRESA>\(bankCode)</EMPRESA>" +
            "                               <CENTRO>\(branchCode)</CENTRO>" +
            "                           </CENTRO>" +
            "                           <PRODUCTO>\(product)</PRODUCTO>" +
            "                           <NUMERO_DE_CONTRATO>\(contractNumber)</NUMERO_DE_CONTRATO>" +
            "                       </CONTRATO>" +
            "                       <SUBCONTRATO>\(params.subContractString)</SUBCONTRATO>" +
            "                   </subcontratoImposicion>" +
            "               </datosAux>" +
            "               <importeLiq>" +
            "                   <IMPORTE>\(amountString)</IMPORTE>" +
            "                   <DIVISA>\(params.currency)</DIVISA>" +
            "               </importeLiq>" +
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
