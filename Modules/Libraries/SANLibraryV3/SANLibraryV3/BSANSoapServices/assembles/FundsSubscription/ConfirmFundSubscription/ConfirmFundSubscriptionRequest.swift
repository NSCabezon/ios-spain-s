import Foundation

public class ConfirmFundSubscriptionRequest: BSANSoapRequest <ConfirmFundSubscriptionRequestParams, ConfirmFundSubscriptionHandler, ConfirmFundSubscriptionResponse, ConfirmFundSubscriptionParser> {
    
    public static let serviceName = "confirmarSuscripcion_LA"
    
    public override var serviceName: String {
        return ConfirmFundSubscriptionRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/FONDO1/Suscripfondos_la/F_fondo1_suscripfondos_la/internet/"
    }
    
    override var message: String {
        let bankCode = params.bankCode
        let branchCode = params.branchCode
        let product = params.product
        let contractNumber = params.contractNumber
        let dateString: String
        if let settlementValueDate = params.settlementValueDate {
            dateString = DateFormats.toString(date: settlementValueDate, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            dateString = ""
        }
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "    <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "    <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <entrada>" +
            "               <contratoFondo>" +
            "                   <CENTRO>" +
            "                       <EMPRESA>\(bankCode)</EMPRESA>" +
            "                       <CENTRO>\(branchCode)</CENTRO>" +
            "                   </CENTRO>" +
            "                   <PRODUCTO>\(product)</PRODUCTO>" +
            "                   <NUMERO_DE_CONTRATO>\(contractNumber)</NUMERO_DE_CONTRATO>" +
            "               </contratoFondo>" +
            "               <tokenPasos>\(params.tokenPasos)</tokenPasos>" +
            "               <datosFirma>\(FieldsUtils.getSignatureXml(signatureDTO: params.signatureDTO))</datosFirma>" +
            "               <datosSalidaVal>" +
            "                   <fechaValLiq>\(dateString)</fechaValLiq>" +
            "                   <ctaDomiciliacionPres>" +
            "                       <CENTRO>" +
            "                           <EMPRESA>\(params.directDebtBankCode)</EMPRESA>" +
            "                           <CENTRO>\(params.directDebtBranchCode)</CENTRO>" +
            "                       </CENTRO>" +
            "                       <PRODUCTO>\(params.directDebtProduct)</PRODUCTO>" +
            "                       <NUMERO_DE_CONTRATO>\(params.directDebtContractNumber)</NUMERO_DE_CONTRATO>" +
            "                   </ctaDomiciliacionPres>" +
            "                   <codIdioma>\(params.languageCode)</codIdioma>" +
            "                   <codMonedaCuenta>\(params.accountCurrencyCode)</codMonedaCuenta>" +
            "                   <importeValLiq>" +
            "                       <VALOR_LIQUIDATIVO>\(params.settlementValueAmount)</VALOR_LIQUIDATIVO>" +
            "                       <DIVISA>\(params.settlementCurrencyAmount)</DIVISA>" +
            "                   </importeValLiq>" +
            "               </datosSalidaVal>" +
            "               <participacionOImporte>\((params.typeSuscription == FundOperationsType.typeAmount) ? "I" : "P")</participacionOImporte>" +
            "               <importeSuscripcion>" +
            "                   <IMPORTE>\(params.amountForWS)</IMPORTE>" +
            "                   <DIVISA>\(params.currency)</DIVISA>" +
            "               </importeSuscripcion>" +
            "               <numParticipaciones>\(params.sharesNumber)</numParticipaciones>" +
            "          </entrada>" +
            "          <datosConexion>\(params.userDataDTO.clientAndChannelXml)</datosConexion>" +
            "          <datosCabecera>" +
            "               <idioma>" +
            "                   <IDIOMA_ISO>\(serviceLanguage(params.language))</IDIOMA_ISO>" +
            "                   <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>" +
            "               </idioma>" +
            "               <empresaAsociada>\(BSANHeaderData.DEFAULT_LINKED_COMPANY_SAN_ES_0049)</empresaAsociada>" +
            "          </datosCabecera>" +
            "       </v1:\(serviceName)>" +
            "    </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
