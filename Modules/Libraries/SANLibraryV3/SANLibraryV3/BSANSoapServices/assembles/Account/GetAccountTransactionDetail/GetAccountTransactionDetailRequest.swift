import Foundation

public class GetAccountTransactionDetailRequest: BSANSoapRequest <GetAccountTransactionDetailRequestParams, GetAccountTransactionDetailHandler, GetAccountTransactionDetailResponse, GetAccountTransactionDetailParser> {
    
    public static let serviceName = "detalleMovCuenta_LIP"
    
    public override var serviceName: String {
        return GetAccountTransactionDetailRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Cuentas/F_bamobi_cuentas_lip/internet/"
    }
    
    override var message: String {
        let empresa = params.bankCode
        let centro = params.branchCode
        let producto = params.product
        let numeroContrato = params.contractNumber
        let operationDateString: String
        if let operationDate = params.operationDate {
            operationDateString = DateFormats.toString(date: operationDate, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            operationDateString = ""
        }
        let annotationDateString: String
        if let annotationDate = params.annotationDate {
            annotationDateString = DateFormats.toString(date: annotationDate, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            annotationDateString = ""
        }
        let amountString: String
        if let value = params.value {
            amountString = AmountFormats.formattedAmountForWS(amount: value)
        } else {
            amountString = ""
        }
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
            "               <codigoProducto>\(params.productSubtype)</codigoProducto>" +
            "               <importe>" +
            "                   <IMPORTE>\(amountString)</IMPORTE>" +
            "                   <DIVISA>\(params.currency)</DIVISA>" +
            "               </importe>" +
            "               <tipoMovimiento>\(params.transactionType)</tipoMovimiento>" +
            "               <diaMovimiento>\(params.transactionDay)</diaMovimiento>" +
            "               <fechaOperacion>\(operationDateString)</fechaOperacion>" +
            "               <fechaAnotacion>\(annotationDateString)</fechaAnotacion>" +
            "               <numeroDGO>" +
            "                   <CODIGO_TERMINAL_DGO>\(params.dgoTerminalCode)</CODIGO_TERMINAL_DGO>" +
            "                   <NUMERO_DGO>\(params.dgoNumber)</NUMERO_DGO>" +
            "                   <CENTRO>" +
            "                       <CENTRO>\(params.dgoCenter)</CENTRO>" +
            "                       <EMPRESA>\(params.dgoCompany)</EMPRESA>" +
            "                   </CENTRO>" +
            "               </numeroDGO>                " +
            "               <numeroMovimiento>\(params.transactionNumber)</numeroMovimiento>" +
            "           </entrada>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
