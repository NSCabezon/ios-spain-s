import Foundation

public class ValidateWithdrawalOTPRequest: BSANSoapRequest <ValidateWithdrawalOTPRequestParams, ValidateWithdrawalOTPHandler, ValidateWithdrawalOTPResponse, ValidateWithdrawalOTPParser> {
    
    public static let serviceName = "validarEmisionSacarDineroOTP_LA"
    
    public override var serviceName: String {
        return ValidateWithdrawalOTPRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/SADIEL/Sacardineroemi_la/F_sadiel_sacardineroemi_la/internet/"
    }
    
    override var message: String {
        let signature: String
        if let cardSignature = params.cardSignature {
            signature = getSignatureXml(signatureDTO: cardSignature)
        } else {
            signature = ""
        }
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <entrada>" +
            "                   <token>\(params.cardToken)</token>" +
            "                   <valoresFirma>\(signature)</valoresFirma>" +
            XMLHelper.getContractXML(parentKey: "contratoTarjeta", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractNumber) +
            "                   <numTarjeta>\(params.PAN)</numTarjeta>" +
            "               </entrada>" +
            "               <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>" +
            XMLHelper.getHeaderData(language: serviceLanguage(params.languageISO), dialect: params.dialectISO, linkedCompany: params.linkedCompany) +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
