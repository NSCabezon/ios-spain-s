import Foundation

public class ConfirmWithdrawalOTPRequest: BSANSoapRequest <ConfirmWithdrawalOTPRequestParams, ConfirmWithdrawalOTPHandler, ConfirmWithdrawalOTPResponse, ConfirmWithdrawalOTPParser> {
    
    public static let serviceName = "confirmarEmisionSacarDinero_LA"
    
    public override var serviceName: String {
        return ConfirmWithdrawalOTPRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/SADIEL/Sacardineroemi_la/F_sadiel_sacardineroemi_la/internet/"
    }
    
    private var trusteer: String {
        getTrusteerData(params.trusteerInfo, withUrl: "/mobile/SacarDineroCodigo")
    }
    
    override var message: String {
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <entrada>" +
            "                   <token>\(params.otpToken)</token>" +
            "                   <codigoOTP>\(params.otpCode)</codigoOTP>" +
            "                   <ticketOTP>\(params.otpTicket)</ticketOTP>" +
            "                   <numTarjeta>\(params.PAN)</numTarjeta>" +
            XMLHelper.getAmountXML(parentKey: "importeADisp", importe: AmountFormats.getDecimalForWS(value: params.amount.value), divisa: params.amount.currency?.currencyName ?? "") +
            "                   <descConceptoDisp>RETIRADA SIN TARJETA</descConceptoDisp>" +
            XMLHelper.getContractXML(parentKey: "contratoTarjeta", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractNumber) +
            "               </entrada>" +
            "               <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            XMLHelper.getHeaderData(language: serviceLanguage(params.languageISO), dialect: params.dialectISO, linkedCompany: params.linkedCompany) +
            "               \(trusteer)" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
