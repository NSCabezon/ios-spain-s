import Foundation
public class ValidateAccountTransferRequest: BSANSoapRequest <ValidateAccountTransferRequestParams, ValidateAccountTransferHandler, ValidateAccountTransferResponse, ValidateAccountTransferParser> {
    
    public static let serviceName = "validarTraspasoSEPA_LA"
    
    public override var serviceName: String {
        return ValidateAccountTransferRequest.serviceName
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
            XMLHelper.getContractXML(parentKey: "cuentaCargo", company: params.originBankCode, branch: params.originBranchCode, product: params.originProduct, contractNumber: params.originContractNumber) +
            "                       <impTransferencia>" +
            "                           <descParteEntera>\(params.transferAmount.wholePart)</descParteEntera>" +
            "                           <descParteDecimal>\(params.transferAmount.getDecimalPart())</descParteDecimal>" +
            "                       </impTransferencia>" +
            "                       <conceptoTransfer>\(params.concept)</conceptoTransfer>" +
            "                   </datosTransf>" +
            XMLHelper.getContractXML(parentKey: "cuentaAbono", company: params.destinationBankCode, branch: params.destinationBranchCode, product: params.destinationProduct, contractNumber: params.destinationContractNumber) +
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
