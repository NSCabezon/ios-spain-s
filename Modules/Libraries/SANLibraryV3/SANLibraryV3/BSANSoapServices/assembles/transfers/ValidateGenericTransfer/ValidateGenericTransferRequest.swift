import Foundation
public class ValidateGenericTransferRequest: BSANSoapRequest <ValidateGenericTransferRequestParams, ValidateGenericTransferHandler, ValidateGenericTransferResponse, ValidateGenericTransferParser> {
    
    public static let serviceName = "validarNacionalSEPA_LA"
    
    public override var serviceName: String {
        return ValidateGenericTransferRequest.serviceName
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
            "                       <nombreBeneficiario>\(params.beneficiary.uppercased())</nombreBeneficiario>" +
            "                       <indResidenciaBeneficiario>\(params.isSpanishResidentBeneficiary ? "S" : "N")</indResidenciaBeneficiario>" +
            "                       <alias>\(params.saveAsUsualAlias?.uppercased() ?? "")</alias>" +
            "                       <indGuardarComoHabitual>\(params.saveAsUsual ? "S" : "N")</indGuardarComoHabitual>" +
            "                       <mailBenef>\(params.beneficiaryMail)</mailBenef>" +
            "                       <datosBasicos>" +
            "                           <cuentaAbonoPais>\(params.ibandto.countryCode)</cuentaAbonoPais>" +
            "                           <cuentaAbonoDigitoControl>\(params.ibandto.checkDigits)</cuentaAbonoDigitoControl>" +
            "                           <cuentaAbonoCodBBan>\(params.ibandto.codBban30)</cuentaAbonoCodBBan>" +
            "                           <impTransferencia>" +
            "                               <descParteEntera>\(params.transferAmount.wholePart)</descParteEntera>" +
            "                               <descParteDecimal>\(params.transferAmount.getDecimalPart())</descParteDecimal>" +
            "                           </impTransferencia>" +
            XMLHelper.getContractXML(parentKey: "cuentaCargo", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractNumber) +
            "                       </datosBasicos>" +
            "                       <tipTransf></tipTransf>" +
            "                       <indUrgente>\(params.transferType.getType())</indUrgente>" +
            "                   </datosTransf>" +
            "                   <conceptoTransfer>\(params.concept)</conceptoTransfer>" +
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


public class ValidateSanKeyTransferRequest: BSANSoapRequest<ValidateSanKeyTransferRequestParams, ValidateGenericTransferHandler, ValidateGenericTransferResponse, ValidateGenericTransferParser> {
    
    public static let serviceName = "sanKeyValidarNacionalSEPA_LA"

    public override var serviceName: String {
        return ValidateSanKeyTransferRequest.serviceName
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
            "                       <nombreBeneficiario>\(params.beneficiary.uppercased())</nombreBeneficiario>" +
            "                       <indResidenciaBeneficiario>\(params.isSpanishResidentBeneficiary ? "S" : "N")</indResidenciaBeneficiario>" +
            "                       <alias>\(params.saveAsUsualAlias?.uppercased() ?? "")</alias>" +
            "                       <indGuardarComoHabitual>\(params.saveAsUsual ? "S" : "N")</indGuardarComoHabitual>" +
            "                       <mailBenef>\(params.beneficiaryMail)</mailBenef>" +
            "                       <datosBasicos>" +
            "                           <cuentaAbonoPais>\(params.ibandto.countryCode)</cuentaAbonoPais>" +
            "                           <cuentaAbonoDigitoControl>\(params.ibandto.checkDigits)</cuentaAbonoDigitoControl>" +
            "                           <cuentaAbonoCodBBan>\(params.ibandto.codBban30)</cuentaAbonoCodBBan>" +
            "                           <impTransferencia>" +
            "                               <descParteEntera>\(params.transferAmount.wholePart)</descParteEntera>" +
            "                               <descParteDecimal>\(params.transferAmount.getDecimalPart())</descParteDecimal>" +
            "                           </impTransferencia>" +
            XMLHelper.getContractXML(parentKey: "cuentaCargo", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractNumber) +
            "                       </datosBasicos>" +
            "                       <tipTransf></tipTransf>" +
            "                       <indUrgente>\(params.transferType.getType())</indUrgente>" +
            "                   </datosTransf>" +
            "                   <conceptoTransfer>\(params.concept)</conceptoTransfer>" +
        "                   <tokenPush>\(params.tokenPush ?? "")</tokenPush>" +
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
