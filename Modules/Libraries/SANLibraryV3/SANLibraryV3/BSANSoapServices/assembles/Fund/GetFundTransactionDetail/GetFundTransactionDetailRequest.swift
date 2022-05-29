import Foundation

public class GetFundTransactionDetailRequest: BSANSoapRequest <GetFundTransactionDetailRequestParams, GetFundTransactionDetailHandler, GetFundTransactionDetailResponse, GetFundTransactionDetailParser> {
    
    public static let serviceName = "detalleMovimientoFondo_LA"
    
    public override var serviceName: String {
        return GetFundTransactionDetailRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Fondos/F_bamobi_fondos_lip/internet/"
    }
    
    override var message: String {
        let bankCode = params.bankCode
        let branchCode = params.branchCode
        let product = params.product
        let contractNumber = params.contractNumber
        let datosUsuarioWithEmpresa = params.userDataDTO.datosUsuarioWithEmpresa
        let applyDateString: String
        if let applyDate = params.applyDate {
            applyDateString = DateFormats.toString(date: applyDate, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            applyDateString = ""
        }
        let valueDateString: String
        if let valueDate = params.valueDate {
            valueDateString = DateFormats.toString(date: valueDate, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            valueDateString = ""
        }
        let amountString: String
        if let value = params.value {
            amountString = AmountFormats.formattedAmountForWS(amount: value)
        } else {
            amountString = ""
        }
        let settlementValueString: String
        if let value = params.settlementValue {
            settlementValueString = AmountFormats.formattedAmountForWS(amount: value)
        } else {
            settlementValueString = ""
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
            
            "            <datosBasicos>" +
            "               <codOperacionBancaria>\(params.bankOperationCode)</codOperacionBancaria>" +
            "                     <fechaSolicitud>\(applyDateString)</fechaSolicitud>" +
            "                     <fechaValor>\(valueDateString)</fechaValor>" +
            "                     <impOperacion>" +
            "                        <IMPORTE>\(amountString)</IMPORTE>" +
            "                        <DIVISA>\(params.currencyValue)</DIVISA>" +
            "                     </impOperacion>" +
            "                     <numSecOperacion>\(params.transactionNumber)</numSecOperacion>" +
            "                     <impValorLiquidativo>" +
            "                        <VALOR_LIQUIDATIVO>\(settlementValueString)</VALOR_LIQUIDATIVO>" +
            "                        <DIVISA>\(params.currencySettlement)</DIVISA>" +
            "                     </impValorLiquidativo>" +
            "            </datosBasicos>" +
            "           <codigoSubproducto>" +
            "               <TIPO_DE_PRODUCTO>" +
            "                  <EMPRESA></EMPRESA>" +
            "                  <TIPO_DE_PRODUCTO></TIPO_DE_PRODUCTO>" +
            "               </TIPO_DE_PRODUCTO>" +
            "               <SUBTIPO_DE_PRODUCTO>\(params.productSubtypeCode)</SUBTIPO_DE_PRODUCTO>" +
            "            </codigoSubproducto>" +
            
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


