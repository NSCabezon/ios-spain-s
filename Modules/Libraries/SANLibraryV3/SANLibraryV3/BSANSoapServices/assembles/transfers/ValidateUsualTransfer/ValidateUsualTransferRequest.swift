import Foundation
public class ValidateUsualTransferRequest: BSANSoapRequest <ValidateUsualTransferRequestParams, ValidateUsualTransferHandler, ValidateUsualTransferResponse, ValidateUsualTransferParser> {
    
    public static let serviceName = "validarHabitualSEPA_LA"
    
    public override var serviceName: String {
        return ValidateUsualTransferRequest.serviceName
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
            XMLHelper.getContractXML(parentKey: "cuentaCargo", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractNumber) +
            "                       <impTransferencia>" +
            "                           <descParteEntera>\(params.transferAmount?.wholePart ?? "")</descParteEntera>" +
            "                           <descParteDecimal>\(params.transferAmount?.getDecimalPart() ?? "")</descParteDecimal>" +
            "                       </impTransferencia>" +
            "                       <conceptoTransfer>\(params.concept)</conceptoTransfer>" +
            "                   </datosTransf>" +
            "                   <aliasBeneficiario>\(params.beneficiary)</aliasBeneficiario>" +
            "                   <cuentaAbono>" +
            "                       <PAIS>\(params.ibandto?.countryCode ?? "")</PAIS>" +
            "                       <DIGITO_DE_CONTROL>\(params.ibandto?.checkDigits ?? "")</DIGITO_DE_CONTROL>" +
            "                       <CODBBAN>\(params.ibandto?.codBban30 ?? "")</CODBBAN>" +
            "                   </cuentaAbono>" +
            "        <tipTransf></tipTransf>" +
            "        <indUrgente>\(params.transferType.getType())</indUrgente> " +
            "               </entrada>" +
            "               <datosConexion>\(params.userDataDTO?.datosUsuarioWithEmpresa ?? "")</datosConexion>" +
            "               <datosCabecera>" +
            "                   <version>\(params.version)</version>" +
            "                   <terminalID>\(params.terminalId)</terminalID>" +
            "                   <idioma>\(serviceLanguage(params.language))</idioma>" +
            "               </datosCabecera>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
