import Foundation
public class GetLoanTransactionDetailRequest: BSANSoapRequest <GetLoanTransactionDetailRequestParams, GetLoanTransactionDetailHandler, GetLoanTransactionDetailResponse, GetLoanTransactionDetailParser> {
    
    public static let serviceName = "detalleMovimientoPrestamo_LA"
    
    public override var serviceName: String {
        return GetLoanTransactionDetailRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Prestamos/F_bamobi_prestamos_lip/internet/"
    }
    
    override var message: String {
        let bankCode = params.bankCode
        let branchCode = params.branchCode
        let product = params.product
        let contractNumber = params.contractNumber
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        let operationDateString: String
        if let operationDate = params.loanTransactionDTO.operationDate {
            operationDateString = DateFormats.toString(date: operationDate, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            operationDateString = ""
        }
        let valueDateString: String
        if let valueDate = params.loanTransactionDTO.valueDate {
            valueDateString = DateFormats.toString(date: valueDate, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            valueDateString = ""
        }
        let amountString: String
        if let value = params.loanTransactionDTO.amount?.value {
            amountString = AmountFormats.formattedAmountForWS(amount: value)
        } else {
            amountString = ""
        }
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "          <entrada>" +
            "             <contrato>" +
            "                <CENTRO>" +
            "                   <EMPRESA>\(bankCode)</EMPRESA>" +
            "                   <CENTRO>\(branchCode)</CENTRO>" +
            "                </CENTRO>" +
            "                <PRODUCTO>\(product)</PRODUCTO>" +
            "                <NUMERO_DE_CONTRATO>\(contractNumber)</NUMERO_DE_CONTRATO>" +
            "             </contrato>" +
            "             <datosMovimiento>" +
            "               <operacionDGO>" +
            "                   <CENTRO>" +
            "                       <CENTRO>\(params.loanTransactionDTO.dgoNumber?.center ?? "")</CENTRO>" +
            "                       <EMPRESA>\(params.loanTransactionDTO.dgoNumber?.company ?? "")</EMPRESA>" +
            "                    </CENTRO>" +
            "                    <CODIGO_TERMINAL_DGO>\(params.loanTransactionDTO.dgoNumber?.terminalCode ?? "")</CODIGO_TERMINAL_DGO>" +
            "                    <NUMERO_DGO>\(params.loanTransactionDTO.dgoNumber?.number ?? "")</NUMERO_DGO>" +
            "               </operacionDGO>                " +
            "               <impMovimiento>" +
            "                   <IMPORTE>\(amountString)</IMPORTE>" +
            "                   <DIVISA>\(params.loanTransactionDTO.amount?.currency?.currencyName ?? "")</DIVISA>" +
            "               </impMovimiento>" +
            "               <operacionBancaria>" +
            "                   <OPERACION_BASICA>\(params.loanTransactionDTO.bankOperation?.basicOperation ?? "")</OPERACION_BASICA>" +
            "                   <OPERACION_BANCARIA>\(params.loanTransactionDTO.bankOperation?.bankOperation ?? "")</OPERACION_BANCARIA>" +
            "               </operacionBancaria>" +
            "               <numSecMovimiento>\(params.loanTransactionDTO.transactionNumber ?? "")</numSecMovimiento>" +
            "                   <datosAux>" +
            "                       <fechaOperacion>\(operationDateString)</fechaOperacion>" +
            "                       <fechaValor>\(valueDateString)</fechaValor>" +
            "                   </datosAux>" +
            "             </datosMovimiento>" +
            "          </entrada>" +
            "          <datosConexion>\(datosUsuarioWithEmpresa)</datosConexion>" +
            "          <datosCabecera>" +
            "             <version>\(params.version)</version>" +
            "             <terminalID>\(params.terminalId)</terminalID>" +
            "             <idioma>\(serviceLanguage(params.language))</idioma>" +
            "          </datosCabecera>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
