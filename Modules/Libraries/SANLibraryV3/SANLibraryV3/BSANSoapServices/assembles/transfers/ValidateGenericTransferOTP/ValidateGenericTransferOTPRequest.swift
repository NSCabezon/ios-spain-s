import Foundation
public class ValidateGenericTransferOTPRequest: BSANSoapRequest <ValidateGenericTransferOTPRequestParams, ValidateGenericTransferOTPHandler, ValidateGenericTransferOTPResponse, ValidateGenericTransferOTPParser> {
    
    public static let serviceName = "validarNacionalOTPSEPA_LA"
    
    public override var serviceName: String {
        return ValidateGenericTransferOTPRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BAMOBI/Transfcobrossepa_la/F_bamobi_transfcobrossepa_la/internet/"
    }
    
    override var message: String {
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <entrada>" +
            "                   <datosTransf>" +
            "                       <cuentaAbonoPais>\(params.ibandto.countryCode)</cuentaAbonoPais>" +
            "                       <cuentaAbonoDigitoControl>\(params.ibandto.checkDigits)</cuentaAbonoDigitoControl>" +
            "                       <cuentaAbonoCodBBan>\(params.ibandto.codBban30)</cuentaAbonoCodBBan>" +
            XMLHelper.getContractXML(parentKey: "cuentaCargo", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractNumber) +
            "                       <impTransferencia>" +
            "                           <descParteEntera>\(params.transferAmount.wholePart)</descParteEntera>" +
            "                           <descParteDecimal>\(params.transferAmount.getDecimalPart())</descParteDecimal>" +
            "                       </impTransferencia>" +
            "                   </datosTransf>" +
            "                   <datosFirma>\(FieldsUtils.getSignatureXml(signatureDTO: params.signatureDTO))</datosFirma>" +
            "               </entrada>" +
            "               <datosConexion>\(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")</datosConexion>" +
            "               <datosCabecera>" +
            "                   <version>\(params.version)</version>" +
            "                   <terminalID>\(params.terminalId)</terminalID>" +
            "                   <idioma>\(serviceLanguage(originalLanguage: params.language, dialectISO: params.dialectISO))</idioma>" +
            "               </datosCabecera>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
